setwd('~/Documents/mlb-hackathon/')

# Load Packages
library(plyr)

# Load Datasets
# data2013 <- read.csv('data/2013.csv')
# data2014 <- read.csv('data/2014.csv')
# data2015 <- read.csv('data/2015.csv')
# 
# all_data <- rbind(data2013, data2014, data2015)
all_data <- read.csv('data/2015-WS.csv')

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


# Write the IP/APP variable to the main dataframe
mainData <- aggregate(IP$IP, by=list(IP$pitcher, IP$pos), mean)


# Fastball Percentage

# Function to  find fastball percentage, little more straightforward
fastball_pct <- function(df){
  fastballs <- nrow(subset(df[df$pitchType %in% c("FA", "FT", "FF", "FC", "SI"), ]))
  pitches <- nrow(subset(df))
  
  return (round((fastballs / pitches), 3))
  
}

# Fastball percentage per game
fastballs_per_game <- ddply(all_data, .(gameString, pitcher), fastball_pct)

