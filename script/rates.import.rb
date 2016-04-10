require 'net/http'
require 'json'

PAIR = %w["AUDCHF" "AUDJPY" "AUDNZD" "AUDUSD" "CADJPY" "CHFJPY" "EURAUD" "EURCAD" "EURCHF" "EURGBP" "EURJPY" "EURNZD"
          "EURUSD" "GBPAUD" "GBPCHF" "GBPJPY" "GBPNZD" "GBPUSD" "NZDJPY" "NZDUSD" "USDCAD" "USDCHF" "USDJPY" "ZARJPY"]
SQL = "select id,Rate from yahoo.finance.xchange where pair in (#{PAIR.join(',')})"
RAW_URL = "http://query.yahooapis.com/v1/public/yql?q=#{URI.encode(SQL)}&format=json&env=store://datatables.org/alltableswithkeys"
PARSED_URL = URI.parse(RAW_URL)
ENV['TZ'] = 'UTC'

def get_rates
  req = Net::HTTP::Get.new(PARSED_URL)
  res = Net::HTTP.start(PARSED_URL.host, PARSED_URL.port) {|http| http.request req }
  results = JSON.parse(res.read_body)['query']['results']['rate']

  now = Time.now.strftime('%Y-%m-%d %H:%M:%S')
  results.each do |result|
    query = <<"EOF"
INSERT INTO
  rates
VALUES (
  '#{now}', '#{result['id']}', #{result['Rate'].to_f}
)
EOF
    `mysql --user=root --password=7QiSlC?4 regulus -e "#{query}"`
  end

  results.map! {|result| "{pair: #{result['id']}, rate: #{result['Rate'].to_f}}" }
  puts [
    "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}]",
    '[import]',
    "{time: #{now}, rates: [#{results.join(', ')}]}",
  ].join(' ')
end

get_rates
sleep 30
get_rates
