function fileList = mergeAllDatasets(eegPaths, outputDir, outputStem, markerPath)
% Given a cell array of paths to clean EEG data sets, merge them back
% together by creating a new data set for each strip/grid/depth.
%
% >> fileList = mergeAllDatasets(eegPaths, samplesToTrim, outputDir, outputStem, markerPath)
%
% Inputs:
%   eegPaths: cell array of paths to cleaned EEG data sets
%   samplesToTrim: number of samples to trim from the dataset (i.e., the
%       number of NaNs the data set was padded with)
%   outputDir: directory to save newly created merged data sets
%   outputStem: filename stem to use for newly created data sets; the strip
%       name will be appended to this stem
%
% Optional Input:
%   markerPath: path to the marker channel data set; if provided, will be
%       appended to each new data set
%
% Output:
%   fileList: cell array of path to the newly created data set

%% prep output
% make the output directory if it doesn't exist
if ~exist(outputDir, 'dir')
    outputDirNoSpace = strrep(outputDir, ' ', '\ ');
    system(['mkdir ' outputDirNoSpace]);
end

if strcmpi(outputDir(end), '/') == 0
    outputDir = [outputDir '/'];
end

if strcmpi(outputStem(end), '_') == 0
    outputStem = [outputStem '_'];
end

outputDirMerged = [outputDir 'multiChan_continuous_marked/'];

if ~exist('outputDirNoSpace', 'var')
    outputDirNoSpace = strrep(outputDir, ' ', '\ ');
end
outputDirMergedNoSpace = [outputDirNoSpace 'multiChan_continuous_marked/'];
system(['mkdir ' outputDirMergedNoSpace]);

%% merge data
if exist('markerPath', 'var')
    mergedEEG = mergeCleanedDatasets(eegPaths, markerPath);
else
    mergedEEG = mergeCleanedDatasets(eegPaths);
end

% save
savePath = [outputDirMerged outputStem '.set'];
pop_saveset(mergedEEG, savePath);
fileList = savePath;

% save file list
save([outputDirMerged 'fileList.mat'], 'fileList');