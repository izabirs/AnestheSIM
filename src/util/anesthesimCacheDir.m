function d = anesthesimCacheDir(varargin)
%ANESTHESIMCACHEDIR Local cache folder for downloaded records (created on demand).
%   d = anesthesimCacheDir('vitaldb', 'tracks') returns <root>/cache/vitaldb/tracks.
%   Set the environment variable ANESTHESIM_CACHE to use another location.

base = getenv('ANESTHESIM_CACHE');
if isempty(base)
    base = fullfile(anesthesimRoot(), 'cache');
end
d = fullfile(base, varargin{:});
if ~isfolder(d)
    mkdir(d);
end
end
