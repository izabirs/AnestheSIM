function models = buildPatientModels(patient, data)
%BUILDPATIENTMODELS Instantiate all covariate PK models for one patient.
%   models = buildPatientModels(patient, data) returns the state-space
%   models used by the Simulink core and by offline analyses (computeConcentrations):
%
%   models.prop   Schnider propofol PK + effect site   (mg/s  -> [Cp Ce] ug/mL)
%   models.remi   Minto remifentanil PK + effect site  (ug/s  -> [Cp Ce] ng/mL)
%   models.nepi   Joachim norepinephrine PK/PD         (nmol/s -> Cc nmol/L)
%   models.sevo   sevoflurane effect site              (vol%  -> vol%)
%   models.des    desflurane effect site               (vol%  -> vol%)
%   models.conv   pump-rate converters, u = rate * c_sol / 3600
%
%   data (canonical patientData) supplies the pump solution strengths.

if nargin < 2 || isempty(data)
    data = emptyPatientData();
end

NE_MOLAR_MASS = 169.18;  % g/mol

models.prop = SchniderModel(patient);
models.remi = MintoModel(patient);
models.nepi = JoachimModel(patient);
models.sevo = VolatileModel('sevoflurane', patient);
models.des = VolatileModel('desflurane', patient);

models.conv.prop = data.Propofol.concentration / 3600;                         % mL/h -> mg/s
models.conv.remi = data.Remifentanil.concentration / 3600;                     % mL/h -> ug/s
models.conv.nepi = data.Norepinephrine.concentration / 3600 * 1e3 / NE_MOLAR_MASS; % mL/h -> nmol/s
end
