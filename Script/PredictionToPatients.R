##########################################
# CREATE BY JOHN MARK (Jang Jeong Hyeon) #
##########################################


install.packages('RMySQL')
install.packages('data.table')
install.packages('xlsx')
require(xlsx)
require(RMySQL)
require(data.table)

## Connect to our database
db <- dbConnect(MySQL(), user="root", password="soo2080", dbname='dalab_disease', host='localhost')

## Check table list in database
dbListTables(db)

## Exctract table data
dbresult <- dbSendQuery(db,"SELECT * FROM dalab_disease.popmedicinecity;")

## Fetch data from query result
dbresult <- dbFetch(dbresult,n=-1)

## convert to data.table 
result <- as.data.table(dbresult)

## Check dataset
View(result)

## Character encoding
Encoding(result$sidoName) <- "UTF-8"

## exporting data set
write.xlsx(result,"F:/JJH/Desktop/result.xlsx", row.names = FALSE)

## Check encoding result
View(result)

## Data set summary
summary(result)

## Calculate Weight point per month and city
weight <- round((result$usedMedicineQty/result$population)*100,0)

## Check data type and data structure
is(weight)

## binding weight vector to result data table
result <-cbind(result, weight)
## Check result
result

## Calculate total weight per year and month
totalWeight <- result[,sum(weight),by='diagYm']
totalWeight
## Change column name
names(totalWeight) <- c('date','totalWeight')

## Change result column name
names(result) <- c('date','city','usedMedicineQty','population','weight')

## backup result dataset
resultB <- result

## loop for add column for total weight per month
## Create empty vector
perMonthWeight = c()
for(i in 1:nrow(result)){
  year <- result[i]$date
  for(j in 1:nrow(totalWeight)){
    if(totalWeight[j]$date == year){
       perMonthWeight[i] <- totalWeight[j]$totalWeight
    }
  }
}

# check result of loop
is(perMonthWeight)
length(perMonthWeight) == nrow(result)

# merge perMonthWeight to result data table
result <- cbind(result,perMonthWeight)

# Check result data table
result

# calcualte weight percent of per month and city
weightPercent <- round((result$weight/result$perMonthWeight)*100,2)

# Check calculate result
weightPercent
length(weightPercent) == nrow(result)

# append above result to result data table
result <- cbind(result,weightPercent)

# check append result
result

# divide result by date year(e.g 2015)
result_2015 <- result[substr(result$date,1,4)==2015]


# load 2015 monthly patients data of total population 
annualDisease <- dbSendQuery(db, "SELECT * FROM annualDisease")
annualDisease <- dbFetch(annualDisease)

# check dataset
annualDisease

# rename columns
names(annualDisease) <- c('date','totalPatient','percent')

# check result of renames
annualDisease
is(annualDisease)

# convet date column data for matching format to result date column data
newDate <- paste(substr(annualDisease$date,1,4),substr(annualDisease$date,6,7),sep="")

# replace data
annualDisease[1] <- newDate

# Check result of replacing data
annualDisease

# prediction monthly patients of per city
predictPatients = c()
for( i in 1:nrow(result_2015)){
  print(i)
  re_date <- result_2015[i]$date
  print(re_date)
  onePercentPatients <- annualDisease[annualDisease$date == re_date,]$percent
  print(onePercentPatients)
  predictPatients[i] = round(result[i]$weightPercent*onePercentPatients,0)
}

# check result size
length(predictPatients) == nrow(result_2015)

# append number of predict patients data to result_2015 data table
analysis_result <- cbind(result_2015,predictPatients)

# calculate monthly number of predict patients and assign to new object
total_analysis_result <- analysis_result[,sum(predictPatients), by='date']

# check prediction result
total_analysis_result

# change column name
names(total_analysis_result) <- c('date','prediction')
total_analysis_result

# combind real data of monthly number of patients
total_analysis_result <- cbind(total_analysis_result, annualDisease[,2])

# renmaes
names(total_analysis_result) <- c('date','prediction','real')
total_analysis_result

# calculate error rate per month
errorRate <- (abs(total_analysis_result$real - total_analysis_result$prediction)/total_analysis_result$real)*100

total_analysis_result <- cbind(total_analysis_result,errorRate)
total_analysis_result
mean(total_analysis_result$errorRate)

total_analysis_result
write.xlsx(total_analysis_result,"F:/JJH/Desktop/gaemang.xlsx", row.names = FALSE)


write.xlsx(result,"F:/JJH/Desktop/result.xlsx", row.names = FALSE)
