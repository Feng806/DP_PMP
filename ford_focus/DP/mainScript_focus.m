% mainScript_focus.m
%
% this script will be for running DP fuel-minimizing optimization algorithm
% The mainScript is broken up into three parts:
%   1. Defining work directory.
%   2. Loading runFocusDP algorithm inputs.
%   3. Run runFocusDP algorithm.
%
% last edited 12.08.2016 (asgard kaleb marroquin)
%% 1. Defining work directory
% make sure to be in the DP directory, where the functions are located
cd('C:\Users\s0032360\Documents\GitHub\DP_PMP\ford_focus\DP\');
% cd('/home/kaulef/Documents/DAAD/TUD/4Kaleb/ford_focus/DP')

addpath('../model_data')

%% 2. Loading runFocusDP algorithm inputs
% define init_focus() inputs

% define mainConfig.txt string location
config_filename = 'mainConfig_focus.txt';
% define raw data directory
datafile_dir    = 'raw_data';
% bool for if user wishes to rewrite raw data
write_bool      = 1;

% call init_port() - outputs are input structures to clcDP_port()
[inputparams, tst_scalar_struct, fzg_scalar_struct, tst_array_struct, nedc_array_struct, fzg_array_struct]...
         = init_focus(config_filename, datafile_dir, write_bool);
     
%% 3. Run runFocusDP algorithm
[   batEngDltOptMat,    ... Vektor - optimale Batterieenergiešnderung
    fulEngDltOptMat,    ... Vektor - optimale Kraftstoffenergiešnderung
    geaStaMat,          ... Vektor - Trajektorie des optimalen Antriebsstrangzustands
    engStaMat,          ... vector showing optimal engine contorl w/ profile
    batPwrMat,          ... vector showing optimal battery level control
    batEngMat,          ... vector showing optimal battery levels
    fulEngOptVec,       ... Skalar - optimale Kraftstoffenergie
] =                     ...
    runFocusDP          ...
(                       ...
    inputparams,        ... input model parameters (mainConfig group 1)
    tst_scalar_struct,  ...
    fzg_scalar_struct,  ...
    nedc_array_struct,  ...
    fzg_array_struct    ...
);
