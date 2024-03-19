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

function DV_EEGPhaseVelocityPlotter(eegFull, fs, windowSize, ...
    totalWindows, overlapSeconds, metricMatrices, metricNames)

[M, N] = size(eegFull);
totalChannels = M;
nameChannel = cell(1, totalChannels);
for i = 1:totalChannels
    nameChannel{i} = ['ch' num2str(i, '%02d')];
end

% Reverse the order to coincide with the display of the EEG
nameChannel = flip(nameChannel);
metricMatrices = cellfun(@(x) flip(x), metricMatrices, 'UniformOutput', false);

stepSize = windowSize - overlapSeconds; % From window start to window start
windowStarts = (0:totalWindows-1) * stepSize;
tickPositions = windowStarts + windowSize / 2;
tickLabels = cell(1, length(tickPositions));

for i = 1:length(tickPositions)
    % tickLabels{i} = [num2str(tickPositions(i)), ' - ', num2str(tickPositions(i) + windowSize)];
    tickLabels{i} = [num2str(windowStarts(i)), ' - ', num2str(windowStarts(i) + windowSize)];
end

figure;

interpreter = 'latex';
titlesFontSize = 16;
axisFontWeight = 'bold';

set(groot,'defaultAxesTickLabelInterpreter',interpreter);
set(groot,'defaulttextinterpreter',interpreter);
set(groot,'defaultLegendInterpreter',interpreter);

numMetrics = numel(metricMatrices);

% Draw DANGER zones because of boundary effect
totalDuration = floor(N / fs);
boundaryAffectedSeconds = 0.05 * totalDuration;
beginningBoundaryZone = boundaryAffectedSeconds;
endingBoundaryZone = totalDuration - boundaryAffectedSeconds;

% The loop searches the amount of windows affected by the boundary effect,
% since it is simmetrical, the same number of windows are affected at the
% tail of the signal. 
affectedNumberOfWindows = -1;
for i = 1:length(windowStarts)
    if windowStarts(i) < beginningBoundaryZone
        affectedNumberOfWindows = i;
    else
        break; 
    end
end

beginningBoundaryZonePlotPosition = tickPositions(affectedNumberOfWindows);
endingBoundaryZonePlotPosition = tickPositions(length(windowStarts) - affectedNumberOfWindows + 1);

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
            %10-90
            % minValue = 0.3058;
            % maxValue = 1.9650;
            %20-80
            % minValue = 0.3209;
            % maxValue = 1.6722;
            %30-70
            minValue = 0.33954;
            maxValue = 1.2844;
        case 'M'
            metricDescription = 'Mean Phase Velocity';
            % minValue = 0.1158;
            % maxValue = 1.6065;
            % minValue = 0.1374;
            % maxValue = 1.5829;
            minValue = 0.1501;
            maxValue = 1.5554;
        case 'S'
            metricDescription = 'Phase Velocity Std';
            % minValue = 0.1366;
            % maxValue = 0.5185;
            % minValue = 0.1584;
            % maxValue = 0.4972;
            minValue = 0.17713;
            maxValue = 0.47295;
        otherwise
            metricDescription = ''; % Default case
    end

    title([metricDescription, ' (', metricNames{i}, ')'], 'Interpreter', interpreter, 'FontWeight', axisFontWeight, 'FontSize', titlesFontSize);
    colormap('hot');
    clim(gca, [minValue, maxValue]);

    % Draw vertical lines for the boundary zones
    hold on;
    line([beginningBoundaryZonePlotPosition beginningBoundaryZonePlotPosition], ...
        ylim, 'Color',  [0 0.447 0.741], 'LineStyle', '--','LineWidth', 2); % beginning boundary zone
    line([endingBoundaryZonePlotPosition endingBoundaryZonePlotPosition], ...
        ylim, 'Color',  [0 0.447 0.741], 'LineStyle', '--', 'LineWidth', 2); % ending boundary zone
    hold off;
end
end
