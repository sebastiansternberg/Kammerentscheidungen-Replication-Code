# chamberGFCC


This Github provides the files necessary to replicate the analysis for the paper *"Are Judges Political Animals After All? Quasi-experimental Evidence from the German Federal Constitutional Court"*. In the folder in/prepareddata there is are also the final data sets so you do not have to run the code to create the data sets. **chamber_gfcc_analysisdata.dta** is a Stata data set which is ready to use to run the analyses without the pre-processing. 

## Code

The file *maste.R* can be used to run all necessary steps for the replication in one file. The repository contains the following files. 

functions.R

- contains helpful functions to clean the names of the judges, convert dates, or collaps lists. 

prep.formal.R

- contains the code that is necessary to provide the basic data that is necessary to start the analysis, in particular which judge is supposed to being replaced by whom according to the RoP (Geschäftsverteilung). 


prep.case.R

- reads all the chamber decisions which were automatically scraped from the website of the GFCC and obtains the judges who actually signed the decisions; we also compare the data with respect to its consistency and merge the judges allocation for the replacement according to the RoP. 


code_vars.R

- creates the variables for the analysis. In particular, it compares the actually sitting judges with the judges that are supposed to sit there on a given day. It also automatically checks the party label of the judges, that is, whether a red judge is replaced by a red or "black" judges and vice versa. 

Analysis.rmd

- Is a markdown file where all the analyses are run. Includes the main analyses and all the robustness checks plus a description about the codings etc.

## Data Sets

DateInput contains three data sets that are necessary to replicate our analyses.

kammer-formal_utf.csv:

- Data about the year of a chamber, the Senate, the chamber number, the name of the judges in this chamber, and the order of replacement. The data set goes from 1998 to 2019. The order of 321 indicates which judges of the respective Chamber is the first, second or third to replace a dropping judge. 

Liste_Richter_1_utf.csv:


- contains a lot of information about the biographies of the judges at the GFCC. This data set contains also the information about the party that nominated the judge, which is necessary for our analyses. 


chamber_decision_cleaned.csv:

- contains all chamber decisions that are available on the webpage of the GFCC from 1998-2018. You can find all code to replicate the webscraping in this [Github Repository](https://github.com/sebastiansternberg/scraper-decisions-German-Federal-Constitutional-Court). 



## General information/ context on data

The Geschäftsverteilung (RoP) is published on the website of the GFCC as well. In the RoP, the judges determine who is sitting in which chamber. They also write down who is replacing judges who drop out, e.g. because of illness. Typical replacement rules read as follows:

Bei Verhinderung ordentlicher Kammermitglieder treten:

- für die Mitglieder der 1. Kammer die Mitglieder der 3. Kammer, sodann die Mitglieder der 2. Kammer,
- für die Mitglieder der 2. Kammer die Mitglieder der 1. Kammer, sodann die Mitglieder der 3. Kammer,
- für die Mitglieder der 3. Kammer die Mitglieder der 2. Kammer, sodann die Mitglieder der 1. Kammer,
 
jeweils mit dem zuletzt genannten Mitglied beginnend, als Stellvertreter ein. This would lead to a replacement order of 321


In the second senate, often the the seniority, beginning with the younges, is used. For instance: 

2010 Senate 2 Chamber 3 did consist of: Voßkuhle, Mellinghoff, Lübbe-Wolf. Came to Court (04/2008, 01/2001, 03/2002). Therefore the replacement would be: 132, because Voßkuhle is the youngest.

The final data set used for the analysis is in folder in/data-input and is called "final_dataset.csv". The data set with the full data (where the analysis data set was created from) is called "full_dataset.csv". 

The **final_dataset.csv** contains the following variables:

- az: Aktenzeichen
- date: then date of the decision
- senat: the Senat the decision was decided in (either 1 or 2)
- anordnung: is the decision a BvQ or not. This info is directly from az
- link: the url to the decision: 
- year: the year of the decision
- kammer: the number of the three-judge panel a decision was decided
- r1, r2, r3: 
The judges actual signing a decision. 
- r1_f, r2_f, r3_f
The judges formally sitting in this panel according to the RoP

- gv:
 The order of the judges who are going to replace an absente judge. 

- ersetzt:
The name(s) of the judges who are absent.

- ersatz:
The name of the judges who are the replacement/substitution. 

- konform:
how the panel would look like if the replacement order is in according with the RoP

- crit:
critical episode; this is, whether following the replacement order (RoP) would lead to a totally black or red chamber (a homogenous panel only consisting of justices with the same party label, e.h. three left or three right justices)

- c_nachgversatz:
panel composition if the RoP was followed. how many of the judges in the real/observed panel are red? zero means all justices are right, 1 means LRR, 2 means LLR, 3 means LLL. 


- which_gov:
At which position in the order of the replacement is the actual replacement? 1 3 for instance means the first and then the third judge of the substitution order are selected

- real_c:
how many of the judges in the real/observed panel are red? zero means all justices are right, 1 means LRR, 2 means LLR, 3 means LLL.

- gv_viol: was the first rule of the substitution order according to the RoP violated or not. 


## How to replicate the analyses

It is generally adviced to use a unix-system for the replication, because the German Umlaute can make the name merging tricky.

1. To replicate our results, you first use the *master.R* and follow the code. The *master.R* sources the r code which is necessary to create the final data set used for the analyses. It sources prep.formal.R, prep.case.R, code_vars.R. Once you have run this, you are ready to do the analyses.

2. The analysis.rmd is a RMarkdown containing all the code for the main analysis and robustness checks. It also produces the graphs and the regression tables, and codes the variables necessary to do the robustness checks. 












