function [          ...  --- Ausgangsgrößen:
    optPreInxTn3,   ... Tensor 3. Stufe f�r opt. Vorg�ngerkoordinaten
    batFrcOptTn3,   ... Tensor 3. Stufe der Batteriekraft
    fulEngOptTn3,   ... Tensor 3. Stufe f�r die Kraftstoffenergie 
    cos2goActMat    ... Matrix der optimalen Kosten der Hamiltonfunktion 
    ] =             ...
    clcDP_a         ...
    (               ... --- Eingangsgr��en:
    disFlg,         ... Skalar - Flag f�r Ausgabe in das Commandwindow
    iceFlgBool,     ...skalar - is engine toggle on/off allowed?
    timeStp,        ... Skalar f�r die Wegschrittweite in m
    batEngStp,      ... Skalar der Batteriediskretisierung in J
    batEngBeg,      ... Skalar f�r die Batterieenergie am Beginn in Ws
    batPwrAux,      ... Skalar f�r die Nebenverbrauchlast in W
    staChgPenCosVal,... Skalar f�r die Strafkosten beim Zustandswechsel
    wayInxBeg,      ... Skalar f�r Anfangsindex in den Eingangsdaten
    wayInxEnd,      ... Skalar f�r Endindex in den Eingangsdaten
    staNum,         ... Skalar f�r die max. Anzahl an Zustandsst�tzstellen
    timeNum,        ... Skalar f�r die Stufe der Batteriekraftmax. Anzahl an Wegst�tzstellen
    engBeg,         ... scalar - beginnnig engine state
    engEnd,         ... scalar - end engine state
    staBeg,         ... Skalar f�r den Startzustand des Antriebsstrangs
    velVec,         ... velocity vector contiaing input speed profile
    whlTrq,         ... wheel torque demand vector for the speed profile
    fzg_scalar_struct,     ... struct der Fahrzeugparameter - NUR SKALARS
    fzg_array_struct       ... struct der Fahrzeugparameter - NUR ARRAYS
    )%#codegen
%
% 01.07.2016 - asgard kaleb marroquin - creating new algorithm based solely 
% on DP for minimizing fuel use based on battery charge value with a given
% speed and slope profile wrt time, not distance. 
%
% 06.07.2016 - replacing KE state dimension with engine control
% Since engine control will be treated as a boolean 0-1 value, for indexing
% values with on-off possibilities, a value of 1 is added to the boolean
% value in order to create 'indexable numbers' (ie, 1 and 2 for off and on)
%
% Differences:
%   - Kinetic energy is not a state/costate variable considered. 
%   - The gear variable should be able to be toggled to be used
%   (static,dynamic).
%   - Algorithm here is wrt time, not displacement (Time is not a state
%   here).
%   - B/c KE states (and possibly discrete gear states) are not considered, 
%   DP is much more plausable for this algorithm. PMP will not be used for
%   finding time and battery energy costates. DP will be used to find 
%   optimal battery energy and possibly gear states for optimal path.
% Similarities:
%   - Want to find optimal battery electric energy path for given profile.
%   - Optimal fuel minimization - engine on/off toggle from torque split.
%
% Algorithm:
%   - Must be able to handle any length of time/speed profile.
%   - There is no energy loss penalty for turning engine on/off.
%
%INIDP Calculating optimal predecessors with DP + PMP
% Erstellungsdatum der ersten Version 20.08.2015 - Stephan Uebel
%
% Diese Funktion berechnet die optimalen Vorgänger der Dynamischen
% Programmierung (DP). Diese subsitutiert die Zustände Zeit und
% Batterieenergie durch Co-States. Die Kosten werden mit dem
% Pontryaginschen Minimumsprinzip berechnet.
%   This function calculates the optimum predecessor from dynamic
%   programming (DP). Each state's time and battery power costates are
%   substituted from a Potryagin's Minimum Principle calculation.
%
% Variante olyHyb erlaubt nur hybridisches Fahren (Motor ist immer an)
%   variation olyHyb permits only hybrid driving (motor is always on)
%
% Änderung am 23.02.2016 - optimale Kosten nicht direkt aus Index von min()
% bestimmt. Das fährt zu einem anderen Schaltverhalten, da Gänge teilweise
% gleiche Kosten verursachen. In dem Fall wird jetzt der niedrigste Gang
% gewählt, wie in der DP.
%   change on 23.02.2016 - optimal costs are not directly from the min()
%   index. The move to another switching behaviour is because the
%   transitions FZGtially caused the same costs. The lowester gear is now
%   selected in DP
%
% !!!! Generelle Festlegung, wie Vektoren/Tensoren zu lesen sind !!!!
% Werte, die am Anfang und am Ende eines Intervalls gelten, stehen an der
% jeweiligen Position des Vektors.
%   !!!! Please note, how vectors/tensors are read (??) !!!!
%   Values that are at the beginning and end of an interval are at their
%   respective indexes along the vector.
%
% Mittelwerte, d.h. Flussgrößen wie Kräfte, Leistungen etc., stehen immmer
% am Anfang des Intervalls für das folgende Intervall. Diese
% Vektoren/Tensoren sind daher um einen gültigen Eintrag kürzer.
%   mean values (eg flow variables like forces, services) are always at the
%   beginning of the interval for the next interval. Those vectors/tensors
%   are therefore shorter by a valid entry (index?).
%
%% Initialisieren der persistent Größen
% Diese werden die nur einmal für die Funktion berechnet
%   assigning input structure values to function persistant variables
%   - just once
% persistent geaNum vehMas vehAccMin vehAccMax iceFlg
persistent geaNum iceFlg engNum

