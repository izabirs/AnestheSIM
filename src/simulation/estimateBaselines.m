function [MAP0, HR0, src] = estimateBaselines(simIn, patient)
%ESTIMATEBASELINES Pre-induction baseline MAP and HR of a case.
%   [MAP0, HR0] = estimateBaselines(simIn, patient) takes the median of the
%   recorded MAP/HR before the first drug administration when at least
%   60 s of valid awake recording exist. Otherwise MAP0 falls back to a
%   covariate estimate and HR0 to the population value (70.8 bpm).
%   src.MAP / src.HR report 'recording' or 'covariates'.

MIN_SAMPLES = 60;

firstDrug = find(simIn.u.prop.Data > 0 | simIn.u.remi.Data > 0 | ...
    simIn.u.sevo.Data > 0.1 | simIn.u.des.Data > 0.1, 1);
if isempty(firstDrug)
    firstDrug = numel(simIn.t);
end
awake = 1:firstDrug - 1;

map = simIn.meas.MAP(awake);
map = map(map > 30 & map < 200);
if numel(map) >= MIN_SAMPLES / simIn.Ts
    MAP0 = median(map);
    src.MAP = 'recording';
else
    MAP0 = covariateMAP0(patient);
    src.MAP = 'covariates';
end

hr = simIn.meas.HR(awake);
hr = hr(hr > 30 & hr < 200);
if numel(hr) >= MIN_SAMPLES / simIn.Ts
    HR0 = median(hr);
    src.HR = 'recording';
else
    HR0 = 70.8;
    src.HR = 'covariates';
end
end

function MAP0 = covariateMAP0(patient)
% Heuristic awake MAP: 75 mmHg for a 30-year-old woman with BMI 25,
% +0.4 mmHg/year above 30, +5 mmHg for men, +0.5 mmHg per BMI unit above 25.
MAP0 = 75 + 0.4 * max(0, patient.age - 30) + 5 * patient.isMale() + 0.5 * max(0, patient.bmi - 25);
MAP0 = min(max(MAP0, 65), 115);
end
