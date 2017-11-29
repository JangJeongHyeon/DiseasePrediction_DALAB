##########################################
# CREATE BY JOHN MARK (Jang Jeong Hyeon) #
##########################################


## install packages...
install.packages("readxl")
install.packages("data.table")

## load library from installed packages....
library(data.table)
library(readxl)
library(RMySQL)
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


################################ DATABASE ACCESS CODE ################################

db <- dbConnect(MySQL(), user='root',password='soo2080', dbname='dalab', host='localhost')
dbListTables(db)

gun_join <- dbSendQuery(db, "SELECT 
	A.sidoCode, A.sidoName, B.sidoCdNm, A.siggCode, B.sgguCd, A.siggName, B.sgguCdNm
                        FROM gun_sgis AS A
                        LEFT
                        JOIN meidicinesgiscode AS B
                        ON A.siggName = B.sgguCdNm")
gun_join <- dbFetch(gun_join,n=-1)
Encoding(gun_join$sidoName) <- "UTF-8"
Encoding(gun_join$sidoCdNm) <- "UTF-8"
Encoding(gun_join$sgguCdNm) <- "UTF-8"
Encoding(gun_join$siggName) <- "UTF-8"

write.csv(gun_join,"F:/JJH/Desktop/gun_sgis.csv", row.names = FALSE)

sgis <- dbSendQuery(db, "SELECT * FROM sgis")
sgis <- dbFetch(sgis,n=-1)

Encoding(sgis$sidoName) <- "UTF-8"
Encoding(sgis$sidoName_2) <- "UTF-8"
Encoding(sgis$siggName) <- "UTF-8"
sgis

write.csv(sgis,"F:/JJH/Desktop/origin_sgis.csv", row.names = FALSE)



