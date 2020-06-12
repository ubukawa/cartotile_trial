#######################################
#test 4
# by Taro Ubukawa taro.ubukawa@un.org
#######################################
#Please store the source data in src folder.
#Please prepare a folder for graph.
######################################

#install.packages("dplyr", dependencies = TRUE)
library(dplyr)

#Parameters
loc <- "./"
indicators <- c("1.1.1", "2.1.1","3.2.1","4.2.2","5.5.1","6.1.1","7.1.1","8.1.1","9.5.1","10.4.1","11.1.1","12.2.2","13.1.1","14.a.1","15.1.1","16.1.1")
joinkey <-"GeoAreaCode"
graphloc <-"graph"
tableloc <-"table"

#source files
srcfile <- "src/data.csv"
srcisocode <- "src/iso3cd.csv" #table for join




#settings
srcdatapath <- paste(loc,srcfile,sep="")
isocodepath <- paste(loc,srcisocode,sep="")
all.data <- read.csv(file = srcdatapath, header = TRUE)
iso.data <- read.csv(file = isocodepath, header = TRUE)
all2.data <- all.data[,c(3,4,6,7,8,9,10,14,15,16,17,18,19,20,21,22,23,24)] 
all3.data <- left_join(all2.data,iso.data,by=joinkey) #need to change if necessary
codelist <- iso.data$GeoAreaCode #area code list

##loop for each 16 indicators
k <- 1
while (k <= length(indicators)){
type <- indicators[k]


test.data <- filter(all3.data,all3.data$Indicator == type)

###loop for countries (start)
i <- 1
while (i <= length(codelist)){ #for loop would be better
state <-test.data$GeoAreaName[test.data$GeoAreaCode == codelist[i]][1]  
filename <- paste(loc,graphloc,"/",type,"_",state,".png",sep="")

if (length(test.data$TimePeriod[test.data$GeoAreaCode==codelist[i]]) == 0){
filename <- "" #do nothing
  } else {
png(filename,width=600, height=200)
x <- test.data$TimePeriod[test.data$GeoAreaCode == codelist[i]]
y <- test.data$Value[test.data$GeoAreaCode == codelist[i]]
title <- paste("Index", type, state)
plot(x,y,pch=19,col=2,xlim=c(2000,2020),ylim=c(0,100),main=title, xlab="Year", ylab="Value")
dev.off()
}

i <- i+1
}
###loop for countries (end)
export.data <- filter(test.data,test.data$ISO3CD != "NA")
write.csv(export.data,paste(loc,tableloc,"/export_",type,".csv",sep=""))

k <- k+1
}
##loop for each 16 indicators (end) 