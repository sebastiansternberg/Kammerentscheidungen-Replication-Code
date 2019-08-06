# chamberGFCC




In the mean time, there have been more decisions made available. 


functions.R:
- contains helpful functions to clean the names of the judges, convert dates, or collaps lists. 




prep.formal.R

- contains the code that is necessary to provide the basic data that is necessary to start the analysis, in particular which judge is supposed to being replaced by whom according to the RoP (Geschäftsverteilung). 


prep.case.R

- reads all the chamber decisions which were automatically scraped from the website of the GFCC and obtains the judges who actually signed the decisions; we also compare the data with respect to its consistency and merge the judges allocation for the replacement according to the RoP. 


code_vars.R
- creates the variables for the analysis. In particular, it compares the actually sitting judges with the judges that are supposed to sit there on a given day. It also automatically checks the party label of the judges, that is, whether a red judge is replaced by a red or "black" judges and vice versa. 



THis creates a data set:

ersetzt: the judge who formally is supposed to sit (the judge dropping out).
ersatz: the judge who really sit on the bench (the judge replacing the judge dropping out).




DateInput contains:

kammer-formal_utf.csv:
- Data about the year of a chamber, the senat, the chamber number, the name of the judges in this chamber, and the order of replacement. The data set goes from 1998 to 2016. 



Reihenfolge 321 heißt das letztgenannter Richter zuerst drankommt, dann der mittlere und dann der erstgenannte. 



Liste_Richter_1_utf.csv:
- contains a lot of information about the biographies of the judges at the GFCC. This data set contains also the information about the party that nominated the judge. 



judicialData_Sep16.txt:
- contains all chamber decisions that are available at the 



Replacement rules: First Senate:

Bei Verhinderung ordentlicher Kammermitglieder treten:

-  für die Mitglieder der 1. Kammer die Mitglieder der 3. Kammer, sodann die Mitglieder der 2. Kammer,
 -  für die Mitglieder der 2. Kammer die Mitglieder der 1. Kammer, sodann die Mitglieder der 3. Kammer,
-  für die Mitglieder der 3. Kammer die Mitglieder der 2. Kammer, sodann die Mitglieder der 1. Kammer,
 
jeweils mit dem zuletzt genannten Mitglied beginnend,
 als Stellvertreter ein. 



Second Senate is about the seniority, beginning with the youngest:
2010 Senate 2 Chamber 3 did consist of: Voßkuhle, Mellinghoff, Lübbe-Wolf. Came to Court (04/2008, 01/2001, 03/2002). Therefore the replacement would be: 132, because Voßkuhle is the youngest.












