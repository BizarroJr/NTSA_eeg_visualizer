function metrics = DV_EEGPhaseVelocityAnalyzer(fs, eegChannel, windowSizeSeconds, overlapSeconds)

if(overlapSeconds >= windowSizeSeconds)
    error('Overlap cannot be greater than the window size. Please re-adjust the parameters.');
end

windowSizeSamples = windowSizeSeconds * fs;
overlapSamples = fs * overlapSeconds;

% numFullWindows = floor(length(eegChannel) / windowSizeSamples) % For non-overlapping systems
numFullWindows = floor((length(eegChannel) - windowSizeSamples) / (windowSizeSamples - overlapSamples)) + 1;
% remainingSamples = mod(length(eegChannel), windowSizeSamples);
remainingSamples = 0; % Kept to 0 to prevent last window from being less than the established window size
totalWindows = numFullWindows + (remainingSamples > 0);

% Create a cell array to store the windows and the matrix that will
% store V, M, S. V (Row 1), M (Row 2), S(Row 3)
segments = cell(1, totalWindows);
metrics = zeros(3, totalWindows);

% Window the full windows
for i = 1:numFullWindows
    startIndex = (i - 1) * (windowSizeSamples - overlapSamples) + 1;
    endIndex = min(startIndex + windowSizeSamples - 1, length(eegChannel));

    % Store the window in the cell array
    segments{i} = eegChannel(startIndex:endIndex);
end

% Include the remaining samples in the last window
if remainingSamples > 0
    startIndex = numFullWindows * windowSizeSamples + 1;
    endIndex = startIndex + remainingSamples - 1;

    % Store the last window in the cell array
    segments{numFullWindows + 1} = eegChannel(startIndex:endIndex);
end

for i = 1:totalWindows
    [V, M, S] = DV_PhaseBasedMeasures(segments{i});
    metrics(:, i) = [V, M, S];
end
end
