# Load packages
library(plyr)
library(lattice)
library(ggplot2)

# Load Data
data2013 <- read.csv('data/2013.csv')

# Group pitchers into RP/SP, get the first inning they appeared in the game
first_app <- ddply(data2013, .(gameString, pitcher), "[", 1, "inning")
last_app <- ddply(data2013, .(gameString, pitcher), "]", 1, "inning")
data2013$inningOuts = paste0(data2013$inning - 1, '.', data2013$outs)
pitches_per_game <- ddply(data2013, .(gameString, pitcher), nrow)
first_app$pos <- ifelse(first_app$`[` == 1, "SP", "RP")
first_app <- merge(first_app, pitches_per_game, by=c("gameString", "pitcher"))
appearances <- ddply(first_app, .(pitcher, pos), summarize, appearances=length(unique(gameString)))
first_app <- merge(first_app, appearances, by=c("pitcher", "pos"))

names(first_app) <- c("pitcher",  "pos", "gameString", "firstInning", "pitchesThrown", "appearances")


joined <- merge(data2013, first_app, by=c("gameString", "pitcher"))


# Plot density plots of SP vs RP mph
densityplot(~releaseVelocity, 
            data=joined, 
            groups=pos, 
            plot.points=FALSE, 
            auto.key=TRUE)

# Plot pitches thrown SP vs RP
densityplot(~pitchesThrown, 
            data=joined, 
            groups=pos, 
            plot.points=FALSE, 
            auto.key=TRUE)

# Plot pitches thrown vs average Velo
pitch_velo <- ddply(joined[joined$appearances>= 10, ], 
                    .(pitcher, pos),
                    summarize,
                    mean_velo = mean(releaseVelocity, na.rm = TRUE), 
                    mean_pitches=mean(pitchesThrown))


pitch_velo_plot <- ggplot(pitch_velo, aes(x=mean_velo, y=mean_pitches, color=pos)) + geom_point()


# Find fastball percentage
fastball_pct <- function(df){
  fastballs <- nrow(subset(df[df$pitchType %in% c("FA", "FT", "FF", "FC", "SI"), ]))
  pitches <- nrow(subset(df))

  return (fastballs / pitches)
  
}


fastballs_per_game <- ddply(data2013, .(gameString, pitcher), fastball_pct)



##########################
## These will be in 
## the final script
##########################
data2013$inningOuts = paste0(data2013$inning - 1, '.', data2013$outs)
test_df <- ddply(data2013, .(gameString, pitcher), summarize, leftGame = max(inningOuts), startedGame = min(inningOuts))