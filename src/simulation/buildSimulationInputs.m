function simIn = buildSimulationInputs(data, opts)
%BUILDSIMULATIONINPUTS Resample canonical patientData onto the simulation clock.
%   simIn = buildSimulationInputs(data) aligns every signal on the common
%   grid t = 0:Ts:T. Pump rates are held between samples ('previous'),
%   gas and monitored signals are interpolated linearly. Inputs are zero
%   where nothing was recorded; monitored signals are NaN there.
%
%   simIn.t                 time grid [s]
%   simIn.u.prop/remi/nepi  pump rates [mL/h] (timeseries, Simulink inputs)
%   simIn.u.sevo/des        end-tidal volatile agents [vol%] (timeseries)
%   simIn.meas.*            recorded BIS, MAP, HR, pump Cp/Ce, device gas traces
%
%   Options: 'Ts' (default 1 s), 'Duration' (default: end of the record).

arguments
    data (1,1) struct
    opts.Ts (1,1) double {mustBePositive} = 1
    opts.Duration double = []
end

T = opts.Duration;
if isempty(T)
    T = recordDuration(data);
end
t = (0:opts.Ts:T)';

simIn.t = t;
simIn.Ts = opts.Ts;
simIn.T = t(end);

simIn.u.prop = inputSeries(data.Propofol.infRate, t, 'previous');
simIn.u.remi = inputSeries(data.Remifentanil.infRate, t, 'previous');
simIn.u.nepi = inputSeries(data.Norepinephrine.infRate, t, 'previous');
simIn.u.sevo = inputSeries(data.Sevoflurane.Et, t, 'linear');
simIn.u.des = inputSeries(data.Desflurane.Et, t, 'linear');

simIn.meas.BIS = tsInterp(data.BIS, t, 'linear', NaN);
simIn.meas.MAP = tsInterp(data.MAP, t, 'linear', NaN);
simIn.meas.HR = tsInterp(data.HR, t, 'linear', NaN);
simIn.meas.SQI = tsInterp(data.BISQuality.SQI, t, 'previous', NaN);
simIn.meas.CeProp = tsInterp(data.Propofol.Ce, t, 'linear', NaN);
simIn.meas.CpProp = tsInterp(data.Propofol.Cp, t, 'linear', NaN);
simIn.meas.CeRemi = tsInterp(data.Remifentanil.Ce, t, 'linear', NaN);
simIn.meas.CpRemi = tsInterp(data.Remifentanil.Cp, t, 'linear', NaN);
for f = string(fieldnames(data.Volatile))'
    simIn.meas.(f) = tsInterp(data.Volatile.(f), t, 'linear', NaN);
end
end

function ts = inputSeries(src, t, method)
v = tsInterp(src, t, method, 0);
v(~isfinite(v) | v < 0) = 0;
ts = timeseries(v, t);
end

function T = recordDuration(data)
series = {data.Propofol.infRate, data.Remifentanil.infRate, data.Norepinephrine.infRate, ...
    data.Sevoflurane.Et, data.Desflurane.Et, data.BIS, data.MAP, data.HR};
T = 0;
for k = 1:numel(series)
    s = series{k};
    if isa(s, 'timeseries') && s.Length > 1
        T = max(T, max(s.Time));
    end
end
if T == 0
    error('anesthesim:buildSimulationInputs:noData', ...
        'No recorded signal found; pass ''Duration'' explicitly.');
end
T = floor(T);
end
