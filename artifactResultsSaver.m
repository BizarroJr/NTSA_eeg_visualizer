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


function artifactResultsSaverResultsSaver(dataDirectory, visualizerDirectory, fs, windowSizeSeconds, patientId)

    % Validate input parameters
    if fs <= 0
        error('Invalid input parameters. Ensure fs, totalChannels, and N are positive values.');
    end
    
    % Get information about '.mat' files in the folder
    matFilesInfo = dir(fullfile(dataDirectory, '*.mat'));

    % Extract numbers from filenames
    fileNumbers = sscanf([matFilesInfo.name], 'Seizure_%d.mat');
    numMatFiles = max(fileNumbers);

    finalArtifactsResults = zeros(numMatFiles, 5); % We collect time, maxDropouts, totalDropoutTime, dropoutPercentage, flatline
    totalDropoutAffectedRecordings = 0;
    totalFlatlineAffectedRecordings = 0;
    totalMissingFiles = 0;
    
    for record = 1:numMatFiles
        cd(dataDirectory);
        try
            fullEeg = load(sprintf('Seizure_%03d.mat', record));
        catch
            totalMissingFiles = totalMissingFiles + 1;
            warning(['File ', record, ' does not exist. Skipping to the next iteration.']);
            continue;  % Skips to the next iteration of the loop
        end
        cd(visualizerDirectory); % Changes back to where code is
    
        fullEeg = fullEeg.data';
        time=[0:1/fs:(1/fs)*(length(fullEeg(1,:))-1)];
        verbose = false;
        
        % DROPOUTS
        %[dropoutStartingPoints, dropoutEndingPoints, totalDropouts, totalDropoutTime, dropoutRatio] = detectAndCalculateDropouts(fullEeg, time, fs, verbose);
        [dropoutStartingPoints, dropoutEndingPoints, totalDropouts, totalDropoutTime, dropoutRatio] = dropoutDetector(fullEeg, fs, verbose);
        disp(['Seizure: ', num2str(record), ', Total Dropouts: ', num2str(totalDropouts), ', Total Dropout Time: ', num2str(totalDropoutTime), ', Dropout Ratio: ', num2str(dropoutRatio)]);

        if totalDropouts > 0
            totalDropoutAffectedRecordings = totalDropoutAffectedRecordings + 1;
        end

        % Check if ratio exceeds 1, set corresponding value to -1
        if dropoutRatio > 1
            finalArtifactsResults(record, 1:4) = -1;
            disp(["Bad result detected in recording: ", num2str(record)])
        else
            finalArtifactsResults(record, 1:4) = [length(fullEeg(1,:)) / fs, totalDropouts, totalDropoutTime, dropoutRatio];
        end

        % FLATLINES
        [isFlatline, flatlineChannels] = flatlineDetector(fullEeg, fs, windowSizeSeconds, verbose);
        if isFlatline
            disp(['Flatline found on: ', num2str(flatlineChannels')]);
            totalFlatlineAffectedRecordings = totalFlatlineAffectedRecordings + 1;
        end
        finalArtifactsResults(record, 5) = isFlatline;


    end
    
    % Construct the filename based on patientId
    disp('*****************************************************************')
    disp(['Total dropout affected files: ', num2str(totalDropoutAffectedRecordings), ' out of ', num2str(numMatFiles-totalMissingFiles), ' (', num2str((totalDropoutAffectedRecordings/numMatFiles)*100), '%)']);
    disp(['Total flatline affected files: ', num2str(totalFlatlineAffectedRecordings), ' out of ', num2str(numMatFiles-totalMissingFiles), ' (', num2str((totalFlatlineAffectedRecordings/numMatFiles)*100), '%)']);
    disp(['Number of missing files: ', num2str(totalMissingFiles)]);
    filename = sprintf('Dropouts_of_Patient_%d_V3.xlsx', str2double(patientId));
    cd(dataDirectory);
    
    % Save the matrix to the Excel file
    writematrix(finalArtifactsResults, filename, 'Sheet', 'Results');
    disp(['Matrix saved to file: ', filename]);
    cd(visualizerDirectory);
end

