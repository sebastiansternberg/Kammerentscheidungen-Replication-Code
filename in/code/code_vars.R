###### VARIABLES AND OUTPUT
###############################
source("in/code/functions.R") # helper functions

# convert to by case lists
real <- as.list(data.frame(t(rr)))
formal <- as.list(data.frame(t(rf)))
gv <- as.list(data.frame(t(gv)))


################# define in and out sets
wechsel <- ersetzt <- ersatz <- rest <- list()
real_c <- formal_c <- ersetzt_c <- ersatz_c <- rest_c <- list()

for (i in 1:length(real)){
  # color of sets: 0-3
  real_c[[i]] <- sum(is.red(real[[i]])) #which of the judges in the real chamber are red?
  formal_c[[i]] <- sum(is.red(formal[[i]])) #which of the judges in the chamber according to RoP are red?
  
  # wechsel and set help variables
  wechsel[[i]] <- as.numeric(!setequal(real[[i]], formal[[i]])) #how many changes
  ersetzt[[i]] <- zero.as.NA(setdiff(formal[[i]], real[[i]])) #who is replacing whom?
    ersetzt_c[[i]] <- is.red(ersetzt[[i]]) #is it a red judge who is to be replaced?
  ersatz[[i]] <- zero.as.NA(setdiff(real[[i]], formal[[i]])) 
    ersatz_c[[i]] <- is.red(ersatz[[i]]) #is it a red judge who is replacing?
  rest[[i]] <- zero.as.NA(setdiff(real[[i]], ersatz[[i]])) #which are the remaining judges of that chamber?
    rest_c[[i]] <- is.red(rest[[i]]) #is one of the remaining a red judge?
}


############# daybyday abwesenheitsliste

# richter zählt so lang als nicht verfügbar bis er wieder nachweislich da ist
alldays <- seq(min(out$date), max(out$date), by=1)

abw1 <- abw2 <- list()
store1 <- store2 <- NULL
for (i in 1:length(alldays)){
  update1 <- unique(as.character(unlist(real[which(out$date==alldays[i] & out$senat==1)]))) # wer war nachweislich anwesend
  update2 <- unique(as.character(unlist(real[which(out$date==alldays[i] & out$senat==2)]))) #same for the second senate
  tmp1 <- zero.as.NA(unlist(ersetzt[which(out$date==alldays[i] & out$senat==1)])) # wer war an Tag nachweislich abwesend?
  tmp2 <- zero.as.NA(unlist(ersetzt[which(out$date==alldays[i] & out$senat==2)])) 
  
  store1 <- c(store1, tmp1[!is.na(tmp1)]) # neue abwesende in store container rein
  store2 <- c(store2, tmp2[!is.na(tmp2)])
  store1 <- setdiff(store1, update1) # aus store löschen wenn nachweislich anwesend (!!ausgeschiedene Richter bleiben drin - aber kein Problem)
  store2 <- setdiff(store2, update2)
  abw1[[i]] <- store1
  abw2[[i]] <- store2
}

### abwesende richter aus gv löschen
for (i in 1:length(real)){
  if(out$senat[i]==1) tmp <- abw1[[which(alldays==out$date[i])]] else tmp <- abw2[[which(alldays==out$date[i])]]
  gv[[i]] <- setdiff(unlist(richter.split(gv[[i]])), tmp)
}
rm(abw1, abw2, store1, store2, update1, update2, tmp1, tmp2)


# test: öfter weniger als 5 mögliche Ersetzer
table(unlist(lapply(gv, length)))

#### SPECIAL CASE: both BROß and DiFabio are gv1 replacements for Winter in 2000, senat 2 ####################
##########################################################################################################

# replace richternames in ersatz und gv
for (i in 1:length(ersetzt)){
  if("Winter"%in%ersetzt[[i]] & format(out$date[[i]],"%Y")=="2000"){
    ersatz[[i]] <- str_replace_all(ersatz[[i]], "Broß|DiFabio", "BroßDiFabio")
    gv[[i]] <- str_replace_all(gv[[i]], "Broß|DiFabio", "BroßDiFabio")
      # 2. vorkommen in gv reihenfolge löschen
      gv[[i]] <- gv[[i]][-which(gv[[i]]=="BroßDiFabio")[2]]
  }
} 
     
##################### id ausfallsepidsoden
# delete duplicates #########################

