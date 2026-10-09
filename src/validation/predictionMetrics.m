function m = predictionMetrics(pred, meas)
%PREDICTIONMETRICS Predictive performance of a model against a recording.
%   m = predictionMetrics(pred, meas) returns, over samples where both are
%   finite, the Varvel criteria (Varvel, Donoho and Shafer 1992) based on
%   the performance error relative to the prediction,
%       PE = 100 (meas - pred) / pred:
%       m.MDPE    median PE (bias; positive = model under-predicts) [%]
%       m.MDAPE   median |PE| (inaccuracy) [%]
%       m.wobble  median |PE - MDPE| (intra-individual variability) [%]
%   and m.RMSE (signal units), m.R2, m.n.

ok = isfinite(pred(:)) & isfinite(meas(:)) & pred(:) > 0;
p = pred(ok);
y = meas(ok);
PE = 100 * (y - p) ./ p;

m.MDPE = median(PE);
m.MDAPE = median(abs(PE));
m.wobble = median(abs(PE - m.MDPE));
m.RMSE = sqrt(mean((p - y).^2));
m.R2 = 1 - sum((p - y).^2) / max(sum((y - mean(y)).^2), eps);
m.n = numel(y);
end
