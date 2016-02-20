# Prep file for export to districts~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Load packages
library(plyr)
library(rJava)
library(xlsx)

# Define districts of interest
nineDist <- c("Milwaukee", "Racine Unified", "Green Bay Area Public", 
              "Madison Metropolitan", "West Allis-West Milwaukee", 
              "Waukesha", "Janesville", "Kenosha", "Beloit")

# Load and merge files~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
tmp <- read.csv("FRLandEmergInequalitySchools.csv", stringsAsFactors = FALSE)
tmp2 <- read.csv("FRLandExperienceInequalitySchools.csv", stringsAsFactors = FALSE)
tmp3 <- read.csv("NonwhiteandEmergInequalitySchools.csv", stringsAsFactors = FALSE)
tmp4 <- read.csv("NonwhiteandExperienceInequalitySchools.csv", stringsAsFactors = FALSE)

tmp_FRL <- merge(tmp, tmp2, by = c("SCHOOL_YEAR", "DIST_NAME", "SCH_NAME"))
tmp_nonWhite <- merge(tmp3, tmp4, by = c("SCHOOL_YEAR", "DIST_NAME", "SCH_NAME"))

# Drop duplicate variables~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
tmp_FRL$FRL_PER.y <- NULL
tmp_FRL$PUPIL_COUNT.y <- NULL
tmp_FRL$Assignments.y <- NULL

tmp_nonWhite$nonWhitePer.y <- NULL
tmp_nonWhite$PUPIL_COUNT.y <- NULL
tmp_nonWhite$Assignments.y <- NULL

# Create list of data frames for looping~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
df <- list(tmp_FRL, tmp_nonWhite)

# Reorder variables~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
for(i in 1:2){
  df[[i]] <- df[[i]][c(2, 1, 3, 5, 4, 7, 9, 6, 8, 12, 10, 11)]
}

# Change rates to zero when zero emergency/low experience teachers present in a school
for(i in 1:2){
  df[[i]]$emergRate[df[[i]]$N_EMERG_TEACHERS==0] <- 0
  df[[i]]$experRate[df[[i]]$N_INEXP_TEACHERS==0] <- 0
}

# Round numbers to tenths ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
for(i in 1:2){
  df[[i]][c(5, 8, 11)] <- round(df[[i]][c(5, 8, 11)], 1)
}

# Rename variables
for(i in 1:2){
  df[[i]] <- rename(df[[i]], c("SCHOOL_YEAR"="School Year", "DIST_NAME"="District", "SCH_NAME"="School", 
                               "PUPIL_COUNT.x"="Nmb. Students", 
                               "emergRate"="Emergency Credential Rate", "Assignments.x"="Nmb. Teachers", 
                               "highInequityFlag.x"="High Emergency Credential Inequality",
                               "N_EMERG_TEACHERS"="Nmb. Emergency Credentialed Teachers", 
                               "experRate"="Inexperienced Teacher Rate", 
                               "highInequityFlag.y"="High Experience Inequality", 
                               "N_INEXP_TEACHERS"="Nmb. Inexperienced Teachers"))
}
df[[1]] <- rename(df[[1]], c("FRL_PER.x"="Pct. FRL"))
df[[2]] <- rename(df[[2]], c("nonWhitePer.x"="Pct. Non-White"))

# Create codebook~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
vars <- names(df[[1]][c(2:12)])
vars[6:12] <- vars[5:11]
vars[5] <- "Pct. Non-White"

school_year <- "School year."
school <- "School name."
nmb <- "Number of students."
pct_frl <- "Percentage of students who receive free and/or reduced-price lunch."
pct_non <- "Percentage of students who are non-White."
nmb_teach <- "Number of teachers."
nmb_emerg <- "Number of of teachers with an emergency license and/or permit."
emerg_rate <- "Percentage of teachers with an emergency license and/or permit."
emerg_ineq <- "School identified as contributing significantly to inequality in the distribution of emergency credentialed teachers across the state, as identified in the State Educator Equity Plan."
nmb_inex <- "Number of teachers with three or less years of experience in their current subjects."
inex_rate <- "Percentage of teachers with three or less years of experience in their current subjects."
inex_ineq <- "School identified as contributing significantly to inequality in the distribution of inexperienced teachers across the state, as identified in the State Educator Equity Plan."


definitions <- c(school_year, school, nmb, pct_frl, pct_non, nmb_teach, nmb_emerg, emerg_rate, emerg_ineq,
                 nmb_inex, inex_rate, inex_ineq)
  
codebook <- data.frame(vars, definitions)
codebook <- rename(codebook, c("vars"="Variables", "definitions"="Explanation"))

# Export data ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
for(i in nineDist){
  fn <- paste0("export/", i, "_teachQualityData.xlsx")
  write.xlsx(df[[1]][c(2:12)][df[[1]]$District == i,], file = fn, row.names=FALSE, sheetName="FRL")
  write.xlsx(df[[2]][c(2:12)][df[[2]]$District == i,], file = fn, row.names=FALSE, sheetName="Non-White", append = TRUE)
  write.xlsx(codebook, file = fn, row.names=FALSE, sheetName="Codebook", append = TRUE)
}