if isempty(geaNum)
    
%     geaNum    = zeros(1,1);
%     vehMas    = zeros(1,1);
%     vehAccMin = zeros(1,1);
%     vehAccMax = zeros(1,1);
    
    % number of engine states possible (1 = OFF; 2 = ON);
    engNum = 2;
    % Anzahl der Gänge
    %   number of gears
    geaNum = staNum; % max number of state nodes
    
    % Fahrzeugmasse;
%     vehMas = fzg_scalar_struct.vehMas;
 
    % minmiale und maximale Beschleunigung
    %   min and max accerlations (bounds)
%     vehAccMin = fzg_scalar_struct.vehAccMin;
%     vehAccMax = fzg_scalar_struct.vehAccMax;
    
    % In dieser Version ist der Motor immer an
    % not anymore - iceFlg is whatever is in mainConfig.txt
%     iceFlg = true;
    iceFlg = iceFlgBool;
end

%% Initialisieren der Ausgabe der Funktion
%   initialzing function output

% Tensor 3. Stufe f�r optimalen Vorgängerkoordinaten
%   tensor3 for optimal previous coordinates/idx
% IS NOT MAT SINCE KE IS NO LONGER CONSIDERED - REDUCES A DIMENSION
%   - back to being a tensor - adding engine control dimension
optPreInxTn3 = zeros(engNum, geaNum,timeNum);

% Tensor 3. Stufe f�r die Kraftstoffenergie
%   tensor3 for fuel energy
% NOW A MATRIX
fulEngOptTn3 = inf(engNum, geaNum,timeNum);
%   set initial fuel energy level to 0
fulEngOptTn3(engBeg, staBeg, wayInxBeg) = 0; 

% Tensor 3. Stufe f�r die Batterienergie
%   tensor3 for battery energy
batFrcOptTn3 = inf(engNum, geaNum,timeNum);

%% Berechnung der optimalen Vorgänger
%   calculating the optimal predecessors

% Initialisieren der Matrix f�r die Kosten bis zu den Punkten im letzten
% Wegschritt
%   initialize the matrix for the cost to the points in the last wayidx
% NOW A VECTOR - REMOVED KE DIMENSION
% not anymore - added engine contorl dimension
cos2goPreMat = inf(engNum, geaNum);
cos2goActMat = inf(engNum, geaNum);

% Erste Initilisierung beim Startindex mit 0 f�r alle Zust�nde (concluded)
%   first, initialize the startidx to 0 for all states
cos2goPreMat(engBeg, staBeg) = 0;

% Initialisierung der Matrix der Batterieenergien
%   initialize the battery energy matrix
batEngPreMat = inf(engNum, geaNum);

% Erste Initilisierung beim Startindex mit Startladung f�r den Startzustand
%   first, intialize start index of the starting charge for intial state
batEngPreMat(engBeg, staBeg) = batEngBeg;

% Initialisierung der Matrix der Kraftstoffenergien
%   initialze the fuel energy matrix
fulEngPreMat = inf(engNum, geaNum);
% Erste Initilisierung beim Startindex mit 0 f�r den Startzustand
%   first, intialize the start idx for the intitial states to 0
fulEngPreMat(engBeg, staBeg) = 0;

% define vector for possibilities of engine state on-off values
%   2 = can toggle (two states, on-of)
%   1 = cannot toggle, must stay in current state for idx (most likely off)
engStaVec_wayInx = ones(wayInxEnd, 1)*2;
engStaVec_wayInx(wayInxBeg) = engBeg;
engStaVec_wayInx(wayInxEnd) = engEnd;

