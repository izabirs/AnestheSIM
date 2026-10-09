function file = saveFigure(fig, name)
%SAVEFIGURE Export a figure as PNG into <root>/results.

folder = fullfile(anesthesimRoot(), 'results');
if ~isfolder(folder)
    mkdir(folder);
end
file = fullfile(folder, [name '.png']);
for ax = findall(fig, 'Type', 'axes')'
    ax.Toolbar.Visible = 'off';
end
exportgraphics(fig, file, 'Resolution', 200);
fprintf('Saved %s\n', file);
end
