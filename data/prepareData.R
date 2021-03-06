setwd('~/Documents/mlb-hackathon/')

# Load Packages
library(plyr)

# Load Datasets
data2013 <- read.csv('data/2013.csv')
data2014 <- read.csv('data/2014.csv')
data2015 <- read.csv('data/2015.csv')

all_data <- rbind(data2013, data2014, data2015)

all_data <- subset(all_data, !(all_data$pitchType %in% c("UN", "PO", "IN", "AB", "AS")))

#######################
## FEATURE ENGINEERING
#######################

# Innings Pitched per Appearance

# Create an Inning/Out variable
all_data$inningOuts = as.numeric(paste0(all_data$inning - 1, '.', all_data$outs))


# Need to create a function that determines IP
# Note: you need to pass the function a dataframe subsetted for a single pitcher and a single game.
# It's meant to be used with ddply like I do below
enter_exit_inning <- function(df, var){
  entrance <- min(df$inningOuts)
  
  # Did an out occur in the play in which you left? If so we need to add an out to your exit
  if(as.character("["(df$paResult, length(df$paResult))) %in% c("IP_OUT", "K", "FC", "DP", "TP", "SH", "SF", "NO_PLAY")){
    # Due to baseball doing the 7.2 for 2 of 3 outs 
    # we need to do this to account for the non-mathy nature of that system
    if(round(max(df$inningOuts) %% 1, 1) == 0.2){
      exit <- max(df$inningOuts) + 0.8
    } else {
      exit <- max(df$inningOuts) + 0.1
    }
  } else {
    exit <- max(df$inningOuts) 
  }
  
  if(var == "enter"){
    return(entrance)
  } else {
    return(exit)
  }
  
}

enters<- ddply(all_data, .(gameString, pitcher), enter_exit_inning, "enter")
names(enters) <- c("gameString", "pitcher", "enter")
exits <- ddply(all_data, .(gameString, pitcher), enter_exit_inning, "exit")
names(exits) <- c("gameString", "pitcher", "exit")
IP <- merge(enters, exits, by=c("gameString", "pitcher"))

# Finally calculate IP
innings_pitched <- function(enter_exit_vector){
  entrance <- enter_exit_vector[1]
  last_pitch <- enter_exit_vector[2]
  
  IP = 0
  if(round(entrance %% 1, 1) == 0.1){
    IP = IP + 0.2
    entrance = entrance + 0.2
  } else if(round(entrance %% 1, 1) == 0.2){
    IP = IP + 0.1
    entrance = entrance + 0.8
  }
  
  return(IP + last_pitch - entrance)
}


IP$IP <- apply(IP[, c("enter", "exit")], 1, innings_pitched)
IP$pos <- ifelse(IP$enter == 0.0, "SP", "RP")

# Merge position into all data
all_data <- merge(all_data, IP[, c("gameString", "pitcher", "pos")])


# Write the IP/APP variable to the main dataframe
mainData <- aggregate(IP$IP, by=list(IP$pitcher, IP$pos), mean, na.rm=TRUE)
names(mainData) <- c("pitcher", "pos", "IP/App")
app <- ddply(IP, .(pitcher, pos), summarize, appearances=length(unique(gameString)))
mainData <- merge(mainData, app, by=c("pitcher", "pos"))



# Fastball Percentage

# Function to  find fastball percentage, little more straightforward
fastball_pct <- function(df){
  fastballs <- nrow(subset(df[df$pitchType %in% c("FA", "FT", "FF", "FC", "SI"), ]))
  pitches <- nrow(subset(df))
  
  return (round((fastballs / pitches), 3))
  
}

# Fastball percentage per game
fastballs_per_game <- ddply(all_data, .(gameString, pitcher), fastball_pct)

# Bring in position to aggregate
fastballs_per_game <- merge(fastballs_per_game, IP[,c("gameString", "pitcher", "pos")])
fastball_agg <- aggregate(fastballs_per_game$V1, by=list(fastballs_per_game$pitcher, fastballs_per_game$pos), mean, na.rm=TRUE)
names(fastball_agg) <- c("pitcher", "pos", "FB%")

#add to mainData
mainData <- merge(mainData, fastball_agg, by=c("pitcher", "pos"))


