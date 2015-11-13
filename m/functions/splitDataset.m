function [fileList, markerPath] = splitDataset(EEG, outputDir, outputStem)
% Split one EEG dataset containing N channels into N datasets containing
% one channel each.
%
% >> [fileList, markerPath] = splitDataset(EEG, outputDir, outputStem)
%
% Inputs:
%   EEG: EEGLAB struct
%   outputDir: string containing the path to the directory in which to save
%       the newly created datasets
%   outputStem: string containing a stem for the filename for each new
%       dataset; the channel name will be appended to the end of the stem;
%       for example:
%       outputStem: 'UCDMC14_Session1_ReRef_Strip_'
%       fileName:   'UCDMC14_Session1_ReRef_Strip_LHD1.set'
%
% Outputs:
%   fileList: cell array containing the paths to the newly created data sets
%   markerPath: path to the marker channel (must be designated in the marks
%       structure with label 'marker' for this to return data)

% check that outputDir ends with '/'
if strcmpi(outputDir(end), '/') == 0
    outputDir = [outputDir '/'];
end

% if outputDir doesn't exist, create it
if ~exist(outputDir, 'dir')
    outputDirNoSpace = strrep(outputDir, ' ', '\ ');
    system(['mkdir ' outputDirNoSpace]);
end

% check that outputStem ends with '_'
if strcmpi(outputStem(end), '_') == 0
    outputStem = [outputStem '_'];
end

% get list of good channels from marks structure
if isfield(EEG, 'marks')
    allFlags  = [EEG.marks.chan_info.flags];
    allFlags  = sum(allFlags, 2);
    goodChans = find(allFlags == 0);
    
    % try to get marker channel from EEG.marks
    markerFlagInd = find(strcmpi('marker', {EEG.marks.chan_info.label}));

    if length(markerFlagInd) == 0
        markerFlagInd = find(strcmpi('marker', {EEG.chanlocs.labels}));
    end

    try
        markerInd = find(EEG.marks.chan_info(markerFlagInd).flags);
    catch
        markerInd = NaN;
        warning('Could not identify marker channel based on EEG.marks or EEG.chanlocs.labels. Did not find a flag or channel with label ''marker''.')
    end
else
    warning('EEG.marks structure not found. Will create a new data set for every channel.')
    goodChans = 1:1:size(EEG.data,1);
end

% initialize log
fileList = cell(length(goodChans), 1);

% make new data sets for all good channels
for thisChan = 1:length(goodChans)
    chanInd = goodChans(thisChan);
    outputPath = makeNewDataset(EEG, chanInd, outputDir, outputStem);
    fileList{thisChan} = outputPath;
end

% make new data set for marker channel
if ~isnan(markerInd)
    markerPath = makeNewDataset(EEG, markerInd, outputDir, outputStem);
end

function outputPath = makeNewDataset(EEG, chanInd, outputDir, outputStem)
% initialize new EEG structure
newEEG = EEG;

thisChanName = EEG.chanlocs(chanInd).labels;
outputPath = [outputDir outputStem thisChanName '.set'];

% update EEG structure
newEEG.filename = [outputStem thisChanName '.set'];
newEEG.filepath = outputPath;
newEEG.nbchan   = 1;
newEEG.data     = [];
newEEG.data     = EEG.data(chanInd, :);
newEEG.chanlocs = [];
newEEG.chanlocs = EEG.chanlocs(chanInd);
newEEG.datfile  = [outputStem thisChanName '.fdt'];

% update chan_history
if isfield(newEEG, 'chan_history')
    histInd = length(newEEG.chan_history) + 1;
else
    histInd = 1;
end

newEEG.chan_history(histInd).date = datestr(now);
newEEG.chan_history(histInd).good_chans.electrode_name = thisChanName;
newEEG.chan_history(histInd).good_chans.electrode_ind = 1;
newEEG.chan_history(histInd).bad_chans = [];

% save new dataset
pop_saveset(newEEG, outputPath);