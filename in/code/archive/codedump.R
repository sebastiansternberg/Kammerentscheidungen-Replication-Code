### controls



# doppel.R
### code Doppelbelastung
f=stoch

# id unique senate-spec terms
dup=NULL

for(k in 1:2){
  t <- unique(f[f$senat==k, "start"]); te <- unique(f[f$senat==k, "end"])
  for(i in t){
    r <- unlist(richter.split(f[f$start==i & f$senat==k, "richter"])) # get all richter in term
    rd <- r[duplicated(r)] # get duplicate richter
    if(length(rd)<3) dup <- rbind(dup, c(k, str_c(r[duplicated(r)], collapse=" "))) else dup <- rbind(dup, c(k, NA))
  }
  if(k==1) date=t else date <- c(date, t)
}
dup=data.frame(date=date, dup)
names(dup)=c("start", "senat", "doppelbelastung_kammer")

f <- merge(f, dup, by=c("senat", "start"))
write.csv(f,"Daten-output/chambers_overview.csv"
          
          
          ##### 2. code doppelbelastung
          source("Daten/doppel.R")
          
          # merge doppel to case data
          d$doppelbelastung_kammer <- NA
          for(i in 1:nrow(d)) d$doppelbelastung_kammer[i] <- str_c(unique(
            f[f$senat==d$senat[i] & f$start<=d$date[i] & f$end>=d$date[i], "doppelbelastung_kammer"]
          ), collapse=" ")
          
          d$doppelbel_in_gv <- NA
          for(i in 1:nrow(d))  d$doppelbel_in_gv[i] <- as.numeric(d$doppelbelastung_kammer[i] %in% unlist(richter.split(d$gv_mod[i]))[1:d$nersetzt[i]])
          
          
          
          
          ### code presidentship
          p <- read.csv("Daten/presidentship.csv")
          
          d$pres <- NA
          for(i in 1:nrow(d)) d$pres[i] <- str_c(unique(
            p[p$senate==d$senat[i] & as.Date(p$start_date)<=d$date[i] & as.Date(p$end_date)>=d$date[i], "name"]
          ), collapse=" ")
          
          d$pres_in_gv <- NA
          for(i in 1:nrow(d))  d$pres_in_gv[i] <- as.numeric(d$pres[i] %in% unlist(richter.split(d$gv_mod[i]))[1:d$nersetzt[i]])
          
          
          
          # # controlling for presidents
          mc <- glm(gv_viol ~ crit + pres_in_gv, data=d, family = "binomial")
          mc1 <- glm(gv_viol ~ crit + pres_in_gv, data=d[d$senat==1,], family = "binomial")
          mc2 <- glm(gv_viol ~ crit + pres_in_gv, data=d[d$senat==2,], family = "binomial")
          stargazer(mc1, mc2
                    , digits = 1
                    , dep.var.caption = "RoP deviation"
                    , dep.var.labels.include = F
                    , column.labels = c("Senate 1", "Senate 2")
                    , covariate.labels = c("Critical case", "(Vice)President first in RoP")
                    , star.cutoffs = 0.05
                    , summary.stat = "n"
                    , omit.stat = c("ll", "aic")
                    , model.numbers = F
                    , notes = "$*: p < 0.05$"
                    , notes.align = "r"
                    , notes.append = FALSE
                    , out = "out/regtable2.tex"
          )

          ate_viol <- ggplot(data=out, aes(y=diff, x=factor(senate, levels = rev(levels(senate))))) + coord_flip() + theme_bw() + guides(fill=FALSE) +
            geom_violin(aes(fill=factor(senate))) + scale_fill_grey() +
            xlab("") + ylab("Difference in RoP violation probabilities (critical - non-critical)") +
            geom_abline(slope=0) +
            theme(axis.line = element_line(colour = "black"),
                  #axis.text.y = element_blank(),
                  axis.line.y = element_blank(),
                  panel.grid.major = element_blank(),
                  panel.grid.minor = element_blank(),
                  panel.border = element_blank(),
                  panel.background = element_blank(),
                  plot.margin = unit(c(1,1,1,1), "cm")
            ) 
          
          pdf("out/sim_violin.pdf", width = 8, height = 6)
          print(ate_viol)
          dev.off()
          
          