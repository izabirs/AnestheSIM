function data = vitaldbToCanonical(raw, signals)
%VITALDBTOCANONICAL Map raw VitalDB channels onto the canonical patientData.
%   raw is a containers.Map from channel string to timeseries. This is the
%   only function that knows VitalDB channel suffixes and units.

data = emptyPatientData();

for s = signals
    ch = s.Channels;
    switch s.Name
        case TrackName.PROP20
            data.Propofol.infRate = raw(ch{1});
            data.Propofol.Ce = raw(ch{2});
            data.Propofol.Cp = raw(ch{3});
            data.Propofol.concentration = 20;           % mg/mL
        case {TrackName.REMI20, TrackName.REMI50}
            data.Remifentanil.infRate = raw(ch{1});
            data.Remifentanil.Ce = raw(ch{2});
            data.Remifentanil.Cp = raw(ch{3});
            if s.Name == TrackName.REMI50
                data.Remifentanil.concentration = 50;   % ug/mL
            else
                data.Remifentanil.concentration = 20;   % ug/mL
            end
        case TrackName.NEPI
            data.Norepinephrine.infRate = raw(ch{1});
            data.Norepinephrine.concentration = 20;     % ug/mL
        case TrackName.BIS
            data.BIS = raw(ch{1});
        case TrackName.SQI
            data.BISQuality.SQI = raw(ch{1});
        case TrackName.MAP
            data.MAP = raw(ch{1});
        case TrackName.HR
            data.HR = raw(ch{1});
        case TrackName.SEVO     % Primus, partial pressure [kPa]
            data.Volatile.PrimusSevo = kpaToVolPercent(raw(ch{2}));
        case TrackName.DES      % Primus, partial pressure [kPa]
            data.Volatile.PrimusDes = kpaToVolPercent(raw(ch{2}));
        case TrackName.GAS2     % Solar8000, total volatile [vol%]
            data.Volatile.SolarTotal = raw(ch{2});
    end
end

data = vitaldbResolveVolatiles(data);
end

function ts = kpaToVolPercent(ts)
% Dalton's law: volume fraction = partial pressure / atmospheric pressure.
P_ATM = 101.3;  % kPa
ts.Data = ts.Data / P_ATM * 100;
end
