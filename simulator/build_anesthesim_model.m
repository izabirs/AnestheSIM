function build_anesthesim_model(outFile)
%BUILD_ANESTHESIM_MODEL Generate the AnestheSIM Simulink model (anesthesim.slx).
%   build_anesthesim_model() rebuilds simulator/anesthesim.slx from library
%   blocks. The model is generated so that its structure is reviewable as
%   code and reproducible in any recent MATLAB release.
%
%   Top level: five drug inputs (From Workspace, variable u) feed a single
%   Patient block whose outputs are logged to the workspace:
%       BIS_IV    [Minto, Bouillon, reduced Greco]   intravenous agents only
%       BIS_vol   reduced Greco with volatile agents
%       MAP       [separable (turnover + NE), unified three-drug]
%       HR        turnover heart-rate model
%       Conc      [CpP CeP CpR CeR CcN CeSevo CeDes]
%
%   All parameters are resolved from variables supplied by runAnesthesim
%   (models, pBisMinto, pBisBouillon, pBisGreco, pBisVolatile, pHemo, pNE,
%   pMapUnified, u, Ts).

if nargin < 1
    outFile = fullfile(fileparts(mfilename('fullpath')), 'anesthesim.slx');
end
[~, mdl] = fileparts(outFile);

if bdIsLoaded(mdl)
    close_system(mdl, 0);
end
new_system(mdl);
load_system('simulink');

set_param(mdl, 'Solver', 'ode15s', 'MaxStep', 'Ts', 'RelTol', '1e-4', ...
    'StopTime', '3600', 'SaveOutput', 'off', 'SaveTime', 'off', ...
    'ReturnWorkspaceOutputs', 'on', 'SignalLogging', 'off');

%% Top level
inputs = {
    'Propofol rate',          'u.prop', 'propofol pump rate [mL/h]'
    'Remifentanil rate',      'u.remi', 'remifentanil pump rate [mL/h]'
    'Norepinephrine rate',    'u.nepi', 'norepinephrine pump rate [mL/h]'
    'Sevoflurane Et',         'u.sevo', 'end-tidal sevoflurane [vol%]'
    'Desflurane Et',          'u.des',  'end-tidal desflurane [vol%]'};
for k = 1:size(inputs, 1)
    y = 40 + 70 * (k - 1);
    b = [mdl '/' inputs{k, 1}];
    add_block('simulink/Sources/From Workspace', b, 'Position', [40 y 190 y + 30], ...
        'VariableName', inputs{k, 2}, 'SampleTime', 'Ts', 'Interpolate', 'off', ...
        'OutputAfterFinalValue', 'Holding final value');
end

patient = [mdl '/Patient'];
add_block('simulink/Ports & Subsystems/Subsystem', patient, 'Position', [300 30 500 380]);
delete_line(patient, 'In1/1', 'Out1/1');
delete_block([patient '/In1']);
delete_block([patient '/Out1']);
set_param(patient, 'BackgroundColor', 'lightBlue');

outputs = {'BIS_IV', 'BIS_vol', 'MAP', 'HR', 'Conc'};

buildPatient(patient, inputs, outputs);

for k = 1:size(inputs, 1)
    add_line(mdl, [inputs{k, 1} '/1'], ['Patient/' num2str(k)]);
end
for k = 1:numel(outputs)
    y = 40 + 70 * (k - 1);
    b = [mdl '/' outputs{k}];
    add_block('simulink/Sinks/To Workspace', b, 'Position', [600 y 700 y + 30], ...
        'VariableName', outputs{k}, 'SaveFormat', 'Timeseries', 'SampleTime', 'Ts');
    add_line(mdl, ['Patient/' num2str(k)], [outputs{k} '/1']);
end

add_block('built-in/Note', [mdl '/AnestheSIM'], 'Position', [40 420], ...
    'Text', ['AnestheSIM patient model. Inputs in pump units (mL/h) and end-tidal vol%. ' ...
             'Run via runAnesthesim(patient, simIn).'], 'FontSize', '10');

save_system(mdl, outFile);
close_system(mdl);
fprintf('Saved %s\n', outFile);
end

