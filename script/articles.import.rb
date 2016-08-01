require 'mysql2'
require 'feedjira'

feed = Feedjira::Feed.fetch_and_parse 'http://www.nikkeibp.co.jp/rss/index.rdf'

ENV['TZ'] = 'UTC'
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
  %w[regulus regulus_development regulus_production].each do |db|
    begin
      client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => "7QiSlC?4", :database => db)
      client.query(query)
      client.close
      puts [
        "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}]",
        '[import]',
        "{database: #{db}, url: #{entry.url}}",
      ].join(' ')
    rescue
      next
    end
  end
end
