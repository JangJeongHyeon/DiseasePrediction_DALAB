library(data.table)

## Connect to our database
db2 <- dbConnect(MySQL(), user="root", password="", dbname='', host='')

## Check table list in database
dbListTables(db2)

## Exctract table data
dbresult2 <- dbSendQuery(db2,"SELECT * FROM dalab_disease1015.monthlyMedicineQty")

## Fetch data from query result
dbresult2 <- dbFetch(dbresult2,n=-1)

## convert to data.table 
result2 <- as.data.table(dbresult2)
result2

regression <- result[,sum(usedMedicineQty), by=date]
names(regression) <- c('date','totalMedicine','realPatients')
regression
realPatients <- annualDisease[1:2]
regression <- cbind(regression, realPatients$totalPatient)


cor_result <- cor.test(regression$totalMedicine, regression$realPatients)
cor_result

plot(regression$totalMedicine, regression$realPatients)

l_result <- lm(realPatients~totalMedicine, data=regression)
summary(l_result)
l_result

# y = 0.004136*x + 813200
predict_totalPatinets = c()
for(i in 1: nrow(regression)){
  x <- regression[i,]$totalMedicine
  y <- (0.004136 * x + 813200)
  predict_totalPatinets[i] <- y
}

regression <- cbind(regression,err$errRate)


err <- regression[,abs(realPatients-predict_totalPatinets)/realPatients, date]
names(err) <- c('date','errRate')

mean(err$errRate)


regression[,realPatients-predict_totalPatinets, date]

names(regression) <- c('date', "totalMedicine","realPatients","predict_totalPatinets","errorRate")
regression
write.xlsx(regression,"F:/JJH/Desktop/regressionResult.xlsx")


pp <- result[,weightPercent/100,date]
names(pp) <- c('date','ww')

vv  = c()
for(i in 1:nrow(pp)){
  dd <- pp[i]$date
  x <- regression[regression$date == dd]$predict_totalPatinets
  vv[i] <- pp[i]$ww * x
}

ee = c()
for(j in 1:nrow(pp)){
  ddd <- pp[j]$date
  xx <- regression[regression$date == ddd]$realPatients
  ee[j] <- pp[j]$ww * xx
}



result <- cbind(result, err_temp)
result
names(result) <- c ("date","city","usedMedicineQty","population","weight","perMonthWeight","weightPercen","predict_patients","real_patients","error_rate")

result

err_temp <- result[,abs(real_patients-predict_patients)/real_patients, by = date]
err_temp

write.xlsx(result,"F:/JJH/Desktop/totalResult.xlsx",row.names = FALSE)
