require 'feedjira'
require 'mysql2'
require_relative 'config/settings'
require_relative 'lib/mysql_client'

IMPORT = Settings.article['import']
ENV['TZ'] = 'UTC'

now = Time.now.strftime('%Y-%m-%d %H:%M:%S')
feed = Feedjira::Feed.fetch_and_parse IMPORT['url']
feed.entries.each do |entry|
  params = %i[ published title summary url ].map {|key| [key, entry.send(key)] }.to_h

  IMPORT['databases'].each do |db|
    begin
      execute_sql(db, __FILE__.sub('.rb', '.sql'),   params.merge(:created_at => now))
      puts [
        "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}]",
        '[import]',
        "{database: #{db}, url: #{entry.url}}",
      ].join(' ')
    rescue
    end
  end
end
