/*
 This example highlights the new Relaxed Lasso selection method for the GLM Action - introduced in SAS Viya 2024.01
 In order for this option to run you need to set the selection method to Lasso and the parameter relaxed to true.
 To find out more about this new selection method please refer to the SAS documentation:
 https://go.documentation.sas.com/doc/en/pgmsascdc/default/casactstat/cas-regression-glm.htm

 Find the result of a run here:
 https://criptic.github.io/SAS-Whats-New/202401/Relaxed-Lasso-Selection-Method-GLM-Action.html
*/

cas mysess;
libname casuser cas caslib='casuser';

data casuser.hmeq;
	set sampsio.hmeq;
run;

proc cas;
	regression.glm /
		table={caslib = 'casuser', name = 'hmeq'},
		target='BAD',
		inputs={
			'REASON', 
			'JOB',
			'LOAN',
			'MORTDUE',
			'VALUE',
			'YOJ',
			'DEROG',
			'DELINQ',
			'CLAGE',
			'NINQ',
			'CLNO',
			'DEBTINC'
		},
		nominals={
			'REASON', 
			'JOB'
		}
		selection = {
			method = 'Lasso',
			relaxed = True
		};
	run;
quit;