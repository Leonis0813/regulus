require 'mysql2'
require 'twitter'
require_relative 'config/settings'

IMPORT = Settings.tweet['import']
ENV['TZ'] = 'UTC'
CLIENT = Twitter::REST::Client.new do |config|
  config.consumer_key = IMPORT['consumer_key']
  config.consumer_secret = IMPORT['consumer_secret']
  config.access_token = IMPORT['access_token']
  config.access_token_secret = IMPORT['access_token_secret']
end

def get_tweets
  now = Time.now.strftime('%Y-%m-%d %H:%M:%S')

  query = IMPORT['query']
  tweets = CLIENT.search(query['word'], :count => query['count'], :result_type => query['result_type'])
  tweets.take(query['max_count']).each do |tweet|
    query = <<"EOF"
INSERT INTO
  tweets
VALUES (
  '#{tweet.id}', "#{tweet.user.name}", '#{tweet.user.profile_image_url}', "#{tweet.full_text.gsub('\'', '&apos;')}", '#{tweet.created_at}', '#{now}'
)
ON DUPLICATE KEY UPDATE
  user_name = VALUES(user_name),
  profile_image_url = VALUES(profile_image_url),
  full_text = VALUES(full_text)
EOF
    IMPORT['databases'].each do |db|
      begin
        client = Mysql2::Client.new(Settings.mysql.merge('database' => db))
        client.query(query)
        client.close
        puts [
          "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}]",
          '[import]',
          "{database: #{db}, tweet_id: #{tweet.id}}",
        ].join(' ')
      rescue => e
        puts e
        next
      end
    end
  end
end

get_tweets
sleep 30
get_tweets
