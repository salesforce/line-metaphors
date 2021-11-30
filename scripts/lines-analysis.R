library('pracma')
library('dplyr')
library('ggplot2')
library('ggthemes')
library('jsonlite')

setwd("~/Documents/Research/Lines/line-metaphors")

lowerCI <- function(v) {
  mean(v) - sd(v)*1.96/sqrt(length(v))
}

upperCI <- function(v) {
  mean(v) + sd(v)*1.96/sqrt(length(v))
}

plotCIs <- function(dataFrame, x_variable, y_variable, xlabel, ylabel, zeroLine=NA) {
  p <- ggplot(dataFrame, aes(x=x_variable, fill=factor(x_variable), y=y_variable))
  
  if (!is.na(zeroLine)) {
    p <- p + geom_hline(yintercept=0, linetype=zeroLine)
  }
  
  p <- p +
    stat_summary(fun.min=lowerCI, fun.max=upperCI, geom="errorbar", aes(width=.1)) +
    stat_summary(fun=mean, geom="point", shape=18, size=3, show.legend = FALSE) + 
    labs(x = xlabel, y = ylabel)
  
  p + theme_minimal()
}

crossings <- read.csv('results/main-results-crossings.csv')

correct_crossings <- filter(crossings, numCrossings > 0)

plotCIs(correct_crossings, correct_crossings$style, correct_crossings$distance, 'style', 'distance')

# ANOVA just in case…
summary(aov(distance ~ style, correct_crossings))

#######
# Line correlations

results <- readLines(file('public/data/main-results.jsonl', open='r'))

j <- lapply(results, fromJSON)

id <- c()
stepID <- c()
metaphor <- c()
style <- c()
focus_intercept <- c()
focus_coeff <- c()
user_intercept <- c()
user_coeff <- c()
rsquared <- c()
termslope <- c()
for (i in 1:length(j)) {
    if (j[[i]]$part == 'B') {
        id <- append(id, j[[i]]$id)
        stepID <- append(stepID, j[[i]]$stepID)
        metaphor <- append(metaphor, j[[i]]$metaphor)
        style <- append(style, j[[i]]$style)

        df <- data.frame(j[[i]]$focusdata)
        linreg <- lm(y ~ x, df)
        focus_intercept <- append(focus_intercept, linreg$coefficients[1])
        focus_coeff <- append(focus_coeff, linreg$coefficients[2])

        df <- data.frame(j[[i]]$userdata)
        linreg <- lm(y ~ x, df)
        user_intercept <- append(user_intercept, linreg$coefficients[1])
        user_coeff <- append(user_coeff, linreg$coefficients[2])

        df <- data.frame(uy=j[[i]]$userdata$y, fy=j[[i]]$refdata$y)
        linreg <- lm(uy ~ fy, df)
        rsquared <- append(rsquared, summary(linreg)$r.squared)
        
        termslope_focus <- j[[i]]$focusdata$y[11]-j[[i]]$focusdata$y[10]
        termslope_user <- j[[i]]$userdata$y[11]-j[[i]]$userdata$y[10]
        termslope <- append(termslope, termslope_user/termslope_focus)
    }
}
df <- data.frame(id, stepID, metaphor, style, focus_intercept, focus_coeff, user_intercept, user_coeff, rsquared, termslope)

plotCIs(df, df$style, df$rsquared, 'Style', 'R-squared')
plotCIs(df, df$metaphor, df$rsquared, 'Metaphor', 'R-squared')

summary(aov(rsquared ~ style, df))
summary(aov(rsquared ~ metaphor, df))

plotCIs(df, df$style, df$termslope, 'Style', 'Terminal Slope Fraction')
plotCIs(df, df$metaphor, df$termslope, 'Metaphor', 'Terminal Slope Fraction')

summary(aov(termslope ~ style, df))
summary(aov(termslope ~ metaphor, df))

