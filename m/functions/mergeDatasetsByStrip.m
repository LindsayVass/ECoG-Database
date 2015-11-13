function fileList = mergeDatasetsByStrip(eegPaths, samplesToTrim, outputDir, outputStem, markerPath)
% Given a cell array of paths to clean EEG data sets, merge them back
% together by creating a new data set for each strip/grid/depth.
%
% >> fileList = mergeDatasetsByStrip(eegPaths, samplesToTrim, markerPath)
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
%   fileList: cell array of paths to the newly created data sets

%% load data
for thisEEG = 1:length(eegPaths)
    EEG(thisEEG) = pop_loadset(eegPaths{thisEEG});
end

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

%% get list of strips/depths/grids
chanList = cell(size(eegPaths));
for thisEEG = 1:length(eegPaths)
    chanList{thisEEG} = EEG(thisEEG).chanlocs.labels;
end

stripList  = chanList;
stripList  = cellfun(@(x) x(regexp(x, '[^\d]')), chanList, 'UniformOutput', false);
stripNames = unique(stripList);

%% merge each strip
fileList = cell(size(stripNames));
for thisStrip = 1:length(stripNames)
    stripInd = find(strcmpi(stripNames{thisStrip}, stripList));
    thisEEGList = eegPaths(stripInd);
    
    if exist('markerPath', 'var')
        mergedEEG = mergeCleanedDatasets(thisEEGList, samplesToTrim, markerPath);
    else
        mergedEEG = mergeCleanedDatasets(thisEEGList, samplesToTrim);
    end
    
    % save
    savePath = [outputDir outputStem stripNames{thisStrip} '.set'];
    pop_saveset(mergedEEG, savePath);
    fileList{thisStrip} = savePath;
end