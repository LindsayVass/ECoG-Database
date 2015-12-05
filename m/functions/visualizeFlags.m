function [flagsMatrix, flagSummary] = visualizeFlags(splitFileList)
% Examine the prevalence of flagged data points for all channels.
%
% >> flagsMatrix = visualizeFlags(splitFileList)
%
% Input:
%   splitFileList: cell array of paths to the single-channel flagged
%       datasets (output by splitAndCleanDataset.m)
%
% Outputs:
%   flagsMatrix: channels x time points matrix of flag data
%   flagSummary: table containing the total number of flagged time points
%       for each channel, arranged in descending order

% get flag data and channel name for each file in the list
channelNames = cell(length(splitFileList), 1);
for thisFile = 1:length(splitFileList)
    EEG = pop_loadset(splitFileList(thisFile));
    channelNames{thisFile} = EEG.chanlocs(1).labels;
    
    flagInd = find(strcmpi('rejthresh', {EEG.marks.time_info.label}));
    if isempty(flagInd)
        warning(['No flags found for ' channelNames{thisFile}]);
        if thisFile == 1
            flagsMatrix = zeros(1, size(EEG.data, 3));
        else
            flagsMatrix(end+1,:) = zeros(1, size(EEG.data, 3));
        end
    else
        if thisFile == 1
            flagsMatrix = squeeze(EEG.marks.time_info(flagInd).flags(:,1,:))';
        else
            flagsMatrix(end+1,:) = squeeze(EEG.marks.time_info(flagInd).flags(:,1,:))';
        end
    end
end

% plot flag data
figure;
imagesc(flagsMatrix);
title('Flagged epochs for all channels and time points (Red = Bad)');
xlabel('Epoch Index');
ylabel('Channel Index');

% summarize flag data
flagsTotal = sum(flagsMatrix, 2);
[flagsTotalSorted, sortInd] = sort(flagsTotal, 1, 'descend');
channelNamesSorted = channelNames(sortInd);
flagSummary = table(channelNamesSorted, flagsTotalSorted, sortInd, 'VariableNames', {'Channel_Name', 'Total_Flags', 'Channel_Index'});