function mergedEEG = mergeEpochedDatasets(eegPaths)
% Given a cell array of paths to epoched EEG data sets, load all data sets,
% and merge them together.
%
% >> mergedEEG = mergeCleanedDatasets(eegPaths)
%
% Inputs:
%   eegPaths: cell array of paths to epoched EEG data sets
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
    mergedEEG.chanlocs(thisEEG).index = thisEEG;
end

mergedEEG.chan_history = [];
mergedEEG.chan_history.date = datestr(now);
[mergedEEG.chan_history.good_chans(1:length(mergedEEG.chanlocs)).electrode_name] = deal(mergedEEG.chanlocs.labels);
chanInds = num2cell([1:1:mergedEEG.nbchan]);
[mergedEEG.chan_history.good_chans(1:length(mergedEEG.chanlocs)).electrode_ind] = deal(chanInds{:});
mergedEEG.chan_history.bad_chans.label = [];
mergedEEG.chan_history.bad_chans.electrode_name = [];
mergedEEG.chan_history.bad_chans.electrode_ind = [];

% copy chan_history
for thisEEG = 1:length(EEG)
    mergedEEG.chan_history.individ_chan_history(thisEEG).electrode_name = mergedEEG.chanlocs(thisEEG).labels;
    mergedEEG.chan_history.individ_chan_history(thisEEG).electrode_ind  = thisEEG;
    if isfield(EEG(thisEEG), 'chan_history')
        mergedEEG.chan_history.individ_chan_history(thisEEG).chan_history = EEG(thisEEG).chan_history;
    end
end

%% merge marks

% identify the artifact rejection labels
rejLabels = cell(length(EEG), 1);
for thisEEG = 1:length(EEG)
    rejLabels{thisEEG} = {EEG(thisEEG).marks.time_info.label};
end
uniqueRejLabels = {};
for thisEEG = 1:length(EEG)
    uniqueRejLabels = [uniqueRejLabels; rejLabels{thisEEG}'];
end
uniqueRejLabels = unique(uniqueRejLabels);

% initialize new marks structure
newMarks = marks_init(size(mergedEEG.data), 1);

% merge marks
for thisLabel = 1:length(uniqueRejLabels)
    thisColor = [];
    label = uniqueRejLabels{thisLabel};
    tmpFlags = zeros(size(mergedEEG.data));
    for thisEEG = 1:length(EEG)
        labelInd = find(strcmpi(label, rejLabels{thisEEG}));
        if ~isempty(labelInd)
            tmpFlags(thisEEG, :, :) = EEG(thisEEG).marks.time_info(labelInd).flags;
            if isempty(thisColor)
                thisColor = EEG(thisEEG).marks.time_info(labelInd).color;
            end
        end
    end % thisEEG
    tmpFlags = sum(tmpFlags, 1);
    tmpFlags(tmpFlags > 1) = 1;
    
    newMarks.time_info(thisLabel).label = label;
    newMarks.time_info(thisLabel).color = thisColor;
    newMarks.time_info(thisLabel).flags = tmpFlags;
end % thisLabel

mergedEEG.marks = newMarks;



%% update artifact_history
if isfield(mergedEEG, 'artifact_history')
    mergedEEG = rmfield(mergedEEG, 'artifact_history');
end
mergedEEG.artifact_history.date                       = datestr(now);
mergedEEG.artifact_history.type                       = 'Merged Artifacts';
mergedEEG.artifact_history.artifacts.Mean             = NaN;
mergedEEG.artifact_history.artifacts.SD               = NaN;
if isfield(EEG(1), 'artifact_history')
    mergedEEG.artifact_history.artifacts.EpochSecs        = EEG(1).artifact_history(1).artifacts.EpochSecs;
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

%% update rereference history
for thisEEG = 1:length(EEG)
    if isfield(EEG(thisEEG), 'reref')
        mergedEEG.channel_reref_history(thisEEG).electrode_name = EEG(thisEEG).chanlocs(1).labels;
        mergedEEG.channel_reref_history(thisEEG).electrode_ind  = thisEEG;
        mergedEEG.channel_reref_history(thisEEG).reref          = EEG(thisEEG).reref;
    end
end

% Prepare a string to submit to isequal later (will test whether all
% EEG.reref structures are identical)
eqSchemeTestString = '';
eqDateTestString   = '';
eqChanTestString   = '';
for thisEEG = 1:length(EEG)
    if isfield(EEG(thisEEG), 'reref')
        if thisEEG == length(EEG);
            eqSchemeTestString = [eqSchemeTestString 'EEG(' num2str(thisEEG) ').reref.scheme'];
            eqDateTestString   = [eqDateTestString 'EEG(' num2str(thisEEG) ').reref.date'];
            eqChanTestString   = [eqChanTestString 'EEG(' num2str(thisEEG) ').reref.chan'];
        else
            eqSchemeTestString = [eqSchemeTestString 'EEG(' num2str(thisEEG) ').reref.scheme, '];
            eqDateTestString   = [eqDateTestString 'EEG(' num2str(thisEEG) ').reref.date, '];
            eqChanTestString   = [eqChanTestString 'EEG(' num2str(thisEEG) ').reref.chan, '];
        end
    else % reref structures are not equal if one doesn't exist
        eqSchemeTestString = '';
        eqDateTestString   = '';
        eqChanTestString   = '';
        return
    end
end

% Test whether all EEG.reref.scheme are equal
if length(EEG) > 1
    if ~strcmpi(eqSchemeTestString, '')
        eqSchemeTest = eval(['isequal(' sprintf(eqSchemeTestString) ')']);
        if eqSchemeTest
            mergedEEG.reref.scheme = EEG(1).reref.scheme;
        else
            mergedEEG.reref.scheme = 'Mixed - See channel_reref_history';
        end
    end
else
    mergedEEG.reref.scheme = EEG(1).reref.scheme;
end

% Test whether all EEG.reref.date are equal
if length(EEG) > 1
    if ~strcmpi(eqDateTestString, '')
        eqDateTest = eval(['isequal(' sprintf(eqDateTestString) ')']);
        if eqDateTest
            mergedEEG.reref.date = EEG(1).reref.date;
        else
            mergedEEG.reref.date = 'Mixed - See channel_reref_history';
        end
    end
else
    mergedEEG.reref.date = EEG(1).reref.date;
end

% Test whether all EEG.reref.chan are equal
if length(EEG) > 1
    if ~strcmpi(eqChanTestString, '')
        eqChanTest = eval(['isequal(' sprintf(eqChanTestString) ')']);
        if eqChanTest
            mergedEEG.reref.chan = EEG(1).reref.chan;
        else
            mergedEEG.reref.chan = 'Mixed - See channel_reref_history';
        end
    end
else
    mergedEEG.reref.chan = EEG(1).reref.chan;
end