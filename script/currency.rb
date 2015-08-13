require 'net/http'
require 'json'

url = 'http://www.gaitameonline.com/rateaj/getrate'
parsed_url = URI.parse(url)
req = Net::HTTP::Get.new(parsed_url)
res = Net::HTTP.start(parsed_url.host, parsed_url.port) {|http| http.request req }
parsed_body = JSON.parse(res.read_body)
now = Time.now.strftime('%Y-%m-%d %H:%M:%S')

parsed_body['quotes'].each do |rate|
  query = <<"EOF"
INSERT INTO
  currencies
VALUES (
  '#{now}', '#{rate['currencyPairCode']}', #{rate['bid']}, #{rate['ask']}, #{rate['open']}, #{rate['high']}, #{rate['low']}
)
EOF
  `mysql --user=root --password=7QiSlC?4 regulus -e "#{query}"`
end
