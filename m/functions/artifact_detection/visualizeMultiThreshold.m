function mergedEEG = visualizeMultiThreshold(singleChanCleanFileList, numSD)
% Visualize data that has been flagged for artifacts at multiple
% thresholds.
%
% >> mergedEEG = visualizeMultiThreshold(singleChanCleanFileList, numSD)
%
% Inputs:
%   singleChanCleanFileList: cell array of strings containing the paths to
%       the single channel epoched and marked data sets
%   numSD: vector containing the thresholds used to detect artifacts
%
% Output:
%   mergedEEG: EEG structure containing all of the datasets in
%       singleChanCleanFileList


% combine data from all channels
mergedEEG = mergeEpochedDatasets(singleChanCleanFileList);

% if thresh >= 10, flags will be in incorrect order, so fix that now
if max(numSD) >= 10
    labels = {mergedEEG.marks.time_info.label};
    rejLabelInds = find(strncmp('rejthresh', labels, 9));
    nonRejLabelInds = setdiff([1:length(labels)], rejLabelInds);
    rejLabels = labels(rejLabelInds);
    rejLabelNums = cellfun(@(x) x(regexp(x, '[\d]')), rejLabels, 'UniformOutput', false);
    rejLabelNums = str2double(rejLabelNums);
    [~, ind] = sort(rejLabelNums, 'ascend');
    rejLabels = rejLabels(ind);
    ind = [nonRejLabelInds ind + length(nonRejLabelInds)];
    mergedEEG.marks.time_info = mergedEEG.marks.time_info(ind);
    
end

% plot data
mergedEEG = pop_vised(mergedEEG);