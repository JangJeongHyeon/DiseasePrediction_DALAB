##########################################
# CREATE BY JOHN MARK (Jang Jeong Hyeon) #
##########################################


## install packages...
install.packages("readxl")
install.packages("data.table")

## load library from installed packages....
library(data.table)
library(readxl)

## load data set from dataset directory in this project directory
result <- read_excel(":/JJH/DevProject/R/DiseasePrediction_DALAB/DataSet/1th_result.xlsx")

## check dataset
View(result)

## convert data frame
result <- as.data.frame(result)

## calculate the weight value for each city's amount of used medicine per population.
weight <- round((result$AmountOfMedicineUsed/result$population)*100,0)

## check value
weight

## weight value merge to result dataframe
result <-cbind(result,weight)

## view dataframe
View(result)

## calculate total weight value on each month per year
year <- strsplit(result$DATE,"-",0)
re <- result
