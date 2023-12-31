%--------------------------------------------------------------------------
% dropout_detector: Identifies potential dropout regions in an EEG signal.
%--------------------------------------------------------------------------
% DESCRIPTION:
%   The function utilizes the following steps to detect dropout regions in an
%   EEG signal:
%
%   1. Identifying Samples Near 0:
%      The function identifies samples in the input EEG signal that are
%      close to zero based on a user-defined threshold value.
%
%   2. Filtering Consecutive Samples:
%      To mitigate false positives, consecutive samples are identified among
%      the previously identified near-zero samples. If the number of
%      consecutive samples is below a user-defined threshold, these samples
%      are discarded as false-positive dropouts.
%
% INPUTS:
%   - signal: The EEG signal under consideration.
%   - thresholdValue: The user-defined threshold to identify samples near 0.
%   - consecutiveThreshold: The user-defined threshold for consecutive
%     samples to be considered part of a dropout region.
%   - fs: The sampling frequency of the EEG signal.
%   - channel: (Optional) An integer indicating the channel number of the signal.
%   - verbose: (Optional) A logical value indicating whether to display
%     dropout information. Default is true.
%
% OUTPUTS:
%   - dropoutIndices: Indices of the identified dropout regions in the EEG signal.
%   - dropoutGroups: Cell array containing indices of each identified dropout group.
%   - dropoutCount: Total number of identified dropout regions.
%   - dropoutDurations: Cell array containing the duration of each dropout.
%   - dropoutInfo: Formatted string containing dropout information.
%
%--------------------------------------------------------------------------

function [dropoutIndices, dropoutGroups, dropoutCount, dropoutDurations, dropoutInfo] = dropout_detector(signal, thresholdValue, consecutiveThreshold, fs, channel, verbose) 
    % Set default values for optional parameters if not provided
    if nargin < 6
        verbose = true;
    end
    if nargin < 5
        channel = NaN;
    end

    % Identify samples near 0
    nearZeroIndices = find(abs(signal) < thresholdValue);
    
    % Identify consecutive samples
    consecutiveGroups = split_consecutive(nearZeroIndices);
    
    % Filter out false positives
    validDropoutGroups = consecutiveGroups(cellfun(@numel, consecutiveGroups) >= consecutiveThreshold);
    
    % Check if any dropout groups are found
    if isempty(validDropoutGroups)
        dropoutIndices = [];
        dropoutGroups = {};
        dropoutCount = 0;
        dropoutDurations = [];
        dropoutInfo = ['A total of ', num2str(dropoutCount), ' possible dropouts has been found in Channel ', num2str(channel), newline];
        
        % Display or return the dropout information based on the verbose parameter
        if verbose
            disp(dropoutInfo);
        end
        return;
    end
    
    % Obtain indices of dropouts
    dropoutIndices = cat(2, validDropoutGroups{:});

    % Calculate dropout count
    dropoutCount = numel(validDropoutGroups);
    dropoutDurations = cellfun(@(indices) numel(indices) / fs, validDropoutGroups);

    % Generate the output string
    if isnan(channel)
        dropoutInfo = ['A total of ', num2str(dropoutCount), ' possible dropouts has been found.'];
    else
        dropoutInfo = ['A total of ', num2str(dropoutCount), ' possible dropouts has been found in Channel ', num2str(channel)];
    end
    
    for i = 1:dropoutCount
        dropoutInfo = [dropoutInfo, sprintf('\nDropout %d lasts %.2f seconds', i, dropoutDurations(i))];
    end
    dropoutInfo = [dropoutInfo, newline]; 
    
    % Display or return the dropout information based on the verbose parameter
    if verbose
        disp(dropoutInfo);
    end

    % Calculate number of groups and return dropoutGroups
    numGroups = length(validDropoutGroups);
    dropoutGroups = validDropoutGroups;
end
