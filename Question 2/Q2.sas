libname IPEDS '~/IPEDS';
options fmtsearch=(IPEDS);

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
  
data GradRates2;
    set GradRates;
    if GradRate >= 0.599 then AboveMedian = 1;
    else AboveMedian = 0;
run;

/*Forward*/
ods select ModelInfo ClassLevelInfo FitStatistics ParameterEstimates OddsRatios;

proc logistic data=GradRates2;
    class control Highest_level_offered / param=ref;
    model AboveMedian(event='1') = 
        men
        Asian_Total African_American_Total Hispanic_Total Multi_Race Race_Other
        control Highest_level_offered
        In_State_Tution
        / selection=forward slentry=0.05;
run;

ods select all;

/*Stepwise*/
ods select ModelInfo ClassLevelInfo FitStatistics ParameterEstimates OddsRatios;

proc logistic data=GradRates2;
    class control Highest_level_offered / param=ref;
    model AboveMedian(event='1') =
        men
        Asian_Total African_American_Total Hispanic_Total Multi_Race Race_Other
        control Highest_level_offered
        In_State_Tution
        / selection=stepwise slentry=0.05 slstay=0.05;
run;


ods select all;

/*Backward**/

ods select ModelInfo ClassLevelInfo FitStatistics ParameterEstimates OddsRatios;

proc logistic data=GradRates2;
    class control Highest_level_offered / param=ref;
    model AboveMedian(event='1') =
        men
        Asian_Total African_American_Total Hispanic_Total Multi_Race Race_Other
        control Highest_level_offered
        In_State_Tution
        / selection=backward slstay=0.05;
run;

ods select all;

/**Lasso**/

ods select ModelInfo ClassLevelInfo FitStatistics ParameterEstimates OddsRatios;

proc logistic data=GradRates2;
    class control Highest_level_offered / param=ref;
    model AboveMedian(event='1') =
        men
        Asian_Total African_American_Total Hispanic_Total Multi_Race Race_Other
        control Highest_level_offered
        In_State_Tution;
run; 

ods select all;