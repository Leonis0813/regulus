# 4.9.2 (2020/01/15)
- [UPDATE] gems

# 4.9.1 (2019/12/02)
- [UPDATE] ruby version to 2.6.3
- [UPDATE] gems

# 4.9.0 (2019/11/04)
- [UPDATE] prediction view to display current setting for auto prediction

# 4.8.2 (2019/11/03)
- [FIX] config file handling
- [UPDATE] gems

# 4.8.1 (2019/10/20)
- [UPDATE] index api to search by pair

# 4.8.0 (2019/10/19)
- [UPDATE] prediction view to predict multiple pairs automatically
- [UPDATE] gems

# 4.7.0 (2019/10/12)
- [UPDATE] analysis view to confirm result by tensorboard

# 4.6.0 (2019/10/03)
- [UPDATE] learning script to output training data
- [UPDATE] gems

# 4.5.2 (2019/09/21)
- [FIX] bug for production
- [ADD] logging for error message and backtrace
- [UPDATE] gems

# 4.5.1 (2019/09/10)
- [UPDATE] gems

# 4.5.0 (2019/08/16)
- [ADD] Web API to index predictions
- [UPDATE] gems

# 4.4.3 (2019/08/06)
- [UPDATE] rails version to 5.0.x

# 4.4.2 (2019/08/04)
- [UPDATE] job scheduler

# 4.4.1 (2019/08/02)
- [UPDATE] ruby version to 2.5.5

# 4.4.0 (2019/07/15)
- [UPDATE] feature to predict automatically per hour
- [UPDATE] gems

# 4.3.1 (2019/06/30)
- [ADD] gems for pronto
- [UPDATE] gems

# 4.3.0 (2019/06/23)
- [UPDATE] analysis and prediction to specify pair
- [UPDATE] gems

# 4.2.0 (2019/06/08)
- [UPDATE] views to notify error
- [UPDATE] gems

# 4.1.10 (2019/05/03)
- [FIX] coding style
- [UPDATE] gems

# 4.1.9 (2019/05/02)
- [UPDATE] ruby version to 2.3.8

# 4.1.8 (2019/04/21)
- [UPDATE] gems

# 4.1.7 (2019/03/30)
- [UPDATE] neural network
- [UPDATE] gems

# 4.1.6 (2019/03/02)
- [UPDATE] ruby version to 2.3.7
- [UPDATE] gems

# 4.1.5 (2019/02/04)
- [UPDATE] submit button not to push twice

# 4.1.4 (2019/02/01)
- [UPDATE] rails version

# 4.1.3 (2019/01/18)
- [UPDATE] gems

# 4.1.2 (2019/01/14)
- [UPDATE] gems

# 4.1.1 (2019/01/13)
- [UPDATE] gems

# 4.1.0 (2019/01/06)
- [ADD] rebuild button to analysis view

# 4.0.1 (2019/01/05)
- [UPDATE] gems

# 4.0.0 (2018/12/30)
- [ADD] new feature to predict the FX rate

# 3.3.2 (2018/12/23)
- [UPDATE] gems

# 3.3.1 (2018/12/22)
- [UPDATE] gems

# 3.3.0 (2018/12/15)
- [ADD] attachments to email for notification of analysis result

# 3.2.1 (2018/11/24)
- [UPDATE] learning script to use candle sticks and save model

# 3.2.0 (2018/10/15)
- [UPDATE] analysis view for deep learning
- [UPDATE] scripts for deep learning

# 3.1.0 (2018/08/06)
- [ADD] paging to analysis view

# 3.0.1 (2018/01/21)
- [REMOVE] scripts except analyzing

# 3.0.0 (2018/01/02)
- [ADD] list view to confirm analysis jobs

# 2.1.0 (2017/12/31)
- [ADD] view to manage analysis

# 2.0.10 (2017/10/25)
- [UPDATE] learning algorithm to lm

# 2.0.9 (2017/08/27)
- [ADD] learning script

# 2.0.8 (2017/07/16)
- [UPDATE] logger to stdout

# 2.0.7 (2017/06/18)
- [CHANGE] method name to info

# 2.0.6 (2017/04/20)
- [ADD] logging to backup
- [ADD] logging to compress
- [UPDATE] logger for runtime
- [CHANGE] method name to info

# 2.0.5 (2017/04/08)
- [CREATE] script for backup to compute server

# 2.0.4 (2017/03/27)
- [UPDATE] change collection script to custom indicator

# 2.0.3 (2017/03/25)
- [CREATE] script for compressing backup csv files

# 2.0.2 (2017/03/18)
- [CREATE] script for deleting rates

# 2.0.1 (2017/03/12)
- [ADD] mql code
- [CREATE] mysql client

# 2.0.0 (2017/03/05)
- [REMOVE] rails app
- [ADD] index to time, pair column

# 1.4.8 (2016/10/31)
- [ADD] scripts for analyzing

# 1.4.7 (2016/10/14)
- [REFACTOR] view for tweet and article
- [UPDATE] favicon.ico

# 1.4.6 (2016/09/19)
- [FIX] require settings.rb

# 1.4.5 (2016/09/18)
- [FIX] not aggregate when out pf service

# 1.4.4 (2016/09/15)
- [CHANGE] timeout
- [FIX] y range
- [FIX] bug for fetching profile_image_url from twitter api
- [UPDATE] remove aggregated rates before 2 months
- [FIX] not import when out of service

# 1.4.3 (2016/08/27)
- [REFACTOR] scripts

# 1.4.2 (2016/07/30)
- [FIX] add error handling for external service error
- [ADD] output http response as log

# 1.4.1 (2016/07/05)
- [FIX] reverse moving average
- [FIX] set jst for event

# 1.4.0 (2016/07/04)
- [ADD] moving average

# 1.3.0 (2016/06/27)
- [UPDATE] show rate info on display
- [UPDATE] refactor javascript

# 1.2.0 (2016/05/22)
- [UPDATE] add select tag for pair & interval
- [UPDATE] use d3.js instead of jqplot
- [UPDATE] use gem 'mysql2' in external scripts

# 1.1.1 (2016/04/16)
- [UPDATE] write style to scss
- [UPDATE] change currencies to rates
- [UPDATE] modify interval for updating tweets

# 1.1.0 (2016/04/10)
- [UPDATE] create each view for rates, tweets and articles

# 1.0.3 (2016/01/31)
- [UPDATE] scripts
- [ADD] rspec

# 1.0.2 (2015/12/19)
- [UPDATE] table schema of currency
- [FIX] bug when deploying for production environment

# 1.0.1 (2015/10/18)
- [ADD] module and functional test
- [FIX] controllers and models

# 1.0.0 (2015/08/23)
- [NEW] create app
