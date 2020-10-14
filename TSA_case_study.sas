/* Accessing Data */
* Import the TSAClaims2002_2017.csv file;

%let path=/home/u49946413/ECRB94/data;

libname TSA "&path";

options validvarname=v7;
proc import datafile="&path/TSAClaims2002_2017.csv" 
	dbms=csv out=TSA.TSAClaims2002_2017 replace;
	guessingrows=max;
run;
* Total rows: 220855 Total columns: 14

/* Exploring Data */
/* Preparing Data */

* Remove entirely duplicated records;
proc sort data=TSA.tsaclaims2002_2017 out=tsaclaims_nodup;
	by _ALL_;
run;
* Total rows: 220855 Total columns: 14;

proc print data=work.tsaclaims_nodup(obs=50);
	var Claim_Site Disposition Claim_Type Date_Received Incident_Date;
run;

proc contents data=work.tsaclaims_nodup;
run;

data work.tsaclaims_nonmissing;
	set work.tsaclaims_nodup;
	if Claim_Type='' or Claim_Type='-' then Claim_Type="Unknown";
	if Claim_Site='' or Claim_Site='-' then Claim_Site="Unknown";
	if Disposition='' or Disposition='-' then Disposition="Unknown";
run;

data work.tsaclaims_columnClean;
	set work.tsaclaims_nonmissing;
	Claim_Type=scan(Claim_Type, 1, '/');
	if Disposition in ('Closed: Canceled', 'losed: Contractor Claim') 
		then Disposition='Closed:Canceled';
	StateName=Propcase(StateName);
	State=Upcase(State);
run;
	
proc freq data=work.tsaclaims_columnClean;
	tables Claim_Site Disposition Claim_Type;
run;

proc sort data=work.tsaclaims_columnClean;
	by Incident_Date;
run;

data tsa.tsaclaims_Clean label;
	set work.tsaclaims_columnClean;
	if Incident_Date='.' or Date_Received='.' then Date_Issues='Needs Review';
	if Incident_Date<"01Jan2002"d or Incident_Date>"31Dec2017"d then Date_Issues='Needs Review';
	if Date_Received<"01Jan2002"d or Date_Received>"31Dec2017"d then Date_Issues='Needs Review';
	if Date_Received<Incident_Date then Date_Issues='Needs Review';
	drop County City;
	format Close_Amount dollar10.2 Date_Received Incident_Date date9.;
	label Airport_Code="Airport Code"
		  Airport_Name="Airport Name"
		  Claim_Number="Claim Number"
		  Claim_Site="Claim Site"
		  Claim_Type="Claim Type"
		  Close_Amount="Close Amount"
		  Date_Received="Date Received"
		  Date_Issues="Date Issues"
		  Incident_Date="Incident Date"
		  Item_Categoty="Item Categoty";
run;
	


