# chamberGFCC


This Github provides the files necessary to replicate the analysis for the paper *"Are Judges Political Animals After All? Quasi-experimental Evidence from the German Federal Constitutional Court"*. 

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


## Data Sets

DateInput contains:

kammer-formal_utf.csv:

- Data about the year of a chamber, the Senate, the chamber number, the name of the judges in this chamber, and the order of replacement. The data set goes from 1998 to 2019. The order of 321 indicates which judges of the respective Chamber is the first, second or third to replace a dropping judge. 

Liste_Richter_1_utf.csv:


- contains a lot of information about the biographies of the judges at the GFCC. This data set contains also the information about the party that nominated the judge, which is necessary for our analyses. 


judicialData_Sep16.txt:

- contains all chamber decisions that are available on the webpage of the GFCC. You can find all code to replicate the webscraping in this [Github Repository](https://github.com/sebastiansternberg/scraper-decisions-German-Federal-Constitutional-Court). 



## General information

The Geschäftsverteilung (RoP) is published on the website of the GFCC as well. In the RoP, the judges determine who is sitting in which chamber. They also write down who is replacing judges who drop out, e.g. because of illness. Typical replacement rules read as follows:


Bei Verhinderung ordentlicher Kammermitglieder treten:

- für die Mitglieder der 1. Kammer die Mitglieder der 3. Kammer, sodann die Mitglieder der 2. Kammer,
- für die Mitglieder der 2. Kammer die Mitglieder der 1. Kammer, sodann die Mitglieder der 3. Kammer,
- für die Mitglieder der 3. Kammer die Mitglieder der 2. Kammer, sodann die Mitglieder der 1. Kammer,
 
jeweils mit dem zuletzt genannten Mitglied beginnend, als Stellvertreter ein. This would lead to a replacement order of 321


In the second senate, often the the seniority, beginning with the younges, is used. For instance: 

2010 Senate 2 Chamber 3 did consist of: Voßkuhle, Mellinghoff, Lübbe-Wolf. Came to Court (04/2008, 01/2001, 03/2002). Therefore the replacement would be: 132, because Voßkuhle is the youngest.


Final data set consists of:



- r1, r2, r3: 
The judges actual signing a decision.


- r1_f, r2_f, r3_f
The judges formally sitting in this panel

- gv:
 The order of the judges who are going to replace an absente judge. 

- ersetzt:
The name(s) of the judges who are absente.

- ersatz:
The name of the judges who are the replacement. 

-konform:
how the panel would look like if the replacement order is in according with the RoP

- crit:
critical case; this is, whether following the replacement order (RoP) would lead to a totally black or red chamber.

- c_nachgversatz:
kammerfarbe die mit ersatz nach gv entstehen würde

- which_gov:
At which position in the order of the replacement is the actual replacement? 1 3 for instance means the first and then the third judge of the RoP are selected 

- real_c
which of the judges in the real chamber are red?




ToDO:

- descriptives machen/rausschreiben: overall N, overall dropouts, conservative drop out
- check presidents workload
- check simulation distribution slightly skewed
- read German paper again and update data set and graps.
- Datensatz beschreiben
- Master do anpassen
- Was passiert wenn man sich die Fälle ohne Präsident anschaut
- More stories in the data, e.g. informal replacements etc.
- Github dafür machen und rdm updaten












