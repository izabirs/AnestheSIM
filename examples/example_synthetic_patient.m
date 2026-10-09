%% Synthetic patient with a designed infusion profile (no internet needed)
% Uses a patient from the shipped Population database and a hand-made
% dosing schedule: propofol/remifentanil induction and maintenance, a
% sevoflurane phase, and a norepinephrine infusion during hypotension.
% Use this template to test a controller: replace the schedule by the
% controller's commanded pump rates.

setup_anesthesim;

[patient, data] = loadPatientCase(DatabaseType.Population, 5);

t = (0:1:7200)';                       % 2 h, 1 s grid
prop = 25 * (t >= 120);                % mL/h maintenance (20 mg/mL)
prop(t >= 120 & t < 180) = 400;        % induction bolus
prop(t >= 3600 & t < 6000) = 10;       % reduced while sevoflurane is given
remi = 12 * (t >= 120);                % mL/h (20 ug/mL)
remi(t >= 3600) = 6;
sevo = 1.2 * (t >= 3600 & t < 6000);   % vol% end-tidal
nepi = 8 * (t >= 1800 & t < 3000);     % mL/h (20 ug/mL)

data.Propofol.infRate = timeseries(prop, t);
data.Remifentanil.infRate = timeseries(remi, t);
data.Norepinephrine.infRate = timeseries(nepi, t);
data.Sevoflurane.Et = timeseries(sevo, t);

simIn = buildSimulationInputs(data, 'Duration', t(end));
res = runAnesthesim(patient, simIn, 'Data', data);

fig = plotSimulation(res, simIn, sprintf('Synthetic patient %d (%d y, %s)', ...
    patient.id, patient.age, patient.sex));
saveFigure(fig, 'synthetic_patient');

alarms = detectAlarms(res.t, struct('BIS', res.BIS.volatile, 'MAP', res.MAP.separable, 'HR', res.HR));
disp(alarms);
