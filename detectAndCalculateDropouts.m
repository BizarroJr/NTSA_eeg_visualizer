%--------------------------------------------------------------------------
% detectAndCalculateDropouts: Identifies and calculates dropout regions in an EEG signal.
%--------------------------------------------------------------------------
% DESCRIPTION:
%   The function detects dropout regions in an EEG signal based on the
%   detection of peaks of the signal. If peaks are widely separated (established by a threshol)
%
% INPUTS:
%   - eegFull: The EEG signal under consideration.
%   - time: Time vector corresponding to the EEG signal.
%   - fs: The sampling frequency of the EEG signal.
%   - verbose: A logical value indicating whether to display
%     dropout information. Default is true.
%
% OUTPUTS:
%   - dropoutStartingPoints: Time points marking the start of each identified dropout region.
%   - dropoutEndingPoints: Time points marking the end of each identified dropout region.
%   - totalDropouts: Total number of identified dropout regions.
%   - totalDropoutTime: Total duration of identified dropout regions in seconds.
%   - dropoutRatio: Ratio of signal time occupied by dropouts.
%
%--------------------------------------------------------------------------

function [dropoutStartingPoints, dropoutEndingPoints, totalDropouts, totalDropoutTime, dropoutRatio] = ...
    detectAndCalculateDropouts(eegFull, time, fs, verbose)

    % Initialize variables
    [totalChannels, totalSamples] = size(eegFull);
    thresholdDistanceBetweenPeaks = 180;
    dropoutStartPeaks = zeros(totalChannels, 1000); % 1000 given to preallocate memory and give margin if there are a lot of dropouts
    dropoutEndPeaks = zeros(totalChannels, 1000);

    % Detect dropouts for each channel
    for i = 1:totalChannels
                [peakValues,peakLocations]=findpeaks(eegFull(i,:)); %Find the peaks of the EEG
                if peakLocations(1)~=1 %There is a peak added in location 1, in case there is a dropout at the beginning
                    peakLocations=[1 peakLocations];
                end
                if peakLocations(end)~=length(eegFull(i,:)) %There is a peak added in last location, in case there is a dropout at the end
                    peakLocations=[peakLocations length(eegFull(i,:))];
                end
                differences = diff(peakLocations); %Look at the samples difference between peaks
                peakLocationsDropoutDiff = find(differences > thresholdDistanceBetweenPeaks); %If there is a long time without peaks a dropout occurs
                
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
           
            maxDropoutChannel=find(max(sum(dropoutStartingPoints,2)));%Let's find one channel with all the dropouts
            dropoutIndices=find(dropoutStartingPoints(maxDropoutChannel,:)~=0); %Let's find which are positions of dropouts
            definitiveDropoutStartingPoints=zeros(1,length(dropoutIndices)); %definitiveDropoutStartingPoints will contain the times in which the dropouts start
            definitiveDropoutEndingPoints=zeros(1,length(dropoutIndices)); %definitiveDropoutEndingPoints will contain the times in which the dropouts ends
            for k=1:length(dropoutIndices)
                i=dropoutIndices(k);
                dpStartPoint=dropoutStartingPoints(maxDropoutChannel,i); %The position of the beginning of the different dropout is searched
                dpEndPoint=dropoutEndingPoints(maxDropoutChannel,i); %The position of the end of the different dropout is searched
                [inddc1,indds1]=find(dropoutStartingPoints>(dpStartPoint-0.5) & dropoutStartingPoints<(dpStartPoint+0.5) & dropoutStartingPoints~=0); %Let's find the positions of similar values
                [inddc2,indds2]=find(dropoutEndingPoints>(dpEndPoint-0.5) & dropoutEndingPoints<(dpEndPoint+0.5)& dropoutEndingPoints~=0); %Let's find the positions of similar values
                count=0; %This counter is generated since there is a possibility in which one dropout is not found in all the channels
                val1=0;
                val2=0;
                %A mean is performed taking into account that all dropouts
                %start and finish at the same point
                for kk=1:length(inddc1)
                    j=inddc1(kk);
                    val1=(fs*dropoutStartingPoints(j,indds1(count+1,1)))+val1+1;
                    val2=(fs*dropoutEndingPoints(j,indds2(count+1,1)))+val2+1;
                    count=count+1;
                end
                definitiveDropoutStartingPoints(i)= time(fix(val1/count));
                definitiveDropoutEndingPoints(i)=time(fix(val2/count));
            end
    
    totalDropouts = length(dropoutIndices);
    dropoutSamplesTotal = sum(fs * (definitiveDropoutEndingPoints - definitiveDropoutStartingPoints));
    totalDropoutTime = dropoutSamplesTotal / fs;
    [M, totalSamples] = size(eegFull);
    dropoutRatio = dropoutSamplesTotal / totalSamples;

    % Display results
    if(verbose)
        fprintf('<strong>Each channel contains N dropouts:</strong>\n');
        fprintf(string(length(dropoutStartingPoints)) + ' dropouts\n');
        fprintf('<strong>The dropoutPercentagetage of dropouts in the whole signal is:</strong>\n');
        dropoutPercentage = dropoutRatio * 100;
        disp(string(dropoutPercentage) + '%');
    end
end
