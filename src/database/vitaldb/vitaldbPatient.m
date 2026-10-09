function patient = vitaldbPatient(caseId)
%VITALDBPATIENT Patient object for a VitalDB case id.

T = vitaldbClinicalTable();
row = T(T.caseid == caseId, :);
if isempty(row)
    error('anesthesim:vitaldb:unknownCase', 'Case %d not found in VitalDB.', caseId);
end
patient = Patient.fromVitalDbStruct(table2struct(row(1, :)));
end
