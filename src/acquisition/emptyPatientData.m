function data = emptyPatientData()
%EMPTYPATIENTDATA Canonical patientData structure (database independent).
%   Every acquisition function returns this structure. Absent signals are
%   left empty ([]); time series are timeseries objects in seconds.
%
%   data.Propofol.infRate        pump rate [mL/h]
%   data.Propofol.Cp / .Ce       pump-predicted concentrations [ug/mL] (if recorded)
%   data.Propofol.concentration  solution strength [mg/mL]
%   data.Remifentanil.*          as propofol; Cp/Ce [ng/mL], strength [ug/mL]
%   data.Norepinephrine.*        infRate [mL/h], strength [ug/mL]
%   data.Sevoflurane.Et          end-tidal sevoflurane [vol%]
%   data.Desflurane.Et           end-tidal desflurane [vol%]
%   data.BIS, data.MAP, data.HR  monitored outputs
%   data.BISQuality.SQI          BIS signal quality index [%] (if recorded)
%   data.Volatile                device traces kept for display (database specific)

drug = struct('infRate', [], 'Cp', [], 'Ce', [], 'concentration', []);
data = struct();
data.caseId = [];
data.Propofol = drug;
data.Propofol.concentration = 20;        % mg/mL
data.Remifentanil = drug;
data.Remifentanil.concentration = 20;    % ug/mL
data.Norepinephrine = drug;
data.Norepinephrine.concentration = 20;  % ug/mL
data.Sevoflurane = struct('Et', []);
data.Desflurane = struct('Et', []);
data.BIS = [];
data.BISQuality = struct('SQI', []);
data.MAP = [];
data.HR = [];
data.Volatile = struct();
end
