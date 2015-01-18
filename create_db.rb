#!/usr/bin/ruby

require 'sqlite3'
require 'fileutils'

FileUtils::rm_r 'db'
FileUtils::mkdir_p 'db'

db = SQLite3::Database.new "db/website_history.db"

# html storage
rows = db.execute <<-SQL
  create table html_history (
    symbol STRING,
    url TEXT,
    timestamp INT,
    html TEXT
  );
SQL



