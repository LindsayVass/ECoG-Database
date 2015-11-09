function mergedEEG = mergeCleanedDatasets(eegPaths)
% Given a cell array of paths to clean EEG data sets, load all data sets,
% and merge them together, keeping only time points which are clean across
% all data sets.
%
% >> mergedEEG = mergeCleanedDatasets(eegPaths)
%
% Input:
%   eegPaths: cell array of paths to cleaned EEG data sets
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
    error('All data sets must have same epoch length.')
end
if length(unique(sizeCheck(:,3))) > 1
    error('All data sets must have same number of epochs.')
end