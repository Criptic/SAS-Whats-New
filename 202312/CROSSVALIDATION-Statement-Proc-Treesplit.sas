/*
 This example highlights the new Crossvalidation statement for Proc Treesplit - introduced in SAS Viya 2023.12
 In order for this option to run you need to set prune to off, not specify a partition and not specify autotune.
 To find out more about this new statement please refer to the SAS documentation:
 https://go.documentation.sas.com/doc/en/pgmsascdc/default/casstat/casstat_treesplit_syntax05.htm

 Find the result of a run here:
 https://github.com/Criptic/SAS-Whats-New/blob/main/202312/CROSSVALIDATION-Statement-Proc-Treesplit-result.html
*/
cas mysess;
data casuser.hmeq;
	set sampsio.hmeq;
run;

ods graphics on;
title 'Crossvalidation in Proc Treesplit';
proc treesplit data=casuser.hmeq maxdepth=5;
	class Bad Delinq Derog Job nInq Reason;
	model Bad = Delinq Derog Job nInq Reason CLAge CLNo
               DebtInc Loan MortDue Value YoJ;
	prune off;
	crossvalidation kFold=5;
run;