%--------------------------------------------------------------------------
% artifactResultsSaver: Process EEG data, detect dropouts, and save results to an Excel file.
%--------------------------------------------------------------------------
% DESCRIPTION:
%   This function processes EEG data from multiple files, detects dropouts,
%   and saves the results to an Excel file. It utilizes the detectAndCalculateDropouts
%   function to identify dropout regions in the EEG signal.
%
% INPUTS:
%   - dataDirectory: Path to the folder containing '.mat' files with EEG data.
%   - visualizerDirectory: Path to the folder for additional visualization (not critical for functionality).
%   - fs: Sampling frequency of the EEG signal.
%   - patientId: Identifier for the patient (used for constructing the filename).
%
% OUTPUTS:
%   The function saves the detected dropout results to an Excel file and displays relevant information.
%--------------------------------------------------------------------------


function artifactResultsSaverResultsSaver(dataDirectory, visualizerDirectory, fs, patientId)

    % Validate input parameters
    if fs <= 0
        error('Invalid input parameters. Ensure fs, totalChannels, and N are positive values.');
    end
    
    % Get information about '.mat' files in the folder
    matFilesInfo = dir(fullfile(dataDirectory, '*.mat'));
    
    % Get the number of '.mat' files
    numMatFiles = length(matFilesInfo);
    finalArtifactsResults = zeros(numMatFiles, 4); % We collect time, maxDropouts, totalDropoutTime, dropoutPercentage
    
    for record = 1:numMatFiles
        cd(dataDirectory);
        fullEeg = load(sprintf('Seizure_%03d.mat', record));
        cd(visualizerDirectory); % Changes back to where code is
    
        fullEeg = fullEeg.data';
        time=[0:1/fs:(1/fs)*(length(fullEeg(1,:))-1)];
        verbose = false;
    
        [dropoutStartingPoints, dropoutEndingPoints, totalDropouts, totalDropoutTime, dropoutRatio] = detectAndCalculateDropouts(fullEeg, time, fs, verbose);
        disp(['Seizure: ', num2str(record), ', Total Dropouts: ', num2str(totalDropouts), ', Total Dropout Time: ', num2str(totalDropoutTime), ', Dropout Ratio: ', num2str(dropoutRatio)]);

        % Check if ratio exceeds 1, set corresponding value to -1
        if dropoutRatio > 1
            finalArtifactsResults(record, :) = -1;
            disp(["Bad result detected in recording: ", num2str(record)])
        else
            finalArtifactsResults(record, :) = [length(fullEeg(1,:)) / fs, totalDropouts, totalDropoutTime, dropoutRatio];
        end
    end
    
    % Construct the filename based on patientId
    filename = sprintf('Dropouts_of_Patient_%d.xlsx', str2double(patientId));
    cd(dataDirectory);
    
    % Save the matrix to the Excel file
    writematrix(finalArtifactsResults, filename, 'Sheet', 'Results');
    disp(['Matrix saved to file: ', filename]);
end

