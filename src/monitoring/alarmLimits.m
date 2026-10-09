function L = alarmLimits()
%ALARMLIMITS Default safety limits of the monitored signals.
%   Edit or override the returned structure to configure detectAlarms.
%   L.<signal> = [low high]; minDuration is the persistence (s) required
%   before an excursion is reported.

L.BIS = [40 60];      % adequate hypnosis for general anaesthesia
L.MAP = [65 100];     % mmHg
L.HR = [45 120];      % bpm
L.minDuration = 60;   % s
end
