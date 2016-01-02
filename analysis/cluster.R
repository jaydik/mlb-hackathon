setwd('~/Documents/mlb-hackathon/')

mainData <- read.csv('data/mainData.csv')
mainData <- subset(mainData, mainData$appearances > 10)

# Javy Lopez is infinite for some reason, sorry bud, gotta go
mainData <- subset(mainData, !is.infinite(mainData$WHIFF.))

# Separate RP and SP
RP <- subset(mainData, mainData$pos == "RP")
SP <- subset(mainData, mainData$pos == "SP")

RP_clusters <- kmeans(scale(RP[, c("IP.App", "FB.", "MPH", "DIFF", "AGG", "WHIFF.")]), 3)
SP_clusters <- kmeans(scale(SP[, c("IP.App", "FB.", "MPH", "DIFF", "AGG", "WHIFF.")]), 5)

RP$cluster <- RP_clusters$cluster
SP$cluster <- SP_clusters$cluster

RP <- RP[order(-RP$appearances),]
SP <- SP[order(-SP$appearances),]

write.table(RP, file="data/RP.csv", sep=",", row.names=FALSE)
write.table(SP, file="data/SP.csv", sep=",", row.names=FALSE)

