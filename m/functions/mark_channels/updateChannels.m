function EEG = updateChannels(EEG)

% Update EEG.chan_history based on flags in EEG.marks.chan_info. 
%
% >> EEG = updateChannels(EEG);
%
% Input:
%   EEG: EEGLAB structure
%
% Output:
%   EEG: EEGLAB structure with updated EEG.chan_history

% create easy-to-read structures of good and bad channels
[goodChanList, badChanList] = makeChannelLists(EEG);

% update chan_history
EEG = updateChanHistory(EEG, goodChanList, badChanList);
