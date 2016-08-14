require 'feedjira'
require 'mysql2'
require_relative '../config/settings'
require_relative '../lib/mysql_client'

IMPORT = Settings.article['import']
ENV['TZ'] = 'UTC'

now = Time.now.strftime('%Y-%m-%d %H:%M:%S')
feed = Feedjira::Feed.fetch_and_parse IMPORT['url']
feed.entries.each do |entry|
  param = %i[ published title summary url ].map {|key| [key, entry.send(key)] }.to_h
  param.merge!(:created_at => now))

  IMPORT['databases'].each do |db|
    begin
      execute_sql(db, File.join(Settings.application_root, 'articles/import.sql'), param)
      puts [
        "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}]",
        '[import]',
        "{database: #{db}, url: #{entry.url}}",
      ].join(' ')
    rescue => e
      puts e.message
    end
  end
end
