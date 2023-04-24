/*
    SAS Viya 2023.04 - Example created by David.Weik@sas.com
    This example highlights the use of the senspec option in the tables statement in Proc SurveyFreq.
    This example is build on top of the example provided by the SAS Documentation:
    https://go.documentation.sas.com/doc/en/pgmsascdc/v_038/statug/statug_code_surfex1.htm

    Please copy the complete code and run it before proceeding with the rest of this example
*/

* Makeing use of the senspec option in the tables statement.;
proc surveyfreq data=work.SIS_Survey nosummary;
    tables  Department * Response / senspec;
    strata  State NewUser;
    cluster School;
    weight  SamplingWeight;
 run;