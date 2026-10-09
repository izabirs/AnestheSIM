%% Validation of the simulator on real records (VitalDB)
% Every case of the cohort is replayed through the Simulink patient model:
% the recorded pump rates and end-tidal gases are the inputs, and the
% simulated BIS, MAP and HR are compared with the recorded ones. All model
% parameters are the published (literature) values; nothing is fitted to
% the records, except the awake MAP/HR baselines read from the
% pre-induction recording.
%
% The cohort is re-derived from its signal specification. Per-case results
% are written to results/validation/ so an interrupted run resumes.
% Summarise with analyze_validation.

setup_anesthesim;
outDir = fullfile(anesthesimRoot(), 'results', 'validation');
if ~isfolder(outDir)
    mkdir(outDir);
end

MIN_DURATION = 3600;      % s
MIN_VALID_BIS = 0.5;      % fraction of the record
MIN_VALID_HEMO = 1800;    % s of valid MAP / HR
DS = 10;                  % s, sampling of the stored traces

signals = vitaldbDefaultSignals('balanced');   % BIS + SQI, MAP, HR, propofol, remifentanil, gases
optional = [VitalSignal(TrackName.DES, TrackSource.PRIMUS), ...
            VitalSignal(TrackName.NEPI, TrackSource.ORCHESTRA)];
cases = searchPatients(signals);

for caseId = cases'
    file = fullfile(outDir, sprintf('case_%04d.mat', caseId));
    if isfile(file)
        continue
    end
    r = struct('caseId', caseId, 'included', false, 'reason', "");
    try
        [patient, data] = loadPatientCase(DatabaseType.VitalDB, caseId, signals, 'Optional', optional);
        simIn = buildSimulationInputs(data);
        bis = cleanBIS(simIn);
        r.age = patient.age; r.sex = patient.sex; r.bmi = patient.bmi;
        r.duration = simIn.T;
        r.sevoMinutes = nnz(simIn.u.sevo.Data > 0.3) * simIn.Ts / 60;
        r.desMinutes = nnz(simIn.u.des.Data > 0.3) * simIn.Ts / 60;
        r.desFromPrimus = isfield(data.Volatile, 'PrimusDes');
        r.nepiMinutes = nnz(simIn.u.nepi.Data > 0) * simIn.Ts / 60;

        if simIn.T < MIN_DURATION
            r.reason = "duration < 60 min";
        elseif mean(isfinite(bis)) < MIN_VALID_BIS
            r.reason = "valid BIS < 50 %";
        elseif ~any(simIn.u.prop.Data > 0)
            r.reason = "no propofol";
        else
            tic;
            res = runAnesthesim(patient, simIn, 'Data', data);
            r.simSeconds = toc;
            [~, ~, src] = estimateBaselines(simIn, patient);
            r.baselineSource = src;

            for m = ["minto", "bouillon", "greco", "volatile"]
                r.bis.(m) = predictionMetrics(res.BIS.(m), bis);
            end

            map = simIn.meas.MAP;
            map(map < 20 | map > 200) = NaN;
            hr = simIn.meas.HR;
            hr(hr < 20 | hr > 220) = NaN;
            r.hemoValid = nnz(isfinite(map)) * simIn.Ts >= MIN_VALID_HEMO && ...
                nnz(isfinite(hr)) * simIn.Ts >= MIN_VALID_HEMO;
            if r.hemoValid
                r.map = predictionMetrics(res.MAP.separable, map);
                r.hr = predictionMetrics(res.HR, hr);
            end

            k = 1:round(DS / simIn.Ts):numel(simIn.t);
            r.trace = struct('t', simIn.t(k), 'bis', bis(k), 'map', map(k), 'hr', hr(k), ...
                'bisGreco', res.BIS.greco(k), 'bisVolatile', res.BIS.volatile(k), ...
                'mapModel', res.MAP.separable(k), 'hrModel', res.HR(k));
            r.included = true;
        end
    catch err
        r.reason = "error: " + string(err.message);
    end
    save(file, 'r');
    if r.included
        fprintf('case %4d: included\n', caseId);
    else
        fprintf('case %4d: %s\n', caseId, r.reason);
    end
end
