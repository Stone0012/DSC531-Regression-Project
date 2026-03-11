libname IPEDS '~/IPEDS';
options fmtsearch=(IPEDS);

proc sql;
  create table GradRates as 
    select grads.UnitId, 
           grads.Total / ge.Total as GradRate,
           grads.total, 
           grads.men, 
           grads.women,

           (ge.grasiat / ge.Total) as Asian,
           (ge.grbkaat / ge.Total) as African_American,
           (ge.grhispt / ge.Total) as Hispanic,
           (ge.grwhitt / ge.Total) as White,
           (ge.gr2mort / ge.Total) as Multi_Race,
           ((ge.graiant + ge.grnhpit) / ge.Total) as Race_Other,
           (ge.grunknt / ge.Total) as Race_Unknown,

           c.control,
           c.hloffer as Highest_level_offered,
           t.tuition2/1000 as In_State_Tution,
           t.tuition3/1000 as Out_State_Tution,
           s.total_staff,
           (ge.total / s.total_staff) as Student_Faculty_Ratio

    from ipeds.Graduation(where=(group = 'Completers within 150% of normal time')) as grads
    inner join ipeds.graduationextended(where=(group like '%Incoming%' and total ge 200)) as ge
        on grads.UnitID = ge.UnitID
    inner join ipeds.characteristics as c
        on ge.UnitID = c.UnitID
    inner join ipeds.tuitionandcosts as t
        on c.unitid = t.unitid
    left join (
        select put(unitid, 8.) as unitid_char,
               sa09mct as total_staff
        from ipeds.salaries
        where put(rank, ARANK.) = 'All instructional staff total'
    ) as s
        on s.unitid_char = put(grads.unitid, 8.);
quit;

proc means data=GradRates median;
  var GradRate;
run;
  
data GradRates2;
    set GradRates;
    if GradRate >= 0.599 then AboveMedian = 1;
    else AboveMedian = 0;
run;

/**Lasso**/

proc hpgenselect data=GradRates2;
    class control Highest_level_offered;
    model AboveMedian(event='1') =
        men
        Asian African_American Hispanic Multi_Race Race_Other
        control Highest_level_offered
        In_State_Tution
        Student_Faculty_Ratio
        / dist=binomial link=logit;
    selection method=lasso(choose=AIC);
run;

/**Below is the code for creating the Specs-- Leave commented out, dont need to run everytime;

ods noproctitle;
Title 'GradRates';
proc contents data=GradRates varnum;
  ods select position;
  ods output position=GradRatesSpecs;
run;

libname specs xlsx "~/LogRegProj/Question 2/Specs.xlsx";

proc datasets;
  copy out=Specs in=work;
  select GradRatesSpecs;
run;
libname specs clear;*/

/* ods pdf file="~/LogRegProj/Question 2/GradRate_Interpretation.pdf";

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
title; 

ods pdf file="~/LogRegProj/Question 2/GradRate_Interpretation.pdf";

title "Interpretation of Graduation Rate Model";

ods pdf text="C. The final model we chose is LASSO.";
ods pdf text=" ";
ods pdf text="We ran several models, forward, backward, and stepwise, all with a slentry and/or slstay of 0.05.";
ods pdf text="These models focused heavily on correlated factors and produced extreme odds ratios, even though they had similar AIC scores.";
ods pdf text="LASSO used fewer variables, had a lower AIC, and did not overemphasize correlated data such as race.";
ods pdf text="The variables selected by LASSO also appeared in the other models, showing they were consistently relevant.";
ods pdf text=" ";

ods pdf text="D. Interpretation of the Final Model:";
ods pdf text=" ";
ods pdf text="- Men: With all other variables kept constante, each additional male student increases the odds of being above the median graduation rate by about 0.083%, or 8.3% per 100 students.";
ods pdf text=" ";
ods pdf text="- In-State Tuition:  With all other variables kept constante, the odds increase by about 1.3% for every $1,000 increase in in-state tuition.";
ods pdf text=" ";
ods pdf text="- Student-Faculty Ratio:  With all other variables kept constante, the odds decrease by about 2.5% for every one-point increase in the ratio.";
ods pdf text=" ";
ods pdf text="In simpler terms, institutions with more men, higher tuition, and lower student-faculty ratios are more likely to have graduation rates above the median.";

ods pdf close;
title;*/