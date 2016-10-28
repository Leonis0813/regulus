options(repos="http://cran.ism.ac.jp")
library(RMySQL)
md <- dbDriver("MySQL")
dbconnector <- dbConnect(md, dbname="regulus", user="root", password="7QiSlC?4", host="localhost", port=3306)
sample.table <- dbGetQuery(dbconnector, "select bid from rates order by time desc limit 100")

library(forecast)
model <- auto.arima(sample.table, ic="aic", stepwise=F, approximation=F, start.p=0, start.q=0, start.P=0, start.Q=0)
save(model, file="rate.model")
