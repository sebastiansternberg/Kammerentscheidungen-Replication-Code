
load("in/prepareddata/dataset.Rdata")
options(stringsAsFactors = F)

##### 1. check data
# how many replaced?
d$nersetzt <- as.numeric(sapply(d$ersetzt, function(x) length(unlist(richter.split(x)))))
d <- d[d$nersetzt<3,] # delete cases where all richter were replaced

##### 2. descriptives


## crosstabs
make.table <- function(d, path){
  t <- table(d$gv_viol, d$crit)
  t <- rbind(as.character(t[1,]),
        str_c("(", round(prop.table(t, 2)[1,],2)*100, "%)"),
        as.character(t[2,]),
        str_c("(", round(prop.table(t, 2)[2,],2)*100, "%)"))
  t <- cbind(c("no RoP deviation", "", "RoP deviation", ""), t)
  colnames(t) <- c("", "non-critical case", "critical case")
  t <- xtable(t); align(t) <- "ll|cc"
  print(t, include.rownames=F, file=path)
}

make.table(d[d$senat==1,], "out/dtab1.tex")
make.table(d[d$senat==2,], "out/dtab2.tex")



#### 3. models

# RoP violation rate is larger in critical cases.

m <- glm(gv_viol ~ crit, data=d, family = "binomial")
m1 <- glm(gv_viol ~ crit, data=d[d$senat==1,], family = "binomial")
m2 <- glm(gv_viol ~ crit, data=d[d$senat==2,], family = "binomial")
stargazer(m, m1, m2, 
          type = "text"
          , digits = 1
          , dep.var.caption = "RoP deviation"
          , dep.var.labels.include = F
          , column.labels = c("Both Senates", "Senate 1", "Senate 2")
          , covariate.labels = "Critical case"
          , star.cutoffs = 0.05
          , summary.stat = "n"
          , omit.stat = c("ll", "aic")
          , model.numbers = F
          , notes = "$*: p < 0.05$"
          , notes.align = "r"
          , notes.append = FALSE
         # , out = "out/regtable.tex"
          )

#Signs point in the predicted direction (violation is more likely in critical cases).
#Difference in violation rate between critical and non-critical cases is not statistically significant in Senate 2.

nsim=10000

sim <- function(nsim, model, ci=F){
  S <- MASS::mvrnorm(nsim, coef(model), vcov(model))
  logit <- function(x) exp(x)/(1+exp(x))
  s.x <- logit(S%*%c(1,0)); s.x1 <- logit(S%*%c(1,1))
  out <- as.numeric(s.x-s.x1)
  if(ci==T) out <- out[out >= quantile(out, .025) & out <= quantile(out, .975)]
  return(out)
}

out <- rbind(data.frame(senate=rep(0, nsim), diff=sim(nsim, m)),
             data.frame(senate=rep(1, nsim), diff=sim(nsim, m1)),
             data.frame(senate=rep(2, nsim), diff=sim(nsim, m2)))
out$senate <- factor(out$senate, labels=c("Senate 1", "Senate 2"))


####### errorbar
bar <- cbind(senate=unique(out$senate)
      , ate=by(out$diff, out$senate, mean)
      , cil=by(out$diff, out$senate, quantile,.025)
      , ciu=by(out$diff, out$senate, quantile,.975)
      )
bar <- data.frame(bar)
bar$senate <- c(2, 1.5, 1.3) # yplacement main, 1, 2
bar$fett <- c(1, 0, 0)

ate_bar <-
  ggplot(bar, aes(x=ate, y=senate)) +
  geom_point(size=.5+bar$fett) + geom_errorbarh(aes(xmax=ciu, xmin=cil), height = .1, size=.5+bar$fett) + geom_vline(xintercept = 0) +
  scale_y_continuous(breaks=c(2, 1.5, 1.3), limits=c(1,2.5), labels=c("Main Effect", "Senate 2", "Senate 1")) + ylab("") +
  scale_x_continuous(limits=c(-1,1)) + xlab("ATE\nDifference in RoP deviation probability (critical - non-critical cases)") +
  theme_bw() + guides(col=FALSE)

pdf("out/sim_errorbar.pdf", width = 8, height = 6)
print(ate_bar)
dev.off()

### why not in senate 2?
d[d$senat==2 & d$gv_viol==1 & d$crit==1, c("ersetzt", "ersatz", "gv_mod", "doppelbelastung_kammer", "doppelbel_in_gv")]
#write.csv(d[d$senat==2 & d$gv_viol==1 & d$crit==1,], "why2.csv")


#### 2. OI 
# in kritischem Fall, nach gv-violation keine einfarbige kammer

#### 1
nc <- d[d$crit==0,]; nc <- table(nc$real_c%in%c(0,3), nc$gv_viol)
c <- d[d$crit==1,]; c <- table(c$real_c%in%c(0,3), c$gv_viol)

# export weird case
test <- d[d$gv_viol==1 & d$real_c%in%c(0,3),]
write.csv(test, "einfarb_nach_gvdev.csv")
test <- d[d$gv_viol==0 & d$crit==1,]
write.csv(test, "keinedevincritcase.csv")

rownames(c) <- rownames(nc) <- c("Balanced", "Unbalanced")
colnames(c) <- colnames(nc) <- c("RoP conf.", "RoP dev.")
t1 <- latex(as.tabular(nc), file="out/oi2-tab1.tex")
t2 <- latex(as.tabular(c), file="out/oi2-tab2.tex")

#### 2
c <- d[d$gv_viol==1,]
table(c$real_c[c$senat==1]%in%c(0,3), c$crit[c$senat==1])
table(c$real_c[c$senat==2]%in%c(0,3), c$crit[c$senat==2])

# 3. oi
#######################
c <- d[d$crit==1,]

c$needred <- 0
c$needred[c$c_nach_gversatz==0] <- 1

gv <- lapply(c$gv_mod, function(x) unlist(richter.split(x)))

o <- data.frame(cersetzt=sapply(c$ersetzt, function(x) str_c(is.red(unlist(richter.split(x))), collapse="")), # col of ersetzt
                cafter=c$c_nach_gversatz,
                cgv=sapply(gv, function(x) str_c(is.red(x), collapse = "")),
                which=as.character(c$whichgv),
                dev=c$gv_viol,
                rc=c$real_c,
                sentate=c$senat
                )

write.csv(o[o$sentate==1,], "memos/oi3-1.csv")
write.csv(o[o$sentate==2,], "memos/oi3-2.csv")

data.frame(is.red(c$r1_f), is.red(c$r2_f), is.red(c$r3_f),
           cgv=sapply(gv, function(x) str_c(is.red(x), collapse = "")),
           rc=c$real_c,
           cersetzt=sapply(c$ersetzt, function(x) str_c(is.red(unlist(richter.split(x))), collapse="")), # col of ersetzt
           which=as.character(c$whichgv),
           cafter=c$c_nach_gversatz,
           c$needred
)

data.frame(is.red(c$r1_f), is.red(c$r2_f), is.red(c$r3_f),
           rc=c$real_c
)
