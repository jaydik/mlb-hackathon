#!/usr/bin/env Rscript
setwd("~/Documents/mlb-hackathon/")

library(fmsb)

SP <- read.csv("data/SP.csv")

SP_means <- aggregate(SP[,c("IP.App", "FB.", "MPH", "DIFF", "AGG", "WHIFF.")], by=list(SP$cluster), mean)
SP_max <- apply(SP[,c("IP.App", "FB.", "MPH", "DIFF", "AGG", "WHIFF.")], 2, FUN=max)
SP_min <- apply(SP[,c("IP.App", "FB.", "MPH", "DIFF", "AGG", "WHIFF.")], 2, FUN=min)
SP_radar <- rbind(SP_max, SP_min, SP_means[2 ,c("IP.App", "FB.", "MPH", "DIFF", "AGG", "WHIFF.")])
radarchart(SP_radar)
