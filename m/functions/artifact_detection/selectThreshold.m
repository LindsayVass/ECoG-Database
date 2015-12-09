function singleChanSingleThreshCleanFileList = selectThreshold(singleChanCleanFileList, numSD)
% Visualize data that has been flagged for artifacts at multiple thresholds
% and select the desired threshold to use.
%
% >> singleChanSingleThreshCleanFileList = selectThreshold(singleChanCleanFileList, numSD)
%
% Inputs:
%   singleChanCleanFileList: cell array of strings containing the paths to
%       the single channel epoched and marked data sets
%   numSD: vector containing the thresholds used to detect artifacts
%
% Output:
%   singleChanSingleThreshCleanFileList: cell array of strings containing
%       the paths to the single channel epoched and marked data sets, each
%       of which only contains flags for a single threshold


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
    ind = [nonRejLabelInds ind + length(nonRejLabelInds)];
    mergedEEG.marks.time_info = mergedEEG.marks.time_info(ind);
end

% setup vised configuration
global VISED_CONFIG;
VISED_CONFIG                  = visedconfig_obj;
VISED_CONFIG.marks_y_loc      = 0.8;
VISED_CONFIG.inter_mark_int   = 0.04;
VISED_CONFIG.inter_tag_int    = 0.002;
VISED_CONFIG.marks_col_int    = 0.1;
VISED_CONFIG.marks_col_alpha  = 0.7;
VISED_CONFIG.spacing          = 1000;
VISED_CONFIG.winlength        = 10;
VISED_CONFIG.dispchans        = 15;
VISED_CONFIG.command          = 'EEG=ve_update(EEG);EEG.saved = ''no'';EEG=updateChannels(EEG);';
VISED_CONFIG.butlabel         = 'Update EEG structure';
VISED_CONFIG.wincolor         = [0.7, 1, 0.9];
VISED_CONFIG.selectcommand    = {'ve_eegplot(''defdowncom'',gcbf);', 've_eegplot(''defmotioncom'',gcbf);', 've_eegplot(''defupcom'', gcbf);'};
VISED_CONFIG.altselectcommand = {'ve_edit(''quick_chanflag'',''manual'');', 've_eegplot(''defmotioncom'', gcbf);', ''};
VISED_CONFIG.extselectcommand = {'ve_edit;', 've_eegplot(''defmotioncom'', gcbf);', ''};
VISED_CONFIG.keyselectcommand = {'t,ve_eegplot(''topoplot'',gcbf)'; 'r,ve_eegplot(''drawp'',0)'; 'm,ve_edit(''quick_chanflag'',''marker'');'};
