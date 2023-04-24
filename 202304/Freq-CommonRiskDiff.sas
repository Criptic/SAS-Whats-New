/*
    SAS Viya 2023.04 - Example created by David.Weik@sas.com
    This example highlights the use of the commonriskdiff table option in Proc FREQ.
    This example is build on top of the example provided by the SAS Documentation, adjusted to reflect the new option:
    https://go.documentation.sas.com/doc/en/pgmsascdc/v_038/procstat/procstat_freq_examples07.htm
*/

* Create input data set;
data work.Migraine;
    input Gender $ Treatment $ Response $ Count @@;
    datalines;
female Active Better 16 female Active Same 11
female Placebo Better 5 female Placebo Same 20
male Active Better 12 male Active Same 16
male Placebo Better 7 male Placebo Same 19
;
run;

* Calculate the Common Risk Difference and print it to the Results tab;
ods graphics on;
proc freq data=work.Migraine;
   tables Gender*Treatment*Response /
          relrisk plots(only)=relriskplot(stats) commonriskdiff cl noprint;
   weight Count;
   title 'Clinical Trial for Treatment of Migraine Headaches';
run;
ods graphics off;