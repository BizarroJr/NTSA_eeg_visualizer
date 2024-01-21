clear;
clc;
close all;

%% Data under analysis
patientId = "11";
seizure = "53";
user = "David"; % Change your name and define the way to load the eeg accordingly to your preferences

%% Load recording
switch user
    case 'Natalia'
        filePath = sprintf('C:\\Users\\Natalia\\Desktop\\practicas\\patientId %d\\Seizure_Data_%d\\Seizure_%03d.mat', patientId, patientId, seizureNumber);
        eeg1=load(filePath);
        baseDirectory = ""; % Directory containing the data and visualizer directory
        visualizerDirectory = pwd; % Directory containing the code for this visualizer (current folder)
        dataDirectory = pwd; % Directory containing the patient data (current folder)
    case 'David'
        % This configuration assumes a main folder which has one code folder and
        % one data folder
        baseDirectory = "P:\WORK\David\UPF\TFM";
        visualizerDirectory = fullfile(baseDirectory, "EEG_visualizer\");

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
save=[-1,-1]; %List to save the state of the system
ampliary=false;
dropouts=false;
while fig==0
    [x,y,button] = ginput(1);
    button
    switch button
        case 1 % Cursor click
            save(end+1)=y;
            if save(end-1)~=-1 & ampliary==false & save(end-1)~=-3 %In case that we want to see only a part of the window (we need to click where we want the boundaries)
                ampliary=true;
                value1=save(end);
                value2= save(end-1);
                if value1>value2
                    value2=save(end);
                    value1= save(end-1);
                end
                ylim([ value1 value2]); %The portion is plotted
            end

            if save(end-1)==-3 & ampliary==false %In case we want to plot the periodogram (we need to press P and click on the desired channel)
                marginDistanceBetweenChannels=300;
                maximums=max(eegWindowOffset,[],2)+marginDistanceBetweenChannels; %The maximums of each channel at the current window are searched and a certain margin is added because of the offset
                minimums=min(eegWindowOffset,[],2)-marginDistanceBetweenChannels; %The minimums of each channel at the current window are searched and a certain margin is substracted because of the offset
                ranges=[minimums maximums]; %The ranges of each channel at the current window are between the maximum and minimum of the signal
                selectedChannel=find(save(end)>ranges(:,1) & save(end)<ranges(:,2)); %We search the selected channel
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
            save(end+1)=-1;
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
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,dropoutStartingPoints,dropoutEndingPoints,[value1 value2]);
                end
                if ampliary==false
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,dropoutStartingPoints,dropoutEndingPoints);
                end
            end

        case 28 % Move to the left (<-- arrow)
            all=0;
            save(end+1)=-1;
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
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,dropoutStartingPoints,dropoutEndingPoints,[value1 value2]);
                end
                if ampliary==false
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,dropoutStartingPoints,dropoutEndingPoints);
                end
            end
 
        case 30 % Zoom in (up arrow)
            save(end+1)=-1;
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
                        plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,dropoutStartingPoints,dropoutEndingPoints,[value1 value2]);
                    end
                    if ampliary==false
                        plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,dropoutStartingPoints,dropoutEndingPoints);
                    end
                end
            end

        case 31 % Zoom out (down arrow)
            save(end+1)=-1;
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
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,dropoutStartingPoints,dropoutEndingPoints,[value1 value2]);
                end
                if ampliary==false
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,dropoutStartingPoints,dropoutEndingPoints);
                end
            end

        case 43 % Increase amplitude (+)
            save(end+1)=-1;
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
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,dropoutStartingPoints,dropoutEndingPoints,[value1 value2]);
                end
                if ampliary==false
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,dropoutStartingPoints,dropoutEndingPoints);
                end
            end

        case 45 % Decrease amplitude (-)
            save(end+1)=-1;
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
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,dropoutStartingPoints,dropoutEndingPoints,[value1 value2]);
                end
                if ampliary==false
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,dropoutStartingPoints,dropoutEndingPoints);
                end
            end

        case 105  %Eliminate the ylim --> the ampliary (I)
            save(end+1)=-1;
            if ampliary==true
                ampliary=false;
                ylim([ 0 max(max(eegWindowOffset))+500]); %The new ylim is setted
            end

        case 99 % Plot the EEG complete (C)
            save(end+1)=-1;
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
                    plots(eegFullOffset,time,patientId,seizure,dropoutStartingPoints,dropoutEndingPoints,[value1 value2]);
                end
                if ampliary==false
                    plots(eegFullOffset,time,patientId,seizure,dropoutStartingPoints,dropoutEndingPoints);
                end
            end

        case 112 %periodogram (P + click on the channel that you want)
            save(end+1)=-3;

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
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,dropoutStartingPoints,dropoutEndingPoints,[value1 value2]);
                end
                if ampliary==false
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,dropoutStartingPoints,dropoutEndingPoints);
                end
            end

        case 100 % In case that we want to see the dropouts and a report about them (D)
            dropouts = true;
            verbose = true;
            [dropoutStartingPoints, dropoutEndingPoints] = detectAndCalculateDropouts(eegFull, time, fs, verbose);
           
            %The plot with the dropouts is generated
            if dropouts==false
                if ampliary==true %In case that we are only plotting some channels
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,[value1 value2]);
                end
                if ampliary==false
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure);
                end
            else
                if ampliary==true %In case that we are only plotting some channels
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,dropoutStartingPoints,dropoutEndingPoints,[value1 value2]);
                end
                if ampliary==false
                    plots(eegWindowOffset,timeCurrentWindow,patientId,seizure,dropoutStartingPoints,dropoutEndingPoints);
                end
            end

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

        case 115 % Save the artifacts for all the recordings of the patient (S)
            artifactResultsSaver(dataDirectory, visualizerDirectory, fs, patientId)
    end
end

% NOTES:
%     - eegFullOffset: EEG complete with offset
%     - eeg1: Struct that contains the EEG signals
%     - eegFull: EEG complete without offset
%     - eegWindowOffset: EEG of the current window with offset
%     - time: Complete time vector
%     - timeCurrentWindow: Current window time
