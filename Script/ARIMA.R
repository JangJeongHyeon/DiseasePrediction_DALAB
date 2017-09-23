##########################################
# CREATE BY JOHN MARK (Jang Jeong Hyeon) #
##########################################

install.packages("tseries")
install.packages("forecast")
library(tseries)
library(readxl)
library(forecast)
arima_result <- read_excel("F:/JJH/Desktop/result_set_dalab.xlsx")
View(arima_result)
names(arima_result) <- c('year','month','predictValue','realValue','errorRate')
head(arima_result)


### Convert table data type to data frame
arima_result <- as.data.frame(arima_result)
class(arima_result)


### Convert to ts data
dropColumn <- c('year','month','errorRate', 'realValue')
date <- paste(arima_result$year, arima_result$month, sep='-')
arima_ts <- arima_ts[,!(names(arima_ts) %in% 'time')]
date
arima_result <- cbind(time=date, arima_result)

arima_result <- ts(arima_result)

names(arima_result) <- c('time','value')

arima_ts <- arima_ts[,!(names(arima_ts) %in% "time")]

arima_ts <- ts(arima_ts,start= c(2015,1), frequency = 12)
### ARIMA Analysis test

arima_result
arima_ts <- as.data.frame(arima_ts)
arima_ts
adf.test(diff(log(arima_ts)), alternative = "stationary", k=0)


auto_arima <- auto.arima(diff(log(arima_ts)))
auto_arima
