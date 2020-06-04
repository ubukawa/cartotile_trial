#test

#install.packages("dplyr", dependencies = TRUE)

loc <- ""
srcdata <- paste(loc,"data.csv",sep="")
  
#all.data <- read.csv(file = "D:/09_R/data.csv", header = TRUE)
all.data <- read.csv(file = srcdata, header = TRUE)
indicators <- c("1.1.1", "2.1.1","3.2.1","4.2.2","5.5.1","6.1.1","7.1.1","8.1.1","9.5.1","10.4.1","11.1.1","12.2.2","13.1.1","14.a.1","15.1.1","16.1.1")
list <- c("Albania","Angola","Argentina","Azerbaijan","Australia","Austria","Belgium","Bhutan","Bangladesh","Armenia","Bolivia (Plurinational State of)","Botswana","Brazil","China","Colombia","Solomon Islands")

##loop
k <- 1
while (k <= length(indicators)){
type <- indicators[k]

library(dplyr)
test.data <- filter(all.data,all.data$Indicator == type)

###loop for countries (start)
i <- 1
while (i <= length(list)){ #for loop would be better
filename <- paste(loc,"graph/",type,"_",list[i],".png",sep="")

png(filename,width=600, height=200)
x <- test.data$TimePeriod[test.data$GeoAreaName == list[i]]
y <- test.data$Value[test.data$GeoAreaName == list[i]]
title <- paste("Index", type, list[i])
plot(x,y,pch=19,col=2,xlim=c(2000,2020),ylim=c(0,100),main=title, xlab="Year", ylab="Value")
dev.off()
i <- i+1
}
###loop for countries (end)
k <- k+1
}
