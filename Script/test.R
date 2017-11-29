library(data.table)
require(readr)
require(readxl)
medicine <- read.csv("./DataSet/gyeolhack2.csv")
medicine <- as.data.frame(medicine)

realPatients <- read_xls("./DataSet/gyeolhackSUM.xls")
realPatients <- as.data.frame(realPatients)
medicine <- as.data.table(medicine)
monthly <- medicine[,sum(usedMedicineQty), by='diagYm']
b <- monthly

monthly <- monthly[monthly$diagYm >= 201201 & monthly$diagYm <= 201612,]
cor_result <- cor.test(monthly$V1, realPatients$realPatient)

cor_result
