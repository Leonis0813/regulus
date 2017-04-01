library(forecast)
load("rate.model")
prediction <- forecast(model, level = c(50,95), h = 50)
prediction$mean[1:50]
