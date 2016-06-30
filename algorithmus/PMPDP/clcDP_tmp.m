function ...            --- Ausgangsgr��en:
[engKinOptVec,...       Vektor - Trajektorie der optimalen kin. Energien
    batEngDltOptVec, ...Vektor - optimale Batterieenergie�nderung
    fulEngDltOptVec,... Vektor - optimale Kraftstoffenergie�nderung
    staVec,...          Vektor - Trajektorie des optimalen Antriebsstrangzustands
    psiEngKinOptVec,... Vektor - costate f�r kinetische Energie
    fulEngOpt, ...      Skalar - optimale Kraftstoffenergie
    resVld...
    ] = ...
    clcDP_tmp...
    ( ...               --- Eingangsgr��en:
    disFlg, ...         Skalar - Flag f�r Ausgabe in das Commandwindow
    wayStp,...          Skalar f�r die Wegschrittweite in m
    batEngStp,...       Skalar der Batteriediskretisierung in J
    batEngBeg,...       Skalar f�r die Batterieenergie am Beginn in Ws
    batPwrAux,...       Skalar f�r die Nebenverbrauchlast in W
    psiBatEng,...       Skalar f�r den Co-State der Batterieenergie
    psiTim,...          Skalar f�r den Co-State der Zeit
    staChgPenCosVal,... Skalar f�r die Strafkosten beim Zustandswechsel
    wayInxBeg,...       Skalar f�r Anfangsindex in den Eingangsdaten
    wayInxEnd,...       Skalar f�r Endindex in den Eingangsdaten
    engKinNum,...       Skalar f�r die max. Anz. an engKin-St�tzstellen
    staNum,...          Skalar f�r die max. Anzahl an Zustandsst�tzstellen
    wayNum,...          Skalar f�r die max. Anzahl an Wegst�tzstellen
    staBeg,...          Skalar f�r den Startzustand des Antriebsstrangs
    engKinNumVec_wayInx,... Vektor der Anzahl der kinetischen Energien
    slpVec_wayInx,...   Vektor der Steigungen in rad
    engKinMat_engKinInx_wayInx,... Matrix der kinetischen Energien in J%#codegen
    FZG) %#codegen

%% Calculating optimal predecessors with DP + PMP
fprintf('Start\n');
[... --- Ausgangsgr��en:
    optPreInxTn3, ...   Tensor 3. Stufe f�r opt. Vorg�ngerkoordinaten
    batFrcOptTn3, ...   Tensor 3. Stufe der Batteriekraft
    fulEngOptTn3, ...   Tensor 3. Stufe f�r die Kraftstoffenergie 
    cos2goActMat ...    Matrix der optimalen Kosten der Hamiltonfunktion 
    ] = ... 
    clcDP_olyHyb_tmp...     FUNKTION
    ( ...               --- Eingangsgr��en:
    disFlg, ...         Skalar - Flag f�r Ausgabe in das Commandwindow
    wayStp,...          Skalar f�r die Wegschrittweite in m
    batEngStp,...       Skalar der Batteriediskretisierung in J
    batEngBeg,...       Skalar f�r die Batterieenergie am Beginn in Ws
    batPwrAux,...       Skalar f�r die Nebenverbrauchlast in W
    psiBatEng,...       Skalar f�r den Co-State der Batterieenergie
    psiTim,...          Skalar f�r den Co-State der Zeit
    staChgPenCosVal,... Skalar f�r die Strafkosten beim Zustandswechsel
    wayInxBeg,...       Skalar f�r Anfangsindex in den Eingangsdaten
    wayInxEnd,...       Skalar f�r Endindex in den Eingangsdaten
    1,...               Skalar f�r den Index der Anfangsgeschwindigkeit
    engKinNum,...       Skalar f�r die max. Anz. an engKin-St�tzstellen
    staNum,...          Skalar f�r die max. Anzahl an Zustandsst�tzstellen
    wayNum,...          Skalar f�r die max. Anzahl an Wegst�tzstellen
    staBeg,...          Skalar f�r den Startzustand des Antriebsstrangs
    engKinNumVec_wayInx,... Vektor der Anzahl der kinetischen Energien
    slpVec_wayInx,...   Vektor der Steigungen in rad
    engKinMat_engKinInx_wayInx,... Matrix der kinetischen Energien in J
    FZG...              struct der Fahrzeugparameter
    );
engKinEndInxVal = ceil(engKinNumVec_wayInx(wayInxEnd)/2);
staEnd = staBeg;

%% Calculating optimal trajectories for result of DP + PMP
[engKinOptVec,...       Vektor - Trajektorie der optimalen kin. Energien
    batEngDltOptVec, ...Vektor - optimale Batterieenergie�nderung
    fulEngDltOptVec,... Vektor - optimale Kraftstoffenergie�nderung
    staVec,...          Vektor - Trajektorie des optimalen Antriebsstrangzustands
    psiEngKinOptVec,... Vektor - costate f�r kinetische Energie
    fulEngOpt ...       Skalar - optimale Kraftstoffenergie
    ] = ...
    clcOptTrj_tmp...        FUNKTION
    (false,...          Flag, ob Zielzustand genutzt werden muss
    wayStp,...          Skalar f�r die Wegschrittweite in m
    wayNum,...          Skalar f�r die max. Anzahl an Wegst�tzstellen
    wayInxBeg,...       Skalar f�r Anfangsindex in den Eingangsdaten
    wayInxEnd,...       Skalar f�r Endindex in den Eingangsdaten
    staEnd,...          Skalar f�r den finalen Zustand
    engKinNum,...       Skalar f�r die max. Anz. an engKin-St�tzstellen
    engKinEndInxVal,... Skalar f�r Zielindex der kinetischen Energie
    staNum,...          Skalar f�r die max. Anzahl an Zustandsst�tzstellen
    engKinNumVec_wayInx,... Vektor der Anzahl der kinetischen Energien
    engKinMat_engKinInx_wayInx,... Matrix der kinetischen Energien in J
    optPreInxTn3,...    Tensor 3. Stufe f�r opt. Vorg�ngerkoordinaten
    batFrcOptTn3, ...   Tensor 3. Stufe der Batteriekraft
    fulEngOptTn3, ...   Tensor 3. Stufe f�r die Kraftstoffenergie
    cos2goActMat ...    Matrix der optimalen Kosten der Hamiltonfunktion 
    );

% engKinOptVec=0;
% batEngDltOptVec=0;
% fulEngDltOptVec=0;
% staVec=0;
% psiEngKinOptVec=0;
% fulEngOpt=0;
resVld = true;

fprintf('\n\nStop\n');
   
end