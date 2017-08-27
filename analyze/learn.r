library(yaml)
config <- yaml.load_file("analyze/settings.yml")

library(RMySQL)
driver <- dbDriver("MySQL")
dbconnector <- dbConnect(driver, dbname="regulus", user=config$mysql$user, password=config$mysql$password, host=config$mysql$host, port=as.integer(config$mysql$port))

sql <- paste("SELECT time, ask, bid FROM rates WHERE pair = 'USDJPY' ORDER BY time LIMIT 200")
rates <- dbGetQuery(dbconnector, sql)

latest = as.POSIXlt(rates$time[length(rates$time)])
training_data = list(x = rates$bid[as.POSIXlt(rates$time) < latest - 300])
training_data$y = rep(0, length(training_data$x))

for (i in 1:length(training_data$x)) {
  after_5_min = as.POSIXlt(rates$time[i]) + 300
  rate_after_5 = rates$bid[as.POSIXlt(rates$time) == after_5_min]

  if(length(rate_after_5) == 0) {
    training_data$y[i] = 0
  } else if(rate_after_5[1] > rates$bid[i]) {
    training_data$y[i] = 1
  }  else {
    training_data$y[i] = 0
  }
}
