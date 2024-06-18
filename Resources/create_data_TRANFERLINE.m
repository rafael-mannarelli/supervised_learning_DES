%% Clear and close everything
clear all; close all; clc;

%% Path
addpath(genpath('.'));

%% Run setup.m
setup;

%% Set working folder
init('EX_TRANSFERLINE5\');

%% Supervisor design procedure

%%% Step 1

% Creat plant (components)
Q = 2; % number of states
       % the initial state q0 is always labeled "0"
Qm = [0]; % marker state set
delta = [0,1,1; % transition triples (exit state, event, enter state)
         1,2,0];
create('M1', Q, delta, Qm); % create automaton

% Creat plant (components)
Q = 2; % number of states
       % the initial state q0 is always labeled "0"
Qm = [0]; % marker state set
delta = [0,3,1; % transition triples (exit state, event, enter state)
         1,4,0];
create('M2', Q, delta, Qm); % create automaton

% Creat plant (components)
Q = 2; % number of states
       % the initial state q0 is always labeled "0"
Qm = [0]; % marker state set
delta = [0,5,1; % transition triples (exit state, event, enter state)
         1,6,0;
         1,8,0];
create('M3', Q, delta, Qm); % create automaton

% Creat plant (components)
Q = 4; % number of states
       % the initial state q0 is always labeled "0"
Qm = [0,1,2,3]; % marker state set
delta = [0,2,1; % transition triples (exit state, event, enter state)
         0,8,1;
         1,2,2;
         1,8,2;
         2,2,3;
         2,8,3;
         3,3,2;
         2,3,1;
         1,3,0];
create('E1', Q, delta, Qm); % create automaton

% Creat plant (components)
Q = 3; % number of states
       % the initial state q0 is always labeled "0"
Qm = [0,1,2]; % marker state set
delta = [0,4,1; % transition triples (exit state, event, enter state)
         1,4,2;
         2,5,1;
         1,5,0
         ];
create('E2', Q, delta, Qm); % create automaton

%%% Step 2 - Create PLANT and ALL

sync('PLANT','M1','M2','M3');
allevents('ALL', 'PLANT');

%%% Step 3 - Create SPEC, SUP, SUPDAT
sync('SPEC','E1','E2','ALL')

%%% Step 4 - Create SUP

supcon('SUP', 'PLANT', 'SPEC');
printdes('SUP');


%displaydes('SUP') % display automaton


%%% Step 5 - Create SUPDAT

condat('SUPDAT_CA', 'PLANT', 'SUP');
printdat('SUPDAT_CA');

%%% Step 6 - Create SIMSUP

supreduce('SIMSUP','PLANT','SUP','SUPDAT_CA')
printdes('SIMSUP');

condat('SIMSUP_CA','PLANT','SIMSUP')
printdat('SIMSUP_CA');

%%% Display
figure(1);
displaydes('M1');
displaydes('M2');
displaydes('M3');
displaydes('E1');
displaydes('E2');