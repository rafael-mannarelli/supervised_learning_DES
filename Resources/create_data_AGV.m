%% Clear and close everything
clear all; close all; clc;

%% Path
addpath(genpath('.'));

%% Run setup.m
setup;

%% Set working folder
init('EX_AGV');

%% Supervisor design procedure

%%% Step 1

% Creat plant (components)
Q = 4; % number of states
       % the initial state q0 is always labeled "0"
Qm = 0; % marker state set
delta = [0,11,1; % transition triples (exit state, event, enter state)
         1,10,2;
         2,13,3;
         3,12,0];
create('AGV1', Q, delta, Qm); % create automaton

% Creat plant (components)
Q = 8; % number of states
       % the initial state q0 is always labeled "0"
Qm = 0; % marker state set
delta = [0,21,1; % transition triples (exit state, event, enter state)
         1,18,2;
         2,20,3;
         3,22,4;

         4,23,5;
         5,24,6;
         6,26,7;
         7,28,0];
create('AGV2', Q, delta, Qm); % create automaton

% Creat plant (components)
Q = 4; % number of states
       % the initial state q0 is always labeled "0"
Qm = 0; % marker state set
delta = [0,33,1; % transition triples (exit state, event, enter state)
         1,34,2;
         2,31,3;
         3,32,0;];
create('AGV3', Q, delta, Qm); % create automaton

% Creat plant (components)
Q = 6; % number of states
       % the initial state q0 is always labeled "0"
Qm = 0; % marker state set
delta = [0,41,1; % transition triples (exit state, event, enter state)
         1,40,2;
         2,42,3;
         3,43,4;
         4,44,5;
         5,46,0];
create('AGV4', Q, delta, Qm); % create automaton

% Creat plant (components)
Q = 4; % number of states
       % the initial state q0 is always labeled "0"
Qm = 0; % marker state set
delta = [0,51,1; % transition triples (exit state, event, enter state)
         1,50,2;
         2,53,3;
         3,52,0];
create('AGV5', Q, delta, Qm); % create automaton

%%% Step 2 - Sync AGVs

sync('AGV','AGV1','AGV2');
sync('AGV','AGV','AGV3');
sync('AGV','AGV','AGV4');
sync('AGV','AGV','AGV5');
allevents('ALL', 'AGV');

%%% Step 3 - Create ZSPECs and sync them

% Creat plant (components)
Q = 3; % number of states
       % the initial state q0 is always labeled "0"
Qm =[0,1,2]; % marker state set
delta = [0,11,1; % transition triples (exit state, event, enter state)
         0,13,1;
         0,20,2;
         0,23,2;
         1,10,0;
         1,12,0;
         2,22,0;
         2,24,0];
create('Z1SPEC', Q, delta, Qm); % create automaton
sync('Z1SPEC','Z1SPEC','ALL')

% Creat plant (components)
Q = 3; % number of states
       % the initial state q0 is always labeled "0"
Qm =[0,1,2]; % marker state set
delta = [0,18,1; % transition triples (exit state, event, enter state)
         0,24,1;
         0,31,2;
         0,33,2;
         1,20,0;
         1,26,0;
         2,32,0;
         2,34,0];
create('Z2SPEC', Q, delta, Qm); % create automaton
sync('Z2SPEC','Z2SPEC','ALL')

% Creat plant (components)
Q = 3; % number of states
       % the initial state q0 is always labeled "0"
Qm =[0,1,2]; % marker state set
delta = [0,21,1; % transition triples (exit state, event, enter state)
         0,26,1;
         0,41,2;
         0,44,2;
         1,18,0;
         1,28,0;
         2,40,0;
         2,46,0];
create('Z3SPEC', Q, delta, Qm); % create automaton
sync('Z3SPEC','Z3SPEC','ALL')

% Creat plant (components)
Q = 3; % number of states
       % the initial state q0 is always labeled "0"
