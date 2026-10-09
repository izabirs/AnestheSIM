function [bis, E0] = cleanBIS(simIn)
%CLEANBIS Artifact-rejected, smoothed BIS and its awake baseline E0.
%   [bis, E0] = cleanBIS(simIn) removes values outside [5, 100] and, when
%   the signal quality index is recorded, samples with SQI < 50; applies a
%   15 s moving median and a 30 s moving mean, and estimates E0 as the
%   median BIS before the first drug (or the peak of the first 2 minutes
%   when there is no awake recording), limited to [85, 100].

raw = simIn.meas.BIS(:);
raw(raw < 5 | raw > 100) = NaN;
if isfield(simIn.meas, 'SQI')
    raw(simIn.meas.SQI(:) < 50) = NaN;
end

w = @(sec) max(1, round(sec / simIn.Ts));
bis = movmedian(raw, w(15), 'omitnan');
bis = movmean(bis, w(30), 'omitnan');
bis(isnan(raw) & isnan(movmax(raw, w(60), 'omitnan'))) = NaN;  % keep long gaps empty

firstDrug = find(simIn.u.prop.Data > 0 | simIn.u.remi.Data > 0 | ...
    simIn.u.sevo.Data > 0.1 | simIn.u.des.Data > 0.1, 1);
if isempty(firstDrug)
    firstDrug = 1;
end
awake = bis(1:firstDrug - 1);
if nnz(isfinite(awake)) * simIn.Ts >= 10
    E0 = median(awake, 'omitnan');
else
    window = firstDrug:min(numel(bis), firstDrug + w(120));
    E0 = max(bis(window), [], 'omitnan');
end
if isempty(E0) || ~isfinite(E0)
    E0 = 95;
end
E0 = min(max(E0, 85), 100);
end
