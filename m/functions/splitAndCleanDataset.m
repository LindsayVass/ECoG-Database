function [fileList, markerPath] = splitAndCleanDataset(EEG, outputDir, outputStem, epochSecs, numSD)
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
%   markerPath: path to the marker channel (must be designated in the marks
%       structure with label 'marker' for this to return data)

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

outputDirOrig = [outputDir 'dirty_unepoched/'];

% split data set into one for each channel
[splitLog, markerPath] = splitDataset(EEG, outputDirOrig, outputStem);

% prep output dir
if ~exist('outputDirNoSpace', 'var')
    outputDirNoSpace = strrep(outputDir, ' ', '\ ');
end
outputDirClean = [outputDir 'clean_epoched/'];
outputDirCleanNoSpace = [outputDirNoSpace 'clean_epoched/'];
system(['mkdir ' outputDirCleanNoSpace]);

% initialize output log
fileList = cell(size(splitLog));

% clean each channel's data
for thisEEG = 1:length(splitLog)
    % clean file
    EEG = pop_loadset(splitLog{thisEEG});
    [~, markedEEG] = cleanDataset(EEG, epochSecs, numSD);
    
    % save
    outName = [outputDirClean outputStem EEG.chanlocs(1).labels '_marked.set'];
    fileList{thisEEG} = outName;
    pop_saveset(markedEEG, outName);
end