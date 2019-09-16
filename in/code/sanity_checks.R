



#using the links to see which observations are not in the old data set:

d_old <- final_dataset

#generate the correct link for both data sets:

tofind <- paste(c("\\dbvr\\d+","\\dbvq\\d+","\\dbvl\\d+"), collapse="|")

d$new_az <- str_extract_all(d$link, tofind) %>% unlist()

sum(is.na(d$new_az))


###do this for the old data set as well

d_old$new_az <- str_extract_all(d_old$link, tofind) %>% unlist()

sum(is.na(d_old$new_az))


#look which of the new ones are in the old:

table(d$new_az[d$year < 2017] %in% d_old$new_az)




#look which of the old ones are in the new:

table(d_old$new_az %in% d$new_az)


d_old$new_az[!d_old$new_az %in% d$new_az]


####create ID pro Senate Chamber day

d$id_new <- paste(d$date, d$senat, d$kammer)
d_old$id_new <- paste(d_old$date, d_old$senat, d_old$kammer)

#for these the link is dead (using the link of the old (full) data set):
#This is why it is not in the new data set using the new scraper

d_old$new_az[!d_old$id_new %in% d$id_new]





































require(dplyr)

bla <- d%>%   #df1 is yor data frame
  group_by(year)%>%
  summarise(freq=n())

#plot

ggplot(bla, aes(year, freq)) + 
  geom_bar(stat="identity") + theme_bw()


####90 CIs

bla <- d

summary(m <- glm(gv_viol ~ crit, data=bla, family = "binomial"))
summary(m1 <- glm(gv_viol ~ crit, data=bla[bla$senat==1, ], family = "binomial"))
summary(m2 <- glm(gv_viol ~ crit, data=bla[bla$senat==2, ], family = "binomial"))



####taking into account 





#get the older decisions scraped earlier:


d_earlier <- read.csv("~/Dropbox/Papers Mannheim/Paper 2 Kammerbesetzung/Causal Inference Paper/chamber_paper_august2019/archive/in/prepareddata/final_dataset.csv")


#first the az as earlier from link

#then padding:

d_earlier$az[1]

gsub("\\d", d_earlier$az[1])

s = "PleaseAddSpacesBetweenTheseWords"
gsub("([a-z])([A-Z])", "\\1 \\2", s)



x <- '0123456789'
y <- sub("\\s+$", "", gsub('(.{2})', '\\1 ', x))
y

str_pad(d_earlier$az, width = 1)


str_replace_all(d_earlier$az[1],"\\d", "\\1 ")

d_earlier$az %in% d$az



bla <- d

m <- glm(gv_viol ~ crit, data=bla[bla$anordnung == 0, ], family = "binomial")
m1 <- glm(gv_viol ~ crit, data=bla[bla$senat==1 & bla$anordnung == 0, ], family = "binomial")
m2 <- glm(gv_viol ~ crit, data=bla[bla$senat==2 & bla$anordnung == 0, ], family = "binomial")





###Check number of purely red/black chambers (if there are some)


col <- read.csv("in/data-input/Liste_Richter_1_utf.csv", sep="^", encoding = "UTF-8")


# col$last_name_r <- stri_replace_all_fixed(
#   col$last_name_r, 
#   c("ä", "ö", "ü", "Ä", "Ö", "Ü"), 
#   c("ae", "oe", "ue", "Ae", "Oe", "Ue"), 
#   vectorize_all = FALSE
# )


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

#code the color of the judges:

is_r1f_red <- ifelse(out$r1_f %in% redr, 1, 0)
is_r2f_red <- ifelse(out$r2_f %in% redr, 1, 0)
is_r3f_red <- ifelse(out$r3_f %in% redr, 1, 0)


check_data <- cbind.data.frame(is_r1f_red, is_r2f_red, is_r3f_red)

table(rowSums(check_data))

out$red_chamber_gv <- ifelse(sum(is_r1f_red, is_r2f_red, is_r3f_red) == 3, 1, 0)


#for black:

#Sum must be zero because then no judge in the chamber would be red == all are black

#There are some black chambers:

table(rowSums(check_data))

check_data$rowsum <- rowSums(check_data)

out$complete_black <- ifelse(check_data$rowsum == 0, 1, 0)
