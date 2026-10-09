function events = detectAlarms(t, signals, limits)
%DETECTALARMS Excursions of monitored signals beyond their safety limits.
%   events = detectAlarms(t, signals) returns a table with one row per
%   episode (Signal, Type 'low'/'high', Start, Stop, Duration, Extreme)
%   in which a signal stays outside its limits for at least
%   limits.minDuration seconds. signals is a structure of column vectors on
%   t whose field names match alarmLimits (BIS, MAP, HR); fields without
%   limits are ignored.
%
%   Example:
%       ev = detectAlarms(res.t, struct('BIS', res.BIS.volatile, 'MAP', res.MAP.unified));

if nargin < 3
    limits = alarmLimits();
end
t = t(:);
rows = {};
for name = string(fieldnames(signals))'
    if ~isfield(limits, name)
        continue
    end
    x = signals.(name)(:);
    lim = limits.(name);
    rows = [rows; episodes(t, x, x < lim(1), name, "low", @min, limits.minDuration)]; %#ok<AGROW>
    rows = [rows; episodes(t, x, x > lim(2), name, "high", @max, limits.minDuration)]; %#ok<AGROW>
end
if isempty(rows)
    events = table(strings(0, 1), strings(0, 1), zeros(0, 1), zeros(0, 1), zeros(0, 1), zeros(0, 1), ...
        'VariableNames', {'Signal', 'Type', 'Start', 'Stop', 'Duration', 'Extreme'});
else
    events = cell2table(rows, 'VariableNames', {'Signal', 'Type', 'Start', 'Stop', 'Duration', 'Extreme'});
    events = sortrows(events, 'Start');
end
end

function rows = episodes(t, x, mask, name, type, extreme, minDuration)
rows = {};
d = diff([false; mask(:); false]);
starts = find(d == 1);
stops = find(d == -1) - 1;
for k = 1:numel(starts)
    dur = t(stops(k)) - t(starts(k));
    if dur >= minDuration
        rows(end + 1, :) = {name, type, t(starts(k)), t(stops(k)), dur, ...
            extreme(x(starts(k):stops(k)))}; %#ok<AGROW>
    end
end
end
