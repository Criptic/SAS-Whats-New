/*******************************************************************************************************************************************
    This script showcases the new SAS Viya Glossary REST API

    The script is meant to be run from SAS Studio or via the SAS extension for VS Code. The implicit SAS session authorization is used.

    Note in order to write to the Glossary you will need the corresponding capability - SAS Documentation:
    https://go.documentation.sas.com/doc/en/infocatcdc/default/infocatag/n1xniiffqq05c9n1n31o997vvdwu.htm#p0vf1emhy5f723n11yc3roh90k3q

    The full API documentation can be found here: https://developer.sas.com/rest-apis/glossary-v1

    The API is devided into to broad categories:
    1. Term Types, are functional groups for the individual terms, e.g. sort them by business function. Term types can have attributes
      which are then inherited by all the terms grouped under that term type and can be made required or optional.
    2. Terms, are concepts and definitions that are relevant to specific parts of the organization. A term must have a term type and
      can optionally have a parent term which enables further grouping.

    Note this script doesn't dive into deep into filtering, sorting and pagination with the SAS Viya APIs and rather focuses on
      the foundamentals.

    Note in Post requests if not stated otherwise the attribute is required.

    Required License: The SAS Viya Glossary is part of the SAS Information Governance license
*******************************************************************************************************************************************/

* Get the Viya Host URL;
%let viyaHost=%sysfunc(getoption(SERVICESBASEURL));

/***********************
    Term Type Section
***********************/
* Get a list of the term types - https://developer.sas.com/rest-apis/glossary-v1?operation=getTermTypes;
filename trmTpOut temp;

proc http
    method='Get'
    url="&viyaHost./glossary/termTypes"
    oauth_bearer = sas_services
    out=trmTpOut;
    headers 'Accept' = 'application/json';
run; quit;

libname trmTpOut json;

title 'List of the available Term Types';
proc print data=trmTpOut(drop=ordinal_root ordinal_items) noObs;
run; quit;
title;

* Clean up;
libname trmTpOut clear;
filename trmTpOut clear;

* Create a new term type - https://developer.sas.com/rest-apis/glossary-v1?operation=createTermType;
filename trmTpIn temp;

* Define the term type;
data _null_;
    file trmTpIn;
    put '{';
    * Names can be up to 100 characters long and must be unique (case-sensitive);
    put '"name": "Test Term Type",';
    * Label can be up to 100 characters long, if you specify a label it replaces the UI name for the user - optional;
    put '"label": "Test term type label",';
    * Description can be up to 1.000 characters long - optional;
    put '"description": "This is just a test term type and can be deleted",';
    * Base Type specifies if this term type is based on another term type - optional;
    *put '"baseType": "term",';
    * Attributes an ordered list of attributes - optional;
    put '"attributes": [';
    put '{';
    * Name of the attribute can be up to 63 characters long and must be unique (case-sensitive);
    put '"name": "Test Attribute",';
    * Specify the type of attribute: single-line, multi-line, single-select, multi-select, boolean, date, time & date-time;
    put '"type": "single-line",';
    * Label of the attribute can be up to 100 characters long and must be unique (case-sensitive) - optional;
    put '"label": "Test attribute label",';
    * Description of the attribute can be up to 140 characters long - optional;
    put '"description": "Test attribute description",';
    * Indicate if the attribute should be hidden from the user interface - optional, defaults to false;
    put '"hidden": false,';
    * Indicate if the attribute is required for terms - optional, defaults to false;
    put '"required": false,';
    * Editor options that are used to specify additional properties of the editor controls - optional;
    *put '"editorOptions": {"key": "value"},';
    * Specify a list of possible attribute values - required if the attribute type is single-select or multi-select;
    * put '"items": ["Value 1", "Value 2", "..."],';
    * The default value of the attribute - optional, if single-select or multi-select must be within the items list;
    put '"defaultValue": "Testing"';
    put '}';
    * Now you could add additional attributes here;
    put ']';
    put '}';
run;

filename trmTpOut temp;

proc http
    method='Post'
    url="&viyaHost./glossary/termTypes"
    oauth_bearer = sas_services
    in=trmTpIn
    out=trmTpOut;
    headers 'Accept' = 'application/json';
    headers 'Content-Type' = 'application/vnd.sas.glossary.term.type+json';
run; quit;

libname trmTpOut json;

* Get the ID of the newly created term type;
proc sql noPrint;
    select id into :newTermTypeID
        from trmTpOut.root;
run; quit;

%put &=newTermTypeID;

* Clean up;
filename trmTpIn clear;
libname trmTpOut clear;
filename trmTpOut clear;

* Get information about a specific term - https://developer.sas.com/rest-apis/glossary-v1?operation=getTermType;
* Note this section reuses the ID from the previous request called newTermTypeID;
filename trmTpOut temp;