function buildPatient(sys, inputs, outputs)
% Ports
names = {'u_prop', 'u_remi', 'u_nepi', 'Et_sevo', 'Et_des'};
for k = 1:numel(names)
    y = 50 + 120 * (k - 1);
    add_block('simulink/Sources/In1', [sys '/' names{k}], 'Position', [20 y 50 y + 14], ...
        'Port', num2str(k));
    set_param([sys '/' names{k}], 'Description', inputs{k, 3});
end
for k = 1:numel(outputs)
    y = 50 + 120 * (k - 1);
    add_block('simulink/Sinks/Out1', [sys '/' outputs{k}], 'Position', [1500 y 1530 y + 14], ...
        'Port', num2str(k));
end

pkColor = 'cyan';
bisColor = 'magenta';
hemoColor = 'orange';
volColor = 'yellow';

% Propofol: converter -> Schnider PK + effect site
addGain(sys, 'Propofol converter', 'models.conv.prop', [120 45 230 75]);
addStateSpace(sys, 'Schnider PK', 'models.prop', [290 40 400 80], pkColor);
addDemux(sys, 'Demux prop', 2, [440 40 445 80]);
add_line(sys, 'u_prop/1', 'Propofol converter/1');
add_line(sys, 'Propofol converter/1', 'Schnider PK/1');
add_line(sys, 'Schnider PK/1', 'Demux prop/1');

% Remifentanil: converter -> Minto PK + effect site
addGain(sys, 'Remifentanil converter', 'models.conv.remi', [120 165 230 195]);
addStateSpace(sys, 'Minto PK', 'models.remi', [290 160 400 200], pkColor);
addDemux(sys, 'Demux remi', 2, [440 160 445 200]);
add_line(sys, 'u_remi/1', 'Remifentanil converter/1');
add_line(sys, 'Remifentanil converter/1', 'Minto PK/1');
add_line(sys, 'Minto PK/1', 'Demux remi/1');

% Norepinephrine: converter -> transport lag -> Joachim PK
addGain(sys, 'NE converter', 'models.conv.nepi', [120 285 230 315]);
add_block('simulink/Continuous/Transport Delay', [sys '/NE transport lag'], ...
    'Position', [260 285 320 315], 'DelayTime', 'models.nepi.Tlag', ...
    'InitialOutput', '0', 'BufferSize', '16384', 'BackgroundColor', pkColor);
addStateSpace(sys, 'Joachim PK', 'models.nepi', [350 280 440 320], pkColor);
add_line(sys, 'u_nepi/1', 'NE converter/1');
add_line(sys, 'NE converter/1', 'NE transport lag/1');
add_line(sys, 'NE transport lag/1', 'Joachim PK/1');

% Volatile agents: first-order effect sites
addStateSpace(sys, 'Sevoflurane effect site', 'models.sevo', [290 400 400 440], volColor);
addStateSpace(sys, 'Desflurane effect site', 'models.des', [290 520 400 560], volColor);
add_line(sys, 'Et_sevo/1', 'Sevoflurane effect site/1');
add_line(sys, 'Et_des/1', 'Desflurane effect site/1');

% BIS, intravenous agents: three interaction surfaces in parallel
addFcn(sys, 'BIS Minto', [600 30 720 80], bisColor, ...
    'function BIS = fcn(CeP, CeR, pBisMinto)', 'BIS = bisMinto(CeP, CeR, pBisMinto);', {'pBisMinto'});
addFcn(sys, 'BIS Bouillon', [600 100 720 150], bisColor, ...
    'function BIS = fcn(CeP, CeR, pBisBouillon)', 'BIS = bisBouillon(CeP, CeR, pBisBouillon);', {'pBisBouillon'});
addFcn(sys, 'BIS reduced Greco', [600 170 720 220], bisColor, ...
    'function BIS = fcn(CeP, CeR, pBisGreco)', 'BIS = bisGreco(CeP, CeR, pBisGreco);', {'pBisGreco'});
add_block('simulink/Signal Routing/Mux', [sys '/Mux BIS_IV'], 'Inputs', '3', ...
    'Position', [800 40 805 210]);
for b = {'BIS Minto', 'BIS Bouillon', 'BIS reduced Greco'}
    add_line(sys, 'Demux prop/2', [b{1} '/1'], 'autorouting', 'smart');
    add_line(sys, 'Demux remi/2', [b{1} '/2'], 'autorouting', 'smart');
