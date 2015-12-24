function [singleChanCleanFileList] = cleanDatasetOneThresh(singleChanFileList, outputDir, outputStem, epochSecs, numSD)
% Take a list of paths to single channel unepoched unmarked datasets
% (singleChanFileList) and clean each channel's data. Each channel's data
% will be split into contiguous epochs (length = epochSecs) and epochs
% containing extreme values (>numSD above or below the mean for that
% channel) will be flagged as bad.
%
% >> [singleChanCleanFileList] = cleanDatasetOneThresh(singleChanFileList, outputDir, outputStem, epochSecs, numSD)
%
% Inputs:
%   singleChanFileList: cell array containing paths to the single channel
%       unepoched unmarked data sets created by "splitDataset.m"
%   outputDir: string containing the path to the artifact detection output
%       directory; this function will create a subdirectory within it
%       called 'singleChan_epoched_marked_singleThresh' to hold the output data
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
%   singleChanCleanFileList: cell array of strings containing the path to
%       each of the newly created datasets

if nargin < 5
    numSD = 5;
end
if nargin < 4
    epochSecs = 1;
end

% check that outputDir ends with '/'
if strcmpi(outputDir(end), '/') == 0
    outputDir = [outputDir '/'];
end

% if outputDir doesn't exist, create it
if ~exist(outputDir, 'dir')
    outputDirNoSpace = strrep(outputDir, ' ', '\ ');
    system(['mkdir ' outputDirNoSpace]);
end

% create the subdirectory
outputSubDir = [outputDir 'singleChan_epoched_marked_singleThresh/'];
if ~exist(outputSubDir, 'dir')
    outputSubDirNoSpace = strrep(outputSubDir, ' ', '\ ');
    system(['mkdir ' outputSubDirNoSpace]);
end


% check that outputStem ends with '_'
if strcmpi(outputStem(end), '_') == 0
    outputStem = [outputStem '_'];
end

% initialize output list of files
singleChanCleanFileList = cell(size(singleChanFileList));

% clean each channel's data
for thisEEG = 1:length(singleChanFileList)
    % load
    EEG = pop_loadset(singleChanFileList{thisEEG});
    
    % clean
    [~, markedEEG, ~] = cleanDataset(EEG, epochSecs, numSD);
    
    % save
    outName = [outputSubDir outputStem EEG.chanlocs(1).labels '_epoched_marked.set'];
    singleChanCleanFileList{thisEEG} = outName;
    pop_saveset(markedEEG, outName);
end % thisEEG