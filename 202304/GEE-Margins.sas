/*
    SAS Viya 2023.04 - Example created by David.Weik@sas.com
    This example highlights the use of the margins statement in Proc GEE.
    This example is build on top of the example provided by the SAS Documentation, adjusted to reflect the new statement:
    https://go.documentation.sas.com/doc/en/pgmsascdc/v_038/statug/statug_gee_examples01.htm

    For a deeper dive into the margins statement please reference this SAS Documentation entry:
    https://go.documentation.sas.com/doc/en/pgmsascdc/v_038/statug/statug_introcom_sect065.htm
*/

* Generate example data;
data work.Resp;
    input Center ID Treatment $ Sex $ Age Baseline Visit1-Visit4;
    datalines;
1 1 P M 46 0 0 0 0 0
1 2 P M 28 0 0 0 0 0
1 3 A M 23 1 1 1 1 1
1 4 P M 44 1 1 1 1 0
1 5 P F 13 1 1 1 1 1
1 6 A M 34 0 0 0 0 0
2 51 A M 43 1 1 1 1 0
2 52 A F 39 0 1 1 1 1
2 53 A M 68 0 1 1 1 1
2 54 A F 63 1 1 1 1 1
2 55 A M 31 1 1 1 1 1
;
run;

data work.Resp;
    set work.Resp;
    Visit=1; Outcome=Visit1; output;
    Visit=2; Outcome=Visit2; output;
    Visit=3; Outcome=Visit3; output;
    Visit=4; Outcome=Visit4; output;
run;

* Run proc gee with the margins statement;
* Please note this throws an Error but this is expected behavior;
proc gee data=work.Resp descend;
    class ID Treatment Center Sex Baseline;
    model Outcome=Treatment Center Sex Age Baseline /
            dist=bin link=logit;
	margins Treatment / at means;
    repeated subject=ID(Center) / corr=exch corrw;
run;