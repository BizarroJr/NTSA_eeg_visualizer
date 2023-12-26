% Adds an offset to each row of a given matrix. The purpose of this 
% offset is to vertically separate different rows of the matrix when it is 
% visualized, especially in the context of EEG data where each row corresponds 
% to a different channel.
% eeg - matrix with signals to be offseted vertically
% offset - offset for calculating y-coordinates of each channel

function [eeg_offset] = offset(eeg)
    eeg_offset=zeros(size(eeg));
    [M,N]=size(eeg);
    for j=1:M
         eeg_offset(j,:)=eeg(j,:)+j*900;
    end
end