Qm =[0,1,2]; % marker state set
delta = [0,40,1; % transition triples (exit state, event, enter state)
         0,43,1;
         0,51,2;
         0,53,2;
         1,42,0;
         1,44,0;
         2,50,0;
         2,52,0];
create('Z4SPEC', Q, delta, Qm); % create automaton
sync('Z4SPEC','Z4SPEC','ALL');

meet('ZSPEC','Z1SPEC','Z2SPEC');
meet('ZSPEC','ZSPEC','Z3SPEC');
meet('ZSPEC','ZSPEC','Z4SPEC');

%%% Step 4 - Create supervisor for ZSPEC

supcon('ZSUP', 'AGV', 'ZSPEC');
printdes('ZSUP');


%%% Step 5 - Create WSSPECs and sync them

% Creat plant (components)
Q = 4; % number of states
       % the initial state q0 is always labeled "0"
Qm =[0,1,2,3]; % marker state set
delta = [0,32,1; % transition triples (exit state, event, enter state)
         0,46,2;
         1,46,3;
         2,32,3;
         3,50,0];
create('WS1SPEC', Q, delta, Qm); % create automaton
sync('WS1SPEC','WS1SPEC','ALL');

% Creat plant (components)
Q = 2; % number of states
       % the initial state q0 is always labeled "0"
Qm =[0,1]; % marker state set
delta = [0,12,1; % transition triples (exit state, event, enter state)
         1,34,0];
create('WS2SPEC', Q, delta, Qm); % create automaton
sync('WS2SPEC','WS2SPEC','ALL');

% Creat plant (components)
Q = 2; % number of states
       % the initial state q0 is always labeled "0"
Qm =[0,1]; % marker state set
delta = [0,28,1; % transition triples (exit state, event, enter state)
         1,42,0];
create('WS3SPEC', Q, delta, Qm); % create automaton
sync('WS3SPEC','WS3SPEC','ALL');

meet('WSSPEC','WS1SPEC','WS2SPEC');
meet('WSSPEC','WSSPEC','WS3SPEC');

%%% Step 6 - Create supervisor for WSSPEC

supcon('WSSUP', 'AGV', 'WSSPEC');
printdes('WSSUP');

%%% Step 7 - Create IPSSPEC and sync them

% Creat plant (components)
Q = 3; % number of states
       % the initial state q0 is always labeled "0"
Qm =[0,1,2]; % marker state set
delta = [0,10,1; % transition triples (exit state, event, enter state)
         0,22,2;
         1,13,0;
         2,23,0];
create('IPSSPEC', Q, delta, Qm); % create automaton
sync('IPSSPEC','IPSSPEC','ALL');

%%% Step 8 - Create controlable supervisor for IPSSPEC

supcon('IPSSPEC', 'AGV', 'IPSSPEC');
condat('IPSSPEC_CA','AGV','IPSSPEC')
printdat('IPSSPEC_CA');

%%% Step 9 - Create a supervisor for ZSPEC and WSSPEC
meet('ZWSSPEC','ZSPEC','WSSPEC')
supcon('ZWSSUP','AGV','ZWSSPEC')
printdes('ZWSSUP');

%%% Step 10 - Create a supervisor for ZWSSPEC and IPSSPEC
meet('ZWSISSPEC','ZWSSPEC','IPSSPEC')
supcon('ZWSISSUP','AGV','ZWSISSPEC')
printdes('ZWSISSUP')
condat('ZWSISSUP_CA','AGV','ZWSISSUP')
printdat('ZWSISSUP_CA')

%%% Step 11 - Verify
%supreduce('ZWSISSIMSUP','AGV','ZWSISSUP','ZWSISSUP_CA')
%meet('TEST','AGV','ZWSISSIMSUP')
%isomorph('ZWSISSUP_CA','TEST')

%%% Print
displaydes('AGV1')
displaydes('AGV2')
displaydes('AGV3')
displaydes('AGV4')
displaydes('AGV5')
displaydes('')