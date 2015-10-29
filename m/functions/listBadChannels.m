function chanList = listBadChannels(EEG)

% Gather the list of channel names that have been marked, either as bad
% channels, or as the marker channel.
%
% >> chanList = listBadChannels(EEG)
%
% Input: 
%   EEG: EEGLAB structure
%
% Output:
%   chanList: structure containing the labels for each channel marker type
%       (e.g., 'manual', 'marker'), the names of the channel associated
%       with each label, and the indices of each channel in EEG.data


if (isfield(EEG, 'marks') == 0)
    chanList = [];
    fprintf('\n\nNo marked channels found.\n\n')
else
    chanList = struct('label', [], 'electrode_name', [], 'electrode_ind', []);
    for thisLabel = 1:size(EEG.marks.chan_info, 2)
        chanList(thisLabel).label = EEG.marks.chan_info(thisLabel).label;
        
        eInd = find(EEG.marks.chan_info(thisLabel).flags);
        chanList(thisLabel).electrode_ind = eInd;
        chanList(thisLabel).electrode_name = {EEG.chanlocs(eInd).labels}';
    end
end

