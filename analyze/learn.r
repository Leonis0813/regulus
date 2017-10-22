period <- 10
length <- 10
num_training_data <- 200 - (period + length)

library(yaml)
config <- yaml.load_file("analyze/settings.yml")

library(RMySQL)
driver <- dbDriver("MySQL")
dbconnector <- dbConnect(driver, dbname="regulus", user=config$mysql$user, password=config$mysql$password, host=config$mysql$host, port=as.integer(config$mysql$port))

sql <- paste("SELECT close FROM candle_sticks WHERE pair = 'USDJPY' AND `interval` = '1-min' ORDER BY id LIMIT 200")
rates <- dbGetQuery(dbconnector, sql)

x <- matrix(0, nrow=num_training_data, ncol=length)
y <- rep(0, num_training_data)

for (i in 1:num_training_data) {
  x[i,] <- rates$close[i : (i + length - 1)]
  y[i] <- rates$close[i + period + length - 1]
}

model = lm(y ~ x[,1] + x[,2] + x[,3] + x[,4] + x[,5] + x[,6] + x[,7] + x[,8] + x[,9] + x[,10])

timestamp <- format(Sys.time(), "%Y%m%d%H%M%S")

basename <- paste(timestamp, "200", period, length, sep="_")
yml_filename <- paste("results/", basename, ".yml", sep="")
write("coefficients:", file=paste(yml_filename))
coefs <- as.vector(coef(model))
for (i in 2:(length+1)) {
  write(paste("  -", coefs[i]), file=yml_filename, append=T)
}
write(paste("constant:", coefs[1]), file=yml_filename, append=T)
