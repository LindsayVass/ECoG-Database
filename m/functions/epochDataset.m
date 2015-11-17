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

% check that eventLabels is cell array of strings
if ~iscellstr(eventLabels)
    error('eventLabels must be a cell array of strings')
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

% add experiment events to EEG.event
for thisEvent = 1:length(eventLatencies)
    EEG.event = addExperimentEvent(EEG.event, eventLatencies(thisEvent), eventLabels{thisEvent});
end

% get indices of artifacts from EEG.marks
marksInd = marks_label2index(EEG.marks.time_info, {EEG.marks.time_info.label}, 'indexes', 'exact', 'on');
EEG = pop_marks_select_data(EEG, 'time marks', marksInd);

% if artifacts overlap with experimental event, it will be removed
% silently, so check for that now
origLatency = cell2mat({EEG.event.latency});
[missingLatency, missingInd] = intersect(origLatency, marksInd);
noArtifactEpochs = [1:1:length(origLatency)]';
noArtifactEpochs(missingInd) = [];

% epoch data
[EEG_epoch, goodEpochs] = pop_epoch(EEG, unique(eventLabels), [eStartSecs eEndSecs]);
goodEpochs = noArtifactEpochs(goodEpochs);
