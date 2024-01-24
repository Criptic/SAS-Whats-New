/*
 The new recKnn action enables you to train a k-nearest-neighbors model to generate recommendations - introduced in SAS Viya 2024.01
 To find out more about this new action please refer to the SAS documentation:
 https://go.documentation.sas.com/doc/en/pgmsascdc/default/casactml/cas-recommenderengine-recknn.htm
 
 The ASTORE procedure now supports the AGGREGATION_METHOD argument in the SETOPTION statement
 for analytic stores that the recKnn action generates.
 To find out more about this new argument please refer to the SAS documentation:
 https://go.documentation.sas.com/doc/en/pgmsascdc/default/casml/casml_astore_syntax08.htm

 This example build heavily on top of the SAS Documentation provided example:
 https://go.documentation.sas.com/doc/en/pgmsascdc/default/casactml/casactml_recommenderengine_examples11.htm
*/

* Start the CAS session;
cas mysess;
libname casuser cas caslib='casuser';

* Assign a temporary fileref;
filename uccsv temp;

* The download is around 1 MB in size;
proc http
	method = 'Get'
	url = 'https://support.sas.com/documentation/onlinedoc/viya/exampledatasets/usersCommunity.csv'
	out = uccsv;
quit;

proc import
	datafile = uccsv
	dbms = csv
	out = casuser.usersCommunity;
quit;

filename uccsv clear;

* Train the K-Neares-Neighbor Recommender System;
proc cas;
	recommenderEngine.recKnn result=R /
		table = {caslib = 'casuser', name = 'usersCommunity'},
		outModel = {name = 'nearestNeighbors', replace = True},
		outSimilarity = {name = 'nearestNeighborValues', replace = True},
		saveState = {caslib = 'casuser', name = 'astoreModel', replace = true},
		inputs = {'userId', 'boardId'},
		nominals = {'userId', 'boardId'},
		userId = 'userId',
		itemId = 'boardId',
		k = 5,
		memoryEfficient = False,
		distanceMetric = 'cosine';
	run;
quit;

* Score the data set;
proc astore;
	setoption nTopRecoms  5;
	* Specifies the type of aggregation to apply in pooling similarity scores of nearest neighbors;
	* 0 (default) - similarity scores for repeated nearest neighbors are summed;
	setoption aggregationMethod 0;
	* 1 - similarity scores for repeated nearest neighbors are averaged;
	* setoption aggregationMethod 1;
	setoption recItemFilter 1;
	score data=casuser.usersCommunity(obs=1) rstore=casuser.astoreModel out=casuser.rankedItemsKnn;
run; quit;