function caseIds = searchPatients(signals, opts)
%SEARCHPATIENTS VitalDB cases that expose every channel of a signal specification.
%   caseIds = searchPatients(signals) scans the (cached) VitalDB track index
%   and returns the ids of all cases providing the complete set of channels
%   requested by the VitalSignal array, so cohorts are defined by a
%   reproducible specification rather than by manual selection.
%
%   Example:
%       ids = searchPatients(vitaldbDefaultSignals('balanced'));

arguments
    signals (1,:) VitalSignal
    opts.Verbose (1,1) logical = true
end

index = vitaldbTrackIndex();
channels = string(allChannels(signals));

hits = index(ismember(index.tname, channels), {'caseid', 'tname'});
hits = unique(hits, 'rows');
[g, ids] = findgroups(hits.caseid);
counts = splitapply(@numel, hits.tname, g);
caseIds = ids(counts == numel(channels));

if opts.Verbose
    fprintf('%d VitalDB cases provide all %d requested channels.\n', ...
        numel(caseIds), numel(channels));
end
end
