% DV_EEGPhaseVelocityPlotter: Plot a heatmap of EEG phase velocity metrics.
%--------------------------------------------------------------------------
% DESCRIPTION:
%   This function generates a heatmap of EEG phase velocity metrics for
%   multiple channels over time. The heatmap displays the distribution of
%   the specified metrics across channels and time windows.
%
% INPUTS:
%   - eegFull: Matrix containing EEG data, where each row represents a channel.
%   - fs: Sampling frequency of the EEG signal.
%   - windowSize: Size of the analysis window in seconds.
%   - totalWindows: Total number of analysis windows.
%   - metricMatrices: Cell array of metric matrices for each metric to plot.
%   - metricNames: Cell array of strings indicating the specific metrics to plot.
%
% OUTPUTS:
%   Generates subplots with heatmaps for each specified metric and displays relevant information.
%--------------------------------------------------------------------------

function DV_EEGPhaseVelocityPlotter(eegFull, fs, windowSize, totalWindows, metricMatrices, metricNames)

[M, N] = size(eegFull);
totalChannels = M;
nameChannel = cell(1, totalChannels);
for i = 1:totalChannels
    nameChannel{i} = ['ch' num2str(i, '%02d')];
end

% Reverse the order to coincide with the display of the EEG
nameChannel = flip(nameChannel);
metricMatrices = cellfun(@(x) flip(x), metricMatrices, 'UniformOutput', false);

totalTime = round(length(eegFull(1, :)) / fs);
tickPositions = (0:windowSize:(totalWindows - 1) * windowSize);
tickLabels = cell(1, length(tickPositions));

for i = 1:length(tickPositions)
    if i < length(tickPositions)
        tickLabels{i} = [num2str(tickPositions(i)), ' - ', num2str(tickPositions(i + 1))];
    else
        % If last window is computed with less seconds than window size
        % tickLabels{i} = [num2str(tickPositions(i)), ' - ', num2str(totalTime)];
        tickLabels{i} = [num2str(tickPositions(i)), ' - ', num2str(tickPositions(i) + windowSize)];
    end
end

figure;

interpreter = 'latex';
titlesFontSize = 16;
axisFontWeight = 'bold';

set(groot,'defaultAxesTickLabelInterpreter',interpreter);
set(groot,'defaulttextinterpreter',interpreter);
set(groot,'defaultLegendInterpreter',interpreter);

numMetrics = numel(metricMatrices);

for i = 1:numMetrics
    subplot(numMetrics, 1, i);
    imagesc(tickPositions, 1:totalChannels, metricMatrices{i});
    xlabel('Time (s)', 'Interpreter', interpreter, 'FontWeight', axisFontWeight, 'FontSize', titlesFontSize);
    ylabel('Channel', 'Interpreter', interpreter, 'FontWeight', axisFontWeight, 'FontSize', titlesFontSize);
    yticks(1:totalChannels);
    yticklabels(nameChannel);
    set(gca, 'XTick', tickPositions, 'XTickLabel', tickLabels);
    cbar = colorbar;
    cbar.Label.String = metricNames{i};
    cbar.Label.FontSize = titlesFontSize;
    cbar.Label.Interpreter = interpreter;
    set(cbar, 'TickLabelInterpreter', interpreter);
    % Customize titles for each metric
    switch metricNames{i}
        case 'V'
            metricDescription = 'Phase Velocity Variability';
        case 'M'
            metricDescription = 'Mean Phase Variability';
        case 'S'
            metricDescription = 'Phase Velocity Std';
        otherwise
            metricDescription = ''; % Default case
    end

    title([metricDescription, ' (', metricNames{i}, ')'], 'Interpreter', interpreter, 'FontWeight', axisFontWeight, 'FontSize', titlesFontSize);
    colormap('hot');
end

end
