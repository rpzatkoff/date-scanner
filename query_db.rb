#!/usr/bin/ruby

require 'sqlite3'
require 'diffy'

db = SQLite3::Database.new 'db/website_history.db'
db.results_as_hash = true

instrument_id = 7

query = 'SELECT DISTINCT html FROM html 
         WHERE instrument_id = 7
         ORDER BY timestamp DESC LIMIT 2'

rs = db.execute(query)

s = rs[0]['html']
s1 = rs[1]['html']

Diffy::Diff.default_format = :color
d = Diffy::Diff.new(s, s1)


i = 0
d.each do |diff|
    puts diff
    i = i + 1
    break if i > 5
end
