/*
    SAS Viya 2023.04 - Example created by David.Weik@sas.com
    This example highlights the use of the CONVEXHULL subroutine in the IML Action Set and Proc IML.
    This example is build on top of the example provided by the SAS Documentation:
    https://go.documentation.sas.com/doc/en/pgmsascdc/v_038/casimllang/casimllang_common_sect061.htm
*/

cas mysess;

libname casuser cas caslib='casuser';

* Run the ConvexHull Subroutine as part of the IML Action Set;
proc cas;
    source computeConvexHull;
        points = {0 2,0.5 2,1 2,0.5 1,0 0,0.5 0,1 0,
                2 -1,2 0,2 1,3 0,4 1,4 0, 4 -1,
                5  2,5 1,5 0,6 0 };
        
        * Call the ConvexHull Subroutine;
        call convexhull(indices, va, points);
        hullIndices = indices[,1];
        cvxHull = points[hullIndices, ];

        * Print Results to log;
        print indices;
        print hullIndices cvxHull[c={'cx' 'cy'} L=''];
    endsource;

    loadactionset 'iml';
    iml / code=computeConvexHull;
run; quit;

* To further visualize the results please refer to the SAS Documentation linked above;

cas mysess terminate;

* Run the ConvexHull Subroutine as a Proc;
proc iml;
    points = {0 2,0.5 2,1 2,0.5 1,0 0,0.5 0,1 0,
    2 -1,2 0,2 1,3 0,4 1,4 0, 4 -1,
    5  2,5 1,5 0,6 0 };

    * Call the ConvexHull Subroutine;
    call convexhull(indices, va, points);
    hullIndices = indices[,1];
    cvxHull = points[hullIndices, ];

    * Print Results to log;
    print indices;
    print hullIndices cvxHull[c={'cx' 'cy'} L=''];
run;