cas mysess;

libname casuser cas caslib='casuser';

* Load the HMEQ dataset to casuser;
* For more information on the SAMPSIO library see: https://support.sas.com/kb/57/addl/fusion_57672_1_sampsio_data_sets.pdf;
* The document also includes a description of the HMEQ dataset on page 9;
data casuser.hmeq(promote=yes);
    set sampsio.hmeq;
run;

cas mysess terminate;