#!/usr/bin/env Rscript
setwd("~/Documents/mlb-hackathon/")

library(xtable)

SP <- read.csv("data/SP.csv")

cluster5 <- SP[SP$cluster==5, c("pitcher", "IP.App", "FB.", "MPH", "DIFF", "AGG", "WHIFF.", "appearances")]

cluster5 <- cluster5[order(-cluster5$appearances),c("pitcher", "IP.App", "FB.", "MPH", "DIFF", "AGG", "WHIFF.")]
names(cluster5) <- c("Pitcher", "IP/App", "FB%", "MPH", "DIFF", "AGG", "WHIFF%")
print(xtable(head(cluster5,10),caption = "Cluster 5 Pitchers", label="cluster5table"), include.rownames = FALSE)