packages <- c("foreign", "stringr", "ggplot2", "knitr", "stargazer", "ggplot2", "xtable", "lubridate",
              "Hmisc", "tables", "stringi", "strex")
for (p in packages) {
  if (p %in% installed.packages()[,1]) require(p, character.only=T)
  else {
    install.packages(p)
    library(p, character.only=T)
  }
}
rm(list=ls())
options(stringsAsFactors = F)
options(warn=2)

###########################

# prepare RoP (besetzungen) and judge-spec data
source("in/code/prep.formal.R")

# prepare case data
source("in/code/prep.case.R")

# code variables 
source("in/code/code_vars.R")

# The analyses is in a separate file not linked here.


