function [          ...
    batPwrOptVec,   ... Vektor - optimale Batterieenergieänderung
    fulEngDltOptVec,... Vektor - optimale Kraftstoffenergieänderung
    geaStaOptVec,   ... Vektor - Trajektorie des optimalen Antriebsstrangzustands
    engStaOptVec,   ... vector showing optimal engine contorl w/ profile
    batStaOptVec,   ... vector showing optimal battery level control
    batEngOptVec,   ... vector showing optimal battery levels
    emoTrqOpt1Vec,  ...
    emoTrqOpt2Vec,  ...
    iceTrqOptVec,   ...
    brkTrqOptVec,   ...
    fulEngOpt       ... Skalar - optimale Kraftstoffenergie
] =                 ...
    clcOptTrj_focus ...
(                   ...
    timVec,         ... Skalar f�r die max. Anzahl an Wegstützstellen
    staEnd,         ... Skalar f�r den finalen Zustand
    engEnd,         ... scalar - prefinal engine state
    engEndEnd,      ... Skalar f�r Zielindex der kinetischen Energie
    batEndInx,      ... scalar - final battery state
    batStaNum,      ... scalar - for number of battery states exist
    optPreInxTn4,   ... Tensor 3. Stufe f�r opt. Vorg�ngerkoordinaten
    batPwrOptTn4,   ... Tensor 3. Stufe der Batteriekraft
    fulEngOptTn4,   ... Tensor 3. Stufe f�r die Kraftstoffenergie
    cos2goActTn3,   ... Matrix der optimalen Kosten der Hamiltonfunktion 
    emoTrqOpt1Tn4,  ...
    emoTrqOpt2Tn4,   ...
    iceTrqOptTn4,   ...
    brkTrqOptTn4,   ...
    inputparams,    ...
    tst_scalar_struct...
    ) %#codegen
%
%CLCOPTTRJ Calculating optimal trajectories for result of DP + PMP
% Erstellungsdatum der ersten Version 24.08.2015 - Stephan Uebel
% 13.07.2016 - modified to work with engine on-off control instead of KE
% costate calculation and optimization - asgard kaleb marroquin
%
% Diese Funktion berechnet die optimalen Trajketorien der kinetischen
% Energie und Anstriebsstrangzustands. Außerdem wird ein Verlauf für einen
% costate für die kinetische Energie aus den Ergebnissen der DP berechnet.
%   this function calulates the optimal trajectory for kinetic energy and
%   powertrain states. In addition, a course is calculated for a costate
%   for the kinetic energy from the DP results.
%
% !!!! Generelle Festlegung, wie Vektoren/Tensoren zu lesen sind !!!!
% Werte, die am Anfang und am Ende eines Intervalls gelten, stehen an der
% jeweiligen Position des Vektors.
%   !!!! Please note, how vectors/tensors are read !!!!
%   Values that are at the beginning and end of an interval are at their
%   respective indexes along the vector.
%
% Mittelwerte, d.h. Flussgrößen wie Kräfte, Leistungen etc., stehen immmer
% am Anfang des Intervalls für das folgende Intervall. Diese
% Vektoren/Tensoren sind daher um einen gültigen Eintrag kürzer.
%   mean values (eg flow variables like forces, services) are always at the
%   beginning of the interval for the next interval. Those vectors/tensors
%   are therefore shorter by a valid entry (index?).

%% Initialisieren der Ausgabe der Funktion
%   initializing function output
timNum = length(timVec);

% Trajektorie der optimalen kin. Energien
%   optimal kinetic energy trajectory initializaton
engStaOptVec    = inf(timNum,1);

% Trajektorie der optimalen Batterieenergieänderung im Intervall
%   optimal battery energy change trajectories for the interval
batPwrOptVec = inf(timNum,1);

% Trajektorie des optimalen Antriebsstrangzustands im Intervall
%   optimal powertrain state trajectories for the interval
geaStaOptVec    = zeros(timNum,1);

batStaOptVec    = zeros(timNum, 1);

% define timInxEnd because it is invoked so often
timInxEnd = inputparams.timInxEnd;

%% Initialisieren des finalen Zustands
%   intializing the final state

% Indexvektor der optimalen kinetischen Energien
%   index vector for the optimal kinetic energies
% engKinOptInxVec = zeros(wayNum,1);

