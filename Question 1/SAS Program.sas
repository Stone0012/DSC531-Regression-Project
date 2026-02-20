libname IPEDS '~/IPEDS';
options fmtsearch=(IPEDS);
libname regpout '/export/viya/homes/stonesiferb@uncw.edu/DSC531 Project/Regression Project Out';

/**I think that we are going to be able to use most of this SQL code to get us started */

proc sql;
  create table GradRates as 
    select Grads.UnitId, Grads.Total/Cohort.Total as GradRate
    from ipeds.Graduation(where=(group contains 'Completers')) as Grads
            inner join
         ipeds.Graduation(where=(group contains 'Incoming')) as Cohort
      on Grads.UnitID eq Cohort.UnitID
  ;
  create table use as
    select GradRate, cbsatype, tuition2/1000 as tuition
    from GradRates, ipeds.characteristics(where=(cbsatype gt 0)), ipeds.tuitionandcosts
    where GradRates.UnitID eq Characteristics.UnitID eq tuitionandcosts.UnitID
  ;
quit;

*Hello, this is a test;