% define a vector for containing the values of engine control off-on
engStaMat_geaNum_wayInx = zeros(1, wayInxEnd);

% Schleife �ber alle Wegpunkte
%   looping thorugh length of # of discretized time vector
for wayInx = wayInxBeg+1 : timeStp : wayInxEnd      % TIME IDX LOOP
    
    % mittlere Steigung im betrachteten Intervall 
    %   no longer doing mean, using previous gradiant instead
%     slp = slpVec_wayInx(wayInx-1);
    
    %% Berechnung der kinetischen Energien im aktuellen Wegschritt
    % Vorbereitung der FZGallen Schleife (verhindern von zu grossem
    % Datentransfer und unnötigen Berechnungen)
    %   Calculating the KE for current index/waypoint.
    %   Preperation of FZGallel loop (prevent a too large data transfer,
    %   unnecessary computations).   
   
    % Initialisieren der Matrix für die optimalen Batteriekrafter im
    % Intervall
    %   initialize matrix for optimale battery force intervals (discreti.)
    % NOW A VECTOR - REMOVED KE STATE
    % - 06.06.2016 - back to matrix, added engine state dimension
    batFrcOptMat = inf(engNum, geaNum);
        
    % Initialisieren der Matrix f�r die Kosten bis zu den Punkten im
    % aktuellen Wegschritt
    %   initialize cost matrix to points in current path steps (idxs?)
    cos2goActMat = inf(engNum, geaNum);
    
    % Initialisieren der Matrix für die Batterieenergie an den Punkten im
    % aktuellen Wegschritt
    %   initialize matrix for battery energy at points along current wayidx
    batEngActMat = inf(engNum, geaNum);
    
    % Initialisieren der Matrix für die Krafstoffenergie an den Punkten im
    % aktuellen Wegschritt
    %   initialize matrix for fuel energie along current way idxs
    fulEngActMat = inf(engNum, geaNum);
    
    % Anzahl der kinetischen Energien im aktuellen und im
    % Vorg�ngerwegschritt
    %   number of kinetic energies in current and past path_idxs
    engStaNumPre = engStaVec_wayInx(wayInx-1); % and the previous idx KE
    engStaNumAct = engStaVec_wayInx(wayInx);   % look at this loop's KE

    % define previous and actual engine status (on-off)
%     engStaValPre = engStaMat_geaNum_wayInx(wayInx - 1);
%     engStaValAct = engStaMat_geaNum_wayInx(wayInx); 

    % create vector storing current and previous velocity info
    vehVelVec = [velVec(wayInx) velVec(wayInx-1)];
    
    % fetch previous time idx wheel torque
    whlTrqPre = whlTrq(wayInx - 1);
    
%%  go through the possible engine state on-off possibilities
    for engStaActInx = 0:(engStaNumAct-1)   % CURRENT ENGINE STATE LOOP
                         
        % go through off and on version of engine 
        engStaAct = engStaActInx;
        
        % Schleife über alle möglichen aktuellen Zustände des Antriesstrangs
        %   Loop over all possible current powertrain states/all the gears
        for geaStaAct = 1:geaNum           % ALL GEARS LOOP
            %% Initialsiieren
            %   note-you are preallocating over each powertrain state loop
            
            % Initialisieren der Ausgabegröße der Schleife
            %   preallocate the loop's output size
            %   but this is the hamiltonian cost?
%             cosHamMin = inf;
            
            % Initialisieren der Variable für den optimalen Zustandsindex
            %   initializing variable for optimal state index
            geaStaPreOptInx = 0;
            
            % Initialisieren der Variable für die Koordinaten des optimalen
            % Vorg�ngers
            %   initializing variable for optimal coords/KE for prev. idx
