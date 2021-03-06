function ...            --- Ausgangsgr��en:
[engKinOptVec,      ... Vektor - Trajektorie der optimalen kin. Energien
    batEngDltOptVec,... Vektor - optimale Batterieenergie�nderung
    fulEngDltOptVec,... Vektor - optimale Kraftstoffenergie�nderung
    geaStaVec,         ... Vektor - Trajektorie des optimalen Antriebsstrangzustands
    fulEngOpt,      ... Skalar - optimale Kraftstoffenergie
    resVld          ...
    ] =             ...
    runAlgorithmusDP(       ...
    inputparams,            ...
    tst_scalar_struct,      ...
    fzg_scalar_struct,      ...
    tst_array_struct,       ...
    nedc_array_struct,      ...
    fzg_array_struct        ...
    )%#codegen
%% assign structure fields to variables
% inputparams - originally simulink inputs
disFlg          = inputparams.disFlg;
iceFlgBool      = inputparams.iceFlgBool;
timeStp         = inputparams.timeStp;
batEngStp       = inputparams.batEngStp;
batEngBegMinRat = inputparams.batEngBegMinRat;
batEngBegMaxRat = inputparams.batEngBegMaxRat;
batEngEndMinRat = inputparams.batEngEndMinRat;
batEngEndMaxRat = inputparams.batEngEndMaxRat;
batPwrAux       = inputparams.batPwrAux;
engBeg          = inputparams.engBeg;
engEnd          = inputparams.engEnd;
staChgPenCosVal = inputparams.staChgPenCosVal;
wayInxBeg       = inputparams.wayInxBeg;
wayInxEnd       = inputparams.wayInxEnd;
staBeg          = inputparams.staBeg;

% get the max 100% battery energy value possible
batEngMax       = fzg_scalar_struct.batEngMax;

% tst_scalar_struct - originally tstDat800 structure
staNum          = tst_scalar_struct.staNum;
engStaNum       = tst_scalar_struct.engStaNum;
% wayNum          = tst_scalar_struct.wayNum;
% engKinNum       = tst_scalar_struct.engKinNum;
% slpVec_wayInx               = tst_array_struct.slpVec_wayInx;
% engKinMat_engKinInx_wayInx  = tst_array_struct.engKinMat_engKinInx_wayInx;
% engKinNumVec_wayInx         = tst_array_struct.engKinNumVec_wayInx;

% nedc_array_struct - save vector values
timeVecRaw  = nedc_array_struct.vehVel(:,1);
velVecRaw   = nedc_array_struct.vehVel(:,2);
slopeVecRaw = nedc_array_struct.refSlpVec;
% acceleration : dV/dt
accVecRaw  = gradient(velVecRaw);

% discretize raw data wrt time interval step size
timeVec     = timeVecRaw(1) : timeStp : timeVecRaw(end);
[timeBool, timeIdx]= ismember(timeVecRaw, timeVec);
velVec      = velVecRaw(timeBool);
accVec      = accVecRaw(timeBool);
disVec      = velVec * timeStp;
slopeVec    = slopeVecRaw(timeBool);

% determine time length of interval
timeNum = length(timeVec);


% Prüfen(check), ob eine erlaubte Beschleunigung vorliegt.
% Ansonsten zum nächsten Schleifendurchlauf springen
%   Check whether an allowable acceleration exists - if not, warn user
% vehAcc = (engKinAct-engKinPre)/vehMas/wayStp;
if any(accVec < fzg_scalar_struct.vehAccMin) || any(accVec > fzg_scalar_struct.vehAccMax)
    overdemandAcc = find(accVec<fzg_scalar_struct.vehAccMin || accVec>fzg_scalar_struct.vehAccMax);
    fprintf('NOTE: acceleration demanded from speed profile cannot be supplied by the set model bounds (see idx %i)\n', overdemandAcc(1));
    fprintf('Demanded acceleration: %4.3f\n', accVec(overdemandedAcc));
    fprintf('vehAccMin: %4.3\n', fzg_scalar_struct.vehAccMin);
    fprintf('vehAccMax: %4.3\n', fzg_scalar_struct.vehAccMax);
end

%% define battery engine value from input ratios
% make sure that the ratio SOC is discretized to given input energy steps
batEngBegMin    = floor(batEngMax*batEngBegMinRat/batEngStp) * batEngStp;
batEngBegMax    = ceil(batEngMax*batEngBegMaxRat/batEngStp) * batEngStp;

