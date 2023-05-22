/*
	SAS Viya 2023.05 - Example created by David.Weik@sas.com
	This example is quite involved and also showcases different ways to interact with session options.
	Look for 'Setting the session options' if you are only interested in the core of this example.

	This example highlights the two new CAS Session Options defaultTableReplication and dataStepVarLenChk.

	defaultTableReplication enables you to change the number of table replications that are created by default.
	Note that you can overwrite the default using the replication= option in the casOut parameter.
	Fore more information please refer to the SAS Documentation:
	https://go.documentation.sas.com/doc/en/pgmsascdc/v_039/casref/p06133u3qlca7dn1vd1wsi545fsp.htm
	This option can also be set via the CAS configuration:
	https://go.documentation.sas.com/doc/en/sasadmincdc/v_040/calserverscas/n08000viyaservers000000admin.htm?fromDefault=

	dataStepVarLenChk enables you to add a warning/error to the SAS Log when trunctuation occurs during a data step append.
	Only applies when the data step is running in CAS.
	Fore more information please refer to the SAS Documentation:
	https://go.documentation.sas.com/doc/en/pgmsascdc/v_039/casref/p0tuhplt949qwxn15a2jxko2mz08.htm	

	For more information on CAS Session Options please refer to the SAS Documentation:
	https://go.documentation.sas.com/doc/en/pgmsascdc/default/casref/p0xndb5z45pg1gn16ihqwpf43l90.htm
*/

* See CAS options that are set by default on your system;
* the value statment adds a note how the option was set;
* the define statement adds a descirption of the option;
proc options group=CAS value define;
run;

* Start a CAS session with the default options;
cas mysess;
libname casuser cas caslib='casuser';

* List all options of a given session with the CAS statement;
cas mysess listsessopts;

* Let us take a look at the different ways of checking sessions options;
* All of the different ways have in common the the result is written to the Log;
* First up is doing it with a macro function;
%put defaultTableReplication=%sysfunc(getSessOpt(mysess, defaultTableReplication));
%put dataStepVarLenChk=%sysfunc(getSessOpt(mysess, dataStepVarLenChk));

* Next up we make use of the same function but in a data step;
data _null_;
	defaultTableReplication = getSessOpt('mysess', 'defaultTableReplication');
	put defaultTableReplication=;
	
	dataStepVarLenChk = getSessOpt('mysess', 'dataStepVarLenChk');
	put dataStepVarLenChk=;
run;

* And finally we use proc cas and the sessionProp action set;
proc cas;
	session mysess;

	sessionProp.getSessOpt result = r / name = 'defaultTableReplication';
	print 'Session option defaultTableReplication = ' r['defaultRep'];

	sessionProp.getSessOpt result = r / name = 'dataStepVarLenChk';
	print 'Session option dataStepVarLenChk = ' r['dataStepVarLenChk'];
run; quit;

* Run test code to simulate the different behavior;
data casuser.exampleTable;
	length x varchar(5);
	x = 'Hello';
run;

data casuser.exampleTableNew;
	length x varchar(15);
	x = 'Hello World';
run;

* Note this will note generate any note in the log;
* But the 'Hello World' will be truncated to 'Hello';
* If you want to know more about appending CAS tables I recommend the following blog post:;
* https://blogs.sas.com/content/sgf/2020/12/07/append-and-replace-records-in-a-cas-table/;
data casuser.exampleTable(append=yes);
	set casuser.exampleTableNew;
run;

* This will display a table in the Results tab instead of in the log;
* If the replication is set at the default 1 then you should see the either:;
* Two rows, if you have an MPP CAS (more then one worker);
* One row, if you have an SMP CAS (controller and worker are one);
* If you only have an SMP CAS check ./202305/defaultTableReplication-MPP-CAS.png;
proc cas;
	session mysess;

	table.tabledetails result = r /
		level = 'node',
		caslib = 'casuser',
		name = 'exampleTable';

	print r;
run; quit;

* Setting the session options, we will again look at different options for this;
* Lets touch on to special values first for defaultTableReplication:;
* 1. 0 - disables table replication in the session - only ever one row will appear;
* 2. n > workers - if you set the replication higher then the number of workers, then it will use the number of workers - up to n/worker rows will appear;
* Note that the default is 1;

* Now lets look at the three values for dataStepVarLenChk quickly:;
* NOWARN (default) - ignores the truncated values;
* WARN - writes a warning to the log that value might be truncated;
* ERROR - writes an error to the log;

* First lets set the option via the CAS statement;
cas mysess sessopts=(dataStepVarLenChk=warn defaultTableReplication=0);

* And also setting the options via proc and the sessionProp action set;
proc cas;
	session mysess;

	sessionProp.setSessOpt /
		defaultTableReplication = 0,
		dataStepVarLenChk = 'warn';
run; quit;

* This now generates a Warning in the log - the value is still truncated;
data casuser.exampleTable(append=yes);
	set casuser.exampleTableNew;
run;

* If you have an SMP CAS you will not see a difference now;
* If you have an MPP CAS you will now see only one row;
proc cas;
	session mysess;

	table.tabledetails result = r /
		level = 'node',
		caslib = 'casuser',
		name = 'exampleTable';

	print r;
run; quit;

* Now to round it all out lets create an error message;
proc cas;
	session mysess;

	sessionProp.setSessOpt /
		dataStepVarLenChk = 'error';
run; quit;

data casuser.exampleTable(append=yes);
	set casuser.exampleTableNew;
run;

* Clean up;
cas mysess terminate;