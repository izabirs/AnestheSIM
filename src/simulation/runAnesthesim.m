function res = runAnesthesim(patient, simIn, opts)
%RUNANESTHESIM Simulate one patient with the AnestheSIM Simulink model.
%   res = runAnesthesim(patient, simIn) instantiates all covariate models
%   for the patient, drives anesthesim.slx with the recorded (or
%   synthetic) inputs in simIn (see buildSimulationInputs) and returns the
%   monitored outputs on simIn.t:
%
%   res.BIS.minto / .bouillon / .greco   intravenous-only BIS predictions
%   res.BIS.volatile                     reduced Greco including volatile agents
%   res.MAP.separable / .unified         MAP predictions [mmHg]
%   res.HR                               heart rate [bpm]
%   res.conc                             model concentrations (see computeConcentrations)
%   res.params                           every parameter set used
%
%   Name-value options replace a default parameter set, e.g. a user's own:
%       'BisVolatile'   structure with the layout of bisParameters
%       'MapUnified'    structure with the layout of mapUnifiedParameters
%       'Hemodynamics'  structure from hemodynamicParameters
%       'Data'          canonical patientData (pump solution strengths)

arguments
    patient (1,1) Patient
    simIn (1,1) struct
    opts.Data = []
    opts.BisVolatile = []
    opts.MapUnified = []
    opts.Hemodynamics = []
end

models = buildPatientModels(patient, opts.Data);
[MAP0, HR0] = estimateBaselines(simIn, patient);

p.pBisMinto = bisParameters('minto', patient);
p.pBisBouillon = bisParameters('bouillon', patient);
p.pBisGreco = bisParameters('greco', patient);
p.pBisVolatile = defaultTo(opts.BisVolatile, p.pBisGreco);
p.pHemo = defaultTo(opts.Hemodynamics, hemodynamicParameters(MAP0, HR0));
p.pMapUnified = defaultTo(opts.MapUnified, mapUnifiedParameters(MAP0, models.nepi));
p.pNE = struct('Emax', models.nepi.Emax, 'EC50', models.nepi.EC50, ...
    'gamma', models.nepi.gamma, 'Cendo', models.nepi.Cendo);

in = Simulink.SimulationInput('anesthesim');
in = in.setVariable('u', simIn.u);
in = in.setVariable('Ts', simIn.Ts);
in = in.setVariable('models', models);
for name = string(fieldnames(p))'
    in = in.setVariable(name, p.(name));
end
in = in.setModelParameter('StopTime', num2str(simIn.T));
out = sim(in);

t = simIn.t;
bisIV = onGrid(out.BIS_IV, t);
map = onGrid(out.MAP, t);
conc = onGrid(out.Conc, t);

res.t = t;
res.BIS.minto = bisIV(:, 1);
res.BIS.bouillon = bisIV(:, 2);
res.BIS.greco = bisIV(:, 3);
res.BIS.volatile = onGrid(out.BIS_vol, t);
res.MAP.separable = map(:, 1);
res.MAP.unified = map(:, 2);
res.HR = onGrid(out.HR, t);
res.conc = cell2struct(num2cell(conc, 1), {'CpP', 'CeP', 'CpR', 'CeR', 'CcN', 'CeSevo', 'CeDes'}, 2);
res.params = p;
res.models = models;
end

function v = defaultTo(v, default)
if isempty(v)
    v = default;
end
end

function y = onGrid(ts, t)
y = squeeze(ts.Data);
if isrow(y)
    y = y(:);
end
if size(y, 1) ~= numel(t) || any(abs(ts.Time(:) - t) > 1e-9)
    y = interp1(ts.Time, y, t, 'previous', 'extrap');
end
end
