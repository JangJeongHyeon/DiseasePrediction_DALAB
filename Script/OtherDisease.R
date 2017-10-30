install.packages("xlsx")
library(xlsx)
library(RMySQL)
library(data.table)
library(reader)


# connect to database
db <- dbConnect(MySQL(), user='root',password='', dbname='', host='')
dbListTables(db)

# fetch astma data from database
asthma <- dbSendQuery(db, "SELECT * FROM popmedicinecityasthma")
asthma <- dbFetch(asthma,n=-1)

# fetch conuntivitis data from database
conjuntivitis <- dbSendQuery(db, "SELECT * FROM popmedicinecitycheonsick")
conjuntivitis <- dbFetch(conjuntivitis, n=-1)

# UTF-8 encoding for sidoname field
Encoding(asthma$sidoName) <- "UTF-8"
Encoding(conjuntivitis$sidoName) <- "UTF-8"

# check each data sets
View(asthma)
View(conjuntivitis)

# export by Excel file
write.xlsx(x=asthma,"./DataSet/asthma.xlsx",sheetName = '천식', row.names = FALSE)
write.xlsx(x=conjuntivitis,"./DataSet/conjuntivitis.xlsx",sheetName = '결막', row.names = FALSE)


# import real patinets data
realConjuntivitis <- read.xlsx("DataSet/realConjuntivitis.xlsx",sheetIndex = 1)
View(realConjuntivitis)
realConjuntivitis$date <- as.character(realConjuntivitis$date)
Encoding(realConjuntivitis$date) <- "UTF-8"
realConjuntivitis$date


# get monthly total usedMedicineQty
conjuntivitis <- as.data.table(conjuntivitis)
asthma <- as.data.table(asthma)
monthlyConjuntivitis <- conjuntivitis[,sum(usedMedicineQty),by='diagYm']
monthlyAsthma <- asthma[,sum(usedMedicineQty),by='diagYm']
write.xlsx(x = monthlyConjuntivitis,file = "./DataSet/monthlyConjuntivitis.xlsx",sheetName = '월간 사용약품량', row.names = FALSE)
write.xlsx(x= monthlyAsthma, file="./DataSet/monthlyAsthma.xlsx",sheetName = '월간 사용약품량', row.names = FALSE)
write.xlsx(x=realConjuntivitis, file = "./DataSet/realConjuntivitis.xlsx",sheetName = 'test',row.names = FALSE)


# get combined data
combinedInfo <- read.xlsx(file = './DataSet/monthlyConjuntivitis.xlsx',sheetIndex = 1)
# test correlation
cor.test(combinedInfo$amountOfMedicine,combinedInfo$realPaitents)
plot(combinedInfo$amountOfMedicine, combinedInfo$realPaitents)