% Suche des optimalen Gangs und der optimalen Geschwindigkeit, falls 
% Zielgang nicht festgelegt ist
%   find the optimal gear and speed if the target gear isn't fixed
if inputparams.disFlg
    % assigning indexes values to end of timInx so that later invocations
    % stop returning error for reading in an index value of 0
    geaStaOptVec(timInxEnd-1) = staEnd;
    geaStaOptVec(timInxEnd)   = staEnd;
    engStaOptVec(timInxEnd-1) = engEnd;
    engStaOptVec(timInxEnd)   = engEnd;
    batStaOptVec(timInxEnd-1) = batEndInx;
    batStaOptVec(timInxEnd)   = batEndInx;
    
    % Die finale kinetische Energie steht an Stelle 1 im Vektor
    %   the final kinetic energy is at the first index in the vector
    engStaEndInx = engEndEnd;
    
else
    % what is this again? because disFlg is used to display to screen. IS
    % it being used to ensure target trajectory as well? How so?
%     [val,inx] = min(cos2goActTn3);
%     [~,geaStaEndInx] = min(val);
%     engStaEndInx = inx(geaStaEndInx);
%     geaStaOptVec(timInxEnd-1) = geaStaEndInx;

    % switching fuel values to positive so that min eq here works. Albeit that
    % this is not the best place to do so - would be optimal to do when
    % cos2goActTn3 is being populated in clcDP. 
    cos2goActTn3(~isinf(cos2goActTn3)) = -cos2goActTn3(~isinf(cos2goActTn3));
    
    [colmin, colminidx] = min(cos2goActTn3);
    [matmin, matminidx] = min(colmin);
    [~, batStaEndInx] = min(matmin);
    geaStaEndInx    = matminidx(batStaEndInx);
    engStaEndInx    = colminidx(:,geaStaEndInx,batStaEndInx);
    
    geaStaOptVec(timInxEnd-1) = geaStaEndInx;
    engStaOptVec(timInxEnd-1) = engStaEndInx;
    batStaOptVec(timInxEnd-1) = batStaEndInx;

end

% assign the last value in the optimatal KE INDEX vector as the last KE idx
% how to set a boundary between batEngEndMin and Max??
% engStaOptVec(timInxEnd) = engStaEndInx;
engStaOptVec(timInxEnd) = engStaEndInx;

% Zielzustand des Ausgabevektors f�r optimale kinetische Energie
% beschreiben
%   describe the target state of the output vector for the optimal KE

% Batterieenergie�nderung im letzten Intervall initialisieren
%   initialize battery energy change's last interval
batPwrOptVec(timInxEnd-1,1) = ...
    batPwrOptTn4(engStaOptVec(timInxEnd)+1, geaStaOptVec(timInxEnd-1), ...
                 batStaOptVec(timInxEnd-1), timInxEnd-1)...
                 * inputparams.timStp;

% Beschreiben der Ausgabegr��e der optimalen Kraftstoffenergie
%   writing the output for the optimal fuel energy
fulEngOpt = ...
    fulEngOptTn4(engStaOptVec(timInxEnd)+1, geaStaOptVec(timInxEnd-1), ...
                 batStaOptVec(timInxEnd-1), timInxEnd);

% Initialisieren des Vektors der optimalen Kraftstoffenergie�nderung
%   intializing the optimum fuel energy change vector
fulEngDltOptVec = zeros(timNum, 1);
emoTrqOpt1Vec   = zeros(timNum, 1);
emoTrqOpt2Vec   = zeros(timNum, 1);
iceTrqOptVec    = zeros(timNum, 1);
brkTrqOptVec    = zeros(timNum, 1);

%% R�ckw�rtsrechnung �ber alle Wegpunkte 
%   reverse calculation of all the path indexes

% Rekonstruieren des optimalen Pfades aus
%   rebuilding the optimale path
for timInx = timInxEnd:-1:inputparams.timInxBeg+1
    
    % optimalen Vorg�ngerindex aus Tensor auslesen
    %   reading the tensor's optimum previous index 
    optInx = optPreInxTn4(engStaOptVec(timInx,1)+1,...
        geaStaOptVec(timInx-1,1), batStaOptVec(timInx-1,1), timInx);
    
    % <- Vorg�nger = predecessor
    if optInx == 0
        error('Fehler beim Speichern der optimalen Vorgaenger.') 
    end
    
    % optimalen Index dekodieren
    %   decoding the optimal index
    if timInx > inputparams.timInxBeg+1
        % what does this do? - assigns index values, that's for sure
        % - its repopulating the vectors (previously assigned to 0) by
        %   looping through all the path states and selecting all the 
        %   optimum state variables in each of the mats based on the
        %   generated optimum indexes

        [engStaOptVec(timInx-1,1),geaStaOptVec(timInx-2,1), batStaOptVec(timInx-2,1)] = ...
            ind2sub([tst_scalar_struct.engStaNum,tst_scalar_struct.staNum, batStaNum],optInx);
        % revert engStaOptVec from index value to boolean
        engStaOptVec(timInx-1,1) = engStaOptVec(timInx-1,1)-1;
        % 2 - because of number of engine states - send to mainConfig!!
        
        % Batterieenergie�nderung f�r Vorg�ngerintervall speichern
        % Flussgr��e (gilt im Intervall)
        %   storing the previous interval's battery energy change's flow
        %   amount
        batPwrOptVec(timInx-2,1) = ...
            batPwrOptTn4(engStaOptVec(timInx-1)+1,geaStaOptVec(timInx-2),...
                         batStaOptVec(timInx-2), timInx-2) * inputparams.timStp;
