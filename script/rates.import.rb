require 'net/http'
require 'json'
require 'mysql2'

PAIR_CODE = %w[USDJPY EURJPY AUDJPY GBPJPY NZDJPY CADJPY CHFJPY ZARJPY CNHJPY EURUSD GBPUSD AUDUSD]
RAW_URL = 'http://info.finance.yahoo.co.jp/fx/detail/'
ENV['TZ'] = 'UTC'

def get_rates
  now = Time.now.strftime('%Y-%m-%d %H:%M:%S')

  PAIR_CODE.each do |pair_code|
    parsed_url = URI.parse("#{RAW_URL}/?code=#{pair_code}=FX")
    req = Net::HTTP::Get.new(parsed_url)
    res = Net::HTTP.start(parsed_url.host, parsed_url.port) {|http| http.request req }

    rates = res.body.scan(/(.*#{pair_code}_detail_[bid|ask].*)/).flatten
    bid = rates.find {|rate| rate.include?('bid') }.gsub(/<.*?>/, '')
    ask = rates.find {|rate| rate.include?('ask') }.gsub(/<.*?>/, '')

    unless res.code == '200'
      puts [
        "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}]",
        '[import]',
        "{status: #{res.code}, message: #{res.message}, uri: #{res.uri.to_s}, error_type: #{res.error_type}}"
      ].join(' ')
      next
    end

    if bid.to_f == 0.0 or ask.to_f == 0.0
      puts [
        "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}]",
        '[import]',
        "{status: #{res.code}, uri: #{res.uri.to_s}, pair: #{pair_code}, bid: #{bid}, ask: #{ask}}",
      ].join(' ')
      redo
    end

    query = <<"EOF"
INSERT INTO
  rates
VALUES (
  '#{now}', '#{pair_code}', #{bid.to_f}, #{ask.to_f}
)
EOF
    client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => "7QiSlC?4", :database => 'regulus')
    client.query(query)
    client.close
    puts [
      "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}]",
      '[import]',
      "{status: #{res.code}, uri: #{res.uri.to_s}, pair: #{pair_code}, bid: #{bid}, ask: #{ask}}",
    ].join(' ')
  end
end

get_rates
sleep 30
get_rates
