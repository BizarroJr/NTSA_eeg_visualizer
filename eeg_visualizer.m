clear;
clc;
close all;

%% Data under analysis
% STRONG SEIZURES
% patientId = "8";
% seizure = "47";
% patientId = "11";
% seizure = "57";
% patientId = "11";
% seizure = "113";
% patientId = "11";
% seizure = "74";
% patientId = "2";
% seizure = "12";
% patientId = "11";
% seizure = "269";

% MILD SEIZURES
% patientId = "11";
% seizure = "90";
% patientId = "7";
% seizure = "13";

patientId = "1";
seizure = "24";

user = "David"; % Change your name and define the way to load the eeg accordingly to your preferences

%% Load recording
switch user
    case 'Natalia'
        filePath = sprintf('C:\\Users\\Natalia\\Desktop\\practicas\\patientId %d\\Seizure_Data_%d\\Seizure_%03d.mat', patientId, patientId, seizureNumber);
        eeg1=load(filePath);
        baseDirectory = ""; % Directory containing the data and visualizer directory
        visualizerDirectory = pwd; % Directory containing the code for this visualizer (current folder)
        dataDirectory = pwd; % Directory containing the patient data (current folder)
        metricsAndMeasuresDirectory = visualizerDirectory + "Metrics_and_measures";
    case 'David'
        % This configuration assumes a main folder which has one code folder and
        % one data folder
        baseDirectory = "P:\WORK\David\UPF\TFM";
        visualizerDirectory = fullfile(baseDirectory, "EEG_visualizer\");
        metricsAndMeasuresDirectory = visualizerDirectory + "Metrics_and_measures";

        % Load data
        dataDirectory = fullfile(baseDirectory, "Data", "Seizure_Data_" + patientId);
        cd(dataDirectory);
        eeg1 = load(sprintf('Seizure_%03d.mat', str2double(seizure)));
        cd(visualizerDirectory);
    otherwise
        fprintf('No available configuration for this user\n');
end


%% KEYBOARD SHORTCUTS

%--------------------------------------------------------------------------
% KEYBOARD SHORTCUTS
%--------------------------------------------------------------------------
%   - Right Arrow (Button 29):
%     - Moves the display to the right by plotting the next segment.
%
%   - Left Arrow (Button 28):
%     - Moves the display to the left by plotting the previous segment.
%
%   - Up Arrow (Button 30):
%     - Zooms in on the display by plotting a shorter time interval.
%
%   - Down Arrow (Button 31):
%     - Zooms out on the display by plotting a longer time interval.
%
%   - Plus Key (+) (Button 43):
%     - Increases the amplitude of the EEG signal.
%
%   - Minus Key (-) (Button 45):
%     - Decreases the amplitude of the EEG signal.
%
%   - I Key (Button 105):
%     - Eliminates the y-axis limit, allowing the plot to auto-scale.
%
%   - C Key (Button 99):
%     - Plots the complete EEG signal.
%
%   - P Key (Button 112) + Left Mouse Click:
%     - Plots the periodogram of the selected channel.
%
%   - D Key (Button 100):
%     - Plots dropouts.
%
%   - S Key (Button 115):
%     - Saves all the artifacts found in the patient. (Dropouts)
%
%   - V Key (Button 118):
%     - Computes Phase Variability Measures. (V, M, S)
%
%--------------------------------------------------------------------------
%% Intialize visualizer

eegFull=eeg1.data';
fs= 400;
time=[0:1/fs:(1/fs)*(length(eegFull(1,:))-1)]; %Time vector is defined
eegFullOffset=offset(eegFull); %An offset is added to the signal

timeWindow=20; % Total seconds to be visualized
windowLength=timeWindow*fs; %Initial samples in the window

[M, N] = size(eegFull);
totalChannels = M;
channelLength = N;
nameChannel = cell(1, totalChannels);
for i = 1:totalChannels
    nameChannel{i} = ['ch' num2str(i, '%02d')];
end

% First window initialization
h = figure;
eegWindowOffset=eegFullOffset(:,1:windowLength); %The EEG to plot is defined as eegWindowOffset
timeCurrentWindow=time(1:windowLength);
plots(eegWindowOffset,timeCurrentWindow,patientId,seizure)

fig=0;
all=0; %Variable that states if the whole EEG is being plotted
stateSave=[-1,-1]; %List to save the state of the system
ampliary=false;
dropouts=false;

%% Stuff for phase-based measures
windowSizeSeconds = 10; % In seconds
overlapSeconds = 9;
filterType = 1; % 1-No filter, 2-LPF, 3-HPF
saveMetrics = false;
detrendAndUnwrap = true; % When plotting phase (press F)

filteredEegFullCentered = zeros(size(eegFull));
eegPhases = zeros(totalChannels, channelLength);
eegPhasesPadded = zeros(size(eegFull));

% Substract the mean to every channel
channelMeans = mean(eegFull, 2);
eegFullCentered = eegFull - channelMeans;

% Filter the channels
for i = 1:totalChannels
    channelData = eegFullCentered(i, :);
    filteredChannel = DV_BandPassFilter(channelData, fs, filterType);
    filteredEegFullCentered(i, :) = filteredChannel;
end

% Obtain number of total windows after windowing
windowSizeSamples = windowSizeSeconds * fs;
overlapSamples = fs * overlapSeconds;
totalWindows = floor((length(eegFull(1, :)) - windowSizeSamples) / (windowSizeSamples - overlapSamples)) + 1;

%% Different keyboard functions

while fig==0
    [x,y,button] = ginput(1);
    switch button
        case 102 % Display phase of signals (F)

            for i = 1:totalChannels
                hilbertTransform = hilbert(filteredEegFullCentered(i, :));
                if(detrendAndUnwrap)
                    phase = detrend(unwrap(atan2(imag(hilbertTransform), real(hilbertTransform))));
                else
                    phase = atan2(imag(hilbertTransform), real(hilbertTransform)); % Just the phase
                end
                eegPhases(i, :) = phase;
            end

            plots(offset(eegPhases), time, patientId, seizure)

            % Extra plots

            % % Plot of Hilbert Transform "Attractor" to see if phase is well
            % % defined
            % % Plot only the segment of uncutHilbertTransform between
            % % timeStart and timeEnd
            % timeStart = 16;
            % timeEnd = 17;
            % startIndex = round(timeStart * fs);
            % endIndex = round(timeEnd * fs);
            % segmentHilbertTransform = hilbertTransform(startIndex:endIndex);
            % figure;
            % plot(real(segmentHilbertTransform), imag(segmentHilbertTransform))
            % % plot(real(hilbertTransform), imag(hilbertTransform))
            % selectedChannel = 16;
            % title(['HT of Channel ' num2str(selectedChannel)]);
            % ylabel('$\mathrm{Im}(X_H)$', 'Interpreter', 'latex');
            % xlabel('$\mathrm{Re}(X_H)$', 'Interpreter', 'latex');
            % figure;
            % signal = filteredEegFullCentered(selectedChannel, :);
            % frequencies = (0:channelLength-1)*(fs/channelLength);
            % fft_signal = fft(signal);
            % plot(frequencies(1:channelLength/2), abs(fft_signal(1:channelLength/2)));
            % title(['FFT of Channel ' num2str(selectedChannel)]);
            % xlabel('Frequency (Hz)');
            % ylabel('Magnitude');

        case 118 % Gather phase variability for each window (V)
       
            % Obtention of limits for dynamic coloring of the metrics
            processedEEGs = zeros(size(eegFull, 1), size(eegFull, 2), 3);
            metricsClims = {};
            channelsV = zeros(totalChannels, totalWindows, 3);
            channelsM = zeros(totalChannels, totalWindows, 3);
            channelsS = zeros(totalChannels, totalWindows, 3);

            % 1-No filter, 2-LPF, 3-HPF
            for filterApplied=1:3
                cd(visualizerDirectory);
                % Filter data
                for i = 1:totalChannels
                    channelData = eegFullCentered(i, :);
                    processedEEGs(i, :, filterApplied) = DV_BandPassFilter(channelData, fs, filterApplied);
                end

                % Obtain metrics
                cd(metricsAndMeasuresDirectory);
                for i=1:totalChannels
                    hilbertTransform = hilbert(processedEEGs(i, :, filterApplied));
                    metrics = DV_EEGPhaseVelocityAnalyzer(fs, hilbertTransform(1, :), windowSizeSeconds, overlapSeconds);
                    channelsV(i, :, filterApplied) = metrics(1, :);
                    channelsM(i, :, filterApplied) = metrics(2, :);
                    channelsS(i, :, filterApplied) = metrics(3, :);
                end
                metricsV_1D = reshape(channelsV, [], 1);
                metricsM_1D = reshape(channelsM, [], 1);
                metricsS_1D = reshape(channelsS, [], 1);

                % Obtain limit percentiles from each metric
                lowerPercentile = 10;
                upperPercentile = 90;

                [minValue_V, maxValue_V] = deal(prctile(metricsV_1D, lowerPercentile), prctile(metricsV_1D, upperPercentile));
                [minValue_M, maxValue_M] = deal(prctile(metricsM_1D, lowerPercentile), prctile(metricsM_1D, upperPercentile));
                [minValue_S, maxValue_S] = deal(prctile(metricsS_1D, lowerPercentile), prctile(metricsS_1D, upperPercentile));
                metricsClims = { [minValue_V, maxValue_V], [minValue_M, maxValue_M], [minValue_S, maxValue_S] };
            end

            for filterApplied = 1:3
                metricMatrices = {channelsV(:, :, filterApplied), channelsM(:, :, filterApplied), channelsS(:, :, filterApplied)};
                DV_EEG_PBMPlotter(eegFull, fs, windowSizeSeconds, totalWindows, ...
                    overlapSeconds, metricMatrices, {'V', 'M', 'S'}, metricsClims, filterApplied);
            end
        
            disp("Phase variability calculated for all channels!")
            % metricMatrices = {channelsV(:, :, filterType), channelsM(:, :, filterType), channelsS(:, :, filterType)};
            % DV_EEG_PBMPlotter(eegFull, fs, windowSizeSeconds, totalWindows, ...
            %     overlapSeconds, metricMatrices, {'V', 'M', 'S'}, metricsClims, filterType);

            cd(visualizerDirectory);

        case 1 % Cursor click
            stateSave(end+1)=y;
            if stateSave(end-1)~=-1 & ampliary==false & stateSave(end-1)~=-3 %In case that we want to see only a part of the window (we need to click where we want the boundaries)
                ampliary=true;
                value1=stateSave(end);
                value2= stateSave(end-1);
                if value1>value2
                    value2=stateSave(end);
                    value1= stateSave(end-1);
                end
                ylim([ value1 value2]); %The portion is plotted
            end

            if stateSave(end-1)==-3 & ampliary==false %In case we want to plot the periodogram (we need to press P and click on the desired channel)
                marginDistanceBetweenChannels=300;
                maximums=max(eegWindowOffset,[],2)+marginDistanceBetweenChannels; %The maximums of each channel at the current window are searched and a certain margin is added because of the offset
                minimums=min(eegWindowOffset,[],2)-marginDistanceBetweenChannels; %The minimums of each channel at the current window are searched and a certain margin is substracted because of the offset
                ranges=[minimums maximums]; %The ranges of each channel at the current window are between the maximum and minimum of the signal
                selectedChannel=find(stateSave(end)>ranges(:,1) & stateSave(end)<ranges(:,2)); %We search the selected channel
                % periodogram(eegFull(channel2,:))
                [p, f] = periodogram(eegFull(selectedChannel, :), [], [], fs);
                plot(f,log(p))
                xlim('tight')
                xlabel('Frequency (Hz)')
                ylabel('Power')
                title(['Periodogram of ' + string(nameChannel(selectedChannel))]);
            end

        case 29 % Move to the right (--> arrow)
            all=0;
            stateSave(end+1)=-1;
            if all==0
                [eegWindowOffset,timeCurrentWindow]=actualizar_new(eegFullOffset,time,timeCurrentWindow,round(length(timeCurrentWindow)/2),round(length(timeCurrentWindow)/2),0); %The new eegFullOffset and time are defined
            end
            %New window plot
            if dropouts==false
                if ampliary==true %In case that we are only plotting some channels
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,[value1 value2]);
                end
                if ampliary==false
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure);
                end

            else
                if ampliary==true %In case that we are only plotting some channels
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,dropoutStartingPoints(indexmaximum,:),dropoutEndingPoints(indexmaximum,:),[value1 value2]);
                end
                if ampliary==false
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,dropoutStartingPoints(indexmaximum,:),dropoutEndingPoints(indexmaximum,:));
                end
            end

        case 28 % Move to the left (<-- arrow)
            all=0;
            stateSave(end+1)=-1;
            if all==0
                [eegWindowOffset,timeCurrentWindow]=actualizar_new(eegFullOffset,time,timeCurrentWindow,-round(length(timeCurrentWindow)/2),-round(length(timeCurrentWindow)/2),0);
            end

            %New window plot
            if dropouts==false
                if ampliary==true %In case that we are only plotting some channels
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,[value1 value2]);
                end
                if ampliary==false
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure);
                end

            else
                if ampliary==true %In case that we are only plotting some channels
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,dropoutStartingPoints(indexmaximum,:),dropoutEndingPoints(indexmaximum,:),[value1 value2]);
                end
                if ampliary==false
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,dropoutStartingPoints(indexmaximum,:),dropoutEndingPoints(indexmaximum,:));
                end
            end

        case 30 % Zoom in (up arrow)
            stateSave(end+1)=-1;
            maxZoomin=2000;
            if length(timeCurrentWindow)<maxZoomin %We set a maximum to zoom in
                display('Limit of zoom in has been reached')
            end
            if length(timeCurrentWindow)>=maxZoomin
                samplesRemoved=1000; %Samples removed from the sides to zoom in
                [eegWindowOffset,timeCurrentWindow]=actualizar_new(eegFullOffset,time,timeCurrentWindow,samplesRemoved,-samplesRemoved);
                %New window plot
                if dropouts==false
                    if ampliary==true %In case that we are only plotting some channels
                        plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,[value1 value2]);
                    end
                    if ampliary==false
                        plots(eegWindowOffset,timeCurrentWindow,patientId,seizure);
                    end

                else
                    if ampliary==true %In case that we are only plotting some channels
                        plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,dropoutStartingPoints(indexmaximum,:),dropoutEndingPoints(indexmaximum,:),[value1 value2]);
                    end
                    if ampliary==false
                        plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,dropoutStartingPoints(indexmaximum,:),dropoutEndingPoints(indexmaximum,:));
                    end
                end
            end

        case 31 % Zoom out (down arrow)
            stateSave(end+1)=-1;
            samplesAdded=1000; %Samples added to the sides to zoom out
            [eegWindowOffset,timeCurrentWindow]=actualizar_new(eegFullOffset,time,timeCurrentWindow,-samplesAdded,samplesAdded,1);
            %New window plot
            if dropouts==false
                if ampliary==true %In case that we are only plotting some channels
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,[value1 value2]);
                end
                if ampliary==false
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure);
                end

            else
                if ampliary==true %In case that we are only plotting some channels
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,dropoutStartingPoints(indexmaximum,:),dropoutEndingPoints(indexmaximum,:),[value1 value2]);
                end
                if ampliary==false
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,dropoutStartingPoints(indexmaximum,:),dropoutEndingPoints(indexmaximum,:));
                end
            end

        case 43 % Increase amplitude (+)
            stateSave(end+1)=-1;
            factorIncrease=1.5;
            [eegFull,eegFullOffset,eegWindowOffset,timeCurrentWindow]=ampliar_amplitud(eegFull,time,timeCurrentWindow,factorIncrease);
            if dropouts==false
                if ampliary==true %In case that we are only plotting some channels
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,[value1 value2]);
                end
                if ampliary==false
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure);
                end

            else
                if ampliary==true %In case that we are only plotting some channels
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,dropoutStartingPoints(indexmaximum,:),dropoutEndingPoints(indexmaximum,:),[value1 value2]);
                end
                if ampliary==false
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,dropoutStartingPoints(indexmaximum,:),dropoutEndingPoints(indexmaximum,:));
                end
            end

        case 45 % Decrease amplitude (-)
            stateSave(end+1)=-1;
            factorDecrease=0.5;
            [eegFull,eeg_new,eegWindowOffset,timeCurrentWindow]=ampliar_amplitud(eegFull,time,timeCurrentWindow,factorDecrease);%The new EEG contains the changes in amplitude
            if dropouts==false
                if ampliary==true %In case that we are only plotting some channels
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,[value1 value2]);
                end
                if ampliary==false
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure);
                end
            else
                if ampliary==true %In case that we are only plotting some channels
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,dropoutStartingPoints(indexmaximum,:),dropoutEndingPoints(indexmaximum,:),[value1 value2]);
                end
                if ampliary==false
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,dropoutStartingPoints(indexmaximum,:),dropoutEndingPoints(indexmaximum,:));
                end
            end

        case 105  %Eliminate the ylim --> the ampliary (I)
            stateSave(end+1)=-1;
            if ampliary==true
                ampliary=false;
                ylim([ 0 max(max(eegWindowOffset))+500]); %The new ylim is setted
            end

        case 99 % Plot the EEG complete (C)
            stateSave(end+1)=-1;
            all=1;
            if dropouts==false
                if ampliary==true %In case that we are only plotting some channels
                    plots(eegFullOffset,time,patientId,seizure,[value1 value2]);
                end
                if ampliary==false
                    plots(eegFullOffset,time,patientId,seizure);
                end

            else
                if ampliary==true %In case that we are only plotting some channels
                    plots(eegFullOffset,time,patientId,seizure,dropoutStartingPoints(indexmaximum,:),dropoutEndingPoints(indexmaximum,:),[value1 value2]);
                end
                if ampliary==false
                    plots(eegFullOffset,time,patientId,seizure,dropoutStartingPoints(indexmaximum,:),dropoutEndingPoints(indexmaximum,:));
                end
            end

        case 112 %periodogram (P + click on the channel that you want)
            stateSave(end+1)=-3;

        case 114 % Return to the original amplitudes (R)
            % %Return the eegFullOffset variables to the original ones
            % eeg1=load('C:\Users\Natalia\Desktop\practicas\patientId 13\Seizure_Data_13\Seizure_070.mat');
            eegFull= eeg1.data';
            eegFullOffset=offset(eegFull);
            [eegWindowOffset,timeCurrentWindow]=actualizar_new(eegFullOffset,time,timeCurrentWindow,0,0,0);
            %New window plot
            if dropouts==false
                if ampliary==true %In case that we are only plotting some channels
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,[value1 value2]);
                end
                if ampliary==false
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure);
                end
            else
                if ampliary==true %In case that we are only plotting some channels
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,dropoutStartingPoints(indexmaximum,:),dropoutEndingPoints(indexmaximum,:),[value1 value2]);
                end
                if ampliary==false
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,dropoutStartingPoints(indexmaximum,:),dropoutEndingPoints(indexmaximum,:));
                end
            end

        case 100 % In case that we want to see the dropouts and a report about them (D)
            dropouts = true;
            verbose = true;
            windowSizeSeconds = 20;

            % [dropoutStartingPoints, dropoutEndingPoints] = detectAndCalculateDropouts(eegFull, time, fs, verbose);
            [dropoutStartingPoints, dropoutEndingPoints] = dropoutDetector(eegFull, fs, verbose);
            [maximum,indexmaximum] = max(sum(dropoutStartingPoints,2));
            isFlatline = flatlineDetector(eegFull, fs, windowSizeSeconds, verbose);

            %The plot with the dropouts is generated
            % if dropouts==false
            %     if ampliary==true %In case that we are only plotting some channels
            %         plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,[value1 value2]);
            %     end
            %     if ampliary==false
            %         plots(eegWindowOffset,timeCurrentWindow,patientId,seizure);
            %     end
            % else

            if ampliary==true %In case that we are only plotting some channels
                plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,dropoutStartingPoints(indexmaximum,:),dropoutEndingPoints(indexmaximum,:),[value1 value2]);
            end
            if ampliary==false
                plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,dropoutStartingPoints(indexmaximum,:),dropoutEndingPoints(indexmaximum,:));
            end
            % end

        case 115 % Save the artifacts for all the recordings of the patient (S)
            windowSizeSeconds = 10; % In seconds
             DV_ArtifactResultsSaver(dataDirectory, visualizerDirectory, fs, windowSizeSeconds, patientId)

        case 101 % Eliminate the dropouts in the plot (E)
            dropouts=false;
            if all==true
                if ampliary==true %In case that we are only plotting some channels
                    plots(eegFullOffset,time,patientId,seizure,[value1 value2]);
                end
                if ampliary==false
                    plots(eegFullOffset,time,patientId,seizure);
                end
            else
                if ampliary==true %In case that we are only plotting some channels
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,[value1 value2]);
                end
                if ampliary==false
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure);
                end
            end

    end
end

% NOTES:
%     - eegFullOffset: EEG complete with offset
%     - eeg1: Struct that contains the EEG signals
%     - eegFull: EEG complete without offset
%     - eegWindowOffset: EEG of the current window with offset
%     - time: Complete time vector
%     - timeCurrentWindow: Current window time
