% This function aims to extract a new component of the EEG, by moving through the window.
% INPUTS:
%     - eeg: Original EEG
%     - time: Original time
%     - time_: Time displayed in the current window
%     - offset_1: This value sets the samples on the left that want to be
%     removed/added
%     - offset_2:This value sets the samples on the right that want to be
%     removed/added
%     - action: This value states if we are trying to move (0) or to
%     amplify (1)
% OUTPUTS:
%     - eeg_out: Portion of the EEG to display
%     - time_out: Portion of the time to display
function [eeg_out,time_out] = actualizar_new(eeg,time,time_,offset_1,offset_2,action)

    ultimo_tiempo=time_(length(time_));
    ult=find(time==ultimo_tiempo); %Find the index of the last time plotted

    range=[ult+offset_1-length(time_),ult+offset_2]; %The new desired range for the window is defined
    if range(1)<0   %In case that we are plotting sample 1
        if (action==1) && (offset_1<0) %In case that we want to do zoom out we will do it only in the right
            range=[1, length(time_)+offset_2];
        end
        if (action==0) %In case that we want to move to the left, we will not be able
            range=[1, length(time_)];
        end
    end
    if range(2)>length(eeg(1,:)) %In case that we are currently plotting the last sample
        if (action==1) && (offset_2>0) %In case that we want to do zoom out we will do it only in the left
            range=[range(1), length(eeg(1,:))];
        end
        if (action==0) %In case that we want to move to the right, we will not be able
            range=[length(eeg(1,:))-length(time_),length(eeg(1,:))];
        end     
    end
    if range(1)==0
        range(1)=1;
    end
    %The new EEG samples and time are defined
    eeg_out=eeg(:,range(1):range(2));
    time_out=time(range(1):range(2));

end

