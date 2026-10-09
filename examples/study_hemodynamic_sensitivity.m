%% Sensitivity of the MAP prediction to the HR -> MAP feedback
% Replays the validation cohort with the published turnover model and with
% the heart-rate feedback on MAP switched off (FBhr = 0), to show how much
% of the MAP error propagates from the heart-rate prediction.
% Run after study_validation; analyze_validation includes the result.

setup_anesthesim;
files = dir(fullfile(anesthesimRoot(), 'results', 'validation', 'case_*.mat'));
signals = vitaldbDefaultSignals('balanced');
optional = [VitalSignal(TrackName.DES, TrackSource.PRIMUS), VitalSignal(TrackName.NEPI, TrackSource.ORCHESTRA)];
mdpe = [];
mdape = [];
ids = [];
for f = files'
    s = load(fullfile(f.folder, f.name), 'r');
    if ~s.r.included || ~s.r.hemoValid
        continue
    end
    [patient, data] = loadPatientCase(DatabaseType.VitalDB, s.r.caseId, signals, 'Optional', optional);
    simIn = buildSimulationInputs(data);
    [MAP0, HR0] = estimateBaselines(simIn, patient);
    p = hemodynamicParameters(MAP0, HR0);
    p.FBhr = 0;
    res = runAnesthesim(patient, simIn, 'Data', data, 'Hemodynamics', p);
    map = simIn.meas.MAP;
    map(map < 20 | map > 200) = NaN;
    m = predictionMetrics(res.MAP.separable, map);
    mdpe(end + 1) = m.MDPE; %#ok<SAGROW>
    mdape(end + 1) = m.MDAPE; %#ok<SAGROW>
    ids(end + 1) = s.r.caseId; %#ok<SAGROW>
end
fprintf('MAP without HR feedback (n = %d): MDPE %.1f [%.1f-%.1f]%%, MDAPE %.1f [%.1f-%.1f]%%\n', numel(mdpe), ...
    median(mdpe), prctile(mdpe, 25), prctile(mdpe, 75), median(mdape), prctile(mdape, 25), prctile(mdape, 75));
save(fullfile(anesthesimRoot(), 'results', 'hemodynamic_sensitivity.mat'), 'ids', 'mdpe', 'mdape');
