require 'json'
require 'net/http'
require_relative 'config/settings'
require_relative 'lib/mysql_client'

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

  IMPORT['pairs'].each do |pair|
    parsed_url = URI.parse("#{IMPORT['url']}/?code=#{pair}=FX")
    req = Net::HTTP::Get.new(parsed_url)
    res = Net::HTTP.start(parsed_url.host, parsed_url.port) {|http| http.request req }

    rates = res.body.scan(/(.*#{pair}_detail_[bid|ask].*)/).flatten
    bid = rates.find {|rate| rate.include?('bid') }.gsub(/<.*?>/, '').to_f
    ask = rates.find {|rate| rate.include?('ask') }.gsub(/<.*?>/, '').to_f

    unless res.code == '200'
      log "{status: #{res.code}, message: #{res.message}, uri: #{res.uri.to_s}, error_type: #{res.error_type}}"
      next
    end

    if bid == 0.0 or ask == 0.0
      log "{status: #{res.code}, uri: #{res.uri.to_s}, pair: #{pair}, bid: #{bid}, ask: #{ask}}"
      redo
    end

    param = {:time => now, :pair => pair, :bid => bid, :ask => ask}
    execute_sql('regulus', __FILE__.sub('.rb', '.sql'), param)
    log "{status: #{res.code}, uri: #{res.uri.to_s}, pair: #{pair}, bid: #{bid}, ask: #{ask}}"
  end
end

get_rates
sleep 30
get_rates