end
add_line(sys, 'BIS Minto/1', 'Mux BIS_IV/1');
add_line(sys, 'BIS Bouillon/1', 'Mux BIS_IV/2');
add_line(sys, 'BIS reduced Greco/1', 'Mux BIS_IV/3');
add_line(sys, 'Mux BIS_IV/1', 'BIS_IV/1', 'autorouting', 'smart');

% BIS with volatile agents
addFcn(sys, 'BIS reduced Greco + volatiles', [600 380 740 470], volColor, ...
    'function BIS = fcn(CeP, CeR, CeSevo, CeDes, pBisVolatile)', ...
    'BIS = bisGrecoVolatile(CeP, CeR, CeSevo, CeDes, pBisVolatile);', {'pBisVolatile'});
add_line(sys, 'Demux prop/2', 'BIS reduced Greco + volatiles/1', 'autorouting', 'smart');
add_line(sys, 'Demux remi/2', 'BIS reduced Greco + volatiles/2', 'autorouting', 'smart');
add_line(sys, 'Sevoflurane effect site/1', 'BIS reduced Greco + volatiles/3', 'autorouting', 'smart');
add_line(sys, 'Desflurane effect site/1', 'BIS reduced Greco + volatiles/4', 'autorouting', 'smart');
add_line(sys, 'BIS reduced Greco + volatiles/1', 'BIS_vol/1', 'autorouting', 'smart');

% Haemodynamics: turnover MAP/HR model (propofol, remifentanil plasma)
hemo = [sys '/MAP-HR turnover model'];
add_block('simulink/Ports & Subsystems/Subsystem', hemo, 'Position', [600 560 740 640], ...
    'BackgroundColor', hemoColor);
buildTurnover(hemo);
add_line(sys, 'Demux prop/1', 'MAP-HR turnover model/1', 'autorouting', 'smart');
add_line(sys, 'Demux remi/1', 'MAP-HR turnover model/2', 'autorouting', 'smart');

% Norepinephrine pressor effect (Joachim Emax) and separable MAP
addFcn(sys, 'NE pressor effect', [600 280 720 320], hemoColor, ...
    'function dMAP = fcn(CcN, pNE)', 'dMAP = norepinephrineEffect(CcN, pNE);', {'pNE'});
add_line(sys, 'Joachim PK/1', 'NE pressor effect/1', 'autorouting', 'smart');
add_block('simulink/Math Operations/Add', [sys '/MAP separable'], ...
    'Position', [880 560 910 600], 'BackgroundColor', hemoColor);
add_line(sys, 'MAP-HR turnover model/1', 'MAP separable/1', 'autorouting', 'smart');
add_line(sys, 'NE pressor effect/1', 'MAP separable/2', 'autorouting', 'smart');

% Unified three-drug MAP model (effect sites)
addFcn(sys, 'MAP unified', [600 680 740 750], hemoColor, ...
    'function MAP = fcn(CeP, CeR, CcN, pMapUnified)', ...
    'MAP = mapUnified(CeP, CeR, CcN, pMapUnified);', {'pMapUnified'});
add_line(sys, 'Demux prop/2', 'MAP unified/1', 'autorouting', 'smart');
add_line(sys, 'Demux remi/2', 'MAP unified/2', 'autorouting', 'smart');
add_line(sys, 'Joachim PK/1', 'MAP unified/3', 'autorouting', 'smart');

add_block('simulink/Signal Routing/Mux', [sys '/Mux MAP'], 'Inputs', '2', ...
    'Position', [1000 560 1005 760]);
add_line(sys, 'MAP separable/1', 'Mux MAP/1', 'autorouting', 'smart');
add_line(sys, 'MAP unified/1', 'Mux MAP/2', 'autorouting', 'smart');
add_line(sys, 'Mux MAP/1', 'MAP/1', 'autorouting', 'smart');
add_line(sys, 'MAP-HR turnover model/2', 'HR/1', 'autorouting', 'smart');

% Concentrations
add_block('simulink/Signal Routing/Mux', [sys '/Mux Conc'], 'Inputs', '7', ...
    'Position', [1300 380 1305 760]);
