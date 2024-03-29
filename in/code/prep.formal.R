###### prep-macro dataset
####################
source("in/code/functions.R") # helper functions

#formal <- read.csv("in/data-input/kammer-formal_utf.csv", sep=";", encoding = "UTF-8")

formal <- read.csv("in/data-input/kammer-formal_utf8.csv", sep=",", encoding = "UTF-8")

#if windows pc run this (because of German Umlaute Problem):

# formal$richter <- stri_replace_all_fixed(
#   formal$richter, 
#   c("ä", "ö", "ü", "Ä", "Ö", "Ü"), 
#   c("ae", "oe", "ue", "Ae", "Oe", "Ue"), 
#   vectorize_all = FALSE
# )


# gen start of judge terms
formal$start <- jahr.to.date(formal$jahr) #code start year of the term
formal$year <- as.numeric(format(formal$start, "%Y")) #extract year

# gen end of judge terms (if not specified)
formal <- formal[order(formal$senat, formal$kammer),]
formal$end <- as.Date(NA)

for (i in 1:nrow(formal)){
  if (formal$year[i+1]>=formal$year[i] & !is.na(formal$year[i+1]))
    formal$end[i] <- formal$start[i+1] # take next if next is not 1998
  else formal$end[i] <- as.Date(str_c("01/01/", formal$year[i]+1), "%d/%m/%Y") # else take 01/01/endyear+1 as end
}

#Now we have the beginning and the end of each Chamber constellation possible.

# back to nice order
formal <- formal[order(formal$start, formal$senat, formal$kammer),]


######################### define RoP - Gschäftsverteilung
# clean names
formal$richter <- clean.names(formal$richter)

# reihenfolge as list
rf <- lapply(str_split(formal$reihenfolge, ""), as.numeric)

#This is the crucial part: coding who is replacing whom from the other chambers:

### eintragen der ersetzer nach gv aus anderen Kammern
gv <- list()

for (i in 1:nrow(formal)){
  # get set of replacing kammern
  set <- formal[formal$start==formal$start[i] & formal$senat==formal$senat[i] &  formal$kammer!=formal$kammer[i],]
  # encode senate/kammer-specific replacement rules
  #For the first Senate:
  if(formal$senat[i]==1){
    if(formal$kammer[i]==1) gv[[i]] <- c(get.gv(3), get.gv(2)) #for the first Chamber, the replacement is from the 3. Chamber first and the the second chamber
    if(formal$kammer[i]==2) gv[[i]] <- c(get.gv(1), get.gv(3)) #for the second chamber, replacement from 1. Chamber then third
    if(formal$kammer[i]==3) gv[[i]] <- c(get.gv(2), get.gv(1)) #for the third chamber, replacement from 2. chamber then first
  } 
  #Now for the Second Senate:
  if(formal$senat[i]==2 & !any(set$kammer==4) & formal$kammer[i]!=4){
    if(formal$kammer[i]==1) gv[[i]] <- c(get.gv(2), get.gv(3)) #
    if(formal$kammer[i]==2) gv[[i]] <- c(get.gv(3), get.gv(1))
    if(formal$kammer[i]==3) gv[[i]] <- c(get.gv(1), get.gv(2))
  }
  #special case for some years with 4 chambers in senate 2
  if(formal$senat[i]==2 & (any(set$kammer==4)|formal$kammer[i]==4)){
    if(formal$kammer[i]==1) gv[[i]] <- c(get.gv(2), get.gv(3), get.gv(4))
    if(formal$kammer[i]==2) gv[[i]] <- c(get.gv(3), get.gv(4), get.gv(1))
    if(formal$kammer[i]==3) gv[[i]] <- c(get.gv(4), get.gv(1), get.gv(2))
    if(formal$kammer[i]==4) gv[[i]] <- c(get.gv(1), get.gv(2), get.gv(3))
  }
  
  #special case for some years with 4 chambers in senate 1
  if(formal$senat[i]==1 & (any(set$kammer==4)|formal$kammer[i]==4)){
    if(formal$kammer[i]==1) gv[[i]] <- c(get.gv(2), get.gv(3))
    if(formal$kammer[i]==2) gv[[i]] <- c(get.gv(3), get.gv(1))
    if(formal$kammer[i]==3) gv[[i]] <- c(get.gv(1), get.gv(2))
    if(formal$kammer[i]==4) gv[[i]] <- c(get.gv(1), get.gv(2), get.gv(3))
  }
  
  
  # delete selfreplacers
  gv[[i]] <- setdiff(unlist(gv[[i]]), unlist(richter.split(formal$richter[i])))
}

formal$gv <- list.collapse(gv)

# check: immer 5 mögliche Ersetzer (8 - 2 in the chamber - 1 dropping)
table(unlist(lapply(gv, length)))
# except: 1.1.99-11.1.99 - unterbesetzung- nur 7 richter
formal[which(unlist(lapply(gv, length))==4),]

# output: list of all richter in dataset
allr <- sort(unique(unlist(richter.split(formal$richter))))


#Now we have to merge the nominating parties to the judges:
####### get richter farben
#########################################
col <- read.csv("in/data-input/Liste_Richter_1_utf.csv", sep="^", encoding = "UTF-8")


# col$last_name_r <- stri_replace_all_fixed(
#   col$last_name_r, 
#   c("ä", "ö", "ü", "Ä", "Ö", "Ü"), 
#   c("ae", "oe", "ue", "Ae", "Oe", "Ue"), 
#   vectorize_all = FALSE
# )


# clean names

col$last_name_r <- str_trim(clean.names(col$last_name_r))
col$last_name_r <- str_trim(str_replace_all(col$last_name_r, "\\(|\\)| ", ""))
col$first_name_r <- str_trim(col$first_name_r)

col$party_nom <- factor(col$ticket_r)
levels(col$party_nom) <- c("parteilos", "SPD", "CDU", "FDP", "Grüne", "CSU")

# code binary color
col$red <- NA
col$red[col$party_nom%in%c("CDU", "FDP", "CSU")] <- 0
col$red[col$party_nom%in%c("SPD", "Grüne")] <- 1
col <- col[!is.na(col$red), c("last_name_r", "first_name_r", "party_nom", "red")]

# remove duplicate and irrelevant richter
col <- unique(col)
col <- col[col$last_name_r%in%allr,] # irrelevant previous judges
print(str_c("MISSING JUDGE COLOR: ", allr[!allr%in%col$last_name_r]))
print(str_c("nr of list1-judges have NA color: ", table(!is.na(col$red), exclude = NULL)[2]))

redr <- col$last_name_r[col$red==1]


# clean
rm(list=setdiff(ls(), c("allr", "redr", "formal", "col")))
