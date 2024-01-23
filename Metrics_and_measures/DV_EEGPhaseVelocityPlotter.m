%--------------------------------------------------------------------------
% DV_EEGPhaseVelocityPlotter: Plot a heatmap of EEG phase velocity metrics.
%--------------------------------------------------------------------------
% DESCRIPTION:
%   This function generates a heatmap of EEG phase velocity metrics for
%   multiple channels over time. The heatmap displays the distribution of
%   the specified metricToPlot across channels and time windows.
%
% INPUTS:
%   - eegFull: Matrix containing EEG data, where each row represents a channel.
%   - fs: Sampling frequency of the EEG signal.
%   - windowSize: Size of the analysis window in seconds.
%   - totalWindows: Total number of analysis windows.
%   - channelsMetrics: Matrix containing the metric values for each channel and window.
%   - metricToPlot: String indicating the specific metric to plot.
%
% OUTPUTS:
%   Generates a heatmap plot and displays relevant information.
%--------------------------------------------------------------------------

function DV_EEGPhaseVelocityPlotter(eegFull, fs, windowSize, totalWindows, channelsMetrics, metricToPlot)

    [M, N] = size(eegFull);
    totalChannels = M;
    nameChannel = cell(1, totalChannels);
    for i = 1:totalChannels
        nameChannel{i} = ['ch' num2str(i, '%02d')];
    end
    
    % Reverse the order to coincide with the display of the EEG
    channelsMetrics = flip(channelsMetrics);
    nameChannel = flip(nameChannel);

    totalTime = round(length(eegFull(1, :)) / fs);
    tickPositions = (0:windowSize:(totalWindows - 1) * windowSize);
    tickLabels = cell(1, length(tickPositions));
    
    for i = 1:length(tickPositions)
        if i < length(tickPositions)
            tickLabels{i} = [num2str(tickPositions(i)), ' - ', num2str(tickPositions(i + 1))];
        else
            tickLabels{i} = [num2str(tickPositions(i)), ' - ', num2str(totalTime)];
        end
    end
    
    figure;
    imagesc(tickPositions, 1:totalChannels, channelsMetrics);
    xlabel('Time (s)');
    ylabel('Channel');
    yticks(1:totalChannels);
    yticklabels(nameChannel);
    set(gca, 'XTick', tickPositions, 'XTickLabel', tickLabels);
    cbar = colorbar;
    cbar.Label.String = metricToPlot; 
    title(['Heatmap of ', metricToPlot]);
    colormap('hot');
    
    
    % % Plot channelsV
    % figure;
    % subplot(3,1,1);
    % plot(tickPositions, channelsV');
    % title('ChannelsV');
    % xlabel('Time (s)');
    % ylabel('Metric Value (a.u.)');
    % set(gca, 'XTick', tickPositions);
    %
    % % Plot channelsM
    % subplot(3,1,2);
    % plot(tickPositions, channelsM');
    % title('ChannelsM');
    % xlabel('Time (s)');
    % ylabel('Metric Value (a.u.)');
    % set(gca, 'XTick', tickPositions);
    %
    % % Plot channelsS
    % subplot(3,1,3);
    % plot(tickPositions, channelsS');
    % title('ChannelsS');
    % xlabel('Time (s)');
    % ylabel('Metric Value (a.u.)');
    % set(gca, 'XTick', tickPositions);
end