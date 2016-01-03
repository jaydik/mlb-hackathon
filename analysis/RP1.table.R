#!/usr/bin/env Rscript
setwd("~/Documents/mlb-hackathon/")

library(xtable)

RP <- read.csv("data/RP.csv")

cluster1 <- RP[RP$cluster==1, c("pitcher", "IP.App", "FB.", "MPH", "DIFF", "AGG", "WHIFF.", "appearances")]

cluster1 <- cluster1[order(-cluster1$appearances),c("pitcher", "IP.App", "FB.", "MPH", "DIFF", "AGG", "WHIFF.")]
names(cluster1) <- c("Pitcher", "IP/App", "FB%", "MPH", "DIFF", "AGG", "WHIFF%")
print(xtable(head(cluster1,10),caption = "Top 10 Contact Relievers (by appearances)", label="RPcluster1table"), include.rownames = FALSE)