/*
 This example highlights the new TSAOUTLIER object in proc TSMODEl - introduced in SAS Viya 2024.02
 To find out more about this new object please refer to the SAS documentation:
 https://go.documentation.sas.com/doc/en/pgmsascdc/default/castsp/castsp_tsa_sect184.htm

 Thank you to Tamara Fischer for the code to visualize the outliers in the series

 Find the result of a run here:
 https://criptic.github.io/SAS-Whats-New/202402/Proc-TSMODEL-Outlier-Object.html
*/

* Start a CAS session and assign the casuser library;
cas mySess;
libname casuser cas caslib='casuser';

* Load the sashelp.air dataset to CAS;
* The dataset provides airline data (monthly: Jan49–Dec60);
data casuser.air;
	set sashelp.air;
	format date monyy7.;
run;

* Analyze the time series for any outliers;
proc tsmodel data = casuser.air 
	outobj = (oOutlier = casuser.oOutlier(replace = Yes));

	var air;
	id date interval = month;
	require tsa;
	submit;
		* Declare the outlier object;
		declare object outlier(TSAOUTLIER);
		* Declare the output obbject for outliers;
		declare object oOutlier(TSAOUTOUTLIER);

		* Initialize the outlier analysis;
		rc = outlier.Initialize();
		* Set the input time series;
		rc = outlier.SetY(air);
		* Set outlier detection options for the Hampel-based method;
		rc = outlier.SetHampel('DISTRIBUTION', 'EXP');
		* Run the analysis;
		rc = outlier.Run();
		* Collect the result of the outlier run;
		rc = oOutlier.Collect(outlier);
    endsubmit;
quit;

* Print the result of the outlier analysis to the Results pane;
title 'TSMODEL Outlier Analysis Result';
proc print data=casuser.oOutlier;
quit;
title;

* Join the outliers with the original series;
proc fedsql sessref = mySess;
	create table casuser."Plot_Input" as
		select a."Date", a."Air", b."_event_"
			from casuser."Air" as a
				left join casuser."oOutlier" as b
					on a."Date" = b."Date";
quit;

* Plot the series and highlight outliers;
proc sgplot data = casuser.Plot_Input;
	series x = Date y = Air / lineAttrs = (color = grey pattern = solid thickness = 2) legendLabel = 'Date';
	scatter x = Date y = Air / group = _event_ noMissingGroup;
	
	title 'Visualize the outlier in the series';
	yAxis label = 'Air';
	xAxis label = 'Date';
quit;

* Terminate the CAS session;
cas mySess terminate;