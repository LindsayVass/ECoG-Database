%% Set up
eeglab;

% experiment directory, contains a folder for each patient
expDir = '/Users/Lindsay/Documents/ECoG Database/Sample Data/';

% patient ID, same as name of patient folder (expDir/subjID)
subjID     = 'TS071';
subjDir    = [expDir subjID '/'];
preprocDir = [subjDir 'PreProcessing/'];
if ~exist(preprocDir, 'dir')
    mkdir(preprocDir);
end

%% Load raw data 

%%%%%%%%%%%
% HOUSTON %
%%%%%%%%%%%

% path to nkdata .mat file
rawMat  = [subjDir 'ECoG_data/Retrieval_data_uncorr/ts071_EkstromRetrievalUncorr_sEEG.mat'];
load(rawMat);

EEG = nkdata2eeg(nkdata);
clear nkdata;
eeglab redraw;

% save raw data 
rawSavePath = [preprocDir subjID '_raw.set'];
pop_saveset(EEG, rawSavePath);

%%%%%%%%%%%%%%
% SACRAMENTO %
%%%%%%%%%%%%%%

% path to .edf file
rawEDF = [subjDir 'RawData/UCDMC14_020415_teleporter.edf'];

EEG = edf2eeg(rawEDF, subjID);
eeglab redraw;

% save raw data 
rawSavePath = [preprocDir subjID '_raw.set'];
pop_saveset(EEG, rawSavePath);

%% Flag electrodes with gross signal artifacts
EEG = pop_loadset(rawSavePath);
eeglab redraw;

% mark the marker channel and any obviously bad channels
EEG = markBadChannels(EEG);
keyboard;

% save updated version
chanSavePath = [preprocDir subjID '_chan_v1.set'];
pop_saveset(EEG, chanSavePath);

% modifications to the list of channels are stored in EEG.chan_history
disp(EEG.chan_history(end));

%% Re-reference the data
EEG = pop_loadset(chanSavePath);
eeglab redraw;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% using all good channels %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
EEGreref = rerefAllGoodChans(EEG);

% re-referencing details are stored in EEGreref.reref
disp(EEGreref.reref);

% view original data and rereferenced data together
% original = blue
% re-ref = gray
% excluded channels = gray with gray/red triangle next to channel name
EEG = pop_vised(EEG, 'data2', 'EEGreref.data');

% save updated version
rerefSavePath = [preprocDir subjID '_chan_v1_reref_all.set'];
pop_saveset(EEGreref, rerefSavePath);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% using mean of the strip/depth %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EEGreref = rerefStrip(EEG);

% re-referencing details are stored in EEGreref.reref
disp(EEGreref.reref);

% view original data and rereferenced data together
% original = blue
% re-ref = gray
% excluded channels = gray with gray/red triangle next to channel name
EEG = pop_vised(EEG, 'data2', 'EEGreref.data');

% save updated version
rerefSavePath = [preprocDir subjID '_chan_v1_reref_strip.set'];
pop_saveset(EEGreref, rerefSavePath);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% using bi-polar referencing %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[EEGreref, B] = rerefBipolar(EEG);
EEGreref.reref.origData = chanSavePath;

% re-referencing details are stored in EEGreref.reref
disp(EEGreref.reref);

% save updated version
rerefSavePath = [preprocDir subjID '_chan_v1_reref_bipolar.set'];
pop_saveset(EEGreref, rerefSavePath);

% save bipolar structure
bipolarFileName = [preprocDir subjID '_bipolar_referencing_structure.mat'];
save(bipolarFileName, 'B');

%% Perform artifact detection/removal

% prepare data
EEG = pop_loadset(rerefSavePath);
eeglab redraw;

outputDir  = [preprocDir 'artifact_detection/'];
outputStem = 'TS071_chan_v1_reref_strip_';

% Artifact detection works by identifying extreme values in each channel's
% data. We will calculate the mean and standard deviation of each channel's
% activity, and then set a threshold for extreme values based on the number
% of SDs away from the mean. 
% 
% For example, if a channel had mean = 100, SD = 10, and threshold of 5
% SDs, then values < 50 or > 150 would be flagged as extreme.
%
% After identifying the artifacts in each channel's data, we will merge the
% channels back together and exclude any time points that were flagged for
% any channel.

% The first step of the process is to split your dataset into multiple data
% sets containing one channel each. These single channel data sets will be
% stored in a folder called 'singleChan_unepoched_unmarked', which will be
% created inside the directory specified by "outputDir".
[singleChanFileList, markerPath] = splitDataset(EEG, outputDir, outputStem);

% Next, we will epoch each channel's data into short contiguous epochs, the
% length of which are defined by "epochSecs". It will flag any epoch
% containing extreme values, defined as a value that exceeds a certain
% number of standard deviations away from the mean (defined by "numSD").
% These epoched and marked files will be stored in a subdirectory of
% "outputDir" named "singleChan_epoched_marked".
%
% At this point, you have two options. You can either perform artifact
% detection at a single threshold, or you can perform it at a range of
% thresholds. This second option is useful if you want to compare artifact
% detection across thresholds or want to use different thresholds for
% different strips/grids/depths. In either case, you will get back a list
% of the newly created files. If your data set does not divide evenly by
% "epochSecs", your data will be padded with NaN and will return the number
% of samples to later trim when the data is recombined ("samplesToTrim").

