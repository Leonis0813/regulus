require 'date'

last_month = (Date.today -2).strftime('%Y-%m')
system "cd backup/tweets; tar zcf #{last_month}.tar.gz #{last_month}"
