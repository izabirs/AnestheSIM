function y = tsInterp(ts, t, method, outside)
%TSINTERP Resample a timeseries onto the time vector t.
%   y = tsInterp(ts, t, method, outside) drops non-finite samples, then
%   interpolates with METHOD ('linear', 'previous', ...). Points outside the
%   recorded span get the value OUTSIDE (e.g. 0 for inputs, NaN for
%   measurements). An empty or degenerate series returns OUTSIDE everywhere.

t = t(:);
y = repmat(outside, size(t));
if isempty(ts) || ~isa(ts, 'timeseries') || ts.Length < 2
    return
end
tt = double(ts.Time(:));
yy = double(ts.Data(:));
ok = isfinite(tt) & isfinite(yy);
[tt, iu] = unique(tt(ok));
yy = yy(ok);
yy = yy(iu);
if numel(tt) < 2
    return
end
inside = t >= tt(1) & t <= tt(end);
y(inside) = interp1(tt, yy, t(inside), method);
end
