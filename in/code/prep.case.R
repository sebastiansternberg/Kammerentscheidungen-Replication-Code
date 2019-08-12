###### prep case data set
#######################
source("in/code/functions.R") # helper functions

# I. check data consistency
# II. match RoP/gv to cases


# I. Check data
###############


case <- load("chamber_decisions.Rda")

#case1 <- read.table("in/data-input/judicialData_Sep16.txt", sep="\t", encoding = "UTF-8")
#names(case1) <- c("i", "az", "date", "senat", "kammer_cit", "kammer_txt", "richter_raw", "richter_txt", "richter_cit", "Anordnung", "link")


# NAMES AND NO OF JUDGES

  # consolidate richter (from cite)
  richter <- clean.names(case$richter_txt)
  richter[richter=="No names in the text"] <- clean.names(case$richter_cit)[richter=="No names in the text"]
  richter[richter=="None"] <- NA
  
  # no of richter
  nrichter <- unlist(lapply(richter.split(richter), length)) #for our analysis, only the decisions with 3 judges are relevant (8 are Senate decisions)
  
  # impute from raw for less than 3 richter
  allr_case <- unique(unlist(richter.split(richter)))
  fromraw <- str_match_all(case$richter_raw[nrichter<3], str_c(allr_case, collapse = "|"))
  fromraw <- unlist(lapply(fromraw, function(x) as.character(str_c(x, collapse = ", "))))
  richter[nrichter<3] <- fromraw
  
  case$richter=richter; rm(richter)
  
#   # BUG REPORT FOR BVerfG
#   for(i in 1:nrow(case)) case$okrichter[i] <- all(richter.split(clean.names(case$richter_txt[i]))[[1]]%in%richter.split(clean.names(case$richter_cit[i]))[[1]])
#   bug=case[case$okrichter==F, str_detect(names(case), "richter|link")]
#   write.csv(case[case$okrichter==F, str_detect(names(case), "richter|link")], "out/website_bugs/inkonsistenterichter.csv")
 

# DATE
 # case$date[case$date=="None"] <- NA # some missing in senate decisions

  #CHECK PASSED #case <- case[!is.na(case$date),]
  #if(any(is.na(case$date))==T) print("error: some dates missing")
  #case$date <- as.Date(case$date, "%d.%m.%Y")
  
  #case$date <- as.Date(case$date, "%d.%m.%Y")
  
# KAMMER NR

    case$kammer <- case$kammer_txt
    case$kammer[is.na(case$kammer_txt)] <- case$kammer_cit[is.na(case$kammer_txt)] #if missing in kammer text (in the header of the decision), replace with kammer cit (from the citations)
    #table(case$kammer, nrichter, exclude=NULL)
    #case$link[is.na(case$kammer) & nrichter==3]
    
    # BUG REPORT FOR BVG
    # write.csv(case$link[case$kammer_cit!=case$kammer_txt & !is.na(case$kammer_cit) & !is.na(case$kammer_txt)],
    #           "out/website_bugs/falschekammer.csv") # 10 typos on website citation - txt version is correct

# CHECK IF ALL RICHTER FOUND IN BOTH CASE AND MACRO DATA 
print(str_c("case richter not in allr: ", allr_case[!allr_case%in%allr]))


########## subset: keep only if date, kammer and richter specified
case <- case[!is.na(case$date) & !is.na(case$kammer) & !is.na(case$richter),]
str_c("Name check: ", table(unlist(lapply(richter.split(case$richter), length))==3)[1], " of ", nrow(case), " with 3 judges")



######## match cases und formale richterbesetzungen
###########################################################

out <- NULL
for (i in 1:nrow(formal)){
  s <- case[case$date >= formal$start[i] & case$date < formal$end[i] &
              case$senat==formal$senat[i] & case$kammer==formal$kammer[i],]
  # check richter and print errors
  nrichter <- unlist(lapply(richter.split(s$richter), length))
  if (any(nrichter!=3)) print(richter.split(s$richter)[nrichter!=3]) else
    if (nrow(s)==0) print(str_c("no cases found for row ", i, " in formal"))
  else {
    s.r <- data.frame(do.call(rbind, richter.split(s$richter)))
    names(s.r) <- c("r1", "r2", "r3")
    s.f <- data.frame(do.call(rbind, rep(richter.split(formal$richter[i]), nrow(s.r))))
    names(s.f) <- c("r1_f", "r2_f", "r3_f")
    s <- data.frame(s[,  !str_detect(names(s), "abt|richter")], s.r, s.f, gv=formal$gv[i])
    out <- rbind(out, s)
  }
}

# missing cases
missing <- case[case$az%in%setdiff(case$az, out$az),]
print(if(nrow(missing)==0)  "all cases matched" else str_c("case2formal: ", nrow(missing), " unmatched cases between ", min(missing$date), " and ", max(missing$date)))

# order innerhalb der kammern chronologisch [vorgängerzeile die zeitlich letzte entsch in der kammers]
out <- out[order(out$senat, out$kammer, out$date),]

# rr: richter real, rf: richter formal
rr <- apply(out[, str_detect(names(out), "r[1-3]$")], 2, function(x) str_trim(x))
rf <- apply(out[, str_detect(names(out), "r[1-3]_f$")], 2, function(x) str_trim(x))
gv <- str_trim(out$gv)

################### output
out <- out[, setdiff(names(out), c("i", "kammer_cit", "kammer_txt"))]
write.csv(out, "in/prepareddata/cleanedcasedataset.csv")

rm(list=setdiff(ls(), c("formal", "out", "col", "rr", "rf", "gv", "allr", "redr")))

