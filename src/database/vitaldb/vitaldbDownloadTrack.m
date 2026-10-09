function [t, v] = vitaldbDownloadTrack(tid)
%VITALDBDOWNLOADTRACK Time/value series of one VitalDB track (cached).
%   [t, v] = vitaldbDownloadTrack(tid) streams https://api.vitaldb.net/<tid>,
%   decompresses and parses it. Parsed tracks are cached by track id, so
%   repeated runs of the same case do not download again.

tid = char(tid);
file = fullfile(anesthesimCacheDir('vitaldb', 'tracks'), [tid '.mat']);
if isfile(file)
    S = load(file, 't', 'v');
    t = S.t;
    v = S.v;
    return
end

bytes = webread(['https://api.vitaldb.net/' tid], ...
    weboptions('Timeout', 120, 'ContentType', 'binary'));
bytes = uint8(bytes(:));

if numel(bytes) > 2 && bytes(1) == 0x1f && bytes(2) == 0x8b  % gzip magic number
    gz = [tempname '.csv.gz'];
    fid = fopen(gz, 'wb');
    fwrite(fid, bytes, 'uint8');
    fclose(fid);
    csvFile = gunzip(gz);
    txt = fileread(csvFile{1});
    delete(gz, csvFile{1});
else
    txt = char(bytes');
end

cols = textscan(txt, '%f %f', 'Delimiter', ',', 'HeaderLines', 1, 'EmptyValue', NaN);
t = cols{1};
v = cols{2};
keep = isfinite(t);
t = t(keep);
v = v(keep);

save(file, 't', 'v');
end
