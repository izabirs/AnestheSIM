%% Balanced anaesthesia: the effect of the inhaled agents on BIS
% Case 2809 is induced with sevoflurane and emerges under desflurane. The
% intravenous model alone ignores the inhaled agents; the extended reduced
% Greco model adds them as hypnotics. Literature parameters throughout.

setup_anesthesim;

caseId = 2809;
signals = vitaldbDefaultSignals('balanced');
optional = VitalSignal(TrackName.DES, TrackSource.PRIMUS);
[patient, data] = loadPatientCase(DatabaseType.VitalDB, caseId, signals, 'Optional', optional);
simIn = buildSimulationInputs(data);
res = runAnesthesim(patient, simIn, 'Data', data);

fig = plotBalancedCase(res, simIn, caseId);
saveFigure(fig, sprintf('balanced_case%d', caseId));
