clear;
clc;
close all;

%% Data under analysis
patient = "11";
seizure = "002 ";
user = "David"; % Change your name and define the way to load the eeg accordingly to your preferences

%% Load recording
switch user
    case 'Natalia'
        filePath = sprintf('C:\\Users\\Natalia\\Desktop\\practicas\\patientId %d\\Seizure_Data_%d\\Seizure_%03d.mat', patient, patient, seizureNumber);
        eeg1=load(filePath);
        baseDirectory = ""; % Directory containing the data and visualizer directory
        visualizerDirectory = pwd; % Directory containing the code for this visualizer (current folder)
        dataDirectory = pwd; % Directory containing the patient data (current folder)
    case 'David'
        % This configuration assumes a main folder which has one code folder and
        % one data folder
        baseDirectory = "P:\WORK\David\UPF\TFM";
        visualizerDirectory = fullfile(baseDirectory, "eeg visualizator improved with dropouts\");

        % Load data
        dataDirectory = fullfile(baseDirectory, "Data", "Seizure_Data_" + patient);
        cd(dataDirectory);
        eeg1 = load(sprintf('Seizure_%03d.mat', str2double(seizure)));
        cd(visualizerDirectory);
    otherwise
        fprintf('No available configuration for this user\n');
end


eegFull=eeg1.data';
fs= 400;
time=[0:1/fs:(1/fs)*(length(eegFull(1,:))-1)]; %Time vector is defined
eegFullOffset=offset(eegFull); %An offset is added to the signal 

timeWindow=20;
lenwind=timeWindow*fs; %Initial samples in the window

%THE FIRST WINDOW IS DEFINED
h = figure;
eegWindowOffset=eegFullOffset(:,1:lenwind); %The EEG to plot is defined as eegWindowOffset
timeCurrentWindow=time(1:lenwind);
plots(eegWindowOffset,timeCurrentWindow,patient,seizure)

fig=0;
all=0; %Variable that states if the whole EEG is being plotted
save=[-1,-1]; %List to save the state of the system
ampliary=false;
dropouts=false;
while fig==0
    [x,y,button] = ginput(1);
    switch button
        case 1 %Cursor click
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
                channel2=find(save(end)>ranges(:,1) & save(end)<ranges(:,2)); %We search the selected channel
                periodogram(eegFull(channel2,:))
                title(('Peridiogram of channel '+string(name_channel(channel2))))
            end
        
        case 29 %move to the right (--> arrow)
           all=0;
           save(end+1)=-1;
           if all==0
               [eegWindowOffset,timeCurrentWindow]=actualizar_new(eegFullOffset,time,timeCurrentWindow,round(length(timeCurrentWindow)/2),round(length(timeCurrentWindow)/2),0); %The new eegFullOffset and time are defined
           end
           %New window plot
            if dropouts==false
                if ampliary==true %In case that we are only plotting some channels
                     plots(eegWindowOffset,timeCurrentWindow,patient,seizure,[value1 value2]);
                end
                if ampliary==false
                     plots(eegWindowOffset,timeCurrentWindow,patient,seizure);
                end
    
            else
                if ampliary==true %In case that we are only plotting some channels
                      plots(eegWindowOffset,timeCurrentWindow,patient,seizure,definitiveDropoutStartingPoints,definitiveDropoutEndingPoints,[value1 value2]);
                end
                if ampliary==false
                      plots(eegWindowOffset,timeCurrentWindow,patient,seizure,definitiveDropoutStartingPoints,definitiveDropoutEndingPoints);
                end
            end
               
            case 28 %move to the left (<-- arrow)
               all=0;
               save(end+1)=-1;
               if all==0
                [eegWindowOffset,timeCurrentWindow]=actualizar_new(eegFullOffset,time,timeCurrentWindow,-round(length(timeCurrentWindow)/2),-round(length(timeCurrentWindow)/2),0);
               end
               %New window plot
                if dropouts==false
                    if ampliary==true %In case that we are only plotting some channels
                         plots(eegWindowOffset,timeCurrentWindow,patient,seizure,[value1 value2]);
                    end
                    if ampliary==false
                         plots(eegWindowOffset,timeCurrentWindow,patient,seizure);
                    end
        
                    else
                        if ampliary==true %In case that we are only plotting some channels
                              plots(eegWindowOffset,timeCurrentWindow,patient,seizure,definitiveDropoutStartingPoints,definitiveDropoutEndingPoints,[value1 value2]);
                        end
                        if ampliary==false
                              plots(eegWindowOffset,timeCurrentWindow,patient,seizure,definitiveDropoutStartingPoints,definitiveDropoutEndingPoints);
                        end
                 end
               

        case 30 %zoom in (up arrow)
            
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
                         plots(eegWindowOffset,timeCurrentWindow,patient,seizure,[value1 value2]);
                    end
                    if ampliary==false
                         plots(eegWindowOffset,timeCurrentWindow,patient,seizure);
                    end
        
                    else
                        if ampliary==true %In case that we are only plotting some channels
                              plots(eegWindowOffset,timeCurrentWindow,patient,seizure,definitiveDropoutStartingPoints,definitiveDropoutEndingPoints,[value1 value2]);
                        end
                        if ampliary==false
                              plots(eegWindowOffset,timeCurrentWindow,patient,seizure,definitiveDropoutStartingPoints,definitiveDropoutEndingPoints);
                        end
                end
            end

        case 31 %zoom out (down arrow)
            save(end+1)=-1;
            samplesAdded=1000; %Samples added to the sides to zoom out
            [eegWindowOffset,timeCurrentWindow]=actualizar_new(eegFullOffset,time,timeCurrentWindow,-samplesAdded,samplesAdded,1);
            %New window plot
            if dropouts==false
                    if ampliary==true %In case that we are only plotting some channels
                         plots(eegWindowOffset,timeCurrentWindow,patient,seizure,[value1 value2]);
                    end
                    if ampliary==false
                         plots(eegWindowOffset,timeCurrentWindow,patient,seizure);
                    end
        
                    else
                        if ampliary==true %In case that we are only plotting some channels
                              plots(eegWindowOffset,timeCurrentWindow,patient,seizure,definitiveDropoutStartingPoints,definitiveDropoutEndingPoints,[value1 value2]);
                        end
                        if ampliary==false
                              plots(eegWindowOffset,timeCurrentWindow,patient,seizure,definitiveDropoutStartingPoints,definitiveDropoutEndingPoints);
                        end
             end
            
        case 43 %increase amplitude (+)
            save(end+1)=-1;
            factorIncrease=1.5;
            [eegFull,eegFullOffset,eegWindowOffset,timeCurrentWindow]=ampliar_amplitud(eegFull,time,timeCurrentWindow,factorIncrease); 
            if dropouts==false
                    if ampliary==true %In case that we are only plotting some channels
                         plots(eegWindowOffset,timeCurrentWindow,patient,seizure,[value1 value2]);
                    end
                    if ampliary==false
                         plots(eegWindowOffset,timeCurrentWindow,patient,seizure);
                    end
        
                    else
                        if ampliary==true %In case that we are only plotting some channels
                              plots(eegWindowOffset,timeCurrentWindow,patient,seizure,definitiveDropoutStartingPoints,definitiveDropoutEndingPoints,[value1 value2]);
                        end
                        if ampliary==false
                              plots(eegWindowOffset,timeCurrentWindow,patient,seizure,definitiveDropoutStartingPoints,definitiveDropoutEndingPoints);
                        end
             end
            
        case 45 %decrease amplitude (-)
            save(end+1)=-1;
            factorDecrease=0.5;
            [eegFull,eeg_new,eegWindowOffset,timeCurrentWindow]=ampliar_amplitud(eegFull,time,timeCurrentWindow,factorDecrease);%The new EEG contains the changes in amplitude
            if dropouts==false
                    if ampliary==true %In case that we are only plotting some channels
                         plots(eegWindowOffset,timeCurrentWindow,patient,seizure,[value1 value2]);
                    end
                    if ampliary==false
                         plots(eegWindowOffset,timeCurrentWindow,patient,seizure);
                    end
             else
                    if ampliary==true %In case that we are only plotting some channels
                          plots(eegWindowOffset,timeCurrentWindow,patient,seizure,definitiveDropoutStartingPoints,definitiveDropoutEndingPoints,[value1 value2]);
                    end
                    if ampliary==false
                          plots(eegWindowOffset,timeCurrentWindow,patient,seizure,definitiveDropoutStartingPoints,definitiveDropoutEndingPoints);
                    end
             end

        case 105 %Eliminate the ylim --> the ampliary (I)
            save(end+1)=-1;
            if ampliary==true
            ampliary=false;
            ylim([ 0 max(max(eegWindowOffset))+500]); %The new ylim is setted
            end

        case 99 %Plot the EEG complete (C)
            save(end+1)=-1;
            all=1;
            if dropouts==false
                if ampliary==true %In case that we are only plotting some channels
                     plots(eegFullOffset,time,patient,seizure,[value1 value2]);
                end
                if ampliary==false
                     plots(eegFullOffset,time,patient,seizure);
                end
        
            else
                if ampliary==true %In case that we are only plotting some channels
                      plots(eegFullOffset,time,patient,seizure,definitiveDropoutStartingPoints,definitiveDropoutEndingPoints,[value1 value2]);
                end
                if ampliary==false
                      plots(eegFullOffset,time,patient,seizure,definitiveDropoutStartingPoints,definitiveDropoutEndingPoints);
                end
             end

        case 112 %periodogram (P + click on the channel that you want)
            save(end+1)=-3;

        case 114 %Return to the original amplitudes (R)
            %Return the eegFullOffset variables to the original ones
            eeg1=load('C:\Users\Natalia\Desktop\practicas\patient 13\Seizure_Data_13\Seizure_070.mat');
            eegFull= eeg1.data';
            eegFullOffset=offset(eegFull);
            [eegWindowOffset,timeCurrentWindow]=actualizar_new(eegFullOffset,time,timeCurrentWindow,0,0,0);
            %New window plot
            if dropouts==false
                    if ampliary==true %In case that we are only plotting some channels
                         plots(eegWindowOffset,timeCurrentWindow,patient,seizure,[value1 value2]);
                    end
                    if ampliary==false
                         plots(eegWindowOffset,timeCurrentWindow,patient,seizure);
                    end
             else
                    if ampliary==true %In case that we are only plotting some channels
                          plots(eegWindowOffset,timeCurrentWindow,patient,seizure,definitiveDropoutStartingPoints,definitiveDropoutEndingPoints,[value1 value2]);
                    end
                    if ampliary==false
                          plots(eegWindowOffset,timeCurrentWindow,patient,seizure,definitiveDropoutStartingPoints,definitiveDropoutEndingPoints);
                    end
             end
        case 100 %In case that we want to see the dropouts and a report about them (D)
            dropouts=true;
            thresholdDistPeaks=180;
            dropoutStartingPoints=zeros(16,1000); %Preallocate memory
            dropoutEndingPoints=zeros(16,1000); %Preallocate memory
            for i=1:16
                [peakValues,peakLocations]=findpeaks(eegFull(i,:)); %Find the peaks of the EEG
                if peakLocations(1)~=1 %There is a peak added in location 1, in case there is a dropout at the beginning
                    peakLocations=[1 peakLocations];
                end
                if peakLocations(end)~=length(eegFull(i,:)) %There is a peak added in last location, in case there is a dropout at the end
                    peakLocations=[peakLocations length(eegFull(i,:))];
                end
                differences = diff(peakLocations); %Look at the samples difference between peaks
                peakLocationsDropoutDiff = find(differences > thresholdDistPeaks); %If there is a long time without peaks a dropout occurs
                
                %Let's filter some peaks inside the dropout
                dropoutStartTimes=time(peakLocations(peakLocationsDropoutDiff)+1); %Times in which the dropout starts
                dropoutEndTimes=time(peakLocations(peakLocationsDropoutDiff+1)-1); %Times in which the dropout ends
                if length(dropoutStartTimes)>0
                    dropoutStartTimes_=[dropoutStartTimes [0]]; %A 0 is added to mathematical operations 
                    dropoutEndTimes_=[[0] dropoutEndTimes]; %A 0 is added to mathematical operations
                    diffTimes=abs(dropoutStartTimes_-dropoutEndTimes_); %The differences in time between the beginning of the new dropout and the final of the last dropout is computed
                    peakLocationSameDropout=find(diffTimes<(4*(1/fs))); %If the difference is less than 4 samples, the new dropout is eliminated
                    if length(peakLocationSameDropout)>0
                        if peakLocationSameDropout(1)==1 %If the dropout is in the beginning a superposition cannot occur
                            peakLocationSameDropout(1)=[];
                        end
                    end
                    if length(peakLocationSameDropout)>0
                        if peakLocationSameDropout(end)==length(eegFull(1,:))
                            peakLocationSameDropout(end)=[];
                        end
                    end
                    definitiveDropoutStartTimes=dropoutStartTimes;
                    definitiveDropoutStartTimes(peakLocationSameDropout)=[];
                    definitiveDropoutEndTimes=dropoutEndTimes;
                    definitiveDropoutEndTimes(peakLocationSameDropout-1)=[];
                else
                    definitiveDropoutStartTimes=[];
                    definitiveDropoutEndTimes=[];
                end
                dropoutStartingPoints(i,1:length(definitiveDropoutStartTimes))=definitiveDropoutStartTimes;
                dropoutEndingPoints(i,1:length(definitiveDropoutEndTimes))=definitiveDropoutEndTimes;
            end
           
            max1=find(max(sum(dropoutStartingPoints,2)));%Let's find one channel with all the dropouts
            dropoutIndices=find(dropoutStartingPoints(max1,:)~=0); %Let's find which are positions of dropouts
            definitiveDropoutStartingPoints=zeros(1,length(dropoutIndices)); %definitiveDropoutStartingPoints will contain the times in which the dropouts start
            definitiveDropoutEndingPoints=zeros(1,length(dropoutIndices)); %definitiveDropoutEndingPoints will contain the times in which the dropouts ends
            for k=1:length(dropoutIndices)
                i=dropoutIndices(k);
                dpStartPoint=dropoutStartingPoints(max1,i); %The position of the beginning of the different dropout is searched
                dpEndPoint=dropoutEndingPoints(max1,i); %The position of the end of the different dropout is searched
                [inddc1,indds1]=find(dropoutStartingPoints>(dpStartPoint-0.5) & dropoutStartingPoints<(dpStartPoint+0.5) & dropoutStartingPoints~=0); %Let's find the positions of similar values
                [inddc2,indds2]=find(dropoutEndingPoints>(dpEndPoint-0.5) & dropoutEndingPoints<(dpEndPoint+0.5)& dropoutEndingPoints~=0); %Let's find the positions of similar values
                count=0; %This counter is generated since there is a possibility in which one dropout is not found in all the channels
                val1=0;
                val2=0;
                %A mean is performed taking into account that all dropouts
                %start and finish at the same point
                for kk=1:length(inddc1)
                    j=inddc1(kk);
                    val1=(400*dropoutStartingPoints(j,indds1(count+1,1)))+val1+1;
                    val2=(400*dropoutEndingPoints(j,indds2(count+1,1)))+val2+1;
                    count=count+1;
                end
                definitiveDropoutStartingPoints(i)= time(fix(val1/count));
                definitiveDropoutEndingPoints(i)=time(fix(val2/count));
            end

            %The important values are displayed
            fprintf('<strong>Each channel contains N dropouts:</strong>\n');
            fprintf(string(length(definitiveDropoutStartingPoints))+' dropouts\n');
            fprintf('<strong>The percentage of dropouts in the whole signal is:</strong>\n');
            dropoutsamplestotal=16*sum(400*(definitiveDropoutEndingPoints-definitiveDropoutStartingPoints));
            [M,N]=size(eegFull);
            percen=(dropoutsamplestotal/(M*N))*100;
            disp(string(percen)+'%');

            %The plot with the dropouts is generated
            if dropouts==false
                    if ampliary==true %In case that we are only plotting some channels
                         plots(eegWindowOffset,timeCurrentWindow,patient,seizure,[value1 value2]);
                    end
                    if ampliary==false
                         plots(eegWindowOffset,timeCurrentWindow,patient,seizure);
                    end
             else
                    if ampliary==true %In case that we are only plotting some channels
                          plots(eegWindowOffset,timeCurrentWindow,patient,seizure,definitiveDropoutStartingPoints,definitiveDropoutEndingPoints,[value1 value2]);
                    end
                    if ampliary==false
                          plots(eegWindowOffset,timeCurrentWindow,patient,seizure,definitiveDropoutStartingPoints,definitiveDropoutEndingPoints);
                    end
             end

        case 101 %Eliminate the dropouts in the plot (E)
            dropouts=false;
            if all==True
                if ampliary==true %In case that we are only plotting some channels
                     plots(eegFullOffset,time,patient,seizure,[value1 value2]);
                end
                if ampliary==false
                     plots(eegFullOffset,time,patient,seizure);
                end
            else
                if ampliary==true %In case that we are only plotting some channels
                     plots(eegWindowOffset,timeCurrentWindow,patient,seizure,[value1 value2]);
                end
                if ampliary==false
                     plots(eegWindowOffset,timeCurrentWindow,patient,seizure);
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
