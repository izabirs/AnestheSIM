function fig = plotBisComparison(res, simIn, caseId)
%PLOTBISCOMPARISON Measured vs predicted BIS of the three intravenous models.

fig = figure('Color', 'w', 'Position', [100 100 900 420]);
tm = res.t / 60;
plot(tm, simIn.meas.BIS, 'Color', [0.65 0.65 0.65], 'LineWidth', 0.6); hold on
plot(tm, res.BIS.minto, 'LineWidth', 1.4, 'Color', [0.00 0.45 0.74]);
plot(tm, res.BIS.bouillon, 'LineWidth', 1.4, 'Color', [0.85 0.33 0.10]);
plot(tm, res.BIS.greco, 'LineWidth', 1.4, 'Color', [0.47 0.67 0.19]);
hold off
grid on
xlim([0 tm(end)]);
ylim([0 100]);
xlabel('Time (min)');
ylabel('BIS');
title(sprintf('VitalDB case %d', caseId));
legend({'Measured', 'Minto (additive)', 'Bouillon', 'Reduced Greco'}, 'Location', 'southwest');
end
