function setup_anesthesim()
%SETUP_ANESTHESIM Add AnestheSIM to the MATLAB path and build the Simulink model.
%   Run once per MATLAB session from the repository root:
%       setup_anesthesim
%   The Simulink model simulator/anesthesim.slx is (re)generated when it is
%   missing or was saved by a newer MATLAB release.

root = fileparts(mfilename('fullpath'));
addpath(root);
addpath(genpath(fullfile(root, 'src')));
addpath(fullfile(root, 'simulator'));
addpath(fullfile(root, 'examples'));

installed = {ver().Name};
if ~ismember('Simulink', installed)
    error('anesthesim:setup:missingProduct', 'AnestheSIM requires Simulink.');
end

slx = fullfile(root, 'simulator', 'anesthesim.slx');
if ~isfile(slx) || ~modelLoadsHere(slx)
    build_anesthesim_model(slx);
end
fprintf('AnestheSIM ready (%s).\n', root);
end

function tf = modelLoadsHere(slx)
% True when the saved model is not newer than the running Simulink.
saved = sscanf(Simulink.MDLInfo(slx).SimulinkVersion, '%d.%d')';
running = sscanf(ver('simulink').Version, '%d.%d')';
tf = saved(1) < running(1) || (saved(1) == running(1) && saved(2) <= running(2));
end
