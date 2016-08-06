function [          ...
    batPwrOptVec,   ... Vektor - optimale Batterieenergieänderung
    fulEngDltOptVec,... Vektor - optimale Kraftstoffenergieänderung
    geaStaOptVec,   ... Vektor - Trajektorie des optimalen Antriebsstrangzustands
    engStaOptVec,   ... vector showing optimal engine contorl w/ profile
    batStaOptVec,   ... vector showing optimal battery level control
    batEngOptVec,   ... vector showing optimal battery levels
    fulEngOpt       ... Skalar - optimale Kraftstoffenergie
    ] =             ...
    clcOptTrj_focus ...
    (disFlg,        ... Flag, ob Zielzustand genutzt werden muss
    timStp,         ... Skalar f�r die Wegschrittweite in m
    batStp,         ... scalar - bat energy discretization step
    timNum,         ... Skalar f�r die max. Anzahl an Wegstützstellen
    timInxBeg,      ... Skalar f�r Anfangsindex in den Eingangsdaten
    timInxEnd,      ... Skalar f�r Endindex in den Eingangsdaten
    staEnd,         ... Skalar f�r den finalen Zustand
    engEnd,         ... scalar - prefinal engine state
    engEndEnd,      ... Skalar f�r Zielindex der kinetischen Energie
    batEndInx,      ... scalar - final battery state
    geaStaNum,      ... Skalar f�r die max. Anzahl an Zustandsst�tzstellen
    engStaNum,      ... scalar - for number of states engine can take
    batStaNum,      ... scalar - for number of battery states exist
    optPreInxTn4,   ... Tensor 3. Stufe f�r opt. Vorg�ngerkoordinaten
    batPwrOptTn4,   ... Tensor 3. Stufe der Batteriekraft
    fulEngOptTn4,   ... Tensor 3. Stufe f�r die Kraftstoffenergie
    cos2goActTn3    ... Matrix der optimalen Kosten der Hamiltonfunktion 
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

%% Initialisieren des finalen Zustands
%   intializing the final state

% Indexvektor der optimalen kinetischen Energien
%   index vector for the optimal kinetic energies
% engKinOptInxVec = zeros(wayNum,1);

% Suche des optimalen Gangs und der optimalen Geschwindigkeit, falls 
% Zielgang nicht festgelegt ist
%   find the optimal gear and speed if the target gear isn't fixed
if disFlg
    geaStaOptVec(timInxEnd-1) = staEnd;
    
    engStaOptVec(timInxEnd-1) = engEnd;
    
    batStaOptVec(timInxEnd-1) = batEndInx;
    
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
    geaStaEndInx = matminidx(batStaEndInx);
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
                 * timStp;

% Beschreiben der Ausgabegr��e der optimalen Kraftstoffenergie
%   writing the output for the optimal fuel energy
fulEngOpt = ...
    fulEngOptTn4(engStaOptVec(timInxEnd)+1, geaStaOptVec(timInxEnd-1), ...
                 batStaOptVec(timInxEnd-1), timInxEnd);

% Initialisieren des Vektors der optimalen Kraftstoffenergie�nderung
%   intializing the optimum fuel energy change vector
fulEngDltOptVec = zeros(timNum,1);

%% R�ckw�rtsrechnung �ber alle Wegpunkte 
%   reverse calculation of all the path indexes

% Rekonstruieren des optimalen Pfades aus
%   rebuilding the optimale path
for timInx = timInxEnd:-1:timInxBeg+1
    
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
    if timInx > timInxBeg+1
        % what does this do? - assigns index values, that's for sure
        % - its repopulating the vectors (previously assigned to 0) by
        %   looping through all the path states and selecting all the 
        %   optimum state variables in each of the mats based on the
        %   generated optimum indexes

        [engStaOptVec(timInx-1,1),geaStaOptVec(timInx-2,1), batStaOptVec(timInx-2,1)] = ...
            ind2sub([engStaNum,geaStaNum, batStaNum],optInx);
        % revert engStaOptVec from index value to boolean
        engStaOptVec(timInx-1,1) = engStaOptVec(timInx-1,1)-1;
        % 2 - because of number of engine states - send to mainConfig!!
        
        % Batterieenergie�nderung f�r Vorg�ngerintervall speichern
        % Flussgr��e (gilt im Intervall)
        %   storing the previous interval's battery energy change's flow
        %   amount
        batPwrOptVec(timInx-2,1) = ...
            batPwrOptTn4(engStaOptVec(timInx-1)+1,geaStaOptVec(timInx-2),...
                         batStaOptVec(timInxEnd-2), timInx-2) * timStp;
        
        % Krafstoffenergieänderung für Intervall speichern
        % Flussgröße (gilt im Intervall)
        % Beschreiben der Ausgabegröße der optimalen Kraftstoffenergie
        %   storing the interval's fuel energy change flow amount
        %   describing the output size of the optimal fuel energy
        fulEngDltOptVec(timInx-1,1) = ...
            fulEngOptTn4(engStaOptVec(timInx)+1, geaStaOptVec(timInx-1), batStaOptVec(timInx-1), timInx) - ...
            fulEngOptTn4(engStaOptVec(timInx-1)+1,geaStaOptVec(timInx-2),batStaOptVec(timInx-2), timInx-1);
        
   
        %   save potetial variables in the first point/index
    else % if timInx == timInxBeg ( == 1 if wayOInxBeg = 1)
        [engStaOptVec(timInx-1,1), geaStaOptVec(timInx-1,1), batStaOptVec(timInx-1,1)] = ...
            ind2sub([engStaNum, geaStaNum, batStaNum], optInx);
        
        fulEngDltOptVec(timInx-1,1) = ...
            fulEngOptTn4(engStaOptVec(timInx)+1, geaStaOptVec(timInx-1), batStaOptVec(timInx-1), timInx);
        
%         engStaOptVec(timInx-1,1) = engStaOptVec(timInx,1);
    end
        
end % end of path_idx loop

% derive battery energy based on the battery power
batEngOptVec = [(batStaOptVec(1:end-1)-1) * batStp; (batEndInx-1)*batStp];

end % end of function