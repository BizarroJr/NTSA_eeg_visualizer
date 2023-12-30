%--------------------------------------------------------------------------
% split_consecutive: Splits a set of indices into consecutive groups.
%--------------------------------------------------------------------------
% DESCRIPTION:
%   The function splits a set of indices into consecutive groups, where
%   consecutive indices belong to the same group.
%
% INPUTS:
%   - indices: A vector containing indices to be split into consecutive
%     groups.
%
% OUTPUTS:
%   - groups: A cell array containing consecutive index groups.
%
% USAGE:
%   groups = split_consecutive(indices);
%
% EXAMPLE:
%   indices = [1, 2, 3, 5, 6, 8, 10];
%   resultGroups = split_consecutive(indices);
%   disp(resultGroups);
%
%   % Output: { [1, 2, 3], [5, 6], [8], [10] }
%
%--------------------------------------------------------------------------


function groups = split_consecutive(indices)
    % Helper function to split indices into consecutive groups
    groups = {};
    currentGroup = [];
    
    for i = 1:length(indices)-1
        if indices(i+1) - indices(i) == 1
            % Consecutive indices, add to the current group
            currentGroup = [currentGroup, indices(i)];
        else
            % Not consecutive, finalize the current group
            currentGroup = [currentGroup, indices(i)];
            groups = [groups, {currentGroup}];
            currentGroup = [];
        end
    end
    
    % Handle the last group
    currentGroup = [currentGroup, indices(end)];
    groups = [groups, {currentGroup}];
end