function [... --- Ausgangsgr��en:
    wayInxBeg,... Skalar f�r Anfangsindex in den Eingangsdaten
    wayInxEnd,... Skalar f�r Endindex in den Eingangsdaten
    engKinEndInx,...Skalar - Index der kinetischen Energie im Ziel
    timEndRef,...Skalar Zielzeit der Referenzgeschwindigkeit   
    engKinNumVec_wayInx,... Vektor der Anzahl der kinetischen Energien
    slpVec_wayInx,... Vektor der Steigungen in rad
    engKinMat_engKinInx_wayInx,... Matrix der kinetischen Energien in J
    coaPreInxMat_engKinInx_wayInx...Matrix der Segelvorg�nger
    ] = ... 
    iniEngKinMat...
    (... --- Eingangsgr��en:
    coaFlg,...Flag - Umschaltung zwischen Segeln und norm. Diskretisierung
    engKinStp,...Skalar f�r die Schrittweite der kinetischen Energie
    engKinVar,...Skalar f�r die erlaubte Abweichung der kinetischen Energie
    engKinNum,... Skalar f�r die max. Anz. an engKin-St�tzstellen
    wayStp,...Skalar f�r die Wegschrittweite in den Ausgangsdaten
    wayNum,... Skalar f�r die max. Anzahl an Wegst�tzstellen 
    refInxBeg,...Skalar - Startindex in den Referenzdaten
    refInxEnd,...Skalar - Zielindex in den Referenzdaten
    refWayVec,...Vektor der Positionen der Referenzdaten in m
    refVelVec,...Vektor der Referenzgeschwindigkeit in m/s
    refSlpVec,...Vektor der Steigung der Referenz in %!!!!
    par... struct der Fahrzeugparameter 
    ) %#codegen
%INIDP initializing search for optimal predecessors with DP + PMP
% Erstellungsdatum der ersten Version 21.08.2015 - Stephan Uebel
% Diese Funktion initialisiert die Suche nach dem optimalen Vorg�nger mit 
% der Dynamischen Programmierung (DP). Diese subsitutiert die Zust�nde Zeit
% und Batterieenergie durch Co-States. Daher besteht der Zustandsraum nur
% aus dem Antriebsstrangzustand (hier kurz Zustand genannt) und der
% kinetischen Energie �ber dem Weg.

% �nderung am 25.05.2016 - Berechnung timEndRef mit Zero-Order-Hold

%% Initialisierung der Ausgabe der Funktion
  
% Index der kinetischen Energie im Ziel. Es gibt im Ziel nur eine
% kinetische Energie, daher wird der Wert auf 1 gesetzt.
engKinEndInx = 1;

% Zielzeit der Referenzgeschwindigkeit
timEndRef = 0;

% Vektor der Anzahl der kinetischen Energien
engKinNumVec_wayInx = zeros(wayNum,1);

% Matrix der kinetischen Energien in J
engKinMat_engKinInx_wayInx = inf(engKinNum,wayNum);

% Matrix der Segelvorg�nger
coaPreInxMat_engKinInx_wayInx = inf(engKinNum,wayNum);

%% �quidistanten Zyklus aus Referenzdaten erstellen

% Erstellen des �quidistanten Wegvektors
wayVec = 0:wayStp:(wayNum-1)*wayStp;

% Interpolieren der Referenzgeschwindigkeit und Berechnen der
% entsprechenden kinetischen Energie
velVec = interp1(refWayVec,refVelVec,wayVec);

% Interpolieren der Referenzsteigung und Umrechnung der Steigung in rad
% (Referenzsteigung ist in %)
slpVec_wayInx = atan(interp1(refWayVec,refSlpVec,wayVec));

% Anfangs- und Zielindex in den �quidistanten bestimmen
wayInxBeg = floor(refWayVec(refInxBeg) / wayStp)+1;
wayInxEnd = floor(refWayVec(refInxEnd) / wayStp)+1;

% Fehler und Abbruch, wenn nicht mindestens zwei Intervalle zum
% Optimieren vorhanden sind
if wayInxEnd - wayInxBeg < 2
warning('Teilst�ck f�r Optimierung zu kurz!')
end

%% Berechnung der Zielzeit f�r Referenzgeschwindigkeit

