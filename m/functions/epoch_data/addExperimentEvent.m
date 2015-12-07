function eventStruct = addExperimentEvent(eventStruct, onset, label)
% Add an experimental event to the EEG.event structure.
%
% >> eventStruct = addExperimentEvent(eventStruct, onset, label)
%
% Inputs:
%   eventStruct: event structure from EEG (EEG.event)
%   onset: time of event onset in data samples (i.e., pnts, not time)
%   label: string indicating the desired label for the event
%
% Output:
%   eventStruct: updated event structure

ind = length(eventStruct) + 1;
eventStruct(ind).latency = onset;
eventStruct(ind).type = label;