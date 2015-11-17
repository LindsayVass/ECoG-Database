%% set up file naming
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

%% load raw data 

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

%% flag electrodes with gross signal artifacts
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

%% re-reference the data
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

%% perform artifact detection/removal

% prepare data
EEG = pop_loadset(rerefSavePath);
eeglab redraw;

outputDir  = [preprocDir 'artifact_detection/'];
outputStem = 'TS071_chan_v1_reref_strip_';

% Clean the data for each channel separately. This next function will first
% split your dataset into multiple data sets containing one channel each.
% These are contained in a folder called 'dirty_unepoched', which is
% created inside outputDir. It will then epoch each channel's data into
% short consecutive epochs (length = epochSecs). Finally, it will flag any
% epoch that contains extreme values, defined as a value that exceeds a
% certain number of standard deviations away from the mean (threshold =
% numSD). These marked and epoched files will be contained in a folder
% called 'clean_epoched', also found in outputDir. 
%
% If your data set does not divide evenly by epochSecs, it will pad the
% data with NaN and return the number of samples to later trim when the
% data is recombined (samplesToTrim).
epochSecs = 1;
numSD     = 5;
[splitFileList, markerPath, samplesToTrim] = splitAndCleanDataset(EEG, outputDir, outputStem, epochSecs, numSD);

% The next step is to recombine the data from each individual channel.
% There are three options for doing this, detailed below. In each case, the
% merged data will be saved in a folder called 'marked_merged' in
% outputDir.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OPTION 1: Recombine all channels %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To recombine all channels back into one file:
% Note that any time point flagged as bad for one channel will be flagged
% as bad for ALL channels, so you will probably lose a LOT of data this
% way.
mergeFileList = mergeAllDatasets(splitFileList, samplesToTrim, outputDir, outputStem, markerPath);

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
mergeFileList = mergeDatasetsByStrip(splitFileList, samplesToTrim, outputDir, outputStem, markerPath);

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
mergeFileList = mergeAllDatasets(eegPaths, samplesToTrim, outputDir, outputStem, markerPath);

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

