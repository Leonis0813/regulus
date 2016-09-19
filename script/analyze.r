install.packages("DBI")
install.packages("RMySQL")
library(RMySQL)
md <- dbDriver("MySQL")
dbconnector <- dbConnect(md, dbname="regulus_development", user="root", password="7QiSlC?4", host="160.16.66.112", port=3306)
sample.table <- dbGetQuery(dbconnector, "select * from rates order by from_date desc limit 50")
sample.table
