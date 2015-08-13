require 'twitter'

client = Twitter::REST::Client.new do |config|
  config.consumer_key = 'qb5wB14dXWbl5nTz7n7uWUiaE'
  config.consumer_secret = 'zU9FOSNDlQccN0gkkmD9iiHpjYBVuIsLQ9xDFGWSokFP2o4hSc'
  config.access_token = '3313362716-oecmOzhHQnwI7IrIb2WRRtq6LLRiVlrJpSV71oN'
  config.access_token_secret = 't1n8iXnbfCiZKiwJu0RUtHjoiCGw1fFL50pqNyPlZ2Cfw'
end

now = Time.now.strftime('%Y-%m-%d %H:%M:%S')
client.search('overload_anime', :count => 100, :result_type => 'recent').each do |tweet|
=begin
  query = <<"EOF"
INSERT INTO
  tweets
VALUES (
  '#{tweet.id}', '#{tweet.user.name}', 
)
EOF
=end
  p tweet.id
  p "@" + tweet.user.name
  p tweet.full_text
  p tweet.created_at
  
  print("\n")
end
