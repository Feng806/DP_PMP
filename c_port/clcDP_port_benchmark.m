% clcDP_port_benchmark.m
% for matlab_coder purposes

inputparams = load('inputparams');
% 
% % asign values from struct
disFlg          = inputparams.disFlg;
wayStp          = inputparams.wayStp;
batEngStp       = inputparams.batEngStp;
batEngBeg       = inputparams.batEngBeg;
batPwrAux       = inputparams.batPwrAux;
psiBatEng       = inputparams.psiBatEng;
psiTim          = inputparams.psiTim;
staChgPenCosVal = inputparams.staChgPenCosVal;
wayInxBeg       = inputparams.wayInxBeg;
wayInxEnd       = inputparams.wayInxEnd;
staBeg          = inputparams.staBeg;

[engKinOptVec,      ... Vektor - Trajektorie der optimalen kin. Energien
    batEngDltOptVec,... Vektor - optimale Batterieenergie�nderung
    fulEngDltOptVec,... Vektor - optimale Kraftstoffenergie�nderung
    staVec,         ... Vektor - Trajektorie des optimalen Antriebsstrangzustands
    psiEngKinOptVec,... Vektor - costate f�r kinetische Energie
    fulEngOpt,      ... Skalar - optimale Kraftstoffenergie
    resVld]          ...
    = clcDP_port(disFlg,         ...
    wayStp,         ...
    batEngStp,      ...
    batEngBeg,      ...
    batPwrAux,      ...
    psiBatEng,      ...
    psiTim,         ...
    staChgPenCosVal,...
    wayInxBeg,      ...
    wayInxEnd,      ...
    staBeg          ...#
    );