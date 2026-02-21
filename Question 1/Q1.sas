libname IPEDS '~/IPEDS';
options fmtsearch=(IPEDS);
libname regpout '/export/viya/homes/stonesiferb@uncw.edu/DSC531 Project/Regression Project Out';

proc sql;
  create table GradRates as 
    select grads.UnitId, 
            grads.Total/ge.Total as GradRate, 
            grads.total, 
            grads.men, 
            grads.women,
            ge.grasiat as Asian_Total, 
            ge.grbkaat as African_American_Total, 
            ge.grhispt as Hispanic_Total, 
            ge.grwhitt as White_Toal, 
            ge.gr2mort as Multi_Race, 
            ge.graiant + ge.grnhpit as Race_Other,
            ge.grunknt as Race_Unknown,
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

proc means data=GradRates median;
  var GradRate;
run;
  
proc format;
  value mid
  low-0.566 = 'Below Median'
  other = 'Above Median'
  ;
run;

proc logistic data=GradRates;
  format GradRate mid.;
  class Highest_level_offered / param=glm;
  model GradRate = Highest_level_offered In_State_Tution;
  *ods select fitStatistics;
run;

proc logistic data=GradRates;
  format GradRate mid.;
  class control / param=glm;
  model GradRate = control In_State_Tution;
  *ods select fitStatistics;
run;

proc logistic data=GradRates;
  format GradRate mid.;
  class Highest_level_offered / param=glm;
  model GradRate = Highest_level_offered out_State_Tution;
  *ods select fitStatistics;
run;

proc logistic data=GradRates;
  format GradRate mid.;
  class control / param=glm;
  model GradRate = control out_State_Tution;
  *ods select fitStatistics;
run;

/**It looks like the most signficant relationships are control and instate tuition */

proc format;
  value quarters
  low-.421 = '4. Bottom Q'
  .421-.566 = '3. 3rd Q'
  .566-.699 = '2. 2nd Q'
  .699-high = '1. Top Q'
  ;
run;

Title 'All Proportional Odds';
proc logistic data=GradRates;
  format GradRate quarters.;
  class control/ param=glm;
  model GradRate = control in_State_Tution;
  ods select FitStatistics;
run;/**Proportional odds assumption fails**/

Title 'No Proportional Odds';
proc logistic data=GradRates;
  format GradRate quarters.;
  class control/ param=glm;
  model GradRate = control in_State_Tution / unequalslopes;
  ods select FitStatistics;
run;

Title 'Proportional Odds for Tuition';
proc logistic data=GradRates;
  format GradRate quarters.;
  class control/ param=glm;
  model GradRate = control in_State_Tution / unequalslopes=control;
  ods select FitStatistics;
run;

Title 'Proportional Odds for Control';
proc logistic data=GradRates;
  format GradRate quarters.;
  class control/ param=glm;
  model GradRate = control in_State_Tution / unequalslopes=in_State_Tution;
  ods select FitStatistics;
run;


/**AIC Says use 'Proportional Odds for Tuition' and SC says use 'Proportional Odds for Control', but only .105 lower 
        than 'Proportional Odds for Tuition'. AIC for 'Proportional Odds for Tuition' is 10.165 lower than AIC for 
        'Proportional Odds for Control'. There is minor disagreement in SC but drastic disagrement in AIC*/

Title 'Proportional Odds for Tuition';
proc logistic data=GradRates;
  format GradRate quarters.;
  class control/ param=glm;
  model GradRate = control in_State_Tution / unequalslopes=control link=alogit;
  *ods select ParameterEstimates OddsRatios FitStatistics;
run;

Title 'Proportional Odds for Control';
proc logistic data=GradRates;
  format GradRate quarters.;
  class control/ param=glm;
  model GradRate = control in_State_Tution / unequalslopes=in_State_Tution link=alogit;
  ods select ParameterEstimates OddsRatios FitStatistics;
run;

/**From this, AIC and Sc both agree that the best model is 'Proportional Odds for Tuition' */

*Below is the code for creating the Specs-- Leave commented out, dont need to run everytime;

/* ods noproctitle;
Title 'GradRates';
proc contents data=GradRates varnum;
  ods select position;
  ods output position=GradRatesSpecs;
run;

libname specs xlsx "~/LogRegProj/Question 1/Specs.xlsx";

proc datasets;
  copy out=Specs in=work;
  select GradRatesSpecs;
run;
libname specs clear; */

*Below is the code for creating the PDF output for the interpretation-- Leave commented out, dont need to run everytime; 


/* ods pdf file="~/LogRegProj/Question 1/GradRate_Interpretation.pdf";

title "Interpretation of Graduation Rate Model";

ods pdf text="1. Institution type is a significant predictor of gradrate.";
ods pdf text=" ";
ods pdf text="- Public institutions are far more likely to be in higher graduation-rate quartiles than either type of private institution.";
ods pdf text=" ";
ods pdf text="- Private for-profit institutions perform the worst.";
ods pdf text=" ";

ods pdf text="2. Higher in-state tuition predicts higher graduation rates.";
ods pdf text=" ";
ods pdf text="- This may reflect institutional resources, selectivity, or student socioeconomic factors.";
ods pdf text=" ";

ods pdf text="3. The model fits well and predicts well.";
ods pdf text=" ";
ods pdf text="- Strong likelihood ratio test, significant predictors, and a c-statistic near 0.8.";

ods pdf close;
title; */