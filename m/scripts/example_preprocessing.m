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

% update id
id.channels = id.channels + 1;

% save updated version
filePath = saveEEG(EEG, preprocDir, id);

