function [channelStats, markedEEG, samplesToTrim] = cleanDataset(EEG, epochSecs, numSD)
% Mark artifacts in a one-channel dataset. This function will first
% calculate the mean and standard deviation for this particular channel. It
% will then epoch the data into short contiguous epochs (length =
% epochSecs) and flag epochs that contain values that exceed a given number
% of standard deviations above/below the mean (threshold = numSD). Will
% return a marked EEG dataset as well as channel statistics (mean, SD,
% threshold, number & percent of marked epochs).
%
% >> [channelStats, markedEEG, samplesToTrim] = cleanDataset(EEG, epochSecs, numSD)
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
%   samplesToTrim: if the data set does not divide evenly into epochs of
%       length epochSecs, it will be padded with NaN; this value indicates
%       how many samples to trim later to return it to the original size

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
channelStats = struct('Mean', chanMean, 'SD', chanSD, 'EpochSecs', epochSecs, 'ThresholdSD', numSD, 'NumBadEpochs', [], 'TotalEpochs', [], 'PercentBadEpochs', [], 'BadEpochInds', []);

% check if data set length divides evenly by epochSecs (otherwise, will
% lose time points); if it doesn't, pad with NaN
epochSamples  = epochSecs * EEG.srate;
sampsToAdd    = epochSamples - mod(size(EEG.data, 2), epochSamples);
EEG.data      = cat(2, EEG.data, nan(1, sampsToAdd + 1));
EEG.pnts      = size(EEG.data, 2);
EEG           = eeg_checkset(EEG);
samplesToTrim = sampsToAdd;

% initialize new marks structure
if isfield(EEG, 'marks')
    EEG = rmfield(EEG, 'marks');
end
EEG.marks = marks_init(size(EEG.data), 1);

% create epoched dataset
epochedEEG = marks_continuous2epochs_LKV(EEG, 'recurrence', epochSecs, 'limits', [0 epochSecs]);

% identify bad epochs
[markedEEG, ind] = pop_eegthresh(epochedEEG, 1, 1, chanLow, chanHigh, 0, epochSecs, 1, 0);

% copy to marks structure
markedEEG = reject2marks(markedEEG);

% update channelStats
channelStats.NumBadEpochs = length(ind);
channelStats.TotalEpochs = size(markedEEG.data, 3);
channelStats.PercentBadEpochs = (length(ind) / size(markedEEG.data, 3)) * 100;
channelStats.BadEpochInds = ind';

% copy channelStats to markedEEG
if isfield(markedEEG, 'artifact_history')
    histInd = length(markedEEG.artifact_history) + 1;
else
    histInd = 1;
end
markedEEG.artifact_history(histInd).date = datestr(now);
markedEEG.artifact_history(histInd).type = 'Extreme Value';
markedEEG.artifact_history(histInd).artifacts = channelStats;

