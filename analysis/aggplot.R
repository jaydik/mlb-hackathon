library(lattice)

# This will be nice for later in the demonstrations

all_data <- read.csv('data/2015-WS.csv')

all_data$midy <- (all_data$szt - all_data$szb)/2 + all_data$szb

all_data$downMiddle <- 0
mask = all_data$px <=  (2*2.94 / 12) & 
  all_data$px >= (-2*2.94 / 12) & 
  all_data$pz <= all_data$midy + (2*2.94 / 12) & 
  all_data$pz >= all_data$midy - (2*2.94 / 12)

all_data$downMiddle <- ifelse(mask, 1, 0)

all_data$midy <- (all_data$szt - all_data$szb)/2 + all_data$szb


botKzone <- 1.6
inKzone <- -.95
outKzone <- 0.95
topKzone <- 3.5


print(xyplot(pz~px, data=all_data[all_data$downMiddle == 1,], 
       aspect="iso", 
       xlim=c(-2.2, 2.2), 
       ylim=c(0,5), 
       panel=function(...){
         panel.rect(inKzone, 
                    botKzone, 
                    outKzone, 
                    topKzone, 
                    border="black", lty=3)
         panel.xyplot(...) }))