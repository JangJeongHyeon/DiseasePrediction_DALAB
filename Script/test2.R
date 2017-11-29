library(RMySQL)
library(readxl)
library(data.table)

db <- dbConnect(MySQL(), user='',password='', dbname='', host='')
dbListTables(db)

medicine <- dbSendQuery(db, "SELECT * FROM popmedicinecity")
medicine <- dbFetch(medicine, n = -1)

Encoding(medicine$sidoName)<- "UTF-8"
medicine

realPatient <- read_xlsx("./DataSet/annualCold.xlsx")


totalMedicine<- as.data.table(medicine)

totalMedicine <- totalMedicine[,sum(usedMedicineQty), by='diagYm']
names(totalMedicine) <- c("digYm","totalMeidcineQty")

totalMedicine$totalMeidcineQty
names(realPatient) <- c("diagYm",'realPatients')

realPatient <- as.data.frame(realPatient)

realPatient
totalMedicine

realPatient
totalMedicine[1:63,]

cor.test(realPatient$realPatients,totalMedicine[1:63,]$totalMeidcineQty)
summary(lm(realPatient$realPatients~totalMedicine[1:63,]$totalMeidcineQty))

plot(realPatient$realPatients,totalMedicine[1:63,]$totalMeidcineQty)
abline(lm(realPatient$realPatients~totalMedicine[1:63,]$totalMeidcineQty), col="red")

totalMedicineAndPatient <- data.frame(realPatient$diagYm,realPatient$realPatients, totalMedicine[1:63,]$totalMeidcineQty)
names(totalMedicineAndPatient) <- c("diagYm","realPatients","totalMedicineQty")

View(totalMedicineAndPatient)
write.csv(totalMedicineAndPatient, "F:/JJH/Desktop/coldResult1117.csv")
totalMedicineAndPatient


####################################################################################################################################

result <- dbSendQuery(db, "SELECT * FROM popmedicinecity")
result <- dbFetch(result, n=-1)
Encoding(result$sidoName) <- "UTF-8"
weight <- round((result$usedMedicineQty / result$population)*100,0)
result <- cbind(result, weight)
result

## converting result to data.table
result <- as.data.table(result)
totalWeight <- result[,sum(weight), by='diagYm']
totalWeight

monthlyWeight = c()
for(i in 1:nrow(result)){
  monthlyWeight[i] = totalWeight[totalWeight$diagYm == result[i,]$diagYm]$V1  
}

result <- cbind(result, monthlyWeight)
result
weightPercent <- round((result$weight / result$monthlyWeight)*100,2)
weightPercent
result <- cbind(result, weightPercent)

write.csv(result, "F:/JJH/Desktop/result_ear.csv", row.names = FALSE)


#####################################################################################################################################

cold <- read.csv("./DataSet/total/ear.csv")
#cold <- cold[,-1]
names(cold) <- c("diagYm","totalMedicineQty","realPatients","predictPatients","errorRate")
cold
#summary(lm(cold[1:60,]$realPatients~cold[1:60,]$totalMedicineQty))

predictPatients <-0.00145*cold$totalMedicineQty+44574.09179
cold <- cbind(cold, predictPatients)
cold <- as.data.table(cold)
cold[,4] <- cold[,6]
cold <- cold[,-6]
#error <- cold[,(abs(realPatients-predictPatients)/realPatients)*100, by="diagYm"]
#cold <- cbind(cold, error$V1)

onePercent <- round(cold$predictPatients/100,0)

cold <- cbind(cold,onePercent)
cold$predictPatients <- round(cold$predictPatients)
View(cold)

predictCityPatients = c()
for(i in 1: nrow(result)){
  x <- result[i,]$diagYm
  y <- result[i,]$weightPercent
  patient <- cold[cold$diagYm == x]$onePercent
  predictCityPatients[i] <- round(y*patient)
  #print(y*patient)
}

result2 <- result
result2 <- cbind(result2,predictCityPatients)
result2

result2 <- as.data.table(result2)
result2[,sum(predictCityPatients),by="diagYm"]
write.csv(result2, "F:/JJH/Desktop/earResult2.csv", row.names = FALSE)

result2
summary(result2)

############################# outlier processing must be refactoring and improvement

boxplot(result2$weight)
result2[, quantile(predictCityPatients), by="diagYm"]



# danger = c()
# for(i in 1:nrow(result2)){
#   predict <- result2[i,]$predictCityPatients
#   # dangerous
#   if(predict <= 1770){
#     danger[i] <- 1 
#   }else if(predict > 1770 & predict <=22982){
#     danger[i] <- 2
#   }else if(predict > 22982 & predict <= 27816){
#     danger[i] <- 3
#   }else if(predict > 27816){
#     danger[i] <- 4
#   }
# }


# dangerous <- function(data, first, second, third){
#   for(i in 1:nrow(data)){
#     predict <- data[i,]$predictCityPatients
#     if(predict <= first){
#       danger[i] <- 1 
#     }else if(predict > first & predict <=second){
#       danger[i] <- 2
#     }else if(predict > second & predict <= third){
#       danger[i] <- 3
#     }else if(predict > third){
#       danger[i] <- 4
#     }
#   }
# }



diagYm <- unique(result$diagYm)
danger = c()
index <- 1
for(i in 1 : length(diagYm)){
  year <- diagYm[i]
  month <- result2[result2$diagYm == year]
  print(month)
  standard <- quantile(month$predictCityPatients)
  data <- month
  first <- standard[2]
  second <- standard[3]
  third <- standard[4]
  for(i in 1:nrow(data)){
    predict <- data[i,]$predictCityPatients
    if(predict <= first){
      danger[index] <- 1 
    }else if(predict > first & predict <=second){
      danger[index] <- 2
    }else if(predict > second & predict <= third){
      danger[index] <- 3
    }else if(predict > third){
      danger[index] <- 4
    }
    index <- index + 1
  }
}

result3 <- cbind(result2, danger)
result3

View(result3)

Encoding(result3$sidoName) <- 'UTF-8'

write.csv(result3, "F:/JJH/Desktop/earTOtalResult1128.csv", row.names = FALSE)
