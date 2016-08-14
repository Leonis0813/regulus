require 'json'
require 'mysql2'
require 'net/http'
require_relative 'config/settings'

IMPORT = Settings.rate['import']
ENV['TZ'] = 'UTC'

def log(body)
  puts [
    "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}]",
    '[import]',
    body,
  ].join(' ')
end

def get_rates
  now = Time.now.strftime('%Y-%m-%d %H:%M:%S')

  IMPORT['pairs'].each do |pair_code|
    parsed_url = URI.parse("#{IMPORT['url']}/?code=#{pair_code}=FX")
    req = Net::HTTP::Get.new(parsed_url)
    res = Net::HTTP.start(parsed_url.host, parsed_url.port) {|http| http.request req }

    rates = res.body.scan(/(.*#{pair_code}_detail_[bid|ask].*)/).flatten
    bid = rates.find {|rate| rate.include?('bid') }.gsub(/<.*?>/, '')
    ask = rates.find {|rate| rate.include?('ask') }.gsub(/<.*?>/, '')

    unless res.code == '200'
      log "{status: #{res.code}, message: #{res.message}, uri: #{res.uri.to_s}, error_type: #{res.error_type}}"
      next
    end

    if bid.to_f == 0.0 or ask.to_f == 0.0
      log "{status: #{res.code}, uri: #{res.uri.to_s}, pair: #{pair_code}, bid: #{bid}, ask: #{ask}}"
      redo
    end

    query = <<"EOF"
INSERT INTO
  rates
VALUES (
  '#{now}', '#{pair_code}', #{bid.to_f}, #{ask.to_f}
)
EOF
    client = Mysql2::Client.new(Settings.mysql)
    client.query(query)
    client.close
    log "{status: #{res.code}, uri: #{res.uri.to_s}, pair: #{pair_code}, bid: #{bid}, ask: #{ask}}"
  end
end

get_rates
sleep 30
get_rates
