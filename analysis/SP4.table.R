#!/usr/bin/env Rscript
setwd("~/Documents/mlb-hackathon/")

library(xtable)

SP <- read.csv("data/SP.csv")

cluster4 <- SP[SP$cluster==4, c("pitcher", "IP.App", "FB.", "MPH", "DIFF", "AGG", "WHIFF.", "appearances")]

cluster4 <- cluster4[order(-cluster4$appearances),c("pitcher", "IP.App", "FB.", "MPH", "DIFF", "AGG", "WHIFF.")]
names(cluster4) <- c("Pitcher", "IP/App", "FB%", "MPH", "DIFF", "AGG", "WHIFF%")
print(xtable(head(cluster4,10),caption = "Cluster 4 Pitchers", label="cluster4table"), include.rownames = FALSE)