add_line(sys, 'Demux prop/1', 'Mux Conc/1', 'autorouting', 'smart');
add_line(sys, 'Demux prop/2', 'Mux Conc/2', 'autorouting', 'smart');
add_line(sys, 'Demux remi/1', 'Mux Conc/3', 'autorouting', 'smart');
add_line(sys, 'Demux remi/2', 'Mux Conc/4', 'autorouting', 'smart');
add_line(sys, 'Joachim PK/1', 'Mux Conc/5', 'autorouting', 'smart');
add_line(sys, 'Sevoflurane effect site/1', 'Mux Conc/6', 'autorouting', 'smart');
add_line(sys, 'Desflurane effect site/1', 'Mux Conc/7', 'autorouting', 'smart');
add_line(sys, 'Mux Conc/1', 'Conc/1', 'autorouting', 'smart');
end

function buildTurnover(sys)
delete_line(sys, 'In1/1', 'Out1/1');
delete_block([sys '/In1']);
delete_block([sys '/Out1']);
add_block('simulink/Sources/In1', [sys '/CpP'], 'Position', [20 50 50 64]);
add_block('simulink/Sources/In1', [sys '/CpR'], 'Position', [20 100 50 114]);
add_block('simulink/Sources/Clock', [sys '/Clock'], 'Position', [20 150 50 180]);
addFcn(sys, 'Turnover derivatives', [150 40 300 220], 'orange', ...
    'function [dMAP, dHR] = fcn(CpP, CpR, t, MAP, HR, pHemo)', ...
    '[dMAP, dHR] = hemodynamicTurnover(CpP, CpR, t, MAP, HR, pHemo);', {'pHemo'});
add_block('simulink/Continuous/Integrator', [sys '/MAP state'], ...
    'Position', [380 60 410 90], 'InitialCondition', 'pHemo.MAP0');
add_block('simulink/Continuous/Integrator', [sys '/HR state'], ...
    'Position', [380 160 410 190], 'InitialCondition', 'pHemo.HR0');
add_block('simulink/Sinks/Out1', [sys '/MAP'], 'Position', [500 68 530 82]);
add_block('simulink/Sinks/Out1', [sys '/HR'], 'Position', [500 168 530 182]);
add_line(sys, 'CpP/1', 'Turnover derivatives/1');
add_line(sys, 'CpR/1', 'Turnover derivatives/2');
add_line(sys, 'Clock/1', 'Turnover derivatives/3');
add_line(sys, 'Turnover derivatives/1', 'MAP state/1');
add_line(sys, 'Turnover derivatives/2', 'HR state/1');
add_line(sys, 'MAP state/1', 'MAP/1');
add_line(sys, 'HR state/1', 'HR/1');
add_line(sys, 'MAP state/1', 'Turnover derivatives/4', 'autorouting', 'smart');
add_line(sys, 'HR state/1', 'Turnover derivatives/5', 'autorouting', 'smart');
end

function addGain(sys, name, gain, pos)
add_block('simulink/Math Operations/Gain', [sys '/' name], 'Gain', gain, 'Position', pos);
end

function addDemux(sys, name, n, pos)
add_block('simulink/Signal Routing/Demux', [sys '/' name], 'Outputs', num2str(n), 'Position', pos);
end

function addStateSpace(sys, name, var, pos, color)
add_block('simulink/Continuous/State-Space', [sys '/' name], 'Position', pos, ...
    'A', [var '.A'], 'B', [var '.B'], 'C', [var '.C'], 'D', [var '.D'], ...
    'InitialCondition', '0', 'BackgroundColor', color);
end

function addFcn(sys, name, pos, color, signature, body, params)
blk = [sys '/' name];
add_block('simulink/User-Defined Functions/MATLAB Function', blk, 'Position', pos);
set_param(blk, 'BackgroundColor', color);
chart = sfroot().find('-isa', 'Stateflow.EMChart', 'Path', blk);
chart.Script = sprintf('%s\n%%#codegen\n%s\nend\n', signature, body);
for k = 1:numel(params)
    d = chart.find('-isa', 'Stateflow.Data', 'Name', params{k});
    d.Scope = 'Parameter';
end
end
