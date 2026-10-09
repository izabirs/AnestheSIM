function tests = testPatient
tests = functiontests(localfunctions);
end

function testDerivedCovariates(tc)
p = Patient(1, 50, 180, 80, 'M');
tc.verifyEqual(p.bmi, 80 / 1.8^2, 'AbsTol', 1e-12);
tc.verifyEqual(p.lbm, 1.10 * 80 - 128 * (80 / 180)^2, 'AbsTol', 1e-12);
q = Patient(2, 50, 165, 60, {'F'});
tc.verifyEqual(q.lbm, 1.07 * 60 - 148 * (60 / 165)^2, 'AbsTol', 1e-12);
tc.verifyFalse(q.isMale());
end

function testImmutable(tc)
p = Patient(1, 50, 180, 80, 'M');
tc.verifyError(@() setAge(p), 'MATLAB:class:SetProhibited');
end

function testFromVitalDbStruct(tc)
s = struct('caseid', {7, 8}, 'age', {40, 60}, 'height', {170, 160}, ...
    'weight', {70, 55}, 'sex', {'M', 'F'});
p = Patient.fromVitalDbStruct(s);
tc.verifySize(p, [2 1]);
tc.verifyEqual([p.id], [7 8]);
tc.verifyError(@() Patient.fromVitalDbStruct(rmfield(s(1), 'age')), ...
    'anesthesim:Patient:missingField');
end

function testPopulationDatabase(tc)
p = populationPatients();
tc.verifyNotEmpty(p);
tc.verifyClass(p, 'Patient');
end

function p = setAge(p)
p.age = 10;
end
