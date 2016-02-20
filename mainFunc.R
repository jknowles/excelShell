# Set up models

library(lme4)
library(merTools)

d <- expand.grid(fac1=LETTERS[1:5], grp=factor(1:10),
                 obs=1:100)
split <- sample(x = LETTERS[9:15], size = nrow(d), replace=TRUE)
d$y <- simulate(~fac1+(1|grp),family = gaussian,
                newdata=d,
                newparams=list(beta=c(2,1,3,4,7), theta=c(.25),
                               sigma = c(.23)))[[1]]
out <- split(d, split)
rm(split)
g1 <- lmerModList(formula = y~fac1+(1|grp), data=out)
g2 <- blmerModList(formula = y~fac1+(1|grp), data=out)

library(ggplot2)
mod1 <- lmer(sleep_total ~ bodywt + (1|vore/order), data=msleep)

library(broom)
tidy(mod1, effect = c("fixed", "ran_pars"))

mydf <- tidy(mod1, effect = c("fixed", "ran_pars"))
modStats <- as.data.frame(t(glance(mod1)))
modStats$term <- row.names(modStats)
as.data.frame(dplyr::bind_rows(mydf,modStats))

i <- "TEST"
fn <- paste0("export/", i, "_teachQualityData.xlsx")
write.xlsx(mydf, file = fn, row.names=FALSE, sheetName="Mod1")
write.xlsx(df[[2]][c(2:12)][df[[2]]$District == i,], file = fn, row.names=FALSE, sheetName="Non-White", append = TRUE)
write.xlsx(codebook, file = fn, row.names=FALSE, sheetName="Codebook", append = TRUE)





