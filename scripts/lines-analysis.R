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

plotCIs <- function(dataFrame, x_variable, y_variable, xlabel, ylabel, levels=NA, zeroLine=NA) {

	if (!is.na(levels)) {
		p <- ggplot(dataFrame, aes(x=factor(x_variable, levels=levels), y=y_variable))
	} else {
		p <- ggplot(dataFrame, aes(x=x_variable, y=y_variable))
	}	

	if (!is.na(zeroLine)) {
		p <- p + geom_hline(yintercept=0, linetype=zeroLine)
	}
	
	p <- p +
		stat_summary(fun.min=lowerCI, fun.max=upperCI, fun=mean, geom="pointrange") +
		labs(x = xlabel, y = ylabel, title='')
	
	p + theme_minimal()
}

PAPERIMGPATH <- "img/"

savepdf <- function(filename, width, height) {
	ggsave(paste(PAPERIMGPATH, filename, sep=""), device="pdf", width=width, height=height)	
}

crossings <- read.csv('results/main-results-crossings.csv')

correct_crossings <- filter(crossings, numCrossings > 0)
correct_crossings %>% group_by(style) %>% summarize(absErr = mean(absDistance))

plotCIs(correct_crossings, correct_crossings$style, correct_crossings$absDistance, 'Line Design', 'Horizontal Distance')
savepdf('crossing-precision.pdf', 6, 4)

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
focus_angle <- c()

user_intercept <- c()
user_coeff <- c()
user_angle <- c()
rsquared <- c()
termslope <- c()
focus_rmse <- c()
user_rmse <- c()
crossing_x <- c()
updown <- c()

total_pred <- c()
total_pred['crossing'] <- 0
total_pred['converging'] <- 0
total_pred['diverging'] <- 0

correct <- c()
correct['crossing'] <- 0
correct['converging'] <- 0
correct['diverging'] <- 0
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
        focus_angle <- append(focus_angle, atan(linreg$coefficients[2]))
        focus_rmse <- append(focus_rmse, sqrt(c(crossprod(linreg$residuals))/length(linreg$residuals)))
        
        df <- data.frame(j[[i]]$userdata)
        linreg <- lm(y ~ x, df)
        a <- linreg$coefficients[2]
        c <- linreg$coefficients[1]
        user_intercept <- append(user_intercept, linreg$coefficients[1])
        user_coeff <- append(user_coeff, linreg$coefficients[2])
        user_angle <- append(user_angle, atan(linreg$coefficients[2]))
        user_rmse <- append(user_rmse, sqrt(c(crossprod(linreg$residuals))/length(linreg$residuals)))

        # crossing point of target and recreated regression lines
        df <- data.frame(j[[i]]$refdata)
        linreg <- lm(y ~ x, df)
        b <- linreg$coefficients[2]
        d <- linreg$coefficients[1]
        crossing <- (d-c)/(a-b)
        crossing_x <- append(crossing_x, crossing)

        if (crossing > 100) {
        	total_pred['converging'] <- total_pred['converging'] + 1
        	if (j[[i]]$metaphor == 'converge') {
        		correct['converging'] <- correct['converging'] + 1
        	}
        } else if (crossing < 0) {
        	total_pred['diverging'] <- total_pred['diverging'] + 1
        	if (j[[i]]$metaphor == 'diverge') {
        		correct['diverging'] <- correct['diverging'] + 1
        	}
        } else { # crossing
        	total_pred['crossing'] <- total_pred['crossing'] + 1
        	if (j[[i]]$metaphor == 'cross') {
        		correct['crossing'] <- correct['crossing'] + 1
        	}
        }
        
        df <- data.frame(uy=j[[i]]$userdata$y, fy=j[[i]]$focusdata$y)
        linreg <- lm(uy ~ fy, df)
        rsquared <- append(rsquared, summary(linreg)$r.squared)
        
        termslope_focus <- atan2(j[[i]]$focusdata$y[11]-j[[i]]$focusdata$y[10], 100/11)
        termslope_user <- atan2(j[[i]]$userdata$y[11]-j[[i]]$userdata$y[10], 100/11)
#        termslope <- append(termslope, termslope_user/termslope_focus)
        termslope <- append(termslope, termslope_user-termslope_focus)
        
        updown <- append(updown, ifelse(j[[i]]$metaphor=='diverge', 'down', 'up'))
    }
}
df <- data.frame(id, stepID, metaphor, style, focus_intercept, focus_coeff,
					user_intercept, user_coeff, coeff_rel=user_coeff/focus_coeff,
				    focus_angle, user_angle,
					global_angle_diff=user_angle-focus_angle, global_angle_diff_abs=abs(user_angle-focus_angle),
					rsquared, termslope, crossing_x, user_rmse, focus_rmse, updown,
					relative_rmse=user_rmse/focus_rmse)

