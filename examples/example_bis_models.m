%% BIS reconstruction with the three intravenous interaction models (paper Fig. 5)
% The additive Minto, Bouillon and reduced Greco models are wired in
% parallel in the Simulink model, so one run gives all three predictions.

setup_anesthesim;

cases = [34 237];   % elderly, young adult
signals = [VitalSignal(TrackName.BIS,    TrackSource.BIS), ...
           VitalSignal(TrackName.PROP20, TrackSource.ORCHESTRA), ...
           VitalSignal(TrackName.REMI20, TrackSource.ORCHESTRA)];

for caseId = cases
    [patient, data] = loadPatientCase(DatabaseType.VitalDB, caseId, signals);
    simIn = buildSimulationInputs(data);
    res = runAnesthesim(patient, simIn, 'Data', data);

    fig = plotBisComparison(res, simIn, caseId);
    saveFigure(fig, sprintf('bis_case%d', caseId));

    fprintf('Case %d (%d y):', caseId, patient.age);
    for model = ["minto", "bouillon", "greco"]
        m = predictionMetrics(res.BIS.(model), simIn.meas.BIS);
        fprintf('  %s MDAPE %.1f%%', model, m.MDAPE);
    end
    fprintf('\n');
end
