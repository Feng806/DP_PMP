cd('C:\Users\s0032360\Documents\GitHub\DP_PMP\ford_focus\DP\');
% cd('/home/kaulef/Documents/DAAD/TUD/4Kaleb/ford_focus/DP')

addpath('../model_data')

[                       ...
    batEngBeg,          ... Skalar f�r die Batterieenergie am Beginn in Ws
    timVec,             ... Skalar f�r die Stufe der Batteriekraftmax. Anzahl an Wegst�tzstellen
    engStaVec_timInx,   ... scalar - end engine state
    batOcv,             ... battery voltage vector w/ value for each SOC
    velVec,             ... velocity vector contiaing input speed profile
    crsSpdMat,          ... crankshaft speed demand for each gear
    crsTrqMat,          ... crankshaft torque demand for each gear
    emoTrqMinPosMat,    ... min emoTrq along speed profile for each gear
    emoTrqMaxPosMat,    ... max emoTrq along speed profile for each gear
    emoPwrMinPosMat,    ... min emoPwr along speed profile for each gear
    emoPwrMaxPosMat,    ... max emoPwr along speed profile for each gear
    iceTrqMinPosMat,    ... min iceTrq along speed profile for each gear
    iceTrqMaxPosMat,    ... max iceTrq along speed profile for each gear
    batPwrMinIdxTn3,    ... min indexes/steps that bat can change
    batPwrMaxIdxTn3,    ... max indexes/steps that bat can change
    batPwrDemIdxTn3,    ... bat power demand if only EM is running
    inputparams,        ...
    tst_scalar_struct,  ... struct w/ tst data state var params
    fzg_scalar_struct,  ... struct der Fahrzeugparameter - NUR SKALARS
    fzg_array_struct    ... struct der Fahrzeugparameter - NUR ARRAYS] = ...
] =                     ...
    runDP_preProcessing ...
(                       ...
    inputparams,        ...
    tst_scalar_struct,  ...
    fzg_scalar_struct,  ...
    nedc_array_struct,  ...
    fzg_array_struct    ...
);
timNum = length(timVec);
%% Calculating optimal predecessors with DP
% two functions: one finding optimal gear state and one with input gea vals
fprintf('-Initializing model...\n'); 
tic
% DP that is calculating optimal gear state
if ~tst_scalar_struct.useGeaSta
[                       ... --- Ausgangsgr��en:
    optPreInxTn4,       ...  Tensor 4. Stufe f�r opt. Vorg�ngerkoordinaten
    batPwrOptTn4,       ...  Tensor 4. Stufe der Batteriekraft
    fulEngOptTn4,       ...  Tensor 4. Stufe f�r die Kraftstoffenergie 
    cos2goActTn3        ...  Tensor 4. der optimalen Kosten
] =                     ... 
    clcDP_focus         ... FUNKTION
(                       ... --- Eingangsgr��en:
    batEngBeg,          ... Skalar f�r die Batterieenergie am Beginn in Ws
    timNum,             ... Skalar f�r die Stufe der Batteriekraftmax. Anzahl an Wegst�tzstellen
    engStaVec_timInx,   ... scalar - end engine state
    batOcv,             ... battery voltage vector w/ value for each SOC
    velVec,             ... velocity vector contiaing input speed profile
    crsSpdMat,          ... crankshaft speed demand for each gear
    crsTrqMat,          ... crankshaft torque demand for each gear
    emoTrqMinPosMat,    ... min emoTrq along speed profile for each gear
    emoTrqMaxPosMat,    ... max emoTrq along speed profile for each gear
    emoPwrMinPosMat,    ... min emoPwr along speed profile for each gear
    emoPwrMaxPosMat,    ... max emoPwr along speed profile for each gear
    iceTrqMinPosMat,    ... min iceTrq along speed profile for each gear
    iceTrqMaxPosMat,    ... max iceTrq along speed profile for each gear
    batPwrMinIdxTn3,    ... min indexes/steps that bat can change
    batPwrMaxIdxTn3,    ... max indexes/steps that bat can change
    batPwrDemIdxTn3,    ... bat power demand if only EM is running
    inputparams,        ...
    tst_scalar_struct,  ... struct w/ tst data state var params
    fzg_scalar_struct,  ... struct der Fahrzeugparameter - NUR SKALARS
    fzg_array_struct    ... struct der Fahrzeugparameter - NUR ARRAYS
);
else
% sample input gear input vector:
%   geaStaVec = [geaStaMat(1:end-1); geaStaMat(end-1)]; 
  geaStaMat = load('geaStaMat');
  geaStaVec = geaStaMat.geaStaMat;

% DP that requires a gear input vector
[                       ... --- Ausgangsgr��en:
    optPreInxTn3,       ...  Tensor 4. Stufe f�r opt. Vorg�ngerkoordinaten
    batPwrOptTn3,       ...  Tensor 4. Stufe der Batteriekraft
    fulEngOptTn3,       ...  Tensor 4. Stufe f�r die Kraftstoffenergie 
    cos2goActMat        ...  Tensor 4. der optimalen Kosten
] =                     ... 
    clcDP_focus_useGeaVec     ... FUNKTION
(                       ... --- Eingangsgr��en:
    batEngBeg,          ... Skalar f�r die Batterieenergie am Beginn in Ws
    timNum,             ... Skalar f�r die Stufe der Batteriekraftmax. Anzahl an Wegst�tzstellen
    engStaVec_timInx,   ... scalar - end engine state
    batOcv,             ... battery voltage vector w/ value for each SOC
    velVec,             ... velocity vector contiaing input speed profile
    geaStaVec,          ... gear state input vector
    crsSpdMat,          ... crankshaft speed demand for each gear
    crsTrqMat,          ... crankshaft torque demand for each gear
    emoTrqMinPosMat,    ... min emoTrq along speed profile for each gear
    emoTrqMaxPosMat,    ... max emoTrq along speed profile for each gear
    emoPwrMinPosMat,    ... min emoPwr along speed profile for each gear
    emoPwrMaxPosMat,    ... max emoPwr along speed profile for each gear
    iceTrqMinPosMat,    ... min iceTrq along speed profile for each gear
    iceTrqMaxPosMat,    ... max iceTrq along speed profile for each gear
    batPwrMinIdxTn3,    ... min indexes/steps that bat can change
    batPwrMaxIdxTn3,    ... max indexes/steps that bat can change
    batPwrDemIdxTn3,    ... bat power demand if only EM is running
    inputparams,        ...
    tst_scalar_struct,  ... struct w/ tst data state var params
    fzg_scalar_struct,  ... struct der Fahrzeugparameter - NUR SKALARS
    fzg_array_struct    ... struct der Fahrzeugparameter - NUR ARRAYS
);
end