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

proc sql;
  create table GradRates as 
    select Grads.UnitId, Grads.Total/ge.Total as GradRate, grads.total, grads.men, grads.women,
            ge.graiant as American_Indian_or_Alaska_Native, 
            ge.grasiat as Asian_Total, 
            ge.grbkaat as Africant_American_Total, 
            ge.grhispt as Hispanic_Total, 
            ge.grnhpit as Hawaiian_Pacific_Islander_Total, 
            ge.grwhitt as White_Toal, 
            ge.gr2mort as Multi_Race, 
            ge.grunknt as Race_Unknown,
            c.iclevel as Level_of_institution,
            c.control,
            c.hloffer as Highest_level_offered,
            t.tuition2/1000 as In_State_Tution,
            t.tuition3/1000 as Out_State_Tution

    from ipeds.Graduation(where=(group = 'Completers within 150% of normal time')) as grads
                inner join
         ipeds.graduationextended(where=(group contains 'Incoming' and total ge 200)) as ge
            on Grads.UnitID eq ge.UnitID
                inner join
        ipeds.characteristics as c
            on ge.UnitID eq c.UnitID
                inner join
        ipeds.tuitionandcosts as t
            on c.unitid eq t.unitid
  ;
quit;