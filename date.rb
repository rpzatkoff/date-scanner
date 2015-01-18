require 'future'
require 'nokogiri'
require 'open-uri'
require 'chronic'
require 'date'
require 'set'

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
         
        }
    
def get_dates(url)
    html = Nokogiri::HTML(open(url))
    month = /([Jj]an[\s])|([Ff]eb[\s])|([Mm]ar[\s])|([Aa]pr[\s])|([Mm]ay[\s])|([Jj]un[\s])|([Jj]ul[\s])|([Aa]ug[\s])|([Ss]ep[\s])|([Oo]ct[\s])|([Nn]ov[\s])|([Dd]ec[\s])|([Jj]anuary[\s])|([Ff]ebruary[\s])|([Mm]arch[\s])|([Aa]pril[\s])|([Mm]ay[\s])|([Jj]une[\s])|([Jj]uly[\s])|([Aa]ugust[\s])|([Ss]eptember[\s])|([Oo]ctober[\s])|([Nn]ovember[\s])|([Dd]ecember[\s])/
    numerical_date = /(\d{1,2}[\/\- ]+\d{1,2}[\/\- ]+\d{2,4})|(\d{2,4}[\/\- ]+\d{1,2}[\/\- ]+\d{1,2})|([ ]+\d{1,2}.*201[5-9])|([ ]+\d{1,2}.*20[2-9][0-9])/
    number = /\d/ 
    dates = Hash.new
    html.traverse do |node| 
        if node.respond_to?(:content)
            content=node.content.strip
            has_month=content.match(month)
            has_numerical_date=content.match(numerical_date)
            has_number=content.match(number)
            if has_numerical_date != nil or (has_month and has_number)
                date = Chronic.parse(content)
                if date != nil
                    date = date.to_date
                    if date > Date.today
                        if dates.has_key?(date)
                            dates[date].push(content)
                        else
                            dates[date]=[content]
                        end
                    end
                end
            end
        end
    end
    return dates
end


urls.each do |stock, url| 
    dates = get_dates(url)
    dates.each do |date, strings|
        puts stock, date
        strings.each do |string|
            puts string
        end
    end
end


#puts text


#re = /<("[^"]*"|'[^']*'|[^'">])*>/
#text = html.to_html.gsub(re,",").gsub(/\n/,'').squeeze(",")

=begin
text = text.gsub(/[\s]/,',').gsub(/,+/,',').gsub(/,\D+,/,',')

#puts text

text = text.split(/,/)


text.each do |line|
    date = Chronic.parse(line.strip)
    if date != nil # and date.to_date > Date.today
        dates.add(date)
    end
end
=end

