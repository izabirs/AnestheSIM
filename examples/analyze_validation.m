%% Summarise the simulator validation (run study_validation first)
% Tables, statistics and figures of the literature models replayed on real
% records: BIS by anaesthesia type and age, MAP and HR.
% Needs the Statistics and Machine Learning Toolbox for the tests.
% Output: results/validation_summary.mat and results/validation_*.png

setup_anesthesim;
inDir = fullfile(anesthesimRoot(), 'results', 'validation');
R = loadRecords(fullfile(inDir, 'case_*.mat'));
inc = R([R.included]);

fprintf('\nCohort: %d cases matched, %d included\n', numel(R), numel(inc));
reasons = string({R(~[R.included]).reason});
[u, ~, j] = unique(reasons);
for k = 1:numel(u)
    fprintf('  excluded (%s): %d\n', u(k), nnz(j == k));
end

age = [inc.age];
group = repmat("TIVA", 1, numel(inc));
group([inc.sevoMinutes] >= 10 & [inc.desMinutes] < 10) = "Sevoflurane";
group([inc.desMinutes] >= 10) = "Desflurane";
fprintf('Age %s y, men %d, BMI %s, duration %s min, NE given in %d\n', iqrText(age), ...
    nnz([inc.sex] == 'M'), iqrText([inc.bmi]), iqrText([inc.duration] / 60), nnz([inc.nepiMinutes] > 0));

%% BIS
models = ["minto", "bouillon", "greco", "volatile"];
for m = models
    for q = ["MDPE", "MDAPE", "wobble", "RMSE"]
        B.(m).(q) = arrayfun(@(r) r.bis.(m).(q), inc);
    end
end
groups = ["All", "TIVA", "Sevoflurane", "Desflurane"];
T = table();
for g = groups
    sel = g == "All" | group == g;
    row = table(g, nnz(sel), 'VariableNames', {'Group', 'N'});
    for m = models
        row.(m + "_MDAPE") = string(iqrText(B.(m).MDAPE(sel)));
        row.(m + "_MDPE") = string(iqrText(B.(m).MDPE(sel)));
    end
    T = [T; row]; %#ok<AGROW>
end
disp(T);
vol = group ~= "TIVA";
pVol = signrank(B.greco.MDAPE(vol), B.volatile.MDAPE(vol));
pModels = friedman([B.minto.MDAPE(:), B.bouillon.MDAPE(:), B.greco.MDAPE(:)], 1, 'off');
ageGroup = discretize(age, [0 50 65 200], 'categorical', {'<50', '50-64', '65+'});
pAgeMDAPE = kruskalwallis(B.volatile.MDAPE, ageGroup, 'off');
pAgeMDPE = kruskalwallis(B.volatile.MDPE, ageGroup, 'off');
rhoAge = corr(age(:), B.volatile.MDPE(:), 'Type', 'Spearman');
fprintf('Volatile term in balanced cases: Wilcoxon p = %.2g; three IV models: Friedman p = %.2g\n', pVol, pModels);
for a = categories(ageGroup)'
    sel = ageGroup == a{1};
    fprintf('Age %-6s n=%3d  MDAPE %s  MDPE %s\n', a{1}, nnz(sel), iqrText(B.volatile.MDAPE(sel)), ...
        iqrText(B.volatile.MDPE(sel)));
end
fprintf('Age: Kruskal-Wallis MDAPE p = %.2g, MDPE p = %.2g; Spearman(age, MDPE) = %.2f\n', ...
    pAgeMDAPE, pAgeMDPE, rhoAge);

%% MAP and HR
hemo = inc([inc.hemoValid]);
for q = ["MDPE", "MDAPE", "wobble", "RMSE"]
    H.map.(q) = arrayfun(@(r) r.map.(q), hemo);
    H.hr.(q) = arrayfun(@(r) r.hr.(q), hemo);
end
mapFromRecord = arrayfun(@(r) r.baselineSource.MAP == "recording", hemo);
fprintf('\nMAP/HR: %d cases (awake MAP baseline recorded in %d)\n', numel(hemo), nnz(mapFromRecord));
for s = ["map", "hr"]
    fprintf('%s: MDPE %s, MDAPE %s, wobble %s, RMSE %s\n', upper(s), iqrText(H.(s).MDPE), ...
        iqrText(H.(s).MDAPE), iqrText(H.(s).wobble), iqrText(H.(s).RMSE));
