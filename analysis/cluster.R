setwd('~/Documents/mlb-hackathon/')

mainData <- read.csv('mainData.csv')
mainData <- subset(mainData, mainData$appearances > 10)

# Javy Lopez is infinite for some reason, sorry bud, gotta go
mainData <- subset(mainData, !is.infinite(mainData$WHIFF.))

clusters <- kmeans(mainData[mainData$pos == "RP", c("pos", "IP.App", "FB.", "MPH", "DIFF", "AGG", "WHIFF.")], 3)

mainData$cluster <- clusters$cluster
