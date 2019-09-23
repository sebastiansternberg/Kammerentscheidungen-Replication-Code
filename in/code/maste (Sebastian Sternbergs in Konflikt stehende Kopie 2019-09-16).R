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

#Before running: if you use a windows pc, there might be issues with the German Umlaute. In the respective
#Code snippets, you must take care of them by converting them to ue, ae etc. using the code part which is
#currently commented out. All UNIX systems (LINUX, MAC OS work fine). 


# prepare RoP (besetzungen) and judge-spec data
source("in/code/prep.formal.R")

# prepare case data
source("in/code/prep.case.R")

# code variables 
source("in/code/code_vars.R")



