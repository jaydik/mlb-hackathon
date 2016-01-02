#!/usr/bin/env Rscript
setwd("~/Documents/mlb-hackathon/")

library(fmsb)

RP <- read.csv("data/RP.csv")

RP_means <- aggregate(RP[,c("IP.App", "FB.", "MPH", "DIFF", "AGG", "WHIFF.")], by=list(RP$cluster), mean)
RP_max <- apply(RP[,c("IP.App", "FB.", "MPH", "DIFF", "AGG", "WHIFF.")], 2, FUN=max)
RP_min <- apply(RP[,c("IP.App", "FB.", "MPH", "DIFF", "AGG", "WHIFF.")], 2, FUN=min)
RP_radar <- rbind(RP_max, RP_min, RP_means[3 ,c("IP.App", "FB.", "MPH", "DIFF", "AGG", "WHIFF.")])
radarchart(RP_radar)