%             engKinPreOptInx = 0;
            
            % initialize variable for optimal previous idx engine control
            engStaPreOptInx = 0;
            
            % Initialisieren der optimalen Kraftstoffenergieänderung zum
            % betrachteten Punkt
            %   preallocate the optimum fuel energy change to the point
            %   considered
            fulEngOpt = inf;
            
            % Initialisieren der optimalen Batteriekraft zum
            % betrachteten Punkt
            %   preallocate the optimal battery force to the point under
            %   consideration
            batFrcOpt = inf;
            
            % Initialisieren der optimalen Batterieenergie zum
            % betrachteten Punkt
            %   initialize the optimal battery power (up to boundry limits)
            batEngOpt = inf;
            
            %% Vorgängerzustände beschränken
            %   Restrictions on predecessor operation states
          
            % Festlegen, welche Vorg�nger m�glich sind:
            % Es sind im Maximum die Anzahl der Gänge +  1 als Vorgänger
            % m�glich, denn vom Segeln kann in jeden Gang im elektrischen
            % Fahren und Segeln gewechselt  werden
            %   Determine which predecessors are possible:
            %   There are at maximum 'number of gears'+1 possible for the
            %   predecessors, because from the sail in every Gear in
            %   electric travel and the sails will be changed (???)
            
            % Vorg�ngerzustände des Antriebsstrangs beschränken
            %   determine gear possibilities - ie u(g) 
            geaStaPreMin = max(1,geaStaAct-1);
            geaStaPreMax = min(geaNum,geaStaAct+1);
            gea = geaStaAct;
            
            %% Schleife über alle kinetischen Energien (Vorgänger)
            %   loop through all the kinetic energies (previous state idxs)
            %
            % new - loop through previous engine control
            for engStaPreInx = 0:(engStaNumPre-1) % PREVIOUS gear state loop

                % value of previous idx engine control state
                engStaPre = engStaPreInx; %#ok<PFBNS>

                % Schleife über allen Zustände (relativer Index)
                %   Loop through all the gear states (relative index)
                for geaStaPre = geaStaPreMin:geaStaPreMax % CURRENT GEAR CHANGE LOOP
                    
                   
                    %% Batterieenergie beim betrachteten Vorgänger
                    % battery energy when considering last path_idx
                    %   note: batengPreMat has dims #_KE_states x #_gears
                    batEng = batEngPreMat(geaStaPre);  %#ok<PFBNS>
                    
                    % Sollte es keinen gültigen Vorgänger geben, wird zum
                    % nächsten Schleifendurchlauf gesprungen
                    %   if there is no valid previous battery energy, jump
                    %   to the next loop iteration
                    if isinf(batEng)
                        continue; % HOW TO OVERCOME INITIAL INFINITY VALUE?
                    end
                    
                    %% Antriebsstrangzustand und Strafkosten bestimmen   
                    %   determine gear and engine  penalty costs
                    
                    % Kosten für Zustandswechsel setzen
                    %   set costs for state changes
                    if geaStaAct == geaStaPre
                        % Entspricht der Vorgängerzustand dem aktuellen 
                        % Zustand werden keine Kosten gesetzt
                        %   staying in current state? set penalty cost to 0
                        geaStaChgPenCos = 0;                       
                        
                    else
                        % Ansonsten einfache Zustandswechselkosten
                        % berechnen
                        %   otherwise apply a penalty cost to changing gear
                        geaStaChgPenCos = staChgPenCosVal; %<-penCos is input
                    end
                    
                    if engStaAct == engStaPre
                        engStaChgPenCos = 0;
                    else 
                        engStaChgPenCos = staChgPenCosVal;
                    end
                    
                    %% Berechnung der optimalen Kosten zum aktuellen Punkt
                    %   calculating optimal cost to the current point
                    
                    % externe Funktion ausführen, die minimale Kosten der
                    % Hamiltonfunktion zurückgibt
                    %   run the min-cost Hamiltonian finding function 
                    %
                    % ADD ENGINE STATE VARIABLES (ACT AND PRE)!
                    %
                    % do it time interval at a time? will remove vector
                    % aspects
                    % LOOK INTO WHY ONLY USING PREVIOUS IDX FOR FUEL CALC
                    [minFul,batFrc,fulFrc] =        ...
                        clcPMP_a(engStaPre,         ...  
                                gea,                ...
                                iceFlg,             ...
                                batEng,             ...
                                batPwrAux,          ...
                                batEngStp,          ...
                                timeStp,            ...
                                vehVelVec,          ...
                                whlTrqPre,          ... use prev idx whlTrq
                                fzg_scalar_struct,  ...
                                fzg_array_struct);
                    