end
simSeconds = [inc.simSeconds];
fprintf('Simulink run time %s s per case (record %s min)\n', iqrText(simSeconds), iqrText([inc.duration] / 60));

%% Figures
fig = figure('Color', 'w', 'Position', [100 100 1000 380]);
names = ["Minto", "Bouillon", "Reduced Greco", "Greco + volatile"];
vals = [];
grp = strings(0);
mdl = strings(0);
for k = 1:numel(models)
    vals = [vals, B.(models(k)).MDAPE]; %#ok<AGROW>
    grp = [grp, group]; %#ok<AGROW>
    mdl = [mdl, repmat(names(k), 1, numel(inc))]; %#ok<AGROW>
end
boxchart(categorical(mdl, names), vals, 'GroupByColor', categorical(grp, ["TIVA", "Sevoflurane", "Desflurane"]), ...
    'MarkerStyle', '.');
ylabel('BIS MDAPE (%)');
ylim([0 prctile(vals, 99)]);
legend('Location', 'northeast');
grid on
saveFigure(fig, 'validation_bis');

fig = figure('Color', 'w', 'Position', [100 100 900 330]);
subplot(1, 3, 1);
boxchart(ageGroup, B.volatile.MDPE, 'MarkerStyle', '.');
yline(0, 'k:');
ylabel('BIS MDPE (%)'); xlabel('Age (years)'); grid on
title('BIS bias by age');
subplot(1, 3, 2);
sensFile = fullfile(anesthesimRoot(), 'results', 'hemodynamic_sensitivity.mat');
if isfile(sensFile)
    sens = load(sensFile);
    cats = ["Published", "No HR feedback"];
    boxchart(categorical(repelem(cats, [numel(hemo), numel(sens.mdpe)]), cats), [H.map.MDPE, sens.mdpe], 'MarkerStyle', '.');
else
    boxchart(categorical(repelem("Published", numel(hemo))), H.map.MDPE, 'MarkerStyle', '.');
end
yline(0, 'k:'); ylabel('MAP MDPE (%)'); grid on
title(sprintf('MAP (n = %d)', numel(hemo)));
subplot(1, 3, 3);
boxchart(categorical(repelem("Published", numel(hemo))), H.hr.MDPE, 'MarkerStyle', '.');
yline(0, 'k:'); ylabel('HR MDPE (%)'); grid on
title(sprintf('HR (n = %d)', numel(hemo)));
saveFigure(fig, 'validation_age_hemo');

summary = struct('table', T, 'B', B, 'H', H, 'group', group, 'age', age, 'pVol', pVol, ...
    'pModels', pModels, 'pAgeMDAPE', pAgeMDAPE, 'pAgeMDPE', pAgeMDPE, 'rhoAge', rhoAge, ...
    'nMatched', numel(R), 'nIncluded', numel(inc), 'nHemo', numel(hemo), ...
    'nMapBaselineRecorded', nnz(mapFromRecord), 'simSeconds', simSeconds);
save(fullfile(anesthesimRoot(), 'results', 'validation_summary.mat'), 'summary', 'inc');

function R = loadRecords(pattern)
files = dir(pattern);
R = [];
for k = 1:numel(files)
    s = load(fullfile(files(k).folder, files(k).name), 'r');
    r = s.r;
    if isempty(R)
        R = r;
        continue
    end
    f = union(fieldnames(R), fieldnames(r), 'stable');
    for n = 1:numel(f)
        if ~isfield(R, f{n}), [R.(f{n})] = deal([]); end
        if ~isfield(r, f{n}), r.(f{n}) = []; end
    end
    R(end + 1) = orderfields(r, R(1)); %#ok<AGROW>
end
end

function s = iqrText(x)
x = x(isfinite(x));
s = sprintf('%.1f [%.1f-%.1f]', median(x), prctile(x, 25), prctile(x, 75));
end
