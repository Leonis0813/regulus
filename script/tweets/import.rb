require 'twitter'
require_relative '../config/settings'
require_relative '../lib/logger'
require_relative '../lib/mysql_client'

IMPORT = Settings.tweet['import']
ENV['TZ'] = 'UTC'
CLIENT = Twitter::REST::Client.new do |config|
  %w[ consumer_key consumer_secret access_token access_token_secret ].each do |key_name|
    config.send("#{key.name}=", IMPORT[key_name])
  end
end

def get_tweets
  now = Time.now.strftime('%Y-%m-%d %H:%M:%S')

  query = IMPORT['query']
  tweets = CLIENT.search(query['word'], :count => query['count'], :result_type => query['result_type'])
  tweets.take(query['max_count']).each do |tweet|
    param = {
      :id => tweet.id,
      :user_name => tweet.user.name,
      :profile_image_url => tweet.user.profile_image_url,
      :full_text => tweet.full_text.gsub("'", '&apos;'),
      :tweeted_at => tweet.created_at,
      :created_at => now,
    }
    IMPORT['databases'].each do |db|
      begin
        execute_sql(db, File.join(Settings.application_root, 'tweets/import.sql'), param)
        Logger.write('tweets', File.basename(__FILE__, '.rb'), {:database => db, :tweet_id => tweet.id})
      rescue => e
        puts e
      end
    end
  end
end

get_tweets
sleep 30
get_tweets
