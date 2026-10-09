function patients = populationPatients()
%POPULATIONPATIENTS Synthetic patients (demographics only) shipped with AnestheSIM.

S = load(fullfile(anesthesimRoot(), 'data', 'population', 'population_patients.mat'), 'patientTable');
patients = Patient.fromTable(S.patientTable);
end
