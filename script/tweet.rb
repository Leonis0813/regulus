# -*- coding: utf-8 -*-
require 'twitter'

client = Twitter::REST::Client.new do |config|
  config.consumer_key = 'qb5wB14dXWbl5nTz7n7uWUiaE'
  config.consumer_secret = 'zU9FOSNDlQccN0gkkmD9iiHpjYBVuIsLQ9xDFGWSokFP2o4hSc'
  config.access_token = '3313362716-oecmOzhHQnwI7IrIb2WRRtq6LLRiVlrJpSV71oN'
  config.access_token_secret = 't1n8iXnbfCiZKiwJu0RUtHjoiCGw1fFL50pqNyPlZ2Cfw'
end

ENV['TZ'] = 'UTC'
now = Time.now.strftime('%Y-%m-%d %H:%M:%S')

tweets = client.search('為替', :count => 20, :result_type => 'recent')
tweets.take(100).each do |tweet|
  query = <<"EOF"
INSERT INTO
  tweets
VALUES (
  '#{tweet.id}', '#{tweet.user.name}', '#{tweet.user.profile_image_url}', '#{tweet.full_text.gsub('\'', '&apos;')}', '#{tweet.created_at}', '#{now}'
)
ON DUPLICATE KEY UPDATE
  user_name = VALUES(user_name),
  profile_image_url = VALUES(profile_image_url),
  full_text = VALUES(full_text)
EOF
  `mysql --user=root --password=7QiSlC?4 regulus -e "#{query}"`
end