plotCIs(df, df$style, df$rsquared, 'Line Design', 'R² of Target x Reconstructed Points')
# plotCIs(df, df$metaphor, df$rsquared, 'Metaphor', 'R² of Target x Reconstructed Points')
# ggplot(df) + geom_line(aes(x=metaphor, y=rsquared, color=style), position=position_dodge(width=1))
savepdf('r-squared-by-style.pdf', 6, 4)

summary(aov(rsquared ~ style, df)) # F(2, 537) = 3.31, p = 0.037
summary(aov(rsquared ~ metaphor, df))

# Terminal Slope
plotCIs(df, df$style, df$termslope, 'Line Design', 'Terminal Slope Fraction', levels=c('plain', 'arrow', 'animate'))
plotCIs(df, df$metaphor, df$termslope, 'Chart Feature', 'Terminal Slope Difference', zeroLine='dotted')
savepdf('terminal-slope-by-style.pdf', 6, 4)

plotCIs(df, df$updown, df$termslope, 'Chart Feature', 'Terminal Slope Difference')
ggplot(df) + geom_line(aes(x=style, y=termslope, color=updown), position=position_dodge(width=1))

summary(aov(termslope ~ style, df)) # F(2, 537) = 8.216, p < 0.01
summary(aov(termslope ~ metaphor, df)) # F(2, 537) = 3.106, p = 0.456

# Sum of residuals between the two
plotCIs(df, df$style, df$relative_rmse, 'Line Design', 'Relative RMSE', levels=c('plain', 'arrow', 'animate'))
plotCIs(df, df$metaphor, df$relative_rmse, 'Metaphor', 'Relative RMSE')

# Global slopes for diverge vs. converge
plotCIs(df, df$style, df$coeff_rel, 'Line Design', 'Slopes Relative', levels=c('plain', 'arrow', 'animate'))
plotCIs(df, df$metaphor, df$coeff_rel, 'Chart Feature', 'Difference between line slopes')
savepdf('global-slopes-by-style.pdf', 6, 4)

summary(aov(coeff_rel ~ metaphor, df)) # F(2, 537) = 6.574, p < 0.01

# Global angle
plotCIs(df, df$style, df$global_angle_diff, 'Line Design', 'Slopes Relative', levels=c('plain', 'arrow', 'animate'))
plotCIs(df, df$metaphor, df$global_angle_diff, 'Chart Feature', 'Global Line Slope Difference, Signed', zeroLine='dotted')
savepdf('global-angles-by-metaphor.pdf', 6, 4)

summary(aov(global_angle_diff ~ metaphor, df)) 

plotCIs(df, df$style, df$global_angle_diff_abs, 'Line Design', 'Slopes Relative', levels=c('plain', 'arrow', 'animate'))
plotCIs(df, df$metaphor, df$global_angle_diff_abs, 'Chart Feature', 'Global Line Slope Difference, Unsigned',)
savepdf('global-abs-angles-by-metaphor.pdf', 6, 4)

summary(aov(global_angle_diff_abs ~ metaphor, df)) # F(2, 536) = 5.666, p < 0.05


# Compute crossings to see if they're in the [0..100] range
plotCIs(df, df$style, df$crossing_x, 'Style', 'User vs. Reference Crossing X')
plotCIs(df, df$metaphor, df$crossing_x, 'Chart Feature', 'User vs. Reference Crossing X')
ggplot(df) + geom_line(aes(x=style, y=crossing_x, color=metaphor), position=position_dodge(width=1))

# did they capture the feature
# crossing based on crossings calc, converge/diverge by regression slope
# Classify by slope positive or negative
# Binary: sign correct, RMSE of slopes
# Precision and recall for matching the metaphor
# Global RSS/RMSE for error

# Recall: correct/total
correct/180
# Based on actual crossings calculation: 154/180 correct
# Precision:
correct/total_pred

# Global slopes as angles, relative and binary for converge and diverge
converges <- df %>% filter(metaphor == 'converge')
nrow(filter(converges, (user_coeff > 0) && (crossing_x > 100)))
conv <- converges %>% filter(user_coeff > 0) %>% filter(crossing_x > 100)

nrow(filter(converges, converges$crossing_x > 100))
mean(conv$user_angle-conv$focus_angle)

diverges <- df %>% filter(metaphor == 'diverge')
div <- diverges %>% filter(user_coeff < 0) %>% filter(crossing_x < 0)

nrow(filter(diverges, user_coeff < 0))/180
mean(div$user_angle-div$focus_angle)

