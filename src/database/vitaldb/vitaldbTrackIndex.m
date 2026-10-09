function T = vitaldbTrackIndex(refresh)
%VITALDBTRACKINDEX Index of all VitalDB tracks (caseid, tname, tid), cached.
%   The index (~30 MB) is downloaded from https://api.vitaldb.net/trks once
%   and stored as a .mat file; later calls load it from the cache.
%   T = vitaldbTrackIndex(true) forces a fresh download.

if nargin < 1
    refresh = false;
end

persistent cached
cacheDir = anesthesimCacheDir('vitaldb');
matFile = fullfile(cacheDir, 'trks.mat');
if refresh || ~isfile(matFile)
    csvFile = fullfile(cacheDir, 'trks.csv');
    fprintf('Downloading VitalDB track index (~30 MB, once)...\n');
    websave(csvFile, 'https://api.vitaldb.net/trks', weboptions('Timeout', 300));
    trks = readtable(csvFile, 'TextType', 'string', 'Delimiter', ',');
    save(matFile, 'trks');
    delete(csvFile);
    cached = [];
end
if isempty(cached)
    S = load(matFile, 'trks');
    cached = S.trks;
end
T = cached;
end
