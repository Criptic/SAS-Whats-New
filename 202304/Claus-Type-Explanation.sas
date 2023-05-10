/*
    SAS Viya 2023.04 - Example created by David.Weik@sas.com
    This example highlights the types of clauses detected by the CLAUS_N operator
    Example for clause types from https://arxiv.org/pdf/2009.08560.pdf
*/

cas mysess;

libname casuser cas caslib='casuser';

* Generating our caluse examples;
data casuser.example_clauses;
    length clauseType $20. clauseTypeShorthand $5. text $240.;
    infile datalines delimiter='#' missover;
    input clauseType$ clauseTypeShorthand$ text$;
    datalines;
relative clause#rc#Scott Adsit voiced Baymax which was created by Duncan Rouleau.
apposition clause#appos#Leila married the movie director Ruy Guerra, father of her only daughter.
infinitive clause#inf#Nimfa was forced to take part of a devilish plan to fool the Saavedra family.
;
run;

* LITI rules example;
data casuser.liti_concepts;
    length ruleID 8. config $500.;
    infile datalines delimiter='#' missover;
    input ruleID config$;
    datalines;
1#CONCEPT_RULE:CLAUSEXAMPLEHIER1:(CLAUS_1, "_c{rocket}", "red")
;
run;

* Generate Document ID, Compile both concepts and Apply them;
proc cas;
    session mysess;
    output log;

    * Add a unique document ID to the text;
    textManagement.generateIds /
        casOut={name = "example_clauses_id", replace = True}
        id = "docID"
        table = {name = "example_clauses"};
   run;

   * Compile the text concepts;
    textRuleDevelop.compileConcept /
        casOut = {name = 'compiled_concepts', replace = True} 
        config = 'config'
        table = {name = 'liti_concepts'};
    run;

    * Apply the text concepts;
    textRuleScore.applyConcept /
        casOut = {name = 'applied_concepts', replace = True}
        parseTableOut = {name = 'parse_results', replace = True}
        language = 'ENGLISH'
        docId = 'docID'
        model = {name = 'compiled_concepts'}
        table = {name = 'example_clauses_id'}
        text = 'text';
    run;
quit;

* Drop the result table;
proc casutil;
	droptable incaslib='casuser' casdata='result' quiet;
run; quit;

* Join parsing results with text data;
proc fedsql sessref=mysess;
    create table casuser."result" as
        select (t3."docID") as "docID",
            (t3."clauseType") as "clauseType",
            (t3."clauseTypeShorthand") as "clauseTypeShorthand",
            (t1."text") as "text",
            (t1."_word_") as "_word_",
            (t1."_lemma_") as "_lemma_",
            (t1."_tag_") as "_tag_",
            (t1."_xtag_") as "_xtag_",
            (t1."_start_") as "_start_",
            (t1."_end_") as "_end_",
            (t1."_sid_") as "_sid_",
            (t1."_pid_") as "_pid_",
            (t1."_cid_") as "_cid_",
            (t1."_mcid_") as "_mcid_",
            (t1."_cpath_") as "_cpath_"
            from casuser."PARSE_RESULTS" t1
                inner join casuser."EXAMPLE_CLAUSES_ID" t3
                    on (t1."docID" = t3."docID");
run; quit;

* Printing the parsing results as they are interesting;
title1 'Intermediate parsing results created/used by the new parameters';
proc print data=casuser.result label;
run; quit;
title;

* Ending the CAS session and thus dropping all tables created in this example;
cas mysess terminate;