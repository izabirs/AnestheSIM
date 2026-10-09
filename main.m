%% AnestheSIM quick start
% Simulate one VitalDB case end to end: acquire the record, drive the
% Simulink patient model with the recorded infusions and gases, compare
% predicted and measured BIS / MAP / HR, and report alarm episodes.
%
% Requires an internet connection on first use; downloads are cached in
% ./cache. See examples/ for cohort search, synthetic patients, the
% cohort validation and the figures of the accompanying paper.

setup_anesthesim;

caseId = 2809;   % sevoflurane induction, desflurane emergence

% Canonical signals required by this study, and optional ones used when recorded
signals = vitaldbDefaultSignals('tiva');
optional = [VitalSignal(TrackName.NEPI, TrackSource.ORCHESTRA), ...
            VitalSignal(TrackName.SEVO, TrackSource.PRIMUS), ...
            VitalSignal(TrackName.DES,  TrackSource.PRIMUS), ...
            VitalSignal(TrackName.GAS2, TrackSource.SOLAR8000)];

[patient, data] = loadPatientCase(DatabaseType.VitalDB, caseId, signals, 'Optional', optional);
fprintf('Case %d: %s, %d y, %.0f cm, %.1f kg\n', caseId, patient.sex, patient.age, ...
    patient.height, patient.weight);

simIn = buildSimulationInputs(data, 'Ts', 1);
res = runAnesthesim(patient, simIn, 'Data', data);

plotSimulation(res, simIn, sprintf('VitalDB case %d', caseId));

for model = ["minto", "bouillon", "greco", "volatile"]
    m = predictionMetrics(res.BIS.(model), simIn.meas.BIS);
    fprintf('BIS %-9s MDPE %6.1f %%  MDAPE %5.1f %%\n', model, m.MDPE, m.MDAPE);
end

alarms = detectAlarms(res.t, struct('BIS', res.BIS.volatile, 'MAP', res.MAP.separable, 'HR', res.HR));
disp(alarms);
