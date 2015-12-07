function [goodChanList, badChanList] = makeChannelLists(EEG)

% Gather lists of good channels and bad channels (i.e., channels that have
% been flagged in the EEG.marks structure).
%
% >> [goodChanList, badChanList] = makeChannelLists(EEG)
%
% Input: 
%   EEG: EEGLAB structure
%
% Outputs:
%   goodChanList: structure containing the labels and indices of all good
%       channels (i.e., channels that have not been flagged)
%   badChanList: structure containing the labels for each channel marker type
%       (e.g., 'manual', 'marker'), the names of the channel associated
%       with each label, and the indices of each channel in EEG.data

badChanList = struct('label', [], 'electrode_name', [], 'electrode_ind', []);
goodChanList = struct('electrode_name', [], 'electrode_ind', []);

if (isfield(EEG, 'marks') == 0)
    fprintf('\n\nNo marked channels found.\n\n')
    for thisChan = 1:EEG.nbchan
        goodChanList(thisChan).electrode_ind = thisChan;
        goodChanList(thisChan).electrode_name = {EEG.chanlocs(thisChan).labels};
    end
else
    for thisLabel = 1:size(EEG.marks.chan_info, 2)
        badChanList(thisLabel).label = EEG.marks.chan_info(thisLabel).label;
        
        eInd = find(EEG.marks.chan_info(thisLabel).flags);
        badChanList(thisLabel).electrode_ind = eInd;
        badChanList(thisLabel).electrode_name = {EEG.chanlocs(eInd).labels}';
    end
    
    % get list of good chans
    flags = sum([EEG.marks.chan_info.flags], 2);
    goodChanInds = find(flags == 0);
    for thisChan = 1:length(goodChanInds)
        goodChanList(thisChan).electrode_ind = goodChanInds(thisChan);
        goodChanList(thisChan).electrode_name = {EEG.chanlocs(goodChanInds(thisChan)).labels};
    end
end

