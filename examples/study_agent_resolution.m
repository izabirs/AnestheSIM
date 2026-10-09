%% Validation of the volatile-agent resolution rule
% In cases where the Primus records desflurane directly, the rule
% "desflurane = Solar8000 total - Primus sevoflurane" is applied as if the
% Primus desflurane channel were absent and compared with it.
% Uses the cohort of study_validation (run it first).

setup_anesthesim;
files = dir(fullfile(anesthesimRoot(), 'results', 'validation', 'case_*.mat'));
ids = [];
for f = files'
    s = load(fullfile(f.folder, f.name), 'r');
    if s.r.included && s.r.desFromPrimus && s.r.desMinutes >= 10
        ids(end + 1) = s.r.caseId; %#ok<SAGROW>
    end
end
signals = vitaldbDefaultSignals('balanced');
des = VitalSignal(TrackName.DES, TrackSource.PRIMUS);

err = nan(size(ids));
bias = nan(size(ids));
agreement = nan(size(ids));
for k = 1:numel(ids)
    [~, data] = loadPatientCase(DatabaseType.VitalDB, ids(k), signals, 'Optional', des);
    blind = emptyPatientData();
    blind.Volatile = rmfield(data.Volatile, 'PrimusDes');
    blind = vitaldbResolveVolatiles(blind);

    t = data.Volatile.SolarTotal.Time;
    reference = tsInterp(data.Volatile.PrimusDes, t, 'linear', NaN);
    recovered = blind.Desflurane.Et.Data(:);
    on = isfinite(reference) & (reference > 0.3 | recovered > 0.3);
    err(k) = median(abs(recovered(on) - reference(on)));
    bias(k) = median(recovered(on) - reference(on));
    agreement(k) = mean((recovered(on) > 0.3) == (reference(on) > 0.3));
end

fprintf('%d desflurane cases: |recovered - Primus| median %.2f [%.2f-%.2f] vol%%, bias %.2f vol%%\n', ...
    numel(ids), median(err), prctile(err, 25), prctile(err, 75), median(bias));
fprintf('agent identified correctly in %.1f%% [%.1f-%.1f] of samples\n', ...
    100 * median(agreement), 100 * prctile(agreement, 25), 100 * prctile(agreement, 75));
