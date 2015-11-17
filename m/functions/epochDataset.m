function [EEG_epoch epochInfo] = epochDataset(EEG, eventLatencies, eventLabels, eStartSecs, eEndSecs)
% Create an epoched dataset.
%
% >> [EEG_epoch epochInfo] = epochDataset(EEG, eventLatencies, eventLabels, eStartSecs, eEndSecs)
%
% Inputs:
%   EEG: EEGLAB structure
%   eventLatencies: vector of event onsets in data samples (not seconds)
%   eventLabels: cell array of event labels
%   eStartSecs: epoch onset time in seconds, where the time specified by
%       eventLatencies is time 0 (e.g., if eStartSecs = -2, the first data
%       point of the epoch will be 2 seconds before the onset specified by
%       eventLatencies)
%   eEndSecs: epoch end time in seconds, where the time specified by
%       eventLatencies is time 0
%
% Outputs:
%   EEG_epoch: epoched EEGLAB structure
%   epochInfo: structure containing lists of good and bad epochs, along
%       with their indices and labels

% check that eventLatencies and eventLabels contain the same number of
% events
if length(eventLatencies) ~= length(eventLabels)
    error('You must supply the same number of eventLatencies and eventLabels.')
end

% check that all eventLatencies are valid
if any(eventLatencies < 1)
    error('All eventLatencies must be greater than zero.')
end
if any(eventLatencies > size(EEG.data, 2))
    error('At least one of your eventLatencies occurs after the end of the EEG data.')
end

% check that eEndSecs is after eStartSecs
if eEndSecs < eStartSecs
    error('eEndSecs must be later in time than eStartSecs')
end