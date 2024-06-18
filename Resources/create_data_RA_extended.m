%% Clear and close everything
clear all; close all; clc;

%% Path
addpath(genpath('.'));

%% Run setup.m
setup;

%% Set working folder
init('EX_RA');

%% Supervisor design procedure

%%% Step 1

% Creat plant (components)
Q = 3; % number of states
       % the initial state q0 is always labeled "0"
Qm = 0; % marker state set
delta = [0,10,1; % transition triples (exit state, event, enter state)
         1,11,2;
         2,12,0];
create('A1', Q, delta, Qm); % create automaton
printdes('A1');

% Creat plant (components)
Q = 3; % number of states
       % the initial state q0 is always labeled "0"
Qm = 0; % marker state set
delta = [0,20,1; % transition triples (exit state, event, enter state)
         1,21,2;
         2,22,0];
create('A2', Q, delta, Qm); % create automaton
printdes('A2');

% Creat plant (components)
Q = 3; % number of states
       % the initial state q0 is always labeled "0"
Qm = 0; % marker state set
delta = [0,30,1; % transition triples (exit state, event, enter state)
         1,31,2;
         2,32,0];
create('A3', Q, delta, Qm); % create automaton
printdes('A3');

% Creat plant (components)
Q = 5; % number of states
       % the initial state q0 is always labeled "0"
Qm = 0; % marker state set
delta = [0,10,1; % transition triples (exit state, event, enter state)
         1,11,0;
         0,20,2;
         2,21,0;
         1,20,3;
         3,11,2;
         2,10,4;
         4,21,1];
create('SPEC11', Q, delta, Qm); % create automaton
printdes('SPEC11');

% Creat plant (components)
Q = 5; % number of states
       % the initial state q0 is always labeled "0"
Qm = 0; % marker state set
delta = [0,20,1; % transition triples (exit state, event, enter state)
         1,21,0;
         0,30,2;
         2,31,0;
         1,30,3;
         3,21,2;
         2,20,4;
         4,31,1];
create('SPEC12', Q, delta, Qm); % create automaton
printdes('SPEC12');

% Creat plant (components)
Q = 5; % number of states
       % the initial state q0 is always labeled "0"
Qm = 0; % marker state set
delta = [0,10,1; % transition triples (exit state, event, enter state)
         1,11,0;
         0,30,2;
         2,31,0;
         1,30,3;
         3,11,2;
         2,10,4;
         4,31,1];
create('SPEC13', Q, delta, Qm); % create automaton
printdes('SPEC13');

sync('SPEC1','SPEC11','SPEC12','SPEC13')

% Creat plant (components)
Q = 3; % number of states
       % the initial state q0 is always labeled "0"
Qm = [0,1,2]; % marker state set
delta = [0,11,1; % transition triples (exit state, event, enter state)
         1,12,0;
         0,21,2;
         2,22,0];
create('SPEC21', Q, delta, Qm); % create automaton
printdes('SPEC21');

% Creat plant (components)
Q = 3; % number of states
       % the initial state q0 is always labeled "0"
Qm = [0,1,2]; % marker state set
delta = [0,21,1; % transition triples (exit state, event, enter state)
         1,22,0;
         0,31,2;
         2,32,0];
create('SPEC22', Q, delta, Qm); % create automaton
printdes('SPEC22');

% Creat plant (components)
Q = 3; % number of states
       % the initial state q0 is always labeled "0"
Qm = [0,1,2]; % marker state set
delta = [0,11,1; % transition triples (exit state, event, enter state)
         1,12,0;
         0,31,2;
         2,32,0];
create('SPEC23', Q, delta, Qm); % create automaton
printdes('SPEC23');

sync('SPEC2','SPEC21','SPEC22','SPEC23')

%%% Step 2
sync('PLANT','A1','A2','A3');

%%% Step 3
sync('SPEC','SPEC1','SPEC2');
supcon('SUP', 'PLANT', 'SPEC');
printdes('SUP');

%%% Step 4
condat('SUPDAT_CA', 'PLANT', 'SUP');
printdat('SUPDAT_CA');


figure(1);
displaydes('SPEC');
figure(2);
displaydes('SUP');





