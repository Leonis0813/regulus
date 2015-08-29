require 'net/http'
require 'json'

pair = %w["AUDCHF" "AUDJPY" "AUDNZD" "AUDUSD" "CADJPY" "CHFJPY" "EURAUD" "EURCAD" "EURCHF" "EURGBP" "EURJPY" "EURNZD"
          "EURUSD" "GBPAUD" "GBPCHF" "GBPJPY" "GBPNZD" "GBPUSD" "NZDJPY" "NZDUSD" "USDCAD" "USDCHF" "USDJPY" "ZARJPY"]
url = "http://query.yahooapis.com/v1/public/yql?q=select%20id,Rate%20from%20yahoo.finance.xchange%20where%20pair%20in%20(#{pair.join(',')})&format=json&env=store://datatables.org/alltableswithkeys"
parsed_url = URI.parse(url)
req = Net::HTTP::Get.new(parsed_url)
res = Net::HTTP.start(parsed_url.host, parsed_url.port) {|http| http.request req }
parsed_body = JSON.parse(res.read_body)

ENV['TZ'] = 'UTC'
now = Time.now.strftime('%Y-%m-%d %H:%M:%S')
parsed_body['query']['results']['rate'].each do |result|
  query = <<"EOF"
INSERT INTO
  currencies
VALUES (
  '#{now}', '#{result['id']}', #{result['Rate'].to_f}
)
EOF
  `mysql --user=root --password=7QiSlC?4 regulus -e "#{query}"`
end
