/*
 This example highlights the new DIFFRATIOS option in Proc Surveymeans - introduced in SAS Viya 2023.12
 To learn more about this new option please refer to the SAS documentation:
 https://go.documentation.sas.com/doc/en/pgmsascdc/default/statug/statug_surveymeans_syntax05.htm

 The baseline and data for this example can be found in the SAS documentation:
 https://go.documentation.sas.com/doc/en/pgmsascdc/default/statug/statug_code_svmex2.htm

 Find the result of a run here:
 https://github.com/Criptic/SAS-Whats-New/blob/main/202312/DIFFRATIOS-Option-Proc-Surveymeans-result.html
*/
title 'Pairwise Differences between Domain Ratios in Top Companies Profile Study';
proc surveymeans data=work.Company varmethod=jackknife ratio;
	var Profit Sale Employee;
	weight Weight;
	ratio Profit Sale / Employee;
	domain Type / Diffratios;
run;