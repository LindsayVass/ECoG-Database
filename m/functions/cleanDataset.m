function [channelStats, markedEEG] = cleanDataset(EEG, epochSecs, numSD)
% Mark artifacts in a one-channel dataset. This function will first
% calculate the mean and standard deviation for this particular channel. It
% will then epoch the data into short contiguous epochs (length =
% epochSecs) and flag epochs that contain values that exceed a given number
% of standard deviations above/below the mean (threshold = numSD). Will
% return a marked EEG dataset as well as channel statistics (mean, SD,
% threshold, number & percent of marked epochs).
%
% >> [channelStats, markedEEG] = cleanDataset(EEG, epochSecs, numSD)
%
% Input:
%   EEG: EEGLAB struct containing ONE CHANNEL ONLY
%
% Optional Inputs:
%   epochSecs: length of epochs to create in seconds (default = 1)
%   numSD: number of standard deviations above/below the mean to use as
%       threshold for identifying artifacts (default = 5)
%
% Outputs:
%   channelStats: structure containing statistics for this channel,
%       including mean, SD, threshold (numSD), epoch length (epochSecs), 
%       number of flagged epochs, and percent of flagged epochs
%   markedEEG; EEGLAB struct containing epoched data and updated marks
%       structure reflecting bad epochs

% check that dataset is only one channel
if (size(EEG.data, 1) > 1)
    error('EEG must contain only one channel. Try using splitDataset.m')
end

% set epochSecs & numSD if not specified
if nargin < 3
    numSD = 5;
end

if nargin < 2
    epochSecs = 1;
end

% calculate channel statistics
chanMean = mean(EEG.data(:));
chanSD   = std(EEG.data(:));
chanHigh = chanMean + numSD * chanSD;
chanLow  = chanMean - numSD * chanSD;

% prepare channelStats structure
channelStats = struct('Mean', chanMean, 'SD', chanSD, 'EpochSecs', epochSecs, 'ThresholdSD', numSD, 'BadEpochs', [], 'TotalEpochs', [], 'PercentBadEpochs', []);

% create epoched dataset
epochedEEG = marks_continuous2epochs(EEG, 'recurrence', epochSecs, 'limits', [0 epochSecs]);

% identify bad epochs
[markedEEG, ind] = pop_eegthresh(epochedEEG, 1, 1, chanLow, chanHigh, 0, epochSecs, 1, 0);

