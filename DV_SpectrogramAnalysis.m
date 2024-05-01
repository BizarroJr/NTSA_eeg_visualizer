function DV_SpectrogramAnalysis(eeg, fs, channelLength, patientId, seizure)

% Parameters
windowSizeSeconds = 1.5;
overlapRatio = 0.75;
overlapLength = round(windowSizeSeconds * overlapRatio * fs);
windowLength = round(windowSizeSeconds * fs);
colormapColor = 'jet';

% Initialize a cell array to store spectrograms for all channels
spectrograms = cell(size(eeg, 1), 1);

% Create figure
fig = figure;

% Compute spectrograms for all channels
for i = 1:size(eeg, 1)
    [s, f, t] = spectrogram(eeg(i,:), windowLength, overlapLength, [], fs);
    spectrograms{i} = 10*log10(abs(s)); % Store spectrogram in cell array
end

% Find maximum and minimum values across all spectrograms excluding -Inf and Inf
maxVals = cellfun(@(x) max(x(x < Inf)), spectrograms); % Exclude Inf values
minVals = cellfun(@(x) min(x(x > -Inf)), spectrograms); % Exclude -Inf values
maxVal = max(maxVals);
minVal = min(minVals);

% Establish beginning and end window zones
seizureStartSecond = 60;
seizureEndSecond = channelLength / fs - 10;

% Initialize index for current channel
currentChannelIndex = 1;

psds = DV_ComputePSDsFromSpectrograms(spectrograms, fs, seizureStartSecond, seizureEndSecond, channelLength, windowLength, overlapLength);

DV_PlotSpectrogramAndSegmentPSDs( ...
    s, ...
    f, ...
    t, ...
    spectrograms, ...
    psds, ...
    patientId, ...
    seizure, ...
    currentChannelIndex, ...
    seizureStartSecond, ...
    seizureEndSecond, ...
    colormapColor, ...
    minVal, ...
    maxVal, ...
    fs);

while true
    % Wait for mouse click or key press
    waitforbuttonpress;

    % Get the key pressed
    key = fig.CurrentKey;

    % Move to next or previous channel based on arrow key pressed
    if strcmp(key, 'leftarrow')
        currentChannelIndex = currentChannelIndex - 1;
    elseif strcmp(key, 'rightarrow')
        currentChannelIndex = currentChannelIndex + 1;
    end

    % Ensure currentChannelIndex stays within bounds
    currentChannelIndex = mod(currentChannelIndex - 1, size(eeg, 1)) + 1;

    DV_PlotSpectrogramAndSegmentPSDs( ...
        s, ...
        f, ...
        t, ...
        spectrograms, ...
        psds, ...
        patientId, ...
        seizure, ...
        currentChannelIndex, ...
        seizureStartSecond, ...
        seizureEndSecond, ...
        colormapColor, ...
        minVal, ...
        maxVal, ...
        fs);
end
end

%% Calculate histograms

function psds = DV_ComputePSDsFromSpectrograms(spectrograms, fs, seizureStartSecond, seizureEndSecond, channelLength, windowLength, overlapLength)

    % Define segment lengths
    segmentLengths = [seizureStartSecond, ... % Length of pre-ictal segment
                      seizureEndSecond - seizureStartSecond, ... % Length of ictal segment
                      channelLength / fs - seizureEndSecond]; % Length of post-ictal segment
    
    % Initialize cell array to store PSDs for each channel and segment
    numChannels = numel(spectrograms);
    numTimeSegments = length(segmentLengths);
    psds = cell(numChannels, numTimeSegments);

    % Compute indices for each time segment
    segmentIndices = [1, seizureStartSecond * fs; ...
        seizureStartSecond * fs + 1, seizureEndSecond * fs; ...
        seizureEndSecond * fs + 1, channelLength];

    % Iterate over each channel
    for channel = 1:numel(spectrograms)
        for timeSegment = 1:numTimeSegments
            % Compute the indices for the current time segment
            startSample = segmentIndices(timeSegment, 1); % Start sample index
            endSample = segmentIndices(timeSegment, 2); % End sample index
            startWindow = ceil(startSample / windowLength); 
            endWindow = floor(endSample / windowLength); 

             % Adjust start and end window indices based on overlap
             startWindow = round(max(startWindow - overlapLength / windowLength, 1));
             endWindow = round(endWindow + overlapLength / windowLength);

            % Extract the spectrogram windows for the current time segment
            segmentSpectrogram = spectrograms{channel}(startWindow:endWindow, :);
            
            % Normalize the PSD by dividing by the segment length
            segmentLength = segmentLengths(timeSegment);
            psd = mean(abs(segmentSpectrogram).^2, 2);
            normalizedPsd = psd / segmentLength;

            % Compute PSD for the current segment
            psds{channel, timeSegment} = normalizedPsd;
        end
    end
end



%% Plot spectrograms and histograms

function DV_PlotSpectrogramAndSegmentPSDs( ...
    s, ...
    f, ...
    t, ...
    spectrograms, ...
    histograms, ...
    patientId, ...
    seizure, ...
    currentChannelIndex, ...
    seizureStartSecond, ...
    seizureEndSecond, ...
    colormapColor, ...
    minVal, ...
    maxVal, ...
    fs)

% Plot spectrogram
cla;

subplot(2, 1, 1);
surf(t, f, spectrograms{currentChannelIndex}, 'EdgeColor', 'none');
axis tight;
view(0, 90);
xlabel('Time (s)');
ylabel('Frequency (Hz)');
title(['Patient ', num2str(patientId), ', Recording ', num2str(seizure), ' - Channel ', num2str(currentChannelIndex)]);
colormap(colormapColor);
cbar = colorbar;
cbar.Label.String = 'Power (dB)';
clim([minVal, maxVal]);

% Draw vertical lines indicating the beginning and end zones
line([seizureStartSecond, seizureStartSecond], ylim, 'Color', 'g', 'LineWidth', 1.5, 'LineStyle', '--', 'ZData', ones(1,2)*100);
line([seizureEndSecond, seizureEndSecond], ylim, 'Color', 'r', 'LineWidth', 1.5, 'LineStyle', '--', 'ZData', ones(1,2)*100);

% Plot segment histograms
subplot(2, 1, 2);
cla;

% Define colors for each segment
colors = {'r', 'g', 'b'};

hold on; % Hold the plot for multiple histograms

for j = 1:size(histograms, 2)
    % Extract the histogram for the current time segment and channel
    histogram = histograms{currentChannelIndex, j};

    % Plot the histogram
    plot(histogram, 'Color', colors{j});
end

hold off; % Release the hold

% Add labels and legend
xlabel('Frequency (Hz)');
ylabel('Power (dB)');
axis tight;
title(['Histograms for Channel ', num2str(currentChannelIndex)]);
legend('Pre-ictal stage', 'Ictal stage', 'Post-ictal stage');

end