%%%%%%%%%%%%%%%%%%%%
% Single Threshold %
%%%%%%%%%%%%%%%%%%%%
epochSecs = 1;
numSD     = 5;
[singleChanCleanFileList, samplesToTrim] = cleanDatasetOneThresh(singleChanFileList, outputDir, outputStem, epochSecs, numSD);

% Visualize the flags across channels and epochs, and get total number of
% flagged epochs for each channel. 
[flagsMatrix, flagSummary] = visualizeFlags(singleChanCleanFileList, numSD);

%%%%%%%%%%%%%%%%%%%%%%%
% Multiple Thresholds %
%%%%%%%%%%%%%%%%%%%%%%%
epochSecs = 1;
numSD     = 5:10;
[singleChanCleanFileList, samplesToTrim] = cleanDatasetMultiThresh(singleChanFileList, outputDir, outputStem, epochSecs, numSD);

% Visualize the flags across channels and epochs, and get total number of
% flagged epochs for each channel. Will be run for each threshold in numSD.
allFlagSummary = cell(length(numSD), 1);
for thisThresh = 1:length(numSD)
    [flagsMatrix, flagSummary] = visualizeFlags(singleChanCleanFileList, numSD(thisThresh));
    allFlagSummary(thisThresh) = {flagSummary};
end













%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OPTION 1: Recombine all channels %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To recombine all channels back into one file:
% Note that any time point flagged as bad for one channel will be flagged
% as bad for ALL channels, so you will probably lose a LOT of data this
% way.
mergeFileList = mergeAllDatasets(splitFileList, samplesToTrim, outputDir, outputStem);

% view time points marked for rejection 
EEG = pop_loadset(mergeFileList{1});
EEG = pop_vised(EEG);

% details about the artifact removal are stored in EEG.artifact_history
disp(EEG.artifact_history);
disp(EEG.artifact_history.artifacts.PercentBadEpochs);

% details about artifacts for each individual channel are stored in
% EEG.channel_artifact_history
disp(EEG.channel_artifact_history);

% details about each individual channel's re-referencing scheme are stored
% in EEG.channel_reref_history
disp(EEG.channel_reref_history);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OPTION 2: Recombine channels on the same strip/grid/depth %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For this to work, channels on the same strip must have the same string
% (e.g., LAD1, LAD2, LAD3 all share 'LAD'). Will be saved to a directory
% within outputDir called 'marked_merged'.
mergeFileList = mergeDatasetsByStrip(splitFileList, samplesToTrim, outputDir, outputStem);

% view time points marked for rejection (do for each strip by changing the
% number in fileList{1} below
EEG = pop_loadset(mergeFileList{1});
EEG = pop_vised(EEG);

% details about the artifact removal are stored in EEG.artifact_history
disp(EEG.artifact_history);
disp(EEG.artifact_history.artifacts.PercentBadEpochs);

% details about artifacts for each individual channel are stored in
% EEG.channel_artifact_history
disp(EEG.channel_artifact_history);

% details about each individual channel's re-referencing scheme are stored
% in EEG.channel_reref_history
disp(EEG.channel_reref_history);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OPTION 3: Recombine custom channels %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First, create a cell array of paths to each of the datasets you want to
% combine, e.g...
chanInds = [1,2,3,20,21,22];
eegPaths = splitFileList(chanInds);

% Then use same code as Option 1
mergeFileList = mergeAllDatasets(eegPaths, samplesToTrim, outputDir, outputStem);

% view time points marked for rejection 
EEG = pop_loadset(mergeFileList{1});
EEG = pop_vised(EEG);

% details about the artifact removal are stored in EEG.artifact_history
disp(EEG.artifact_history);
disp(EEG.artifact_history.artifacts.PercentBadEpochs);

% details about artifacts for each individual channel are stored in
% EEG.channel_artifact_history
disp(EEG.channel_artifact_history);

% details about each individual channel's re-referencing scheme are stored
% in EEG.channel_reref_history
disp(EEG.channel_reref_history);

%% Epoch the data from experimental events

% You will need a vector of latencies (latency in EEG.data samples, not
% seconds) and a cell array of event labels. Example below.
eventLatencies = [1234 5592 10975 30004 80761 92004 123456];
eventLabels    = {'space', 'time', 'space', 'space', 'time', 'time', 'space'};

% Epoch start and end times in seconds (where eventLatencies specified
% above = time 0)
eStart = -2;
eEnd   = 5;

% Where to save epoched data
epochDir  = [subjDir 'epoched_data/'];
system(['mkdir ' strrep(subjDir, ' ', '\ ') 'epoched_data/']);

for thisFile = 1:length(mergeFileList)
    % load merged data
    EEG = pop_loadset(mergeFileList{thisFile});
    
    % epoch data
    [EEG_epoch, epochInfo] = epochDataset(EEG, eventLatencies, eventLabels, eStart, eEnd);
    
    % save EEG
    epochSavePath = [epochDir EEG_epoch.filename(1:end-4) '_epoched.set'];
    pop_saveset(EEG_epoch, epochSavePath);
    
    % save epoch info
    epochInfoSavePath = [epochDir EEG_epoch.filename(1:end-4) '_epoch_info.mat'];
    save(epochInfoSavePath, 'epochInfo');
end