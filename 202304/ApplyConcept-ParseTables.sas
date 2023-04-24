/*
    SAS Viya 2023.04 - Example created by David.Weik@sas.com
    This example highlights the new parameters in the textRuleScore.applyConcept action: parseTableIn + parseTableOut
    The new parameters can be used to speed up computation between multiple applyConcept actions
    For more information please refer to the SAS Documentation:
    https://go.documentation.sas.com/doc/en/pgmsascdc/v_038/casvtapg/cas-textrulescore-applyconcept.htm#SAS.cas-textrulescore-applyconcept-parsetablein
*/

cas mysess sessopts=(metrics=True);

libname casuser cas caslib='casuser';

* Generating our baseline text that will be parsed;
data casuser.example_text;
    length text $240.;
    infile datalines delimiter='|' missover;
    input text$;
    datalines;
We will find a way to the moon without a red rocket. Second sentence also saying that the rocket is red.
When will be going to the moon and when will we do it without a red rocket?
Having gone to the moon in a rocket, which was red.
Without a rocket, why wouldn't you want to go to the moon in a red one?
;
run;

* LITI rules example 1;
data casuser.liti_concepts_1;
    length ruleID 8. config $500.;
    infile datalines delimiter='#' missover;
    input ruleID config$;
    datalines;
1#CONCEPT_RULE:CLAUSEXAMPLEHIER1:(CLAUS_1, "_c{rocket}", "red")
;
run;

* LITI rules example 2;
data casuser.liti_concepts_2;
    length ruleID 8. config $500.;
    infile datalines delimiter='#' missover;
    input ruleID config$;
    datalines;
2#CONCEPT_RULE:CLAUSEXAMPLEHIER2:(CLAUS_2, "_c{rocket}", "red")
;
run;

* Generate Document ID, Compile both concepts and Apply them;
proc cas;
    session mysess;
    output log;

    * Add a unique document ID to the text;
    textManagement.generateIds /
        casOut={name = "example_text_id", replace = True}
        id = "docID"
        table = {name = "example_text"};
   run;

   * Compile the text concepts 1;
    textRuleDevelop.compileConcept /
        casOut = {name = 'compiled_concepts_1', replace = True} 
        config = 'config'
        table = {name = 'liti_concepts_1'};
    run;

    * Compile the text concepts 2;
    textRuleDevelop.compileConcept /
        casOut = {name = 'compiled_concepts_2', replace = True} 
        config = 'config'
        table = {name = 'liti_concepts_2'};
    run;

    * Apply the text concepts 1;
    * Saving the intermediate parsing results;
    textRuleScore.applyConcept /
        casOut = {name = 'applied_concepts_1', replace = True}
        parseTableOut = {name = 'parse_results', replace = True}
        language = 'ENGLISH'
        docId = 'docID'
        model = {name = 'compiled_concepts_1'}
        table = {name = 'example_text_id'}
        text = 'text';
    run;

    * Apply the text concepts 2;
    * Reusing the intermediate parsing results;
    textRuleScore.applyConcept /
        casOut = {name = 'applied_concepts_2', replace = True}
        parseTableIn = {name = 'parse_results'}
        language = 'ENGLISH'
        docId = 'docID'
        model = {name = 'compiled_concepts_2'}
        table = {name = 'example_text_id'}
        text = 'text';
    run;
quit;

* Take a look at the difference between the real & cpu time between the first and second applyConcept actions;
* Even with such small test data you should see a difference;

* Printing the parsing results as they are interesting;
* If you want to learn more about clauses please see the example ./202304/Claus-Type-Explanation.sas;
title1 'Intermediate parsing results created/used by the new parameters';
proc print data=casuser.parse_results label;
run; quit;
title;

* Ending the CAS session and thus dropping all tables created in this example;
cas mysess terminate;