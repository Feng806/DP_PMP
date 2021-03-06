function [minFulLvl,batFrcOut,fulFrcOut] = ...
    clcPMP_a(                   ...
            engStaPre,          ...
            gea,                ...
            batEng,             ...
            batPwrAux,          ...
            batEngStp,          ...
            timeStp,            ...
            vehVelVec,          ...
            whlTrqPre,          ...
            batEngEndMin,       ... SOC lower limit
            batEngEndMax,       ... SOC upper limit
            fzg_scalar_struct,  ...
            fzg_array_struct)
%#codegen
%CLCPMP Minimizing Hamiltonian: Co-States for soc and time
% Erstellungsdatum der ersten Version 19.08.2015 - Stephan Uebel
%
% Batterieleistungsgrenzen hinzugefügt am 13.12.2015
% ^^added battery power limit
%
% Massenaufschlag durch Trägheitsmoment herausgenommen
% ^^Mass increment removed by inertia
%
% % 06.07.2016 - replacing KE state dimension with engine control

%% Inputdefinition
% engStaPre     - Double(1,1)  - engine state at start of interval (J)
% engStaAct     - Double(1,1)  - engine state at end of interval (J)
% gea           - Double(1,1)  - Gang
%                                ^^ gear
% slp           - Double(1,1)  - Steigung in rad
%                                ^^ slope in radians
% iceFlg        - Boolean(1,1) - Flag für Motorzustand-REMOVED 12.07.2016
%                                ^^ flag for motor condition
% batEng        - Double(1,1)  - Batterieenergie in J
%                                ^^ battery energy (J)
% batPwrAux     - Double(1,1)  - elektr. Nebenverbraucherleistung in W
%                                ^^ electric auxiliary power consumed (W)
% batEngStp     - Double(1,1)  - Drehmomentschritt
%                                ^^ torque step <- no, it's a battery step
% timeStp        - Double(1,1)  - Intervallschrittweite in m
%                                ^^ interval step distance - now [sec]
% fzg_scalar_struct    - Struct(1,1)  - Modelldaten - nur skalar
% fzg_array_struct     - Struct(1,1)  - Modelldaten - nur arrays                             

%% Initialisieren der Ausgabe der Funktion
%   initializing function output

% Ausgabewert des Minimums der Hamiltonfunktion
%   output for minimizing the hamiltonian
minFulLvl = inf;
% Batterieladungsänderung im Wegschritt beir minimaler Hamiltonfunktion
%   battery change in path_idx step with the minial hamiltonian
batFrcOut = inf;
% Kraftstoffkraftänderung im Wegschritt bei minimaler Hamiltonfunktion
%   fuel change in path_idx step with the minimal hamiltonian
fulFrcOut = 0;

%% Initialisieren der persistent Größen
%   initialize the persistance variables

% Diese werden die nur einmal für die Funktion berechnet
%   only calculated once for the function

persistent crsSpdHybMax crsSpdHybMin crsSpdEmoMax

if isempty(crsSpdHybMax)
    
    % maximale Drehzahl Elektrommotor
    %   maximum electric motor rotational speed
    crsSpdEmoMax = fzg_array_struct.emoSpdMgd(1,end);
    
    % maximale Drehzahl der Kurbelwelle
    %   maximum crankshaft rotational speed
    % 12.07.2016 - IF THIS IS FINDING THE HYBRID MAX CRS SPEED, THEN WHY
    % ARE WE SECTNIG THE MINIMUM RATHER THAN THE MAXIMUM? IS IT BECAUSE THE
    % EM CAN ONLY ROTATE SO FAST?? OTHERWISE WHY NOT LET THE ICE TAKE OVER?
    crsSpdHybMax = min(fzg_array_struct.iceSpdMgd(1,end),crsSpdEmoMax);
    
    % minimale Drehzahl der Kurbelwelle
    %   minimum crankshaft rotational speed
    crsSpdHybMin = fzg_array_struct.iceSpdMgd(1,1);
    
