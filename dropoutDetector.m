function [averagedDropoutStartingPoints, averagedDropoutEndingPoints, totalDropouts, totalDropoutTime, dropoutRatio] = dropoutDetector(fullEeg, fs, verbose)
    if nargin < 3
        verbose = true;
    end

    % Intial variable parameters
    histogramResolution = 500;
    differenceThreshold = 10;
    averagingWindowLength = 10;
    minimumAmountOfSamplesPerGroup = 100;
    
    [totalChannels, totalSamples] = size(fullEeg);

    eegDropoutStartPoints = cell(1, totalChannels);
    eegDropoutEndPoints = cell(1, totalChannels);
    
    % Perform a scan over all the channels and extract the existing
    % dropouts in each channel
    for currentChannel = 1:totalChannels
        channelSignal = fullEeg(currentChannel, :);
        absoluteSignalDerivative = abs(diff(channelSignal));
        averagedSignalDerivative = movmean(absoluteSignalDerivative, averagingWindowLength);
        [binCount, binEdges] = histcounts(averagedSignalDerivative, histogramResolution);
        binThreshold = binEdges(2);
        dropoutIndices = find(abs(averagedSignalDerivative) < binThreshold);
    
        % Find the differences between consecutive indices and group those
        % which are close together, then check and remove groups with just 
        % one element
        indexDifferences = diff(dropoutIndices);
        breakPoints = find(indexDifferences > differenceThreshold);
        groups = mat2cell(dropoutIndices, 1, diff([0 breakPoints numel(dropoutIndices)]));
        validGroups = cellfun(@(x) numel(x) > minimumAmountOfSamplesPerGroup, groups);
        groups = groups(validGroups);

        totalDropouts = numel(groups);

        % Initialize vectors to store dropout information for the current channel
        dropoutStartPoints = zeros(1, totalDropouts);
        dropoutEndPoints = zeros(1, totalDropouts);

        for i = 1:totalDropouts
            currentDropoutGroup = groups{i};
            startSample = currentDropoutGroup(1);
            finishSample = currentDropoutGroup(end);
            dropoutStartPoints(i) = startSample;
            dropoutEndPoints(i) = finishSample;
        end

        % Store dropout information in cell arrays
        eegDropoutStartPoints{currentChannel} = dropoutStartPoints';
        eegDropoutEndPoints{currentChannel} = dropoutEndPoints';
    end
    
    % Find the channel which has the most dropouts, and set that number as 
    % the baseline for the recording, then, perform an average of the dropout 
    % marker points between all the channels 
    dropoutLengths = cellfun(@numel, eegDropoutStartPoints);
    [maxDropoutNum, maxDropoutChannel] = max(dropoutLengths);
    equallyDropoutLengthedChannels = cellfun(@(x) numel(x) == maxDropoutNum, eegDropoutStartPoints);
    % Apply boolean mask to filter out those channels which lack a dropout.
    % Then just leave those of equal length to perform the mean.
    filteredDropoutStarts = eegDropoutStartPoints(equallyDropoutLengthedChannels);
    filteredDropoutEnds = eegDropoutEndPoints(equallyDropoutLengthedChannels);

    averagedDropoutStartingPoints = round(mean(cell2mat(filteredDropoutStarts), 2)); 
    averagedDropoutEndingPoints = round(mean(cell2mat(filteredDropoutEnds), 2));  
    totalDropoutSamples = 0;
    for i = 1:maxDropoutNum
        totalDropoutSamples = totalDropoutSamples + (averagedDropoutEndingPoints(i,1) - averagedDropoutStartingPoints(i,1));
    end
    totalDropoutTime = totalDropoutSamples / fs;
    dropoutRatio = totalDropoutSamples / totalSamples;

    % Perform averaging over all channels and do an average of the dropout 
    % Display resultsy
    if(verbose)
        fprintf('<strong>Each channel contains %d dropouts:</strong>\n', totalDropouts);
        fprintf('<strong>The percentage of dropout samples in the whole signal is:</strong>\n%.2f%%\n', dropoutRatio * 100);
    end
end


