function [dMAP, dHR] = hemodynamicTurnover(CpP, CpR, t, MAP, HR, p)
%HEMODYNAMICTURNOVER Derivatives of the MAP/HR indirect-response model.
%   dMAP = kout MAP0 (1 - fP) (HR/HR0)^FBhr h(t) - kout MAP
%   dHR  = kout HR0  (1 - gR)                   - kout HR
%   with fP = EmaxP CpP/(CpP + C50P), gR = EmaxR CpR^g/(CpR^g + C50R^g) and
%   h(t) = 1 + Stim exp(-kStim (t - tStim)) after the stimulation onset.
%   CpP [ug/mL], CpR [ng/mL], p from hemodynamicParameters.

CpP = max(CpP, 0);
CpR = max(CpR, 0);
MAP = max(MAP, 1e-6);
HR = max(HR, 1e-6);

fP = p.EmaxP * CpP / (CpP + p.C50P);
rg = CpR^p.gammaR;
gR = p.EmaxR * rg / (rg + p.C50R^p.gammaR);

if t < p.tStim
    h = 1;
else
    h = 1 + p.Stim * exp(-p.kStim * (t - p.tStim));
end

dMAP = p.kout * p.MAP0 * (1 - fP) * (HR / p.HR0)^p.FBhr * h - p.kout * MAP;
dHR = p.kout * p.HR0 * (1 - gR) - p.kout * HR;
end
