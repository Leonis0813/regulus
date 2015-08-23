require 'feedjira'

feed = Feedjira::Feed.fetch_and_parse 'http://www.nikkeibp.co.jp/rss/business.rdf'

ENV['TZ'] = 'UTC'
now = Time.now.strftime('%Y-%m-%d %H:%M:%S')
feed.entries.each do |entry|
  query = <<"EOF"
INSERT INTO
  articles
VALUES (
  DATE_FORMAT('#{entry.published}', '%Y-%m-%d %H:%i:%S'), '#{entry.title}', '#{entry.summary}', '#{entry.url}', '#{now}'
)
ON DUPLICATE KEY UPDATE
  summary = VALUES(summary),
  url = VALUES(url)
EOF
  `mysql --user=root --password=7QiSlC?4 regulus -e "#{query}"`
end
