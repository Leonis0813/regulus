require 'date'

last_month = (Date.today -1).strftime('%Y-%m')
%w[ rates tweets ].each do |data|
  system "cd backup/#{data}; tar zcf #{last_month}.tar.gz #{last_month}"
end
