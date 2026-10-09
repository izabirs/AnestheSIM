function tests = testSignals
tests = functiontests(localfunctions);
end

function testChannelExpansion(tc)
s = VitalSignal(TrackName.PROP20, TrackSource.ORCHESTRA);
tc.verifyEqual(s.Channels, {'Orchestra/PPF20_RATE', 'Orchestra/PPF20_CE', 'Orchestra/PPF20_CP'});
tc.verifyEqual(VitalSignal(TrackName.SEVO, TrackSource.PRIMUS).Channels, ...
    {'Primus/INSP_SEVO', 'Primus/EXP_SEVO'});
tc.verifyEqual(VitalSignal(TrackName.DES, TrackSource.PRIMUS).Channels, ...
    {'Primus/INSP_DES', 'Primus/EXP_DES'});
tc.verifyEqual(VitalSignal(TrackName.GAS2, TrackSource.SOLAR8000).Channels, ...
    {'Solar8000/GAS2_INSPIRED', 'Solar8000/GAS2_EXPIRED'});
tc.verifyEqual(VitalSignal(TrackName.MAP, TrackSource.EV1000).Channels, {'EV1000/ART_MBP'});
tc.verifyEqual(VitalSignal(TrackName.NEPI, TrackSource.ORCHESTRA).Channels, {'Orchestra/NEPI_RATE'});
end

function testSignalSets(tc)
s = vitaldbDefaultSignals('map', 'remi50');
tc.verifyTrue(has(s, TrackName.REMI50));
tc.verifyFalse(has(s, TrackName.REMI20));
tc.verifyNumElements(allChannels(vitaldbDefaultSignals('bis')), 12);
end

function testCanonicalMapping(tc)
signals = [VitalSignal(TrackName.REMI50, TrackSource.ORCHESTRA), ...
           VitalSignal(TrackName.SEVO, TrackSource.PRIMUS)];
raw = containers.Map();
for ch = allChannels(signals)
    raw(ch{1}) = timeseries([1; 2; 3], [0; 1; 2]);
end
raw('Primus/EXP_SEVO') = timeseries([1.013; 2.026], [0; 1]);
data = vitaldbToCanonical(raw, signals);
tc.verifyEqual(data.Remifentanil.concentration, 50);
tc.verifyEqual(data.Sevoflurane.Et.Data, [1; 2], 'AbsTol', 1e-12);  % kPa -> vol%
end

function testSimulationGrid(tc)
data = emptyPatientData();
data.Propofol.infRate = timeseries([0; 10; 20], [0; 5.5; 10]);
data.BIS = timeseries([95; 50], [2; 8]);
simIn = buildSimulationInputs(data);
tc.verifyEqual(simIn.t', 0:10);
tc.verifyEqual(simIn.u.prop.Data(6:7)', [0 10]);       % zero-order hold
tc.verifyTrue(isnan(simIn.meas.BIS(1)));                  % no extrapolation
tc.verifyEqual(simIn.u.sevo.Data, zeros(11, 1));          % absent input is zero
end
