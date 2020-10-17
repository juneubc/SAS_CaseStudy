%let path=/home/u49946413/ECRB94/data;
libname cr "&path";

/* Create the cleaned_tourism Table */
data cr.cleaned_tourism;
	set cr.tourism(drop=_1995-_2013);
	retain Country_Name Tourism_Type;
	format Tourism_Type $ 16. money_unit $ 9. Y2014 comma20. Category $ 50.; 
	length Country_Name $ 55;
	
	*Create the Country_Name and Tourism_Type;
	if A~=. then do;
		Country_Name=COUNTRY;
		Tourism_Type="";
	end;
	if COUNTRY="Inbound tourism" then Tourism_Type=COUNTRY;
	if COUNTRY="Outbound tourism" then Tourism_Type=COUNTRY;
	
	*Remove Repeated Rows;
	if COUNTRY~=Country_Name and Tourism_Type~="";
	if COUNTRY~=Tourism_Type;
	
	*Conver Series Column;
	if Series=".." then Series=".";
		else Series=upcase(Series);
	
	*Create a Type for money unit;
	if scan(Country, 2, " - ")="Thousands" then money_unit="Thousands";
		else money_unit="Mn";
		
	*Change _2014 Column and create Y2014 Column;
	if _2014=".." then do;
		_2014=.;
		Y2014=.;
	end;
	if money_unit="Thousands" then Y2014=input(_2014, 16.)*1000;
		else Y2014=input(_2014, 16.)*1000000;
		
	* Create Category for Values in Country;
	if COUNTRY in ("Arrivals - Thousands" , "Departures - Thousands") 
			then Category=scan(COUNTRY, 1, " - ");
		else if COUNTRY in ("Tourism expenditure in the country - US$ Mn", 
							"Travel - US$ Mn" , 
							"Passenger transport - US$ Mn", 
							"Tourism expenditure in other countries - US$ Mn")
			then Category=cat(scan(COUNTRY, 1, "$"), "$");
run;

/* Specify Columns Required in Final_Tourism Table */
data cr.cleaned_tourism;
	format Country_Name Tourism_Type Category Series Y2014;
	set cr.cleaned_tourism(keep=Country_Name Tourism_Type Category Series Y2014);
run;

/* Create a Format for Continent */
proc format;
	value ConFmt 1="North America"
				 2="South America"
				 3="Europe"
				 4="Africa"
				 5="Asia"
				 6="Oceania"
				 7="Antarctica";
run;


/* Merge the cleaned_tourism Table with Country_Info to Create the final_tourism table */
proc sort data=cr.country_info out=country_sorted(rename=(Country=Country_Name));
	by Country;
run;

proc sort data=cr.cleaned_tourism out=tourism_sorted;
	by Country_Name;
run;

data cr.final_tourism cr.NoCountryFound(keep=Country_Name);
	merge work.tourism_sorted(in=intour) work.country_sorted(in=incoun);
	by Country_Name;
	if intour=1 and incoun=1 then output cr.final_tourism;
	if intour=1 and incoun=0 then do;
		if first.Country_Name=1;
		output cr.NoCountryFound;
	end;
	format Continent ConFmt.;
run;