# Average MPH (of your fastball)
fastball_velocity <- function(df){
  fastballs <- subset(df[df$pitchType %in% c("FA", "FT", "FF", "FC", "SI"), ])
  
  return (mean(fastballs$releaseVelocity, na.rm=TRUE))
  
}

average_mph <- ddply(all_data, .(gameString, pitcher), fastball_velocity)
average_mph <- merge(average_mph, IP[,c("gameString", "pitcher", "pos")])
mph_agg <- aggregate(average_mph$V1, by=list(average_mph$pitcher, average_mph$pos), mean, na.rm=TRUE)
names(mph_agg) <- c("pitcher", "pos", "MPH")

mainData <- merge(mainData, mph_agg, by=c("pitcher", "pos"))


# Average MPH (of your fastball)
offspeed_velocity <- function(df){
  offspeeds <- subset(df[!(df$pitchType %in% c("FA", "FT", "FF", "FC", "SI")), ])
  
  return (mean(offspeeds$releaseVelocity))
  
}

offspeed_mph <- ddply(all_data, .(gameString, pitcher), offspeed_velocity)
offspeed_mph <- merge(offspeed_mph, IP[,c("gameString", "pitcher", "pos")])
offspeed_agg <- aggregate(offspeed_mph$V1, by=list(offspeed_mph$pitcher, offspeed_mph$pos), mean, na.rm=TRUE)
names(offspeed_agg) <- c("pitcher", "pos", "MPH")

diff_agg = merge(mph_agg, offspeed_agg, by=c("pitcher", "pos"))
names(diff_agg) <- c("pitcher", "pos", "FB", "OFF")

diff_agg$DIFF <- diff_agg$FB - diff_agg$OFF
diff_agg[is.na(diff_agg)] <- 0

mainData <- merge(mainData, diff_agg[,c("pitcher", "pos", "DIFF")], by=c("pitcher", "pos"))


# Aggression (straight down the middle or edges)

#determine the midpoint of the y direction (x centered on 0)
all_data$midy <- (all_data$szt - all_data$szb)/2 + all_data$szb

all_data$downMiddle <- 0
mask = all_data$px <=  (2*2.94 / 12) & 
  all_data$px >= (-2*2.94 / 12) & 
  all_data$pz <= all_data$midy + (2*2.94 / 12) & 
  all_data$pz >= all_data$midy - (2*2.94 / 12)

all_data$downMiddle <- ifelse(mask, 1, 0)

aggression <- aggregate(all_data$downMiddle, by=list(all_data$gameString, all_data$pitcher), mean, na.rm=TRUE)
names(aggression) <- c("gameString", "pitcher", "Aggression")
aggression <- merge(aggression, IP[,c("gameString", "pitcher", "pos")])
aggression_agg <- aggregate(aggression$Aggression, by=list(aggression$pitcher, aggression$pos), mean, na.rm=TRUE)
names(aggression_agg) <- c("pitcher", "pos", "AGG")

# Add to mainData
mainData <- merge(mainData, aggression_agg, by=c("pitcher", "pos"))


# Swinging Strike Pct
swing_and_miss <- function(df){
  swinging_strikes <- nrow(subset(df[df$pitchResult %in% c("SS", "MB"), ]))
  swings <- nrow(subset(df[df$pitchResult %in% c("SS", "F", "FT", "FB", "IP"), ]))
  
  return (round((swinging_strikes / swings), 3))
  
}

whiffs <- ddply(all_data, .(gameString, pitcher), swing_and_miss)
whiffs <- merge(whiffs, IP[,c("gameString", "pitcher", "pos")])
whiffs_agg <- aggregate(whiffs$V1, by=list(whiffs$pitcher, whiffs$pos), mean, na.rm=TRUE)
names(whiffs_agg) <- c("pitcher", "pos", "WHIFF%")

mainData <- merge(mainData, whiffs_agg, by=c("pitcher", "pos"))


mainData <- mainData[, c("pitcher", "pos", "IP/App", "FB%", "MPH", "DIFF", "AGG", "WHIFF%", "appearances")]

write.table(mainData, file="data/mainData.csv", sep=",", row.names=FALSE)
