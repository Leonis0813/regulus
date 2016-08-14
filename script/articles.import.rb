require 'feedjira'
require 'mysql2'
require_relative 'config/settings'

IMPORT = Settings.article['import']
ENV['TZ'] = 'UTC'

feed = Feedjira::Feed.fetch_and_parse IMPORT['url']
now = Time.now.strftime('%Y-%m-%d %H:%M:%S')
feed.entries.each do |entry|
  query = <<"EOF"
INSERT INTO
  articles
VALUES (
  DATE_FORMAT('#{entry.published}', '%Y-%m-%d %H:%i:%S'), "#{entry.title}", "#{entry.summary}", '#{entry.url}', '#{now}'
)
ON DUPLICATE KEY UPDATE
  summary = VALUES(summary),
  url = VALUES(url)
EOF
  IMPORT['databases'].each do |db|
    begin
      client = Mysql2::Client.new(Settings.mysql.merge('database' => db))
      client.query(query)
      puts [
        "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}]",
        '[import]',
        "{database: #{db}, url: #{entry.url}}",
      ].join(' ')
    rescue
      next
    ensure
      client.close
    end
  end
end
