/*
    SAS Viya 2023.04 - Example created by David.Weik@sas.com
    This example highlights the use of the OutRNNOpt and OutRNNStat output collector objects in Proc TsModel with RNN.
    This example is build on top of the example provided by the SAS Documentation:
    https://go.documentation.sas.com/doc/en/pgmsascdc/v_038/castsp/castsp_atsm_sect314.htm
*/

cas mysess;

libname mycas cas caslib='mycas';

* Now copy the full code from the SAS Documentation example;
* Replace the the outobj statement with this one;
*outobj=(airFor=mycas.airFor4 modInfo=mycas.modInfo4 airSelect=mycas.airSelect4 outRnnOptObj=mycas.outRnnOptObj outRnnStatObj=mycas.outRnnStatObj);

* Add the following lines just above the endsubmit statement;
/*
declare object outRnnOptObj(outrnnopt);
rc = outRnnOptObj.collect(airEng);
rc = outRnnOptObj.nrows();

declare object outRnnStatObj(outrnnopt);
rc = outRnnStatObj.collect(airEng);
rc = outRnnStatObj.nrows();
*/

* It should look something like this;
proc tsmodel data=mycas.air
    outobj=(airFor=mycas.airFor4 modInfo=mycas.modInfo4 airSelect=mycas.airSelect4 outRnnOptObj=mycas.outRnnOptObj outRnnStatObj=mycas.outRnnStatObj);

        * Code from Example goes here;

        declare object outRnnOptObj(outrnnopt);
        rc = outRnnOptObj.collect(airEng);
        rc = outRnnOptObj.nrows();

        declare object outRnnStatObj(outrnnopt);
        rc = outRnnStatObj.collect(airEng);
        rc = outRnnStatObj.nrows();
    endsubmit;
run;

* Before you terminate the session take a look at mycas.outRnnOptObj and mycas.outRnnStatObj;
cas mysess terminate;