%                        batStaOptVec(timInxEnd-2), timInx-2) * inputparams.timStp;

        % Krafstoffenergieänderung für Intervall speichern
        % Flussgröße (gilt im Intervall)
        % Beschreiben der Ausgabegröße der optimalen Kraftstoffenergie
        %   storing the interval's fuel energy change flow amount
        %   describing the output size of the optimal fuel energy
        fulEngDltOptVec(timInx-1,1) = ...
            fulEngOptTn4(engStaOptVec(timInx)+1,  geaStaOptVec(timInx-1),batStaOptVec(timInx-1), timInx);... - ...
%             fulEngOptTn4(engStaOptVec(timInx-1)+1,geaStaOptVec(timInx-2),batStaOptVec(timInx-2), timInx-1);
        
        % save optimal torque values 
        % emoTrq
        emoTrqOpt1Vec(timInx-1, 1) = ...
            emoTrqOpt1Tn4(engStaOptVec(timInx-1,1)+1, ...
                          geaStaOptVec(timInx-2,1), ...
                          batStaOptVec(timInx-2,1), ...
                          timInx-1);
        emoTrqOpt2Vec(timInx-1, 1) = ...
            emoTrqOpt2Tn4(engStaOptVec(timInx-1,1)+1, ...
                          geaStaOptVec(timInx-2,1), ...
                          batStaOptVec(timInx-2,1), ...
                          timInx-1);

        % iceTrq
        iceTrqOptVec(timInx-1, 1) = ...
            iceTrqOptTn4(engStaOptVec(timInx-1,1)+1, ...
                          geaStaOptVec(timInx-2,1), ...
                          batStaOptVec(timInx-2,1), ...
                          timInx-1);
        % brkTrq
        brkTrqOptVec(timInx-1, 1) = ...
            brkTrqOptTn4(engStaOptVec(timInx-1,1)+1, ...
                          geaStaOptVec(timInx-2,1), ...
                          batStaOptVec(timInx-2,1), ...
                          timInx-1);
                                            
        %   save potetial variables in the first point/index
    else % if timInx == timInxBeg ( == 1 if wayOInxBeg = 1)
        [engStaOptVec(timInx-1,1), geaStaOptVec(timInx-1,1), batStaOptVec(timInx-1,1)] = ...
            ind2sub([tst_scalar_struct.engStaNum, tst_scalar_struct.staNum, batStaNum], optInx);
        
        fulEngDltOptVec(timInx-1,1) = ...
            fulEngOptTn4(engStaOptVec(timInx)+1, geaStaOptVec(timInx-1), batStaOptVec(timInx-1), timInx);
        
%         engStaOptVec(timInx-1,1) = engStaOptVec(timInx,1);
    end
    
% % save optimal torque values 
% % emoTrq
% emoTrqOpt1Vec(timInx) = ...
%     emoTrqOpt1Tn4(engStaOptVec(timInx,1)+1, ...
%                   geaStaOptVec(timInx,1), ...
%                   batStaOptVec(timInx,1), ...
%                   timInx);
% emoTrqOpt2Vec(timInx) = ...
%     emoTrqOpt2Tn4(engStaOptVec(timInx,1)+1, ...
%                   geaStaOptVec(timInx,1), ...
%                   batStaOptVec(timInx,1), ...
%                   timInx);
%               
% % iceTrq
% iceTrqOptVec(timInx) = ...
%     iceTrqOptTn4(engStaOptVec(timInx,1)+1, ...
%                   geaStaOptVec(timInx,1), ...
%                   batStaOptVec(timInx,1), ...
%                   timInx);
% % brkTrq
% brkTrqOptVec(timInx) = ...
%     brkTrqOptTn4(engStaOptVec(timInx,1)+1, ...
%                   geaStaOptVec(timInx,1), ...
%                   batStaOptVec(timInx,1), ...
%                   timInx);
                            
end % end of path_idx loop

% derive battery energy based on the battery power
batEngOptVec = [(batStaOptVec(1:end-1)-1) * tst_scalar_struct.batEngStp; (batEndInx-1)*tst_scalar_struct.batEngStp];

end % end of function