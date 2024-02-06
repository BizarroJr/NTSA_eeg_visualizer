function [isFlatline, flatlineChannels] = flatlineDetector(fullEeg, fs, windowSizeSeconds, verbose)

if nargin < 4
    verbose = true;
end

[numChannels, signalLength] = size(fullEeg);
windowSizeSamples = windowSizeSeconds * fs;
numFullWindows = floor(signalLength / windowSizeSamples);
% remainingSamples = mod(signalLength, windowSizeSamples);
% totalWindows = numFullWindows + (remainingSamples > 0);
totalWindows = numFullWindows;
fullEeg = abs(fullEeg);

% Initialize variables
windowedSegments = cell(1, totalWindows);
meanOfMeans = zeros(1, totalWindows);
stdOfMeans = zeros(1, totalWindows);
channelMightBeFlatline = false(numChannels, totalWindows);
isFlatline = false;

for i = 1:totalWindows
    % Determine the indices for the current segment
    startIdx = (i - 1) * windowSizeSamples + 1;
    endIdx = min(i * windowSizeSamples, signalLength);

    currentSegment = fullEeg(:, startIdx:endIdx);
    meanValues = mean(currentSegment, 2);
    windowedSegments{i} = meanValues;
    meanOfMeans(:, i) = mean(meanValues);
    stdOfMeans(:, i) = std(meanValues);
    channelMightBeFlatline(:, i) = meanValues < (meanOfMeans(:, i) - stdOfMeans(:, i));
    % disp(['Possible channels with flatlines on segment ' num2str(i) ':']);
    % disp(find(meanValues < (meanOfMeans(:, i) - stdOfMeans(:, i))));
end

channelsWithMoreThanHalfTrue = sum(channelMightBeFlatline, 2) == totalWindows;

if(any(channelsWithMoreThanHalfTrue))
    isFlatline = true;
end

flatlineChannels = find(channelsWithMoreThanHalfTrue);
if(verbose)
    disp(['Flatlines on: ', flatlineChannels]);
end

% meanSegments = cell2mat(windowedSegments);

end