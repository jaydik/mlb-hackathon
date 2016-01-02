#!/usr/bin/env Rscript
setwd("~/Documents/mlb-hackathon/")

library(xtable)

RP <- read.csv("data/RP.csv")

cluster3 <- RP[RP$cluster==3, c("pitcher", "IP.App", "FB.", "MPH", "DIFF", "AGG", "WHIFF.", "appearances")]

cluster3 <- cluster3[order(-cluster3$appearances),c("pitcher", "IP.App", "FB.", "MPH", "DIFF", "AGG", "WHIFF.")]
names(cluster3) <- c("Pitcher", "IP/App", "FB%", "MPH", "DIFF", "AGG", "WHIFF%")
print(xtable(head(cluster3,10),caption = "Cluster 3 Pitchers", label="RPcluster3table"), include.rownames = FALSE)