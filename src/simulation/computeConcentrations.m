function c = computeConcentrations(simIn, models)
%COMPUTECONCENTRATIONS Model-predicted concentrations for a recorded case.
%   c = computeConcentrations(simIn, models) drives the PK models with the
%   recorded inputs (offline, no Simulink) and returns column vectors on
%   simIn.t:
%       c.CpP, c.CeP   propofol plasma / effect site [ug/mL]
%       c.CpR, c.CeR   remifentanil plasma / effect site [ng/mL]
%       c.CcN          exogenous norepinephrine plasma [nmol/L]
%       c.CeSevo, c.CeDes  volatile effect sites [vol%]

Ts = simIn.Ts;

y = simulateLTI(models.prop, simIn.u.prop.Data * models.conv.prop, Ts);
c.CpP = y(:, 1);
c.CeP = y(:, 2);

y = simulateLTI(models.remi, simIn.u.remi.Data * models.conv.remi, Ts);
c.CpR = y(:, 1);
c.CeR = y(:, 2);

c.CcN = simulateLTI(models.nepi, simIn.u.nepi.Data * models.conv.nepi, Ts, models.nepi.Tlag);
c.CeSevo = simulateLTI(models.sevo, simIn.u.sevo.Data, Ts);
c.CeDes = simulateLTI(models.des, simIn.u.des.Data, Ts);
end
