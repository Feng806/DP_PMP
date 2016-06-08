function [ fulVolPerWay,timEnd ] = clcFulVolPerWay( ...
    wayInxBeg,...
    wayInxEnd,...
    wayStp,...
    batPwrAux,...
    slpVec,...
    geaVec,...
    batEngVec,...
    engKinVec,...
    par)
%CLCFULVOLPERWAY Calculates consumated fuel volume per 100 km
%   Aus gegebener Steigungs-, Geschwindigkeits-, Ladungs- und
%   Gangtrajektorie, wird der Kraftstoffverbrauch berechnet. Die erste
%   Version rechnet nur hybridisch.

% Version vom 25.05.2016: Zero-Order-Hold (keine mittlere Geschwindigkeit)

addpath('../model data','../cycle','../functions')

%% Laden der Eingangsdaten

% Laden der Modelldaten
if ~exist('par','var')
    load('vehMdl.mat') % enth�lt: par (struct)
end

% Modelldaten sind eventuell ge�ndert (z.B. Batteriegr��e oder
% Beschleunigung) - siehe cfg.mat
fulEng = 0;
timEnd = 0;
for wayInx = wayInxBeg+1:wayInxEnd
    
    %% Vorbereitung der Daten    
    batEngAct = batEngVec(wayInx);
    batEngDlt = batEngAct - batEngVec(wayInx-1);
    
    engKinPre = engKinVec(wayInx-1);
    velPre = sqrt(2*engKinPre/par.vehMas);
    engKinAct = engKinVec(wayInx);
    
    slp = slpVec(wayInx-1);
    
    gea = geaVec(wayInx-1);    
    if gea > length(par.geaRat)
        error('Diese Funktion akzeptiert nur Zust�nde im hybridischen Fahren!')
    end
    
    %% Berechnung der Zeit
    timEnd = timEnd + wayStp/velPre;    
    
    %% Berechnung der Kraftstoffenergie
    [ fulEngDlt, ...Skalar - Kraftstoffverbrauch in J
        crsSpd, ...Skalar f�r die mittlere Kurbelwellendrehzahl
        emoTrq, ...Skalar f�r das Drehmoment des Elektromotors
        iceTrq, ...Skalar f�r das Drehmoment des Verbrennungsmotors
        batPwr ...Skalar f�r die Batterieleistung
        ] = ...
        fulEngClc...
        (wayStp,... Skalar f�r die Wegschrittweite in m
        batPwrAux,... Nebenverbraucherlast
        slp,... Steigung der Fahrbahn in rad
        engKinPre,...Skalar - kin. Energie am Anfang
        engKinAct,...Skalar - kin. Energie am Ende
        batEngAct,... Skalar - aktuelle Energie der Batterie
        batEngDlt, ... Skalar - Batterieenergie�nderung
        gea,...Skalar - aktueller Gang
        par...struct der Fahrzeugparameter
        );

    fulEng = fulEngDlt + fulEng;

    %% L�ngsdynamikgrenzen
    % Berechnen der konstanten Beschleunigung
    vehAcc = (engKinAct - engKinPre) / (par.vehMas*wayStp);    
    assert(abs(vehAcc) <= par.vehAccMax,...
        'Es treten zu hohe Beschleunigungen auf!')
    
    %% Grenzen Verbrennungsmotor
    % maximales Moment des Verbrennungsmotors berechnen
    iceTrqMax = par.iceTrqMaxCof(1) * crsSpd^2 ...
        + par.iceTrqMaxCof(2) * crsSpd ...
        + par.iceTrqMaxCof(3);
    assert(iceTrq <= iceTrqMax,'Zu hohe Momente des Verbrennungsmotors!')
    
    % minimales Moment des Verbrennungsmotors berechnen
    iceTrqMin = par.iceTrqMinCof(1) * crsSpd^2 ...
        + par.iceTrqMinCof(2) * crsSpd ...
        + par.iceTrqMinCof(3);
    assert(iceTrq >= iceTrqMin && fulEngDlt > 0 || iceTrq < iceTrqMin,...
        'Fehler in Berechnung des Verbrennungsmotormomens!')
    
    %% Grenzen des Elektromotors
    % minimales Moment, dass die E-Maschine liefern kann
    emoTrqMin = ...
        interp1q(par.emoSpdMgd(1,:)',par.emoTrqMin_emoSpd,crsSpd);
    assert(emoTrq >= emoTrqMin*1.01,'Zu niedrige E-Motormomente treten auf!')
    
    % maximales Moment, dass die E-Maschine liefern kann
    emoTrqMax = ...
        interp1q(par.emoSpdMgd(1,:)',par.emoTrqMax_emoSpd,crsSpd);
    assert(emoTrq <= emoTrqMax*1.01,'Zu hohe E-Motormomente treten auf!')
    
    %% Grenzen der Batterie
    assert(batPwr >= par.batPwrMin*1.01,...
        'Zu niedrige Batterieleistungen treten auf!')
    
    assert(batPwr <= par.batPwrMax*1.01,...
        'Zu hohe Batterieleistungen treten auf!')
    
end
fulVolPerWay =  fulEng / par.fulLhv / par.fulDen /...
    (wayInxEnd-wayInxBeg)*1e5/wayStp;     

% Ende der Hauptfunktion
end