end

%% vorzeitiger Funktionsabbruch?
%   premature function termination?
% Drehzahl der Kurbelwelle und Grenzen
%   crankshaft speed and limits

% Aus den kinetischen Energien des Fahrzeugs wird über die Raddrehzahl
% und die übersetzung vom Getriebe die Kurbelwellendrehzahl berechnet.
% Zeilenrichtung entspricht den Gängen. (Zeilenvektor)
%   from the vehicle's kinetic energy, the crankshaft speed is calculated
%   by the speed and gearbox translation. Line direction corresponding to
%   the aisles (row rector). EQUATION 1
%
% since a speed profile is being provided and velocity does not have to be
% calculated for every KE state (they do not exist here), velocity for the
% crs can be calculated vector style for each gear, as vehVel can be
% inputted as a vector
%
% but may need to do this time index by time index instead
crsSpdVec  = fzg_array_struct.geaRat(gea) * vehVelVec / (fzg_scalar_struct.whlDrr);

% Abbruch, wenn die Drehzahlen der Kurbelwelle zu hoch im hybridischen
% Modus
%   stop if the crankshaft rotational speed is too high in hybrid mode
if engStaPre && any(crsSpdVec > crsSpdHybMax)
    return;
end

% Falls die Drehzahl des Verbrennungsmotors niedriger als die
% Leerlaufdrehzahl ist,
%   stop if crankhaft rotional speed is lower than the idling speed
if engStaPre && any(crsSpdVec < crsSpdHybMin)
    return;
end

% Prüfen, ob die Drehzahlgrenze des Elektromotors eingehalten wird
%   check if electric motor speed limit is maintained
if ~engStaPre && any(crsSpdVec > crsSpdEmoMax)
    return;
end
% use previous time idx's crankshaft rotational speed for calculations
crsSpd = crsSpdVec(1);
% use previous vehicle velocity time index for calculations
vehVel = vehVelVec(1);
%% Getriebeübersetzung und -verlust
%   gear ratio and loss

% Berechnung des Kurbelwellenmoments
% Hier muss unterschieden werden, ob das Radmoment positiv oder
% negativ ist, da nur ein einfacher Wirkungsgrad für das Getriebe
% genutzt wird
%   it's important to determine sign of crankshaft torque (positive or
%   negative), since only a simple efficiency is used for the transmission
%   PART OF EQ4  <- perhaps reversed? not too sure
if whlTrqPre < 0
    crsTrq = whlTrqPre / fzg_array_struct.geaRat(gea) * fzg_scalar_struct.geaEfy;
else
    crsTrq = whlTrqPre / fzg_array_struct.geaRat(gea) / fzg_scalar_struct.geaEfy;
end

%% Verbrennungsmotor
%   internal combustion engine

% if engine is turned on
if engStaPre
    % maximales Moment des Verbrennungsmotors berechnen
    %   calculate max torque of the engine (quadratic based on rotation speed)
    iceTrqMax = fzg_array_struct.iceTrqMaxCof(1) * crsSpd.^2 ...
        + fzg_array_struct.iceTrqMaxCof(2) * crsSpd ...
        + fzg_array_struct.iceTrqMaxCof(3);

    % minimales Moment des Verbrennungsmotors berechnen
    %   calculating mimimum ICE moment
    iceTrqMin = fzg_array_struct.iceTrqMinCof(1) * crsSpd.^2 ...
        + fzg_array_struct.iceTrqMinCof(2) * crsSpd ...
        + fzg_array_struct.iceTrqMinCof(3);
    
% if engine is turned off
else                       
   iceTrqMax = 0;
   iceTrqMin = 0;
end

