#!/usr/bin/env Rscript
setwd("~/Documents/mlb-hackathon/")

library(xtable)

SP <- read.csv("data/SP.csv")

cluster1 <- SP[SP$cluster==1, c("pitcher", "IP.App", "FB.", "MPH", "DIFF", "AGG", "WHIFF.", "appearances")]

cluster1 <- cluster1[order(-cluster1$appearances),c("pitcher", "IP.App", "FB.", "MPH", "DIFF", "AGG", "WHIFF.")]
names(cluster1) <- c("Pitcher", "IP/App", "FB%", "MPH", "DIFF", "AGG", "WHIFF%")
print(xtable(head(cluster1,10),caption = "Cluster 1 Pitchers", label="cluster1table"), include.rownames = FALSE)