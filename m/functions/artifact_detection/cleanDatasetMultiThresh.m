function [singleChanCleanFileList, samplesToTrim] = cleanDatasetMultiThresh(singleChanFileList, outputDir, outputStem, epochSecs, numSD)
% Take a list of paths to single channel unepoched unmarked datasets
% (singleChanFileList) and clean each channel's data. Each channel's data
% will be split into contiguous epochs (length = epochSecs) and epochs
% containing extreme values (>numSD above or below the mean for that
% channel) will be flagged as bad. This function will perform artifact
% detection at a range of thresholds specified by numSD.
%
% >> [singleChanCleanFileList, samplesToTrim] = cleanDatasetMultiThresh(singleChanFileList, outputDir, outputStem, epochSecs, numSD)
%
% Inputs:
%   singleChanFileList: cell array containing paths to the single channel
%       unepoched unmarked data sets created by "splitDataset.m"
%   outputDir: string containing the path to the artifact detection output
%       directory; this function will create a subdirectory within it
%       called 'singleChan_epoched_marked' to hold the output data
%   outputStem: string containing the stem for file naming; the channel
%       name will be appended to the stem (e.g., stem = 'TS071' will
%       produce files like 'TS071_LH1.set', 'TS071_LH2.set')
%
% Optional Inputs:
%   epochSecs: length of epochs in seconds to divide the datasets into
%       (default = 1)
%   numSD: vector indicating the number of standard deviations above/below
%       the mean to use as a threshold for identifying epochs containing
%       extreme values (default = [5 6 7 8 9 10])
%
% Outputs:
%   singleChanCleanFileList: cell array of strings containing the path to
%       each of the newly created datasets
%   samplesToTrim: if the data set does not divide evenly into epochs of
%       length epochSecs, it will be padded with NaN; this value indicates
%       how many samples to trim later to return it to the original size

if nargin < 5
    numSD = [5 6 7 8 9 10];
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
outputSubDir = [outputDir 'singleChan_epoched_marked/'];
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

% prepare list of colors for labeling each threshold
colors = distinguishable_colors(length(numSD));

% clean each channel's data
for thisEEG = 1:length(singleChanFileList)
    
    % load
    EEG = pop_loadset(singleChanFileList{thisEEG});
    
    for thisThresh = 1:length(numSD)
        
        % clean
        [~, markedEEG, samplesToTrim] = cleanDataset(EEG, epochSecs, numSD(thisThresh));
        
        if thisThresh == 1
            finalEEG = markedEEG;
            markInd = find(strncmp('rejthresh', {markedEEG.marks.time_info.label}, 9));
            if ~isempty(markInd)
                finalEEG.marks.time_info(markInd).color = colors(thisThresh, :);
            end
        else
            % copy marks to finalEEG
            origMarkInd = find(strncmp('rejthresh', {markedEEG.marks.time_info.label}, 9));
            newMarkInd  = length(finalEEG.marks.time_info) + 1;
            if ~isempty(origMarkInd)
                finalEEG.marks.time_info(newMarkInd) = markedEEG.marks.time_info(origMarkInd);
                finalEEG.marks.time_info(newMarkInd).color = colors(thisThresh, :);
            end
            finalEEG.artifact_history(end + 1) = markedEEG.artifact_history(1);
        end
        
    end % thisThresh
    
    % save
    outName = [outputSubDir outputStem EEG.chanlocs(1).labels '_epoched_marked.set'];
    singleChanCleanFileList{thisEEG} = outName;
    pop_saveset(finalEEG, outName);
    
end % thisEEG