%                     % minimale Kosten der Hamiltonfunktion zum aktuellen
%                     % Punkt bestimmen
%                     [cosHamMin,optPreInx] ...
%                         = min([cosHam...
%                         + cos2goPreMat(engKinPreInx,geaStaPre)...
%                         + staChgPenCos...
%                         ,cosHamMin]); %#ok<PFBNS>
                    
                    % combine the min hamil. cost w/ previous costs and 
                    %   gear penalty to get current cost
                    fulAct = minFul...
                        + cos2goPreMat(engStaPreInx+1,geaStaPre)...
                        + geaStaChgPenCos/timeStp + engStaChgPenCos/timeStp;
                    
                    % Wenn der aktuelle Punkt besser ist, als der in
                    % cosHamMin gespeicherte Wert, werden die Ausgabegr��en
                    % neu beschrieben.
                    %   if current point is better than the cost value
                    %   stored in CosHamMin, then rewrite the output
                    % 
                    %   WHAT IF - WE INCLUDED <= ? WHY NOT? BOTH OPTIONS
                    %   WOULD BE EQUALLY OPTIMAL
                    %   - will implement as of 06.07.2016
                    if fulAct <= minFul
                        minFul = fulAct;             % new hamil. cost
                        geaStaPreOptInx = geaStaPre;    % new opt gear idx
                        engStaPreOptInx = engStaPreInx; % new opt eng state
                        batFrcOpt = batFrc;             % new opt bat force
                        % new opt. battery energy = (batt. force *
                        %   time diff) + previous battery energy valu
                        %   -NOTE: batFrc*timeStp calc is the same as the
                        %       batFrc calculation in batFrcClc_a()
                        %   -   why not output that calculation instead?
                        batEngOpt = batFrc * timeStp + ...
                            batEngPreMat(engStaPreInx+1,geaStaPre);
                        % new opt. fuel energy = (fuel force * time diff)
                        %   + previous fuel energy value
                        fulEngOpt = fulFrc * timeStp + ...
                            fulEngPreMat(engStaPreInx+1,geaStaPre);%#ok<PFBNS>
                    end
                end % end of gear changes loop
            end % end of running through previous engine state ctrl loop
            
            if ~isinf(minFul)
                % optimale Kosten zum aktuellen Punkt speichern
                %   save min hamilton value for current point
                cos2goActMat(engStaActInx+1,geaStaAct) = minFul;
                
                % optimale Batterieenergie zum aktuellen Punkt speichern
                %   save optimal battery energy for current point
                batEngActMat(engStaActInx+1,geaStaAct) = batEngOpt;
                
                % optimale Krafstoffenergie zum aktuellen Punkt speichern
                %   save optimal fuel energy for current point
                fulEngActMat(engStaActInx+1,geaStaAct) = fulEngOpt;

                % optimale Batterieenergie zum aktuellen Punkt
                % Flussgröße gilt im Intervall
                %   populate optimal battery energy flux quantity at point 
                %   that's applicable to current interval
                batFrcOptMat(engStaActInx+1,geaStaAct) = batFrcOpt;
                
                % optimalen Vorgänger codieren über Funktion sub2ind
                % und speichern im Tensor
                %   opt. predecessor idx encoding w/ sub2ind, store in Tn3
                optPreInxTn3(engStaActInx+1,geaStaAct,wayInx) = ...
                    sub2ind([engNum,geaNum],...
                    engStaPreOptInx+1,geaStaPreOptInx);
            end % end of ~inf(hamiltonian) if-statement
        end % end of looping through all gears
    end % end of looping through all the current engine control states
    
    % Speichern der Batterieenergie für den nächsten Schleifendurchlauf
    %   save battery energy value as previous path_idx val for next loop 
    batEngPreMat = batEngActMat;
    
    % Speichern der Krafstoffenergie für den nächsten Schleifendurchlauf
    %   save fuel energy value as previous path_idx value for the next loop
    fulEngPreMat = fulEngActMat;
    
    % Speichern der Kosten für den nächsten Schleifendurchlauf
    %   save cost as previous path_idx value for the next loop
    cos2goPreMat = cos2goActMat; 
    
    % optimale Kraftstoffenergie zum aktuellen Punkt
    %   optimal fuel energy at current point - save current mat in tensor
    fulEngOptTn3(:,:,wayInx) = fulEngActMat;
    % optimale Batterieenergie zum aktuellen Punkt
    %   optimal battery force at current point - save current mat in tensor
    % Flussgröße gilt im Intervall
    %   flux quantity applied over the interval
    batFrcOptTn3(:,wayInx-1) = batFrcOptMat;
    
    % Ausgabe des aktuellen Schleifendurchlaufs
    %   output for current loop - print to terminal
    if disFlg
        fprintf('Schleife %1.0f berechnet. %1.0f %% geschafft. \r', ...
            double(wayInx-wayInxBeg), double(((wayInx-wayInxBeg)))/...
            double(wayInxEnd-wayInxBeg)*100);
    end

end % end of looping through all discretized path indexes

end % END OF FUNCTION