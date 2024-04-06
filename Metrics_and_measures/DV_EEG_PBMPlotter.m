% DV_EEG_PBMPlotter: Plot a heatmap of EEG phase-based metrics.
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
% AUTHOR:
%   David Vizcarro Carretero
%--------------------------------------------------------------------------

function DV_EEG_PBMPlotter(eegFull, fs, windowSize, totalWindows, overlapSeconds, metricMatrices, metricNames, metricsClims, filterApplied)

[totalChannels, channelLength] = size(eegFull);
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
    tickLabels{i} = [num2str(windowStarts(i)), ' - ', num2str(windowStarts(i) + windowSize)];
end

numMetrics = numel(metricMatrices);

%% Auxiliary zones extraction

% Establish DANGER zones because of boundary effect
totalDuration = floor(channelLength / fs);
boundaryAffectedSeconds = 0.05 * totalDuration;
beginningBoundaryZone = boundaryAffectedSeconds;

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

% Establish beginning and end window zones
seizureStartSecond = 60;
seizureEndSecond = channelLength / fs - 10;

% Filter tick positions and labels based on window start and end times
seizureStartTickPositions = intersect(tickPositions(windowStarts <= seizureStartSecond), tickPositions(((windowStarts + windowSize) >= seizureStartSecond)));
seizureEndTickPositions = tickPositions(((windowStarts + windowSize) >= seizureEndSecond));
seizureStartBeginningPlotPosition = seizureStartTickPositions(1);
seizureStartEndingPlotPosition = seizureStartTickPositions(end);
seizureEndBeginningPlotPosition = seizureEndTickPositions(1);

tickDecimateFactor = 1;
tickPositions = tickPositions(1:tickDecimateFactor:end);
tickLabels = tickLabels(1:tickDecimateFactor:end);

%% PAINT CODE

figure;

interpreter = 'latex';
titlesFontSize = 16;
axisFontWeight = 'bold';

set(groot,'defaultAxesTickLabelInterpreter',interpreter);
set(groot,'defaulttextinterpreter',interpreter);
set(groot,'defaultLegendInterpreter',interpreter);

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
            minMaxValues_V = metricsClims{1};
            minValue = minMaxValues_V(1);
            maxValue = minMaxValues_V(2);
        case 'M'
            metricDescription = 'Mean Phase Velocity';
            minMaxValues_M = metricsClims{2};
            minValue = minMaxValues_M(1);
            maxValue = minMaxValues_M(2);
        case 'S'
            metricDescription = 'Phase Velocity Std';
            minMaxValues_S = metricsClims{3};
            minValue = minMaxValues_S(1);
            maxValue = minMaxValues_S(2);
        otherwise
            metricDescription = ''; % Default case
    end

    title([metricDescription, ' (', metricNames{i}, ')'], 'Interpreter', interpreter, 'FontWeight', axisFontWeight, 'FontSize', titlesFontSize);
    colormap('hot');
    clim(gca, [minValue, maxValue]);

    % Draw areas delimiting the boundary zones
    hold on;

    ylim_current = get(gca, 'YLim');
    xlim_current = get(gca, 'XLim');

    % For the beginning boundary zone
    x1_begin = 0;
    x2_begin = beginningBoundaryZonePlotPosition;
    x1_end = endingBoundaryZonePlotPosition;
    x2_end = xlim_current(2);
    y1 = ylim_current(1);
    y2 = ylim_current(2);
    rectangle('Position', [x1_begin, y1, x2_begin-x1_begin, y2-y1], ...
        'FaceColor', [0.8 0.8 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
    line([beginningBoundaryZonePlotPosition beginningBoundaryZonePlotPosition], ylim_current, ...
        'Color',  [0 0.447 0.741], 'LineStyle', '--', 'LineWidth', 2);

    % For the ending boundary zone
    rectangle('Position', [x1_end, y1, x2_end-x1_end, y2-y1], ...
        'FaceColor', [0.8 0.8 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
    line([endingBoundaryZonePlotPosition endingBoundaryZonePlotPosition], ylim_current, ...
        'Color',  [0 0.447 0.741], 'LineStyle', '--', 'LineWidth', 2);

    % Draw areas delimiting the start and end of seizure
    line([seizureStartBeginningPlotPosition seizureStartBeginningPlotPosition], ylim, 'Color',  "g", 'LineStyle', ':','LineWidth', 1.5); % Seizure start beginning
    line([seizureStartEndingPlotPosition seizureStartEndingPlotPosition], ylim, 'Color',  "g", 'LineStyle', ':','LineWidth', 1.5); % Seizure start ending
    line([seizureEndBeginningPlotPosition seizureEndBeginningPlotPosition], ylim, 'Color',  "m", 'LineStyle', ':', 'LineWidth', 1.5); % Seizure end

    hold off;
end

switch filterApplied
    case 1
        generalTitle = 'Phase-based metrics (No Filter)';
    case 2
        generalTitle = 'Phase-based metrics (Low Pass Filter)';
    case 3
        generalTitle = 'Phase-based metrics (High Pass Filter)';
    otherwise
        generalTitle = 'Phase-based metrics';
end

sgtitle(generalTitle, 'Interpreter', interpreter, 'FontWeight', 'bold', 'FontSize', 16);
end