%% Elektromotor
%   electric motor
%
% maximales Moment, dass die E-Maschine liefern kann
%   max torque that the electric motor can provide - from interpolation
emoTrqMaxPos = ...
    interp1q(fzg_array_struct.emoSpdMgd(1,:)',fzg_array_struct.emoTrqMax_emoSpd,crsSpd);

% Die g�ltigen Kurbelwellenmomente müssen kleiner sein als das
% Gesamtmoment von E-Motor und Verbrennungsmotor
%   The valid crankshaft moments must be less than the total moment of the
%   electric motor and the ICE. Otherwise, leave the function
if crsTrq > iceTrqMax + emoTrqMaxPos; 
    return;
end

%% %% Optimaler Momentensplit - Minimierung der Hamiltonfunktion
%       optimum torque split - minimizing the Hamiltonian
% Die Vorgehensweise ist �hnlich wie bei der ECMS. Es wird ein Vektor der
% m�glichen Batterieenergie�nderungen aufgestellt. Aus diesen l�sst sich 
% eine Batterieklemmleistung berechnen. Aus der �ber das
% Kurbelwellenmoment, ein Elektromotormoment berechnet werden kann.
% Über das geforderte Kurbelwellenmoment, kann f�r jedes Moment des 
% Elektromotors ein Moment des Verbrennungsmotors gefunden werden. Für 
% jedes Momentenpaar kann die Hamiltonfunktion berechnet werden.
% Ausgegeben wird der minimale Wert der Hamiltonfunktion und die
% durch das dabei verwendete Elektromotormoment verursachte
% Batterieladungsänderung.
%   The procedure is similar to ECMS. It's based on a vector of possible
%   battery energy changes, from which a battery terminal power can be
%   calculated.
%   From the crankshaft torque, an electric motor torque can be
%   calculated, and an engine torque can be found for every electric motor
%   moment. 
%   For every moment-pair the Hamiltonian can be calculated. It
%   outputs the minimum Hamilotnian value and the battery charge change
%   caused by the electric motor torque used.

%% Elektromotor - Aufstellen des Batterienergievektors
%   electric motor - positioning the battery energy vectors

if batEngStp > 0
    [ ...
        batEngDltMin,       ... Skalar - �nderung der minimalen Batterieenergie�nderung
        batEngDltMax        ... Skalar - �nderung der maximalen Batterieenergie�nderung
        ] =                 ...
        batEngDltClc_a      ... FUNCTION CALL
        (                   ...
        timeStp,            ... Skalar - time step interval
        vehVel,             ... Skalar - mittlere Geschwindigkeit im Intervall
        batPwrAux,          ... Skalar - Nebenverbraucherlast
        batEng,             ... Skalar - Batterieenergie
        fzg_scalar_struct,  ... struct - Fahrzeugparameter - nur skalar
        fzg_array_struct,   ... struct - Fahrzeugparameter - nur array
        crsSpd,             ... Skalar - crankshaft rotational speed
        crsTrq,             ... Skalar - crankshaft torque
        iceTrqMin,          ... Skalar - min ICE torque allowed
        iceTrqMax,          ... Skalar - max ICE torque allowed
        emoTrqMaxPos        ... Skalar - max EM torque possible
        );
    
    % Es werden 2 F�lle unterschieden:
    %   there are 2 different cases
    if batEngDltMin > 0 && batEngDltMax > 0 % battery will charge(yes?)
        
        %% konventionelles Bremsen + Rekuperieren
        %   conventional brakes + recuperation
        %
        % set change in energy to discretized integer values w/ ceil and
        % floor. This also helps for easy looping

        % Konventionelles Bremsen wird ebenfalls untersucht.
        % Hier liegt eventuell noch Beschleunigungspotential, da diese
        % Zustandswechsel u.U. ausgeschlossen werden können.
        % NOTE: u.U. = unter Ümständen = circumstances permitting
        %   convetional breaks also investigated. An accelerating potential
        %   is still possible, as these states can be excluded
        %   (circumstances permitting)  <- ??? not sure what above means
        %
        %   so if both min and max changes in battery energy are
        %   increasing, then set the delta min to zero
        batEngDltMinInx = 0;
        batEngDltMaxInx = floor(batEngDltMax/batEngStp);

    else        
        batEngDltMinInx = ceil(batEngDltMin/batEngStp);
        batEngDltMaxInx = floor(batEngDltMax/batEngStp);
    end
else
    batEngDltMinInx = 0;
    batEngDltMaxInx = 0;
end

% NOTE: if the engine is off, the EM cannot fluctuate how much torque to 
% assign to the crankshaft, since it must satisfy ALL the demanded torque
% - there is no partial split.
% as a result, the same batEngDlt value will be used for min and max. But,
% the max value of the two must be used, since undershooting the minimum
% needed torque will not do.
if ~engStaPre
    batEngDltTmpVec     = [batEngDltMinInx batEngDltMaxInx];
   [~, batEngDltTmpInx] = max(abs(batEngDltTmpVec));
   batEngDltMinInx      = batEngDltTmpVec(batEngDltTmpInx);
   batEngDltMaxInx      = batEngDltMinInx;
end

% you got a larger min change than a max change-you're out of bounds. Leave
% the function
if batEngDltMaxInx < batEngDltMinInx
    return;
end

%% Schleife �ber alle Elektromotormomente
%   now loop through all the electric-motor torques
% why isn't batEngDltInx discretized wrt batEngStp??
for batEngDltInx = batEngDltMinInx:batEngDltMaxInx 
    batEngDlt = batEngDltInx * batEngStp;
    batEngAct = batEng + batEngDlt;
    % open circuit voltage over each iteration
    batOcv = batEngAct*fzg_array_struct.batOcvCof_batEng(1,1)+fzg_array_struct.batOcvCof_batEng(1,2);
    
    [   batPwr,...          Skalar f�r die Batterieleistung in W
        fulFrc ...          Skalar Krafstoffkraft in N
        ] = ...
        fulEngClc_a...            FUNCTION CALL
        (timeStp,...        Skalar f�r die Wegschrittweite in m,
        vehVel,...          Skalar - vehicular velocity
        batPwrAux,...       Nebenverbraucherlast
        batOcv,...          Skalar - battery open circuit voltage
        batEngDlt, ...      Skalar - Batterieenergie�nderung,
        engStaPre,      ... previous state of engine (off-on)
        crsSpd,...          Skalar - crankshaft speed at given path_idx
        crsTrq,...          Skalar - crankshaft torque at given path_idx
        iceTrqMin,...       Skalar - min ICE torque allowed
        iceTrqMax,...       Skalar - max ICE torque
        fzg_scalar_struct,...      struct - Fahrzeugparameter - nur skalar
        fzg_array_struct...        struct - Fahrzeugparameter - nur array        
        );
    
    % calculate the battery force required for specified fuel energy level
    batFrc = batFrcClc_a(...      FUNCTION CALL
        batPwr,...          Skalar - Batterieklemmleistung
        vehVel,...          Skalar - mittlere Geschwindigkeit im Intervall
        fzg_scalar_struct.batRstDch,...   Skalar - Entladewiderstand
        fzg_scalar_struct.batRstChr,...   Skalar - Ladewiderstand
        fzg_scalar_struct.vehVelThresh,...
        batOcv...           Skalar - battery open circuit voltage
        );    
    
    %% Hamiltonfunktion bestimmen
    %   determine the hamiltonian
    % Eq (29b)
    [minFulLvl,optPreInx] = min([fulFrc,minFulLvl]);
    
    % Wenn der aktuelle Punkt besser ist, als der in cosHamMin
    % gespeicherte Wert, werden die Ausgabegrößen neu beschrieben.
    %   if the current point is better than the stored cosHamMin value,
    %   then the output values are rewritten (selected prev. value is = 2)
    if optPreInx == 1
        batFrcOut = batFrc;
        fulFrcOut = fulFrc;
    end
    
end

end % end of function