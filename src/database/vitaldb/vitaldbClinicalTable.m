function T = vitaldbClinicalTable(refresh)
%VITALDBCLINICALTABLE Case-level clinical information of VitalDB (cached).
%   T = vitaldbClinicalTable() downloads https://api.vitaldb.net/cases on
%   first use and reads it from the local cache afterwards.
%   T = vitaldbClinicalTable(true) forces a fresh download.

if nargin < 1
    refresh = false;
end

persistent cached
file = fullfile(anesthesimCacheDir('vitaldb'), 'cases.csv');
if refresh || ~isfile(file)
    fprintf('Downloading VitalDB clinical information...\n');
    websave(file, 'https://api.vitaldb.net/cases', weboptions('Timeout', 120));
    cached = [];
end
if isempty(cached)
    cached = readtable(file, 'TextType', 'string');
end
T = cached;
end
