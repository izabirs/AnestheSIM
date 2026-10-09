function fig = plotBalancedCase(res, simIn, caseId)
%PLOTBALANCEDCASE Balanced anaesthesia: BIS with and without the volatile term.
%   Top: measured BIS vs the intravenous reduced Greco model and the same
%   model extended with the inhaled agents. Bottom: end-tidal agents as
%   resolved from the gas analysers.

fig = figure('Color', 'w', 'Position', [100 100 900 600]);
tm = res.t / 60;
iv = predictionMetrics(res.BIS.greco, simIn.meas.BIS);
vol = predictionMetrics(res.BIS.volatile, simIn.meas.BIS);

subplot(2, 1, 1);
plot(tm, simIn.meas.BIS, 'Color', [0.72 0.72 0.72], 'LineWidth', 0.6); hold on
plot(tm, res.BIS.greco, ':', 'Color', [0.85 0.33 0.10], 'LineWidth', 1.8);
plot(tm, res.BIS.volatile, '-', 'Color', [0.00 0.45 0.74], 'LineWidth', 1.6);
hold off
grid on
xlim([0 tm(end)]);
ylim([0 100]);
ylabel('BIS');
title(sprintf('VitalDB case %d   (MDAPE: intravenous %.1f%%, with volatile term %.1f%%)', ...
    caseId, iv.MDAPE, vol.MDAPE));
legend({'Measured', 'Reduced Greco, intravenous only', 'Reduced Greco + volatile agents'}, ...
    'Location', 'southwest');

subplot(2, 1, 2);
plot(tm, simIn.u.sevo.Data, 'Color', [0.85 0.33 0.10], 'LineWidth', 1.4); hold on
plot(tm, simIn.u.des.Data, 'Color', [0.47 0.67 0.19], 'LineWidth', 1.4);
legendText = {'Sevoflurane Et', 'Desflurane Et'};
if isfield(simIn.meas, 'SolarTotal')
    plot(tm, simIn.meas.SolarTotal, ':', 'Color', [0.3 0.3 0.3], 'LineWidth', 1.0);
    legendText{end + 1} = 'Solar8000 total';
end
hold off
grid on
xlim([0 tm(end)]);
xlabel('Time (min)');
ylabel('End-tidal (vol%)');
legend(legendText, 'Location', 'northwest');
end
