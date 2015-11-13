%% set up file naming

% experiment directory, contains a folder for each patient
expDir = '/Users/Lindsay/Documents/ECoG Database/Sample Data/';

% patient ID, same as name of patient folder (expDir/subjID)
subjID  = 'TS071';
subjDir = [expDir subjID '/'];

% id structure
id = makeIdStruct(subjID, 'LV');

eeglab;

%% load raw .mat data from houston

% path to nkdata .mat file
rawMat  = [subjDir 'ECoG_data/Retrieval_data_uncorr/ts071_EkstromRetrievalUncorr_sEEG.mat'];
load(rawMat);

%% convert from nkdata structure to EEGLAB structure
EEG = nkdata2eeg(nkdata);
clear nkdata;
eeglab redraw;

%% save raw data as EEG mat
preprocDir = [subjDir 'PreProcessing'];
if ~exist(preprocDir, 'dir')
    mkdir(preprocDir);
end

% save
filePath = saveEEG(EEG, preprocDir, id);

%% check for electrodes with gross signal artifacts
EEG = pop_loadset(filePath);
eeglab redraw;

% mark the marker channel and any obviously bad channels
EEG = markBadChannels(EEG);
keyboard;

% update id
id.channels = id.channels + 1;

% save updated version
filePath = saveEEG(EEG, preprocDir, id);

%% re-reference the data

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% using all good channels %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
EEGreref = rerefAllGoodChans(EEG);

% view original data and rereferenced data together
% original = blue
% re-ref = gray
% excluded channels = gray with gray/red triangle next to channel name
EEG = pop_vised(EEG, 'data2', 'EEGreref.data');

% update id
id.rereference = EEGreref.reref.scheme;

% save updated version
filePath = saveEEG(EEGreref, preprocDir, id);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% using mean of the strip/depth %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EEGreref = rerefStrip(EEG);

% view original data and rereferenced data together
% original = blue
% re-ref = gray
% excluded channels = gray with gray/red triangle next to channel name
EEG = pop_vised(EEG, 'data2', 'EEGreref.data');

% update id
id.rereference = EEGreref.reref.scheme;

% save updated version
filePath = saveEEG(EEGreref, preprocDir, id);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% using bi-polar referencing %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[EEGreref, B] = rerefBipolar(EEG);
EEGreref.reref.origData = [preprocDir 'TS071_LV_C01_Ref_Common_A00.set'];

% update id
id.rereference = EEGreref.reref.scheme;

% save updated version
filePath = saveEEG(EEGreref, preprocDir, id);

% save bipolar structure
bipolarFileName = [preprocDir subjID '_bipolar_referencing_structure.mat'];
save(bipolarFileName, 'B');

%% perform artifact detection/removal

% prepare data
origDataPath = '/Users/Lindsay/Documents/ECoG Database/Sample Data/TS071/PreProcessing/TS071_LV_C01_Ref_AllGoodChans_A00.set';
EEG = pop_loadset(origDataPath);
eeglab redraw;

outputDir = '/Users/Lindsay/Documents/ECoG Database/Sample Data/TS071/PreProcessing/C01_Ref_AllGoodChans_A00_Single_Chan_Data/';
outputStem = 'TS071_LV_C01_Ref_AllGoodChans_A00_';

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
[fileList, markerPath, samplesToTrim] = splitAndCleanDataset(EEG, outputDir, outputStem, epochSecs, numSD);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OPTION 1: Recombine all channels %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To recombine all channels back into one file:
% Note that any time point flagged as bad for one channel will be flagged
% as bad for ALL channels, so you will probably lose a LOT of data this
% way.
mergedEEG = mergeCleanedDatasets(fileList, samplesToTrim, markerPath);
fprintf('\n\n%0.1f%% of the data set marked as an artifact.\n', mergedEEG.artifact_history.artifacts.PercentBadEpochs)

% view time points marked for rejection
mergedEEG = pop_vised(mergedEEG);

% save 
savePath = [outputDir outputStem 'merged_clean.set'];
pop_saveset(mergedEEG, savePath);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OPTION 2: Recombine channels on the same strip/grid/depth %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For this to work, channels on the same strip must have the same string
% (e.g., LAD1, LAD2, LAD3 all share 'LAD')
fileList = mergeDatasetsByStrip(fileList, samplesToTrim, markerPath);

% view time points marked for rejection (do for each strip by changing the
% number in fileList{1} below
EEG = pop_loadset(fileList{1});
EEG = pop_vised(EEG);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OPTION 3: Recombine custom channels %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First, create a cell array of paths to each of the datasets you want to
% combine, e.g...
chanInds = [1,2,3,20,21,22];
eegPaths = fileList(chanInds);

% Then use same code as Option 1
mergedEEG = mergeCleanedDatasets(eegPaths, samplesToTrim, markerPath);

% view time points marked for rejection
mergedEEG = pop_vised(mergedEEG);

% save 
savePath = [outputDir outputStem 'merged_clean.set'];
pop_saveset(mergedEEG, savePath);

