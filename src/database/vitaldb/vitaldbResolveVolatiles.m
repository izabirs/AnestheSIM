function data = vitaldbResolveVolatiles(data, deadband)
%VITALDBRESOLVEVOLATILES Assign VitalDB gas-analyser traces to agents.
%   The Primus reports sevoflurane (and desflurane) agent-specifically,
%   whereas the Solar8000 GAS2 channel reports the total volatile agent.
%   A volatile present on both monitors is sevoflurane; volatile present on
%   the Solar8000 alone is desflurane, recovered as
%
%       Et_des = max(Solar8000 total - Primus sevoflurane, 0)
%
%   Residuals below DEADBAND vol% (default 0.3) are treated as calibration
%   offset between the two monitors. When Primus desflurane is recorded it
%   is used directly instead of the difference.

if nargin < 2
    deadband = 0.3;  % vol%
end
v = data.Volatile;

if isfield(v, 'PrimusSevo')
    data.Sevoflurane.Et = v.PrimusSevo;
end

if isfield(v, 'PrimusDes')
    data.Desflurane.Et = v.PrimusDes;
elseif isfield(v, 'SolarTotal')
    total = v.SolarTotal;
    if isfield(v, 'PrimusSevo')
        sevo = tsInterp(v.PrimusSevo, total.Time, 'linear', 0);
        des = total.Data(:) - sevo;
        des(des < deadband | isnan(des)) = 0;
        data.Desflurane.Et = timeseries(des, total.Time, 'Name', 'Desflurane Et');
    else
        warning('anesthesim:vitaldb:volatileAmbiguous', ...
            ['Total volatile requested without the Primus sevoflurane channel; ' ...
             'the agent cannot be identified and is treated as sevoflurane.']);
        data.Sevoflurane.Et = total;
    end
end
end
