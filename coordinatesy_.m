% Generates y-coordinates for visualizing EEG channels based on the input 
% EEG data and an offset.
% eeg - matrix with signals to be offseted vertically
% offset - offset between 
function [coordinates] = coordinatesy_(eeg,offset)
%     coordinates=[0];
%     for j=1:length(eeg(:,1))
%         coordinates(end+1)=j*offset+max(eeg(j,:));
%     end

    % Optimized code: 
    maxValues = max(eeg, [], 2);
    coordinates = offset * (1:length(maxValues)) + maxValues';
    coordinates = [0, coordinates];
end

