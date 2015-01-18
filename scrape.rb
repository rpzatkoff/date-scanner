#!/usr/bin/ruby

require 'mechanize'
require 'sanitize'
require 'sqlite3'
require 'parallel'
require 'daemons'
require 'diffy'


db = SQLite3::Database.new "db/website_history.db"
db.results_as_hash = true


def save_site(db, stock, url, html)
    timestamp = Time.now.to_i
    query = "INSERT INTO html_history VALUES ( ?, ?, ?, ? )"
    
    db.execute(query, stock, url, timestamp, html)

    puts "inserting new website for #{stock}"
end

def save_html_diff(stock, prev, new)
    File.open("html/#{stock}.html", 'w') { |f|
        diff_html = Diffy::Diff.new(prev, new, 
            :include_plus_and_minus_in_html => true).to_s(:html)
        css = Diffy::CSS

        full_html = "<html><head><style> #{css}</style></head>
            <body>
            #{diff_html}
            </body>
            </html>
           "
        f.write(full_html)
    }
end

urls = { 'GE' => 'http://www.ge.com/investor-relations/events', 
         'HPQ' => 'http://h30261.www3.hp.com/phoenix.zhtml?c=71087&p=irol-newslanding', 
         'ZNGA' => 'http://investor.zynga.com/events.cfm',
         'INTC' => 'http://www.intc.com/events.cfm',
         'EXPE' => 'http://ir.expediainc.com/events.cfm',
         'ABBV' => 'http://www.abbvieinvestor.com/phoenix.zhtml?c=251551&p=irol-calendar',
         'MMM' => 'http://phx.corporate-ir.net/phoenix.zhtml?c=80574&p=irol-IRHome',
         'ADBE' => 'http://www.adobe.com/investor-relations/calendar.html',
         'AAPL' => 'http://investor.apple.com/',
         'BHI' => 'http://phx.corporate-ir.net/phoenix.zhtml?c=79687&p=irol-irhome',
         'CMG' => 'http://ir.chipotle.com/phoenix.zhtml?c=194775&p=irol-news',
}

prev_html_hash = Hash[Parallel.map(urls, :in_threads=>5) { |symbol, url|
    query = "SELECT html
             FROM html_history
             WHERE url = '#{url}'
             ORDER BY timestamp DESC LIMIT 1"
    rs = db.execute(query)

    if rs.length > 0
        [ symbol, rs[0]['html'] ]
    else
        [ symbol, "" ]
    end
}]


html_hash = Hash[Parallel.map(urls, :in_processes=>5) { |stock, url| 
    mech = Mechanize.new
    html = mech.get(url).body
    html = Sanitize.clean(html, :remove_contents => ['script', 'style'])

    [stock, html]
}]

changed_hash = html_hash.select {|stock, html| 
    prev_html_hash[stock] != html
}

FileUtils::rm_rf 'html'
FileUtils::mkdir_p 'html'

changed_hash.each { |stock, html|
    prev_html = prev_html_hash[stock]

    save_html_diff(stock, prev_html, html)

    # display to console
    puts Diffy::Diff.new(prev_html, html).to_s(:color)
}

changed_hash.each { |stock, html| 
    url = urls[stock]
    save_site(db, stock, url, html)
}

