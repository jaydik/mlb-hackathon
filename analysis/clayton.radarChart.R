#!/usr/bin/env Rscript
setwd("~/Documents/mlb-hackathon/")

library(fmsb)

SP <- read.csv("data/SP.csv")

clayton <- subset(SP, SP$pitcher == "Clayton Kershaw")
SP_max <- apply(SP[,c("IP.App", "FB.", "MPH", "DIFF", "AGG", "WHIFF.")], 2, FUN=max)
SP_min <- apply(SP[,c("IP.App", "FB.", "MPH", "DIFF", "AGG", "WHIFF.")], 2, FUN=min)
SP_radar <- rbind(SP_max, SP_min, clayton[1 ,c("IP.App", "FB.", "MPH", "DIFF", "AGG", "WHIFF.")])
radarchart(SP_radar)