% Schleife �ber die Referenzgeschwindigkeit
for wayInx = wayInxBeg+1:wayInxEnd
    % Zielzeit berechnen durch Kumulieren der Zeiten f�r jedes Intervall
    % Zero-Order-Hold
    timEndRef = timEndRef + wayStp / velVec(wayInx-1);
end

%% Matrix der kinetischen Energie berechnen

% Startwert der kinetische Energie festlegen
engKinMat_engKinInx_wayInx(1,wayInxBeg) = ...
    .5*par.vehMas*velVec(wayInxBeg)^2;

% Zielwert der kinetischen Energie festlegen
engKinMat_engKinInx_wayInx(1,wayInxEnd) = ...
    .5*par.vehMas*velVec(wayInxEnd)^2;

% Initialisieren des Vektors der Anzahl der kinetischen Energien
engKinNumVec_wayInx(wayInxBeg,1) = 1;

% Die Schleife besetzt l�uft bis zum vorletzten Wegpunkt. Der letzte
% Wegpunkt ist durch die Referenzgeschwindigkeit bestimmt und wird nach der
% Schleife gesetzt.
for wayInx = wayInxBeg+1:wayInxEnd
    
    % kinetische Energie der Referenz im Wegpunkt bestimmen
    engKinRef = .5*par.vehMas*velVec(wayInx)^2;

    %% Bestimmung der Geschwindigkeitsgrenzen im Wegpunkt
    
    % Minimale kinetsiche Energie im aktuellen Wegpunkt berechnen. Sie 
    % ergbit sich bei konstanter Minimalbeschleunigung ab der
    % letzten minimalen kin. Energie. Sie wird der erste
    % Eintrag im Vektor der kin. Energien am aktuellen Wegpunkt.
    engKinAccMin = max([...
        par.vehVelMin^2*.5*par.vehMas,...% minimal m�gliche kinetische Energie ist durch Minimalgeschwindigkeit gegeben
        engKinRef - engKinVar,...% untere Grenze der kinetische Energie
        par.vehMas * par.vehAccMin * wayStp + ...kinetische Energie aus a_min
        engKinMat_engKinInx_wayInx(1,wayInx-1)]); 
    
    % Maximale kinetsiche Energie im aktuellen Wegpunkt berechnen. Sie
    % ergbit sich bei konstanter Maximalbeschleunigung ab der
    % letzten maximalen kin. Energie. Sie wird der erste
    % Eintrag im Vektor der kin. Energien am aktuellen Wegpunkt.
    engKinAccMax = min([...
        engKinRef + engKinVar,...% untere Grenze der kinetische Energie
        par.vehMas * par.vehAccMax * wayStp + ...kinetische Energie aus a_max
        engKinMat_engKinInx_wayInx(engKinNumVec_wayInx(wayInx-1),wayInx-1),...
        par.vehVelMax^2*.5*par.vehMas]); % maximal erlaubte Fahrzeuggeschwindigkeit 
    
    % Anzahl der St�tzstellen im Vektor der kinetischen Energien zum 
    % aktuellen Zeitpunkt berechnen
    engKinNumAct = ceil((engKinAccMax - engKinAccMin) / engKinStp);
    
    % Sollte die maximale Anzahl der St�tzstellen f�r die kinetische
    % Energie f�r die gew�nschte Diskretisierung nicht ausreichen, wird die
    % Diskretisierung vergr�bert
    if engKinNumAct > engKinNum
        warning('Diskretisierung wird gr�ber, da nicht genug St�tzstellen zur Verf�gung stehen.')
        engKinNumAct = engKinNum;
    end
    
    % Berechnung der tats�chlichen Diskretisierung der kinetischen Energie,
    % um minimale und maximale kinetische Energie auch genau zu treffen.
    % Das geht nur, wenn mehr als eine m�gliche kinetische Energie gefunden
    % wurde (else).
    if engKinNumAct > 1
        engKinStpAct = (engKinAccMax - engKinAccMin)/(engKinNumAct-1);
    else
        engKinStpAct = 0;
        engKinNumAct = 1;
    end
    engKinNumVec_wayInx(wayInx,1) = engKinNumAct;
    
    
    %% Erstellen des Vektors der kinetischen Energien 
    
    % Vektor initialisieren
    engKinActVec = inf(engKinNum,1);
    
    % Vektor f�llen f�r die berechnete Schrittweite
    for engKinInx = 1:engKinNumAct
        
        % kinetische Energie berechnen
        engKinActVec(engKinInx) = ...
            engKinAccMin + (engKinInx-1)*engKinStpAct;
        % speichern der kinetischen Energie in der Matrix
        engKinMat_engKinInx_wayInx(engKinInx,wayInx) = ...
            engKinActVec(engKinInx);
        
    end

    %% Segeln behandln (falls Flag gesetzt)
    if coaFlg
        % Es werden die Eintr�ge aus engKinActVec ersetzt, die am n�hesten 
        % an der berechneten durch Segeln erreichbaren kinetischen Energie 
        % liegen. Der erste und letzte Eintrag im Vektor (Grenzenergien)
        % werden dabei nicht ersetzt.
        % Ein Einf�gen der Energien w�rde ggf. zum Aufbl�hen des
        % Zustandsraums f�hren und wird daher nicht durchgef�hrt.
        
        % mittlere Steigung im betrachteten Intervall
        slp = (slpVec_wayInx(wayInx) + slpVec_wayInx(wayInx-1))/2;
        
        % Steigungskraft aus der mittleren Steigung berechnen (Skalar)
        vehFrcSlp = sind(slp) * par.vehMas * 9.81;
        
        % Schleife �ber alle im vorherigen Wegpunkt erreichten kinetischen
        % Energien. F�r jede kinetische Energie wird die durch Segeln
        % erreichbare Energie berechnet
        for engKinPreInx = 1:engKinNumVec_wayInx(wayInx-1)
            
            % betrachtete kinetische Energie am vorherigen Wegpunkt
            engKinPre = engKinMat_engKinInx_wayInx(engKinPreInx,wayInx-1);
                        
            % Rollreibung berechnen (Skalar)
            vehFrcRol = par.whlRolResCof*par.vehMas*9.81 * cosd(slp);
            
            % Luftwiderstandskraft berechnen (2*c_a/m * E_kin)
            % Es wird die kinetische Energie am Anfang des Intervalls als
            % kraftbestimmende Gr��e genutzt und nicht die mittlere
            % kin. Energie im Intervall. Das erleichtert die Berechnung des 
            % Zustands Segeln und verursacht nur einen minimalen Fehler bei 
            % den kleinen Wegschrittweiten        
            vehFrcDrg = 2*par.drgCof/par.vehMas*engKinPre;

            % Die Beschleunig f�r den ausgekuppelten Zustand berechnen
            % (nur R�der als tr�ge Rotationsmasse)
            accCoa = -(vehFrcSlp + vehFrcRol + vehFrcDrg) /...
                (par.whlMoi/par.whlDrr^2 + par.vehMas);
            
            % durch Segeln erreichbare kinetische Energie
            engKinCoa = par.vehMas*accCoa*wayStp + engKinPre;
            
            % Wenn die berechnete kinetische Energie innerhalb der
            % erlaubten Grenzen liegt
            if engKinCoa <= engKinAccMax && engKinCoa >= engKinAccMin
                
                % initialisieren der Differenz der kinetischen Energie
                engKinDifAbs = inf;
                % Index der kinetischen Energie mit der minimalen
                % Abweichung
                engKinInxOpt = 0;
                
                % Schleife �ber alle kinetischen Energien, die ersetzt
                % werden k�nnen. Die maximale und minimale kinetische
                % Energie sollen dabei nicht ersetzt werden k�nnen.
                for engKinInx = 2:engKinNumAct-1
                    
                    % Speichern der absoluten Abweichung der kinetischen
                    % Energie
                    engKinDifActAbs = ...
                        abs(engKinCoa - engKinActVec(engKinInx));
                    
                    % Wenn die aktuelle kinetische Energie eine geringere
                    % Abweichung als die bisher geringste hat, wird der
                    % Index gespreichert und der Index �berschrieben
                    if engKinDifActAbs < engKinDifAbs
                        
                        %  Speichern der minimalen Gr��en
                        engKinDifAbs = engKinDifActAbs;
                        engKinInxOpt = engKinInx;
                        
                    end
                    
                end
                % Wenn ein Index gefunden wurde, wird der Eintrag in der
                % Matrix �berschrieben
                if engKinInxOpt ~= 0
                    engKinMat_engKinInx_wayInx(engKinInxOpt,wayInx) = ...
                        engKinCoa;
                    coaPreInxMat_engKinInx_wayInx(engKinInxOpt,wayInx) = ...
                        engKinPreInx;
                end
            end            
        end  
    end
end

%% Ende des Programms
end