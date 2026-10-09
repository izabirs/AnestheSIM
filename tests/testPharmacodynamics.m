function tests = testPharmacodynamics
tests = functiontests(localfunctions);
end

function testBaselineWithoutDrugs(tc)
for model = ["greco", "bouillon", "minto"]
    p = bisParameters(model);
    tc.verifyEqual(bisMinto(0, 0, p), p.Interaction.E0);
    tc.verifyEqual(bisBouillon(0, 0, p), p.Interaction.E0);
    tc.verifyEqual(bisGrecoVolatile(0, 0, 0, 0, p), p.Interaction.E0);
end
end

function testMonotoneInPropofol(tc)
Ce = linspace(0, 10, 50)';
for f = {@bisMinto, @bisBouillon, @bisGreco}
    p = bisParameters('greco');
    bis = f{1}(Ce, 1, p);
    tc.verifyTrue(all(diff(bis) <= 0), func2str(f{1}));
    tc.verifyTrue(all(bis >= 0 & bis <= 100));
end
end

function testHalfEffect(tc)
p = bisParameters('greco');
tc.verifyEqual(bisGreco(p.Prop.C50, 0, p), p.Interaction.E0 - p.Interaction.Emax / 2, 'AbsTol', 1e-12);
p = bisParameters('bouillon');
tc.verifyEqual(bisBouillon(0, p.Remi.C50, p), p.Interaction.E0 - p.Interaction.Emax / 2, 'AbsTol', 1e-12);
end

function testRemifentanilAloneInMinto(tc)
% Additive Minto: remifentanil alone has an effect; reduced Greco: it has none
p = bisParameters('minto');
tc.verifyLessThan(bisMinto(0, p.Remi.C50, p), p.Interaction.E0);
q = bisParameters('greco');
tc.verifyEqual(bisGreco(0, 5, q), q.Interaction.E0);
end

function testVolatileReducesToIntravenous(tc)
p = bisParameters('greco', Patient(1, 65, 170, 70, 'F'));
CeP = linspace(0, 6, 20)';
CeR = linspace(0, 4, 20)';
tc.verifyEqual(bisGrecoVolatile(CeP, CeR, 0, 0, p), bisGreco(CeP, CeR, p));
end

function testVolatileIsAdditiveHypnotic(tc)
% One C50 of sevoflurane is equipotent to one C50 of propofol
p = bisParameters('greco');
tc.verifyEqual(bisGrecoVolatile(0, 1, p.Sevo.C50, 0, p), bisGreco(p.Prop.C50, 1, p), 'AbsTol', 1e-12);
tc.verifyEqual(bisGrecoVolatile(0, 1, 0, p.Des.C50, p), bisGreco(p.Prop.C50, 1, p), 'AbsTol', 1e-12);
end

function testUnifiedMapRemifentanilSynergy(tc)
p = mapUnifiedParameters(90);
p.EmaxNE = 0;
tc.verifyEqual(mapUnified(0, 0, 0, p), 90);
tc.verifyLessThan(mapUnified(3, 4, 0, p), mapUnified(3, 0, 0, p));
end

function testNorepinephrineEffect(tc)
nepi = JoachimModel(Patient(1, 60, 170, 70, 'M'));
tc.verifyEqual(norepinephrineEffect(0, nepi), 0, 'AbsTol', 1e-12);
tc.verifyGreaterThan(norepinephrineEffect(10, nepi), 0);
tc.verifyLessThan(norepinephrineEffect(1e6, nepi), nepi.Emax + eps);
end

function testTurnoverSteadyState(tc)
p = hemodynamicParameters(90, 70);
p.Stim = 0;
[dMAP, dHR] = hemodynamicTurnover(0, 0, 0, 90, 70, p);
tc.verifyEqual([dMAP, dHR], [0 0], 'AbsTol', 1e-12);
end
