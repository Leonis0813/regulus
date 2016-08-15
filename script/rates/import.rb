require 'json'
require 'net/http'
require_relative '../config/settings'
require_relative '../lib/logger'
require_relative '../lib/mysql_client'

IMPORT = Settings.rate['import']
ENV['TZ'] = 'UTC'

def get_rates
  now = Time.now.strftime('%Y-%m-%d %H:%M:%S')

  IMPORT['pairs'].each do |pair|
    parsed_url = URI.parse("#{IMPORT['url']}/?code=#{pair}=FX")
    req = Net::HTTP::Get.new(parsed_url)
    res = Net::HTTP.start(parsed_url.host, parsed_url.port) {|http| http.request req }

    rates = res.body.scan(/(.*#{pair}_detail_[bid|ask].*)/).flatten
    status, message, uri = res.code, res.message, res.uri.to_s

    unless res.code == '200'
      error_type = res.error_type
      Logger.write {:status => status, :message => message, :uri => uri, :error_type => error_type}
      next
    end

    bid = rates.find {|rate| rate.include?('bid') }.gsub(/<.*?>/, '').to_f
    ask = rates.find {|rate| rate.include?('ask') }.gsub(/<.*?>/, '').to_f

    Logger.write {:status => status, :uri => uri, :pair => pair, :bid => bid, :ask => ask}
    redo if bid == 0.0 or ask == 0.0

    param = {:time => now, :pair => pair, :bid => bid, :ask => ask}
    execute_sql('regulus', File.join(Settings.application_root, 'rates/import.sql'), param)
  end
end

get_rates
sleep 30
get_rates