replace <- list(); replace[[1]] <- NA
for(i in 2:length(ersatz)){
  # wenn 2 oder 4 R doppelt in vorheriger row, diese in replace schreiben
  dupl1 <- ersatz[[i]][which(ersatz[[i]]%in%ersatz[[i-1]])]
  dupl2 <- ersetzt[[i]][which(ersetzt[[i]]%in%ersetzt[[i-1]])]
  dupl <- c(dupl1, dupl2)
  # if even number of duplicates, write in replace list
  if (length(dupl) > 0 & length(dupl)%%2==0) replace[[i]] <- c(ersatz[[i]][ersatz[[i]]%in%dupl1], ersetzt[[i]][ersetzt[[i]]%in%dupl2])
  else replace[[i]] <- NA
}

## indicate drop=T bei leeren zeilen, nach herauslöschen der dopplungen

# modification an kopien von ersatz und ersetzt
ersatz_mod <- ersatz
ersetzt_mod <- ersetzt

drop <- drop_mod <- rep(F, nrow(out))
for(i in 1:length(drop)){
  # delete die in replace genannten dopplungen in ersatz|ersetzt
  ersatz_mod[[i]] <- ersatz[[i]][!ersatz[[i]]%in%replace[[i]]]
  if(length(ersatz_mod[[i]])==0) ersatz_mod[[i]] <- NA
  ersetzt_mod[[i]] <- ersetzt[[i]][!ersetzt[[i]]%in%replace[[i]]]
  if(length(ersetzt_mod[[i]])==0) ersetzt_mod[[i]] <- NA
  # drop NA aus beiden versionen
  if(all(is.na(ersatz[[i]])) & all(is.na(ersetzt[[i]]))) drop[i] <- T
  if(all(is.na(ersatz_mod[[i]])) & all(is.na(ersetzt_mod[[i]]))) drop_mod[i] <- T
  #if(length(ersatz[[i]])==0 & length(ersetzt[[i]])==0) drop[i] <- T
}

# checking
check <- cbind(list.collapse(ersetzt), list.collapse(ersatz), list.collapse(ersetzt_mod), list.collapse(ersatz_mod), unlist(drop), unlist(drop_mod), list.collapse(replace))

#################### dv und critical cases
#################################################

c_nach_gversatz <- whichgv <- gv_konform <- crit <- gv_mod <- list()

for (i in 1:length(real)){
  # ersatz nach which GV
  if (!all(is.na(c(ersatz_mod[[i]], ersetzt_mod[[i]])))){
    ## check if same num of ersatz|ersetzt
    if(length(ersatz_mod[[i]])!=length(ersetzt_mod[[i]])) print(str_c("row ", i, " uneven number"))
    # kritische Fälle
    rest[[i]] <- setdiff(real[[i]], ersatz_mod[[i]])
    gv_mod[[i]] <- setdiff(gv[[i]], rest[[i]])
    # counterfactual gv-konform komposition
    gv_konform[[i]] <- union(rest[[i]], gv_mod[[i]][1:length(ersetzt_mod[[i]])])
    # ersatz is which in reihenfolge gv
    whichgv[[i]] <- zero.as.NA(which(gv_mod[[i]]%in%ersatz_mod[[i]]))
    
    c_nach_gversatz[[i]] <- sum(is.red(gv_konform[[i]])) # kammerfarbe die mit ersatz nach gv entstehen würde
    crit[[i]] <- as.numeric(c_nach_gversatz[[i]]==0|c_nach_gversatz[[i]]==3) # mit gv-ersatz einfarbig?
  } 
  else whichgv[[i]] <- c_nach_gversatz[[i]] <- crit[[i]] <- gv_mod[[i]] <- gv_konform[[i]] <- rest[[i]] <- NA
}

#### output data
#########################

full <- data.frame(out,
                   ersetzt=list.collapse(ersetzt_mod),
                   #ersetzt_c=list.collapse(ersetzt_c),
                   ersatz=list.collapse(ersatz_mod),
                   #ersatz_c=list.collapse(ersatz_c),
                   konform=list.collapse(gv_konform),
                   c_nach_gversatz=unlist(c_nach_gversatz),
                   crit=unlist(crit),
                   whichgv=list.collapse(whichgv),
                   gv_mod=list.collapse(gv_mod),
                   real_c=unlist(real_c),
                   drop=drop_mod
)

full$gv_viol <- as.numeric(!full$whichgv%in%c("1", "1 2", "1 2 3"))
full$gv_viol[is.na(full$whichgv)] <- NA

full1 <- full[full$senat==1,]
full2 <- full[full$senat==2,]
write.csv(full, "in/prepareddata/full_dataset.csv")
d <- full[full$drop==F, ]
write.csv(d, "in/prepareddata/final_dataset.csv")

save.image("in/prepareddata/dataset.Rdata")