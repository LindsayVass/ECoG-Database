function EEG = updateChanHistory(EEG, chanVerID, goodChanList, badChanList)
% Update the EEG.chan_history structure to reflect changes to the list of
% good and bad channels.
%
% >> EEG = updateChanHistory(EEG, goodChanList, badChanList)
%
% Inputs:
%   EEG: EEGLAB structure
%   chanVerID: integer indicating current version of channel inclusion
%   goodChanList: structure of good channel data, output by
%       makeChannelLists.m
%   badChanList: structure of bad channel data, output by
%       makeChannelLists.m
%
% Output:
%   EEG: updated EEGLAB structure

histInd = length(EEG.chan_history) + 1;

EEG.chan_history(histInd).chanVerID = chanVerID;
EEG.chan_history(histInd).date = datestr(now);
EEG.chan_history(histInd).good_chans = goodChanList;
EEG.chan_history(histInd).bad_chans = badChanList;