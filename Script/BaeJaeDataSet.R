install.packages("data.table")
library(data.table)

db3 <- dbConnect(MySQL(), user='root',password='',dbname='baejae')
dbListTables(db3)

baeJae_result <- dbSendQuery(db3,"SELECT * FROM result") 
baeJae_result <- fetch(baeJae_result,-1)
baeJae_result
nrow(baeJae_result)

Encoding(baeJae_result$city) <- 'UTF-8'
names(baeJae_result) <- c('no','date','city','usedMedicineQty','population','weight','weightPercent','predictPatients','diseaseCode')
baeJae_result

summary(baeJae_result)

baeJae_result <- as.data.table(baeJae_result)

baeJae_result[,quantile(baeJae_result$weight),by=date]
