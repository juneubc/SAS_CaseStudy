/* Analyzing Data */
/* Reporting Data */

%let outpath=/home/u49946413/ECRB94/output;
%let state_name=California;

ods noproctitle;
ods pdf file="&outpath/ClaimReports_in_California.pdf" style=meadow pdftoc=1;

*How many date issues are in the overall data? ;
ods proclabel "Number of Date Issues";
title "Number of Date Issues in the Full Data Countrywide";
proc freq data=tsa.tsaclaims_Clean;
	tables Date_Issues;
run;
title;
* 4241

*Exclude Date Issues;
data tsa.tsaclaims_noissue;
	set tsa.tsaclaims_Clean;
	where Date_Issues is null;
run;
* 216614

*How many claims per year of Incident_Date are in the overall data?; 
ods proclabel "Number of Total Claims per Year";
title "Number of Claims per Year Countrywide";
ods graphics on;
proc freq data=tsa.tsaclaims_noissue;
	tables Incident_Date / nocum nopercent plots=freqplot;
	format Incident_Date year4.;
run;
ods graphics off;
title;

*What are the frequency value of each Claim_Type, Claim_Site, and Disposition 
for the selected state? ;
ods proclabel "Frequency for Claim Type, Claim Site and Disposition";
title "Frequency for Claim Type, Claim Site and Disposition for State &state_name";

proc freq data=tsa.tsaclaims_noissue order=freq;
	tables Claim_Type Claim_Site Disposition / nocum;
	where StateName="&state_name";
run;
title;

*What is the mean, min, max, and sum of Close_Amount for the selected state?;
ods proclabel "Statistics of Close Amount";
title "Statistics of Close Amount for State &state_name";
proc means data=tsa.tsaclaims_noissue mean min max sum maxdec=0;
	var Close_Amount;
	where StateName="&state_name";
run;
title;

ods proctitle;
ods pdf close;
	