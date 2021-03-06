function [fileList, markerPath, samplesToTrim] = splitAndCleanDataset(EEG, outputDir, outputStem, epochSecs, numSD)
% Take an EEG structure containing 1 or more channels, split it into
% separate data sets for each channel, and clean each channel. Each
% channel's data will be split into contiguous epochs (length = epochSecs)
% and epochs containing extreme values (>numSD above or below the mean for
% that channel) will be flagged as bad.
%
% >> [fileList, markerPath] = splitAndCleanDataset(EEG, outputDir, outputStem)
%
% Inputs:
%   EEG: EEG structure to be cleaned
%   outputDir: string containing the path to the output directory (will be
%       created if it does not exist)
%   outputStem: string containing the stem for file naming; the channel
%       name will be appended to the stem (e.g., stem = 'TS071' will
%       produce files like 'TS071_LH1.set', 'TS071_LH2.set')
%
% Optional Inputs:
%   epochSecs: length of epochs in seconds to divide the datasets into
%       (default = 1)
%   numSD: number of standard deviations above/below the mean to use as a
%       threshold for identifying epochs containing extreme values (default
%       = 5)
%
% Outputs:
%   fileList: cell array of strings containing the path to each of the newly
%       created datasets
%   markerPath: path to the marker channel; for this to return valid
%       information, you must designate the marker channel either in
%       EEG.chanlocs.labels (i.e., one channel is named 'marker') or by
%       flagging it in EEG.marks (i.e., flag label is 'marker')
%   samplesToTrim: if the data set does not divide evenly into epochs of
%       length epochSecs, it will be padded with NaN; this value indicates
%       how many samples to trim later to return it to the original size

if nargin < 5
    numSD = 5;
end
if nargin < 4
    epochSecs = 1;
end

% make the output directory if it doesn't exist
if ~exist(outputDir, 'dir')
    outputDirNoSpace = strrep(outputDir, ' ', '\ ');
    system(['mkdir ' outputDirNoSpace]);
end

if strcmpi(outputDir(end), '/') == 0
    outputDir = [outputDir '/'];
end

% split data set into one for each channel
[splitLog, markerPath] = splitDataset(EEG, outputDir, outputStem);

% save splitLog
fileList = splitLog;
save([outputDir 'fileList.mat'], 'fileList');
clear fileList;

% prep output dir
if ~exist('outputDirNoSpace', 'var')
    outputDirNoSpace = strrep(outputDir, ' ', '\ ');
end
outputDirClean = [outputDir 'marked_epoched/'];
outputDirCleanNoSpace = [outputDirNoSpace 'marked_epoched/'];
system(['mkdir ' outputDirCleanNoSpace]);

% initialize output log
fileList = cell(size(splitLog));

% clean each channel's data
for thisEEG = 1:length(splitLog)
    % clean file
    EEG = pop_loadset(splitLog{thisEEG});
    [~, markedEEG, samplesToTrim] = cleanDataset(EEG, epochSecs, numSD);
    
    % save
    outName = [outputDirClean outputStem EEG.chanlocs(1).labels '_marked.set'];
    fileList{thisEEG} = outName;
    pop_saveset(markedEEG, outName);
end

% save fileList
save([outputDirClean 'fileList.mat'], 'fileList');

% split the marker data
if exist(markerPath, 'file')
    
    % epoch the data
    EEG = pop_loadset(markerPath);
    EEG.data = cat(2, EEG.data, nan(1, samplesToTrim + 1));
    EEG.pnts = size(EEG.data, 2);
    EEG = eeg_checkset(EEG);
    
    % initialize new marks structure
    if isfield(EEG, 'marks')
        EEG = rmfield(EEG, 'marks');
    end
    EEG.marks = marks_init(size(EEG.data), 1);
    
    EEG = marks_continuous2epochs(EEG, 'recurrence', epochSecs, 'limits', [0 epochSecs]);
    
    % save
    markerPath = [outputDirClean outputStem EEG.chanlocs(1).labels '.set'];
    pop_saveset(EEG, markerPath);
    save([outputDirClean 'markerPath.mat'], 'markerPath');
end
