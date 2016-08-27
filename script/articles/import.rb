require 'feedjira'
require 'mysql2'
require_relative '../config/settings'
require_relative '../lib/logger'
require_relative '../lib/mysql_client'

IMPORT = Settings.article['import']
ENV['TZ'] = 'UTC'

now = Time.now.strftime('%Y-%m-%d %H:%M:%S')
feed = Feedjira::Feed.fetch_and_parse IMPORT['url']
feed.entries.each do |entry|
  param = {
    :published => entry.published.strftime('%Y-%m-%d %H:%M:%S'),
    :title => entry.title,
    :summary => entry.summary,
    :url => entry.url,
    :created_at => now,
  }

  IMPORT['databases'].each do |db|
    begin
      execute_sql(db, File.join(Settings.application_root, 'articles/import.sql'), param)
      Logger.write('articles', File.basename(__FILE__, '.rb'), {:database => db, :url => entry.url})
    rescue => e
      puts e.message
    end
  end
end
