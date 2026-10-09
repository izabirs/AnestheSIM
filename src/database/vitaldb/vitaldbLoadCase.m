function [patient, data] = vitaldbLoadCase(caseId, signals, opts)
%VITALDBLOADCASE Acquire one VitalDB case as a Patient and canonical patientData.
%   [patient, data] = vitaldbLoadCase(caseId, signals)
%
%   1. reads the case demographics and builds a Patient object;
%   2. expands the requested VitalSignals to VitalDB channel names and
%      validates them against the case's track list;
%   3. streams, decompresses and parses each track (cached locally);
%   4. maps the raw channels onto the canonical patientData structure
%      (see emptyPatientData), resolving volatile agents.
%
%   Signals passed with 'Optional' are loaded only when the case provides
%   them (e.g. VitalSignal(TrackName.DES, TrackSource.PRIMUS)).
%
%   Resampling onto the simulation clock is done by buildSimulationInputs.

arguments
    caseId (1,1) double {mustBeInteger, mustBePositive}
    signals (1,:) VitalSignal = vitaldbDefaultSignals('balanced')
    opts.Optional (1,:) VitalSignal = VitalSignal.empty
    opts.Verbose (1,1) logical = true
end

patient = vitaldbPatient(caseId);

index = vitaldbTrackIndex();
tracks = index(index.caseid == caseId, :);
for s = opts.Optional
    if all(ismember(s.Channels, tracks.tname))
        signals(end + 1) = s; %#ok<AGROW>
    end
end
channels = allChannels(signals);
missing = setdiff(channels, tracks.tname);
if ~isempty(missing)
    error('anesthesim:vitaldb:missingTracks', ...
        'Case %d does not provide the required tracks: %s', caseId, strjoin(missing, ', '));
end

if opts.Verbose
    fprintf('Case %d: downloading %d tracks...\n', caseId, numel(channels));
end
raw = containers.Map();
for k = 1:numel(channels)
    row = find(tracks.tname == channels{k}, 1);
    [t, v] = vitaldbDownloadTrack(tracks.tid(row));
    raw(channels{k}) = timeseries(v, t, 'Name', channels{k});
end

data = vitaldbToCanonical(raw, signals);
data.caseId = caseId;
end
