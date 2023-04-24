/*
    SAS Viya 2023.04 - Example created by David.Weik@sas.com
    This example highlights the use of the minSpanTree action/option in the CAS Action Set OptNetwork and Proc OptNetwork.
    This example is build on top of the example provided by the SAS Documentation, adjusted to reflect the new option:
    https://go.documentation.sas.com/doc/en/pgmsascdc/v_038/casactnopt/casactnopt_optnetwork_examples36.htm
*/

cas mysess;

libname casuser cas caslib='casuser';

* Generate example data;
data casuser.LinkSetIn;
   input from to upper;
   datalines;
1 2 10
1 3 5
2 4 5
2 5 10
3 5 10
3 6 3
3 7 4
4 5 5
5 7 8
6 7 20
6 8 5
7 8 15
;
run;

* Run the minSpanTree in the optNetwork Action Set;
* Running the minSpanTree Action;
proc cas;
    action optNetwork.minSpanTree result=r status=s /
        direction = 'Directed'
        links = {name = 'LinkSetIn'}
		logLevel = 'Moderate'
		outGraphList = {name = 'GraphListOut', replace = True}
		outNodes = {name = 'NodesOut', replace = True}
		out = {name = 'Out', replace = True}
        outLinks = {name = 'LinkSetOut', replace = True};
    run;

    * Print results and summaries to the Results tab;
    print r.ProblemSummary; run;
    print r.SolutionSummary; run;
    action table.fetch / table = 'LinkSetOut'  sortBy = {'from', 'to'}; run;
quit;

* Run minSpanTree in Proc OptNetwork;
proc optnetwork links=casuser.LinkSetIn;
	minSpanTree out=casuser.LinkMinSpanTree;
run;

* Also take a look at this extended example https://go.documentation.sas.com/doc/en/pgmsascdc/v_038/casnopt/casnopt_optnet_details57.htm;

cas mysess terminate;