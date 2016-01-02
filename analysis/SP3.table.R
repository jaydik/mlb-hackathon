#!/usr/bin/env Rscript
setwd("~/Documents/mlb-hackathon/")

library(xtable)

SP <- read.csv("data/SP.csv")

cluster3 <- SP[SP$cluster==3, c("pitcher", "IP.App", "FB.", "MPH", "DIFF", "AGG", "WHIFF.", "appearances")]

cluster3 <- cluster3[order(-cluster3$appearances),c("pitcher", "IP.App", "FB.", "MPH", "DIFF", "AGG", "WHIFF.")]
names(cluster3) <- c("Pitcher", "IP/App", "FB%", "MPH", "DIFF", "AGG", "WHIFF%")
print(xtable(head(cluster3,10),caption = "Cluster 3 Pitchers", label="cluster3table"), include.rownames = FALSE)