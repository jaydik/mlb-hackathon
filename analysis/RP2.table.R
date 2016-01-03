#!/usr/bin/env Rscript
setwd("~/Documents/mlb-hackathon/")

library(xtable)

RP <- read.csv("data/RP.csv")

cluster2 <- RP[RP$cluster==2, c("pitcher", "IP.App", "FB.", "MPH", "DIFF", "AGG", "WHIFF.", "appearances")]

cluster2 <- cluster2[order(-cluster2$appearances),c("pitcher", "IP.App", "FB.", "MPH", "DIFF", "AGG", "WHIFF.")]
names(cluster2) <- c("Pitcher", "IP/App", "FB%", "MPH", "DIFF", "AGG", "WHIFF%")
print(xtable(head(cluster2,10),caption = "Average Reliever Pitchers", label="RPcluster2table"), include.rownames = FALSE)