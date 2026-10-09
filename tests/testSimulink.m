function tests = testSimulink
tests = functiontests(localfunctions);
end

function setupOnce(tc)
patient = Patient(1, 45, 172, 74, 'M');
t = (0:1:3600)';
data = emptyPatientData();
prop = 25 * (t >= 60);
prop(t >= 60 & t < 120) = 250;
data.Propofol.infRate = timeseries(prop, t);
data.Remifentanil.infRate = timeseries(12 * (t >= 60), t);
data.Norepinephrine.infRate = timeseries(8 * (t >= 1200 & t < 2400), t);
data.Sevoflurane.Et = timeseries(1.2 * (t >= 1800 & t < 2700), t);
data.Desflurane.Et = timeseries(4 * (t >= 2700), t);
simIn = buildSimulationInputs(data);
tc.TestData.patient = patient;
tc.TestData.simIn = simIn;
tc.TestData.res = runAnesthesim(patient, simIn, 'Data', data);
tc.TestData.offline = computeConcentrations(simIn, buildPatientModels(patient, data));
end

function testOutputsFinite(tc)
res = tc.TestData.res;
for v = {res.BIS.minto, res.BIS.bouillon, res.BIS.greco, res.BIS.volatile, ...
        res.MAP.separable, res.MAP.unified, res.HR}
    tc.verifySize(v{1}, size(tc.TestData.simIn.t));
    tc.verifyTrue(all(isfinite(v{1})));
end
end

function testSimulinkMatchesOffline(tc)
% Identification (offline) and simulation (Simulink) use the same models
res = tc.TestData.res;
off = tc.TestData.offline;
for f = ["CeP", "CeR", "CcN", "CeSevo", "CeDes"]
    tc.verifyLessThan(max(abs(res.conc.(f) - off.(f))), 0.01 * max(abs(off.(f))) + 1e-6, f);
end
end

function testSimulinkPdMatchesFunctions(tc)
res = tc.TestData.res;
p = res.params;
c = res.conc;
tc.verifyEqual(res.BIS.greco, bisGreco(c.CeP, c.CeR, p.pBisGreco), 'AbsTol', 1e-9);
tc.verifyEqual(res.BIS.volatile, bisGrecoVolatile(c.CeP, c.CeR, c.CeSevo, c.CeDes, p.pBisVolatile), 'AbsTol', 1e-9);
tc.verifyEqual(res.MAP.unified, mapUnified(c.CeP, c.CeR, c.CcN, p.pMapUnified), 'AbsTol', 1e-9);
end

function testPhysiologicalResponse(tc)
res = tc.TestData.res;
t = tc.TestData.simIn.t;
tc.verifyLessThan(res.BIS.greco(t == 600), 60);                   % induction
tc.verifyLessThan(res.BIS.volatile(t == 2600), res.BIS.greco(t == 2600));  % sevoflurane deepens
tc.verifyGreaterThan(res.MAP.separable(t == 2300), res.MAP.separable(t == 1150));  % NE pressor
end

function testUserParametersAreUsed(tc)
p = bisParameters('greco', tc.TestData.patient);
p.Interaction.Emax = 30;
res = runAnesthesim(tc.TestData.patient, tc.TestData.simIn, 'BisVolatile', p);
tc.verifyGreaterThan(min(res.BIS.volatile), min(tc.TestData.res.BIS.volatile));
end