proc http
    method='Get'
    url="&viyaHost./glossary/termTypes/&newTermTypeID."
    oauth_bearer = sas_services
    out=trmTpOut;
    headers 'Accept' = 'application/json';
run; quit;

libname trmTpOut json;

title 'Base information about the term type';
proc print data=trmTpOut.root(drop=ordinal_root) noObs;
run; quit;
title;

title 'Information about the term type attributes';
proc print data=trmTpOut.attributes(drop=ordinal_root ordinal_attributes) noObs;
run; quit;
title;

* Clean up;
libname trmTpOut clear;
filename trmTpOut clear;

* Delete a term type - https://developer.sas.com/rest-apis/glossary-v1?operation=deleteTermType; 
proc http
    method='Delete'
    url="&viyaHost./glossary/termTypes/&newTermTypeID."
    oauth_bearer = sas_services;
    headers 'Accept' = 'application/json';
run; quit;

* Clean up;
%symdel newTermTypeID;

/***********************
    Term Section
***********************/
* Get a list of terms - https://developer.sas.com/rest-apis/glossary-v1?operation=getTerms;
filename trmOut temp;

proc http
    method='Get'
    url="&viyaHost./glossary/terms"
    oauth_bearer = sas_services
    out=trmOut;
    headers 'Accept' = 'application/json';
run; quit;

libname trmOut json;

title 'List of terms';
proc print data=trmOut.items(drop=ordinal_root ordinal_items) noObs;
run; quit;
title;

* Clean up;
libname trmOut clear;
filename trmOut clear;

* Create a new term - https://developer.sas.com/rest-apis/glossary-v1?operation=createTerm;
* In odrder to create a new term, you have to provide a term type ID - the following retrieves the ID of the Default Term Type;
filename trmTpOut temp;

proc http
    method='Get'
    url="&viyaHost./glossary/termTypes?filter=eq(label,'Default Term Type')"
    oauth_bearer = sas_services
    out=trmTpOut;
    headers 'Accept' = 'application/json';
run; quit;

libname trmTpOut json;

proc sql noPrint;
    select id into :termTypeID
        from trmTpOut.items;
run; quit;

filename trmIn temp;

* Define the term;
data _null_;
    file trmIn;
    put '{';
    * Names can be up to 100 characters long and must be unique (case-sensitive);
    put '"name": "Test Term",';
    * Label can be up to 100 characters long, if you specify a label it replaces the UI name for the user - optional;
    put '"label": "Test term label",';
    * Description can be up to 1.000 characters long - optional;
    put '"description": "This is just a test term and can be deleted",';
    * The term type id can be set here and is immutable after the term has been published;
    termTypeID = '"termTypeId": "' || "&termTypeID." || '",';
    put termTypeID;
    * The parent ID enables you to create an additional hierarchy between terms - optional but immutable for drafts of published terms;
    * put '"parentId": "Parent Term UUID",';
    * Specify attributes and their value as key value pairs - required, if required by the term type and optional if there are optional attributes available via the term type;
    * put '"attributes": {';
    * put '"attribute1": "value1",';
    * put '"attribute2": "value2"';
    * put '},';
    * Describes the term and its purpose can be up to 450 characters long - optional;
    put '"definition": "This is the definition of the actual term"';
    put '}';
run;

filename trmOut temp;

* One important note here is the additional URL query parameter publish;
* The parameter is optional and defaults to false, which means the term will be created as a draft;
* If you set the value to true instead the term will be published;
proc http
    method='Post'
    url="&viyaHost./glossary/terms?publish=false"
    oauth_bearer = sas_services
    in=trmIn
    out=trmOut;
    headers 'Accept' = 'application/json';
    headers 'Content-Type' = 'application/vnd.sas.glossary.term+json';
run; quit;

libname trmOut json;

proc sql noPrint;
    select id into :newTermID
        from trmOut.root;
run; quit;

%put &=newTermID;

* Clean up;
libname trmTpOut clear;
filename trmTpOut clear;
libname trmOut clear;
filename trmOut clear;
%symdel termTpyeID;

* Select the deletion method based on the query parameter you set on the term creation;
* Delete a published term - https://developer.sas.com/rest-apis/glossary-v1?operation=deleteTerm;
proc http
    method='Delete'
    url="&viyaHost./glossary/terms/&newTermID."
    oauth_bearer = sas_services;
run; quit;

* Delete a drafted term - https://developer.sas.com/rest-apis/glossary-v1?operation=deleteDraft;
proc http
    method='Delete'
    url="&viyaHost./glossary/terms/&newTermID./draft"
    oauth_bearer = sas_services;
run; quit;

* Clean up;
%symdel newTermID;

* Final clean up;
%symdel viyaHost;