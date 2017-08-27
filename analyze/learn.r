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
  future_rates = rates$bid[as.POSIXlt(rates$time) == after_5_min]
  if(length(future_rates) == 0) {
    j = 0
    while(TRUE) {
      before_x_min = as.POSIXlt(rates$time[i]) + 300 - j
      after_x_min = as.POSIXlt(rates$time[i]) + 300 + j
      future_rates = rates$bid[before_x_min < as.POSIXlt(rates$time) & as.POSIXlt(rates$time) < after_x_min]

      if(length(future_rates) > 0) {
        break
      }
      j = j + 1
    }
  }

  if(future_rates[1] > rates$bid[i]) {
    training_data$y[i] = 1
  }  else {
    training_data$y[i] = 0
  }
}

training_data$y = as.factor(training_data$y)

library(randomForest)
model <- randomForest(y~., data=training_data, ntree=500, mtry=1)
