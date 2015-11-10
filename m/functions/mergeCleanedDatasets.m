function mergedEEG = mergeCleanedDatasets(eegPaths)
% Given a cell array of paths to clean EEG data sets, load all data sets,
% and merge them together, keeping only time points which are clean across
% all data sets.
%
% >> mergedEEG = mergeCleanedDatasets(eegPaths)
%
% Input:
%   eegPaths: cell array of paths to cleaned EEG data sets
%
% Output:
%   mergedEEG: EEGLAB struct containing all cleaned data

%% load data
for thisEEG = 1:length(eegPaths)
    EEG(thisEEG) = pop_loadset(eegPaths{thisEEG});
end

%% check that all data has same epoch length and same number of epochs
sizeCheck = zeros(length(EEG), 3);
for thisEEG = 1:length(EEG)
    sizeCheck(thisEEG, :) = size(EEG(thisEEG).data);
end
if length(unique(sizeCheck(:,2))) > 1
    error('All data sets must have same number of time points per epoch.')
end
if length(unique(sizeCheck(:,3))) > 1
    error('All data sets must have same number of epochs.')
end


%% copy data to new data set
mergedEEG = EEG(1);
mergedEEG.filename = '';
mergedEEG.datfile = '';
mergedEEG.nbchan = length(EEG);
mergedEEG.data = zeros(length(EEG), size(EEG(1).data, 2), size(EEG(1).data, 3));

% copy data and channel labels
for thisEEG = 1:length(EEG)
    mergedEEG.data(thisEEG, :, :) = EEG(thisEEG).data;
    mergedEEG.chanlocs(thisEEG) = EEG(thisEEG).chanlocs;
end

mergedEEG.chan_history.date = datestr(now);
mergedEEG.chan_history.good_chans.electrode_name = {mergedEEG.chanlocs.labels}';
mergedEEG.chan_history.good_chans.electrode_ind = [1:1:mergedEEG.nbchan]';

% copy chan_history
for thisEEG = 1:length(EEG)
    mergedEEG.chan_history.individ_chan_history(thisEEG).electrode_name = mergedEEG.chanlocs(thisEEG).labels;
    mergedEEG.chan_history.individ_chan_history(thisEEG).electrode_ind  = thisEEG;
    if isfield(EEG(thisEEG), 'chan_history')
        mergedEEG.chan_history.individ_chan_history(thisEEG).chan_history = EEG(thisEEG).chan_history;
    end
end

% copy artifact_history
mergedEEG.artifact_history.date                       = datestr(now);
mergedEEG.artifact_history.type                       = 'Merged Artifacts';
mergedEEG.artifact_history.artifacts.Mean             = NaN;
mergedEEG.artifact_history.artifacts.SD               = NaN;
if isfield(EEG(1), 'artifact_history')
    mergedEEG.artifact_history.artifacts.EpochSecs        = EEG(1).artifact_history.artifacts.EpochSecs;
else
    mergedEEG.artifact_history.artifacts.EpochSecs = NaN;
end
mergedEEG.artifact_history.artifacts.ThresholdSD      = NaN;
mergedEEG.artifact_history.artifacts.NumBadEpochs     = length(find(mergedEEG.reject.rejthresh));
mergedEEG.artifact_history.artifacts.TotalEpochs      = length(mergedEEG.reject.rejthresh);
mergedEEG.artifact_history.artifacts.PercentBadEpochs = (mergedEEG.artifact_history.artifacts.NumBadEpochs / mergedEEG.artifact_history.artifacts.TotalEpochs) * 100;
mergedEEG.artifact_history.artifacts.BadEpochInds     = find(mergedEEG.reject.rejthresh);

for thisEEG = 1:length(EEG)
    if isfield(EEG(thisEEG), 'artifact_history')
        mergedEEG.channel_artifact_history(thisEEG).electrode_name = EEG(thisEEG).chanlocs(1).labels;
        mergedEEG.channel_artifact_history(thisEEG).electrode_ind = thisEEG;
        
        if ~isfield(mergedEEG, 'channel_artifact_history')
        else
            mergedEEG.channel_artifact_history(thisEEG).artifact_history = EEG(thisEEG).artifact_history;
        end
    end
end

%% merge rejected epochs and marks
newRej = zeros(length(EEG), size(EEG(1).data, 3));
for thisEEG = 1:length(EEG)
    newRej(thisEEG, :) = EEG(thisEEG).reject.rejthresh;
end
newRej = sum(newRej, 1);
newRej(newRej > 1) = 1;

mergedEEG.reject.rejthresh = newRej;
mergedEEG.reject.rejthreshE = [];

mergedEEG = rmfield(mergedEEG, 'marks');
mergedEEG = reject2marks(mergedEEG);

%% convert back to continuous dataset from epoched dataset
mergedEEG = marks_epochs2continuous_LKV(mergedEEG);

