function signals = vitaldbDefaultSignals(varargin)
%VITALDBDEFAULTSIGNALS Canonical signal sets used by the examples.
%   signals = vitaldbDefaultSignals('tiva')      BIS (+SQI), MAP, HR, propofol, remifentanil
%   signals = vitaldbDefaultSignals('balanced')  'tiva' + sevoflurane (Primus) + total gas (Solar8000)
%   signals = vitaldbDefaultSignals('bis')       BIS, propofol, remifentanil, sevoflurane, total gas
%   signals = vitaldbDefaultSignals('map')       MAP (EV1000), propofol, remifentanil, NE
%   Add 'remi50' to request the 50 ug/mL remifentanil solution instead of 20 ug/mL.
%   MAP is read from the Solar8000 except in the 'map' set (EV1000).

setName = 'balanced';
remiName = TrackName.REMI20;
for k = 1:numel(varargin)
    switch lower(varargin{k})
        case 'remi50'
            remiName = TrackName.REMI50;
        otherwise
            setName = lower(varargin{k});
    end
end

bis  = VitalSignal(TrackName.BIS,    TrackSource.BIS);
sqi  = VitalSignal(TrackName.SQI,    TrackSource.BIS);
map  = VitalSignal(TrackName.MAP,    TrackSource.SOLAR8000);
mapE = VitalSignal(TrackName.MAP,    TrackSource.EV1000);
hr   = VitalSignal(TrackName.HR,     TrackSource.SOLAR8000);
prop = VitalSignal(TrackName.PROP20, TrackSource.ORCHESTRA);
remi = VitalSignal(remiName,         TrackSource.ORCHESTRA);
nepi = VitalSignal(TrackName.NEPI,   TrackSource.ORCHESTRA);
sevo = VitalSignal(TrackName.SEVO,   TrackSource.PRIMUS);
gas  = VitalSignal(TrackName.GAS2,   TrackSource.SOLAR8000);

switch setName
    case 'tiva'
        signals = [bis, sqi, map, hr, prop, remi];
    case 'balanced'
        signals = [bis, sqi, map, hr, prop, remi, sevo, gas];
    case 'bis'
        signals = [bis, sqi, prop, remi, sevo, gas];
    case 'map'
        signals = [mapE, prop, remi, nepi];
    otherwise
        error('anesthesim:vitaldb:unknownSet', 'Unknown signal set "%s".', setName);
end
end
