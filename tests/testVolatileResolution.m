function tests = testVolatileResolution
tests = functiontests(localfunctions);
end

function testDesfluraneFromSolarAlone(tc)
% Sevoflurane on both monitors during induction, desflurane on the Solar8000 later
t = (0:100)';
sevo = 2 * (t < 50);
total = sevo + 6 * (t >= 60) + 0.1;           % 0.1 vol% calibration offset
data = emptyPatientData();
data.Volatile.PrimusSevo = timeseries(sevo, t);
data.Volatile.SolarTotal = timeseries(total, t);
data = vitaldbResolveVolatiles(data);
tc.verifyEqual(data.Sevoflurane.Et.Data, sevo);
des = data.Desflurane.Et.Data;
tc.verifyEqual(des(t < 50), zeros(nnz(t < 50), 1));   % offset suppressed
tc.verifyEqual(des(t >= 60), 6.1 * ones(nnz(t >= 60), 1), 'AbsTol', 1e-12);
end

function testPrimusDesfluranePreferred(tc)
t = (0:10)';
data = emptyPatientData();
data.Volatile.PrimusSevo = timeseries(zeros(size(t)), t);
data.Volatile.PrimusDes = timeseries(5 * ones(size(t)), t);
data.Volatile.SolarTotal = timeseries(9 * ones(size(t)), t);
data = vitaldbResolveVolatiles(data);
tc.verifyEqual(data.Desflurane.Et.Data, 5 * ones(size(t)));
end

function testAmbiguousTotalWarns(tc)
t = (0:10)';
data = emptyPatientData();
data.Volatile.SolarTotal = timeseries(ones(size(t)), t);
data = tc.verifyWarning(@() vitaldbResolveVolatiles(data), 'anesthesim:vitaldb:volatileAmbiguous');
tc.verifyEqual(data.Sevoflurane.Et.Data, ones(size(t)));
end
