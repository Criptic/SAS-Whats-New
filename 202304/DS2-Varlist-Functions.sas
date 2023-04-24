/*
    SAS Viya 2023.04 - Example created by David.Weik@sas.com
    This example highlights the two new DS2 function vGetValue() and vSetValue
    The new functions enable better manipultation of the varlist DS2 data structure
    For more information please refer to the SAS Documentation:
    https://go.documentation.sas.com/doc/en/pgmsascdc/v_038/ds2pg/n1xmv73f2gyoddn1ssiuqonjwutp.htm

    The baseline example was taken from the SAS Documentation:
    https://go.documentation.sas.com/doc/en/pgmsascdc/v_038/ds2pg/n0bk99gpptmbfxn1leucrebh80ft.htm
*/

* Create a varlist, set the value depending on the type and then get the value;
proc ds2;
    data _null_;
        * Declare empty variables of different data types;
        vararray double xArray[5];
        dcl bigint xBigint;
        dcl varchar(15) xChar;
    
        * Create a varlist of all variables starting with x;
        varlist t1 [x:];
    
        * Print the names, types and values of a varlist;
        method printVarlist(varlist v);
            dcl varchar(100) name type valueV;
            dcl bigint i;
            dcl double valueD;

            * Iterate over all elements of the varlist;
            do i = 1 to dim(v);
                * Get the name and type of the element;
                name = vname(v[i]);
                type = vtype(v[i]);
                * Depending on the type change the value;
                if (type = 'bigint') then do;
                    * Set the value of the current element;
                    vsetvalue(v[i], i * 100);
                    * Get the value of the current element;
                    vgetvalue(v[i], valueD);
                end;
                else if (type = 'double') then do;
                    vsetvalue(v[i], i * 25);
                    vgetvalue(v[i], valueD);
                end;
                else if (type = 'varchar') then do;
                    vsetvalue(v[i], 'Hello World');
                    vgetvalue(v[i], valueV);
                end;
                * Print everything to the log;
                put name= type= valueD= valueV=;
            end;
        end;
    
        * Call the method;
        method init();
            printVarlist(t1);
        end;
    enddata; 
run; quit;

* Check the log - it should look like this:;
/*
name=xarray1 type=double valueD=25 valueV=
name=xarray2 type=double valueD=50 valueV=
name=xarray3 type=double valueD=75 valueV=
name=xarray4 type=double valueD=100 valueV=
name=xarray5 type=double valueD=125 valueV=
name=xbigint type=bigint valueD=600 valueV=
name=xchar type=varchar valueD=600 valueV=Hello World
*/