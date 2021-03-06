function mergedEEG = mergeCleanedDatasets(eegPaths, numSD, markerPath)
% Given a cell array of paths to clean EEG data sets, load all data sets,
% and merge them together, keeping only time points which are clean across
% all data sets.
%
% >> mergedEEG = mergeCleanedDatasets(eegPaths, numSD, markerPath)
%
% Inputs:
%   eegPaths: cell array of paths to cleaned EEG data sets
%   numSD: threshold in SD to use
%
% Optional Input:
%   markerPath: path to the marker channel data set
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
mergedEEG.data = cat(1, EEG(1:end).data);
[mergedEEG.chanlocs(1:length(EEG))] = deal([EEG(1:length(EEG)).chanlocs]);
for thisEEG = 1:length(EEG)
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

%% merge rejected epochs and marks
newRej = zeros(length(EEG), size(EEG(1).data, 3));
rejLabel = ['rejthresh' num2str(numSD)];
for thisEEG = 1:length(EEG)
    rejInd = find(strcmpi({EEG(thisEEG).marks.time_info.label}, rejLabel));
    if ~isempty(rejInd)
        newRej(thisEEG, :) = squeeze(EEG(thisEEG).marks.time_info(rejInd).flags(1, 1, :));
    end
end
newRej = sum(newRej, 1);
newRej(newRej > 1) = 1;

mergedEEG.reject.rejthresh = newRej;
mergedEEG.reject.rejthreshE = [];

mergedEEG = rmfield(mergedEEG, 'marks');
mergedEEG = reject2marks(mergedEEG);

%% update artifact_history
if isfield(mergedEEG, 'artifact_history')
    mergedEEG = rmfield(mergedEEG, 'artifact_history');
end
mergedEEG.artifact_history.date                       = datestr(now);
mergedEEG.artifact_history.type                       = 'Merged Artifacts';
mergedEEG.artifact_history.artifacts.Mean             = NaN;
mergedEEG.artifact_history.artifacts.SD               = NaN;
if isfield(EEG(1), 'artifact_history')
    tmpStruct = [EEG(1).artifact_history.artifacts]; 
    tmpThresh = [tmpStruct.ThresholdSD];
    artInd = find(tmpThresh == numSD);
    mergedEEG.artifact_history.artifacts.EpochSecs        = EEG(1).artifact_history.artifacts(artInd).EpochSecs;
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
        
        tmpStruct = [EEG(thisEEG).artifact_history.artifacts];
        tmpThresh = [tmpStruct.ThresholdSD];
        artInd = find(tmpThresh == numSD);
        mergedEEG.channel_artifact_history(thisEEG).artifact_history = EEG(thisEEG).artifact_history(artInd);
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
%% convert back to continuous dataset from epoched dataset
mergedEEG = marks_epochs2continuous(mergedEEG);

%% add marker data if it exists
if exist('markerPath', 'var')
    EEG = pop_loadset(markerPath);
    EEG = marks_epochs2continuous(EEG);
    markerInd = size(mergedEEG.data, 1) + 1;
    mergedEEG.data(markerInd, :) = EEG.data(1, :);
    mergedEEG.chanlocs(markerInd).labels = EEG.chanlocs(1).labels;
    mergedEEG.chanlocs(markerInd).index = markerInd;
    if isfield(EEG, 'artifact_history')
        mergedEEG.channel_artifact_history(markerInd).electrode_name = EEG.chanlocs(1).labels;
        mergedEEG.channel_artifact_history(markerInd).electrode_ind = markerInd;
        if isfield(mergedEEG, 'channel_artifact_history')
            mergedEEG.channel_artifact_history(markerInd).artifact_history = EEG.artifact_history;
        end
    end
    
    mergedEEG.nbchan = size(mergedEEG.data, 1);
    
    % update existing chan_info marks
    for thisMark = 1:length(mergedEEG.marks.chan_info)
        if size(mergedEEG.marks.chan_info(thisMark).flags, 1) ~= mergedEEG.nbchan
            mergedEEG.marks.chan_info(thisMark).flags(markerInd) = 0;
        end
    end
    
    % update marker chan_info mark
    tmpFlags = zeros(mergedEEG.nbchan, 1);
    tmpFlags(markerInd) = 1;
    flagOrder = max([mergedEEG.marks.chan_info.order]) + 1;
    if flagOrder == 0
        flagOrder = 1;
    end
    mergedEEG.marks = marks_add_label(mergedEEG.marks, 'chan_info', {'marker', [1 0 0], [1 0 0], flagOrder, tmpFlags});
    
end

%% trim NaN padding
% find NaNs
[~, col] = find(isnan(mergedEEG.data));


if ~isempty(col)
    % check that all channels have NaNs at the same time points
    ctCol = crosstab(col);
    if any(ctCol ~= size(mergedEEG.data, 1))
        error('Channels are padded with different numbers of NaNs.')
    end
    
    % trim the NaNs
    nanCols = unique(col);
    mergedEEG.data(:, nanCols) = [];
    mergedEEG.pnts = size(mergedEEG.data, 2);
    mergedEEG = eeg_checkset(mergedEEG);
    for thisFlag = 1:length(mergedEEG.marks.time_info)
        mergedEEG.marks.time_info(thisFlag).flags(nanCols) = [];
    end

end

%% update struct
mergedEEG.urevent = [];
mergedEEG.setname = 'Merged';
mergedEEG.filepath = '';
mergedEEG.filename = '';


