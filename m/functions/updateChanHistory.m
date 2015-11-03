function EEG = updateChanHistory(EEG, goodChanList, badChanList)
% Update the EEG.chan_history structure to reflect changes to the list of
% good and bad channels.
%
% >> EEG = updateChanHistory(EEG, goodChanList, badChanList)
%
% Inputs:
%   EEG: EEGLAB structure
%   goodChanList: structure of good channel data, output by
%       makeChannelLists.m
%   badChanList: structure of bad channel data, output by
%       makeChannelLists.m
%
% Output:
%   EEG: updated EEGLAB structure

if isfield(EEG, 'chan_history') == 0
    histInd = 1;
    addEntry = 1;
else
    histInd = length(EEG.chan_history) + 1;
    
    % check whether any channels have changed since previous entry
    checkGood = isequal(goodChanList, EEG.chan_history(histInd - 1).good_chans);
    checkBad  = isequal(badChanList, EEG.chan_history(histInd - 1).bad_chans);
    if checkGood == 1 && checkBad == 1
        addEntry = 0;
        warning('Channels are same as previous version. No changes have been made to chan_history.');
    else
        addEntry = 1;
    end
end

if addEntry
    EEG.chan_history(histInd).date = datestr(now);
    EEG.chan_history(histInd).good_chans = goodChanList;
    EEG.chan_history(histInd).bad_chans = badChanList;
end