% select a possible for stating battery energy (random discretized value
% between beg_min and beg_max battery energy values
batEngBegIdx_MaxPossible = (batEngBegMax - batEngBegMin);
batEngBegIdx_Possible = 0 : batEngStp : batEngBegIdx_MaxPossible;
batEngBeg = batEngBegMin + batEngBegIdx_Possible(randi(numel(batEngBegIdx_Possible)));

% boundary conditions the end battery energy must be within bounds of
batEngEndMin = floor(batEngMax*batEngEndMinRat/batEngStp) * batEngStp;
batEngEndMax = ceil(batEngMax*batEngEndMaxRat/batEngStp) * batEngStp;

%% Längsdynamik berechnen
%   calculate longitundinal dynamics
% Es wird eine konstante Beschleunigung angenommen, die im Wegschritt
% wayStp das Fahrzeug von velPre auf velAct beschleunigt.
%   constant acceleration assumed when transitioning from velPre to velAct
%   for the selected wayStp path_idx step distance

% Berechnen der konstanten Beschleunigung
%   calculate the constant acceleration
% vehAcc = (engKinAct - engKinPre) / (fzg_scalar_struct.vehMas*wayStp);

% Aus der mittleren kinetischen Energie im Intervall, der mittleren
% Steigung und dem Gang lässt sich über die Fahrwiderstandsgleichung
% die nötige Fahrwiderstandskraft berechnen, die aufgebracht werden
% muss, um diese zu realisieren.
%   from the (avg) kinetic energy in the interval, the (avg) slope and
%   transition can calculate the necessary traction force on the driving
%   resistance equation (PART OF EQUATION 5)

% Steigungskraft aus der mittleren Steigung berechnen (Skalar)
%   gradiant force from the calculated (average) gradient
vehFrcSlp = fzg_scalar_struct.vehMas * 9.81 * sin(slopeVec);

% Rollreibungskraft berechnen (Skalar)
%   calculated rolling friction force - not included in EQ 5???
vehFrcRol = fzg_scalar_struct.whlRosResCof*fzg_scalar_struct.vehMas * 9.81 * cos(slopeVec);

% Luftwiderstandskraft berechnen (2*c_a/m * E_kin) (Skalar) 
%   calculated air resistance force 
vehFrcDrg = fzg_scalar_struct.drgCof * velVec.^2;

%% Berechnung der minimalen kosten der Hamiltonfunktion
%   Calculating the minimum cost of the Hamiltonian

%% Berechnen der Kraft am Rad für Antriebsstrangmodus
%   calculate the force on the wheel for the drivetrain mode

% % dynamische Fahrzeugmasse bei Fahrzeugmotor an berechnen. Das
% % heißt es werden Trägheitsmoment von Verbrennungsmotor,
% % Elektromotor und Rädern mit einbezogen.
%   calculate dynamic vehicle mass with the vehicle engine (with the moment
%   of intertia of the ICE, electric motor, and wheels)
% vehMasDyn = (par.iceMoi_geaRat(gea) +...
%     par.emoGeaMoi_geaRat(gea) + par.whlMoi)/par.whlDrr^2 ...
%     + par.vehMas;

% Radkraft berechnen (Beschleunigungskraft + Steigungskraft +
% Rollwiderstandskraft + Luftwiderstandskraft)
%   caluclating wheel forces (accerlation force + gradient force + rolling
%   resistance + air resistance)    EQUATION 5
whlFrc  = accVec*fzg_scalar_struct.vehMas + vehFrcSlp + vehFrcRol + vehFrcDrg;
% side note: if vehicle velocity is zero, then set force at wheel to zero
whlFrc(velVec < 0.05) = 0;

% Das Drehmoment des Rades ergibt sich über den Radhalbmesser aus
% der Fahrwiderstandskraft.
%   the weel torque is obtained from the wheel radius of the rolling
%   resistance force (torque = force * distance (in this case, radius)
whlTrq = whlFrc*fzg_scalar_struct.whlDrr;

%% define vector for possibilities of engine state on-off values
%   2 = can toggle (two states, on-of)
%   1 = cannot toggle, must stay in current state for idx (most likely off)
engStaVec_wayInx = ones(wayInxEnd, 1)*2;
engStaVec_wayInx(wayInxBeg) = engBeg;
engStaVec_wayInx(wayInxEnd) = engEnd;

%% Calculating optimal predecessors with DP + PMP
fprintf('-Initializing model...\n');
[... --- Ausgangsgr��en:
    optPreInxTn3,   ...  Tensor 3. Stufe f�r opt. Vorg�ngerkoordinaten
    batFrcOptTn3,   ...  Tensor 3. Stufe der Batteriekraft
    fulEngOptTn3,   ...  Tensor 3. Stufe f�r die Kraftstoffenergie 
    cos2goActMat    ...  Matrix der optimalen Kosten der Hamiltonfunktion 
    ] =             ... 
    clcDP_a         ... FUNKTION
    (               ... --- Eingangsgr��en:
    disFlg,         ... Skalar - Flag f�r Ausgabe in das Commandwindow
    iceFlgBool,     ... skalar - is engine toggle on/off allowed?
    timeStp,        ... Skalar f�r die Wegschrittweite in m
    batEngStp,      ... Skalar der Batteriediskretisierung in J 
    batEngBeg,      ... Skalar f�r die Batterieenergie am Beginn in Ws
    batPwrAux,      ... Skalar f�r die Nebenverbrauchlast in W
    staChgPenCosVal,... Skalar f�r die Strafkosten beim Zustandswechsel
    wayInxBeg,      ... Skalar f�r Anfangsindex in den Eingangsdaten
    wayInxEnd,      ... Skalar f�r Endindex in den Eingangsdaten
    timeNum,        ... Skalar f�r die max. Anzahl an Wegst�tzstellen
    engBeg,         ... scalar - beginnnig engine state
    engStaVec_wayInx,...
    staBeg,         ... Skalar f�r den Startzustand des Antriebsstrangs
    velVec,         ... velocity vector contiaing input speed profile
    whlTrq,         ... wheel torque demand vector for the speed profile
    batEngEndMin,   ... SOC lower limit
    batEngEndMax,   ... SOC upper limit
    tst_scalar_struct,     ... struct w/ tst data state var params
    fzg_scalar_struct,     ... struct der Fahrzeugparameter - NUR SKALARS
    fzg_array_struct       ... struct der Fahrzeugparameter - NUR ARRAYS
    );

%% end conditions 
% why the rounding though?
engStaEndInxVal = ceil(engStaVec_wayInx(wayInxEnd)/2);
% end gear condition
staEnd = staBeg;
% end engine condition
engEnd;

% end battery charge condition - HOW TO IMPLEMENT??
batEngEndMin;
batEngEndMax;

%% Calculating optimal trajectories for result of DP + PMP
[...
    batEngDltOptVec,... Vektor - optimale Batterieenergie�nderung
    fulEngDltOptVec,... Vektor - optimale Kraftstoffenergie�nderung
    geaStaVec,      ... Vektor - Trajektorie des optimalen Antriebsstrangzustands
    fulEngOpt       ... Skalar - optimale Kraftstoffenergie
    ] =             ...
    clcOptTrj_a     ... FUNKTION
    (disFlg,        ... Flag, ob Zielzustand genutzt werden muss - CHANGE VAR NAME ITS THE SAME VAR FOR 2 DIFFERENT USES IN 2 FUNCTIONS
    timeStp,        ... Skalar f�r die Wegschrittweite in m
    timeNum,        ... Skalar f�r die max. Anzahl an Wegst�tzstellen
    wayInxBeg,      ... Skalar f�r Anfangsindex in den Eingangsdaten
    wayInxEnd,      ... Skalar f�r Endindex in den Eingangsdaten
    staEnd,         ... Skalar f�r den finalen Zustand
    engEnd,         ... scalar - final engine state
    engStaEndInxVal,... Skalar f�r Zielindex der kinetischen Energie
    staNum,         ... Skalar f�r die max. Anzahl an Zustandsst�tzstellen
    engStaNum,      ... scalar - for number of states engine can take
    optPreInxTn3,   ... Tensor 3. Stufe f�r opt. Vorg�ngerkoordinaten
    batFrcOptTn3,   ... Tensor 3. Stufe der Batteriekraft
    fulEngOptTn3,   ... Tensor 3. Stufe f�r die Kraftstoffenergie
    cos2goActMat    ... Matrix der optimalen Kosten der Hamiltonfunktion 
    );

% engKinOptVec=0;
% batEngDltOptVec=0;
% fulEngDltOptVec=0;
% staVec=0;
% psiEngKinOptVec=0;
% fulEngOpt=0;
resVld = true;

fprintf('\n\ndone!\n');
   
end