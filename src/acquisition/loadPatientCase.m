function [patient, data] = loadPatientCase(database, caseId, signals, opts)
%LOADPATIENTCASE Database-agnostic entry point of the acquisition layer.
%   [patient, data] = loadPatientCase(DatabaseType.VitalDB, caseId, signals)
%   [patient, data] = loadPatientCase(DatabaseType.Population, patientNo)
%
%   Returns a Patient object and the canonical patientData structure (see
%   emptyPatientData). This switch is the single place where a new
%   repository is connected: implement a loader returning the same two
%   outputs and add a case below.
%
%   'Optional' lists signals loaded only when the case provides them.

arguments
    database (1,1) DatabaseType
    caseId (1,1) double
    signals (1,:) VitalSignal = vitaldbDefaultSignals('balanced')
    opts.Optional (1,:) VitalSignal = VitalSignal.empty
end

switch database
    case DatabaseType.VitalDB
        [patient, data] = vitaldbLoadCase(caseId, signals, 'Optional', opts.Optional);
    case DatabaseType.Population
        patients = populationPatients();
        patient = patients([patients.id] == caseId);
        if isempty(patient)
            error('anesthesim:population:unknownPatient', ...
                'Synthetic patient %d not found.', caseId);
        end
        data = emptyPatientData();
        data.caseId = caseId;
end
end
