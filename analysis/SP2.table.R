#!/usr/bin/env Rscript
setwd("~/Documents/mlb-hackathon/")

library(xtable)

SP <- read.csv("data/SP.csv")

cluster2 <- SP[SP$cluster==2, c("pitcher", "IP.App", "FB.", "MPH", "DIFF", "AGG", "WHIFF.", "appearances")]

cluster2 <- cluster2[order(-cluster2$appearances),c("pitcher", "IP.App", "FB.", "MPH", "DIFF", "AGG", "WHIFF.")]
names(cluster2) <- c("Pitcher", "IP/App", "FB%", "MPH", "DIFF", "AGG", "WHIFF%")
print(xtable(head(cluster2,10),caption = "Top 10 Aggressively Average Pitchers (by appearances)", label="cluster2table"), include.rownames = FALSE)