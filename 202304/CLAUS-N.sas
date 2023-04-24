/*
    SAS Viya 2023.04 - Example created by David.Weik@sas.com
    This example highlights the new Boolean Operator in LITI: CLAUS_N
    The new operator can be used in Concept Rules and Facts (PREDICATE_RULE & SEQUENCE) extraction
    For more information please refer to the SAS Documentation:
    https://go.documentation.sas.com/doc/en/capcdc/v_020/ctxtcdc/ctxtug/p1kf71w7npr9ecn1gysvovfs42x2.htm#p16mjew7hq51znn1taqy0mwncwv5

    If you want to learn more about clauses please see the example ./202304/Claus-Type-Explanation.sas
*/

cas mysess;

libname casuser cas caslib='casuser';

* Generating our baseline text that will be parsed;
data casuser.example_text;
    length text $240.;
    infile datalines delimiter='|' missover;
    input text$;
    datalines;
We will find a way to the moon without a red rocket.
When will be going to the moon and when will we do it without a red rocket?
Having gone to the moon in a rocket, which was red.
Without a rocket, why wouldn't you want to go to the moon in a red one?
;
run;

* LITI rules example;
data casuser.liti_concepts;
    length ruleID 8. config $500.;
    infile datalines delimiter='#' missover;
    input ruleID config$;
    datalines;
1#CONCEPT_RULE:CLAUSEXAMPLEHIER1:(CLAUS_1, "_c{rocket}", "red")
2#CONCEPT_RULE:CLAUSEXAMPLEHIER2:(CLAUS_2, "_c{rocket}", "red")
3#CONCEPT_RULE:CLAUSEXAMPLERED:(CLAUS_1, "_c{red}", "rocket")
;
run;

* Generate Document ID, Compile the concepts, Validate the concepts and Apply them;
proc cas;
    session mysess;
    output log;

    * Add a unique document ID to the text;
    textManagement.generateIds /
        casOut = {name = "example_text_id", replace = True}
        id = "docID"
        table = {name = "example_text"};
   run;

   * Compile the text concepts;
    textRuleDevelop.compileConcept /
        casOut = {name = 'compiled_concepts', replace = True} 
        config = 'config'
        table = {name = 'liti_concepts'};
    run;

    * Check the validity of the concept;
    * You can check the table casuser.error_concepts for any issues;
    textRuleDevelop.validateConcept /
      casOut = {name = "error_concepts", replace = True}
      config = "config"
      ruleId = "ruleID"
      table = {name = "liti_concepts"};
   run;

    * Apply the text concepts;
    textRuleScore.applyConcept /
        casOut = {name = 'applied_concepts', replace = True}
        language = 'ENGLISH'
        docId = 'docID'
        model = {name = 'compiled_concepts'}
        table = {name = 'example_text_id'}
        text = 'text';
    run;
quit;

* Drop the result table;
proc casutil;
	droptable incaslib='casuser' casdata='result' quiet;
run; quit;

* Join concept results with text data;
proc fedsql sessref=mysess;
    create table casuser."result" as
        select (t1."docID") as "docID",
            (t2."text") as "text"
            (t1."_path_") as "_path_",
            (t1."_concept_") as "_concept_",
            (t1."_start_") as "_start_",
            (t1."_end_") as "_end_",
            (t1."_match_text_") as "_match_text_",
            (t1."_canonical_form_") as "_canonical_form_"
            from casuser."APPLIED_CONCEPTS" t1
                inner join casuser."EXAMPLE_TEXT_ID" t2
                    on (t1."docID" = t2."docID");
run; quit;

* Print the results;
title 'Result of using the CLAUS_N Operator';
proc print data=casuser.result(drop=_path_ _canonical_form_) noobs;
run; quit;
title;

* Ending the CAS session and thus dropping all tables created in this example;
cas mysess terminate;