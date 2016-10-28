library(RMySQL)
md <- dbDriver("MySQL")
dbconnector <- dbConnect(md, dbname="regulus", user="root", password="7QiSlC?4", host="localhost", port=3306)
rate <- dbGetQuery(dbconnector, "select bid from rates where pair = 'USDJPY' order by time desc limit 1000")

library(forecast)
model <- auto.arima(rate, ic="aic", stepwise=F, approximation=F, start.p=0, start.q=0, start.P=0, start.Q=0)
save(model, file="rate.model")
