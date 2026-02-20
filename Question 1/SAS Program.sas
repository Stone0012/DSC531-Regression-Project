libname IPEDS '~/IPEDS';
options fmtsearch=(IPEDS);
libname regpout '/export/viya/homes/stonesiferb@uncw.edu/DSC531 Project/Regression Project Out';

*Can use this code to make the spec sheets;
/*
libname specs xlsx '~/GradRet/Updates2-26/Specs.xlsx';

proc datasets;
  copy out=Specs in=work;
  select AdmitSpecs DemographicsSpecs GraduationsSpecs GradingSpecs EnrollSpecs;
run;
libname specs clear;
*/



/**I think that we are going to be able to use most of this SQL code to get us started */

proc sql;
  create table GradRates as 
    select Grads.UnitId, Grads.Total/ge.Total as GradRate, grads.group
    from ipeds.Graduation(where=(group = 'Completers within 150% of normal time')) as grads
            inner join
         ipeds.graduationextended(where=(group contains 'Incoming' and total ge 200)) as ge
      on Grads.UnitID eq ge.UnitID
  ;
quit;