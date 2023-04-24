cas mysess;
libname casuser cas caslib='casuser';

* Load the sashelp.cars dataset to CAS;
data casuser.cars;
	set sashelp.cars;
run;

proc fedsql sessref=mysess;
    create table casuser."result" as
        select (t1."Origin") as "Origin",
            ( uuidgen()) as "uniqueCarID"
            from casuser."CARS"
                group by "Origin";
run; quit;

title1 'Unique ID generated for each row';
proc print data=casuser.result noobs;
run;
title;

cas mysess terminate;