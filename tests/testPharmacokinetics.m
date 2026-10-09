function tests = testPharmacokinetics
tests = functiontests(localfunctions);
end

function setupOnce(tc)
tc.TestData.patient = Patient(1, 53, 177, 77, 'M');
end

function testSchniderSteadyState(tc)
m = SchniderModel(tc.TestData.patient);
u = 0.1;  % mg/s
y = -m.C * (m.A \ m.B) * u;
expected = u / (m.Cl1 / 60);  % Cp = u / Cl1
tc.verifyEqual(y, [expected; expected], 'RelTol', 1e-10);
tc.verifyEqual(m.ke0, 1.21 / 60, 'AbsTol', 1e-15);
end

function testSchniderReferenceCovariates(tc)
% At the reference covariates (53 y, 77 kg, 177 cm, lbm 59) the published values hold
m = SchniderModel(tc.TestData.patient);
tc.verifyEqual(m.V2, 18.9, 'AbsTol', 1e-12);
tc.verifyEqual(m.Cl2, 1.29, 'AbsTol', 1e-12);
end

function testMintoKe0(tc)
p = Patient(2, 40, 170, 70, 'F');
m = MintoModel(p);
tc.verifyEqual(m.ke0, 0.595 / 60, 'AbsTol', 1e-15);
tc.verifyTrue(all(real(eig(m.A)) < 0));
end

function testJoachimStable(tc)
m = JoachimModel(tc.TestData.patient);
tc.verifyTrue(all(real(eig(m.A)) < 0));
tc.verifyTrue(all(real(eig(m.windkessel.A)) < 0));
tc.verifyGreaterThan(m.Tlag, 0);
end

function testVolatileAgeAdjustment(tc)
young = VolatileModel('sevoflurane', Patient(1, 40, 170, 70, 'M'));
old = VolatileModel('sevoflurane', Patient(2, 80, 170, 70, 'M'));
tc.verifyEqual(young.C50, 1.2, 'AbsTol', 1e-12);
tc.verifyEqual(old.C50, 1.2 * 10^(-0.00269 * 40), 'RelTol', 1e-12);
tc.verifyEqual(young.ke0, 0.47 / 60, 'AbsTol', 1e-15);
des = VolatileModel('desflurane', Patient(1, 40, 170, 70, 'M'));
tc.verifyGreaterThan(des.C50, young.C50);
end

function testSimulateLTIMatchesAnalytic(tc)
m = VolatileModel('sevoflurane', tc.TestData.patient);
t = (0:1:600)';
y = simulateLTI(m, ones(size(t)), 1);
tc.verifyEqual(y, 1 - exp(-m.ke0 * t), 'AbsTol', 1e-10);
end

function testConverters(tc)
data = emptyPatientData();
models = buildPatientModels(tc.TestData.patient, data);
tc.verifyEqual(models.conv.prop * 3600, 20, 'AbsTol', 1e-12);       % 1 mL/h of 20 mg/mL
tc.verifyEqual(models.conv.nepi * 3600, 20e3 / 169.18, 'RelTol', 1e-12);  % nmol per mL
end
