eeglab;

%% load raw .mat data from houston
subjDir = '/Users/Lindsay/Documents/ECoG Database/Sample Data/TS071/';
rawMat  = [subjDir 'ECoG_data/Retrieval_data_uncorr/ts071_EkstromRetrievalUncorr_sEEG.mat'];
load(rawMat);

%% convert from nkdata structure to EEGLAB structure
EEG = nkdata2eeg(nkdata);
clear nkdata;

%% save raw data as EEG mat
if ~exist([subjDir 'PreProcessing'], 'dir')
    mkdir([subjDir 'PreProcessing']);
end
pop_saveset(EEG, [subjDir 'PreProcessing/raw.set']);

%% check for electrodes with gross artifacts
EEG = pop_loadset([subjDir 'PreProcess/raw.set']);
eeglab redraw;

% if you have your own customized VISED_CONFIG, then load it here
% visedConfigPath = '/Users/Lindsay/Documents/ECoG Database/vised_config.mat';
% load(visedConfigPath);
% EEG = markBadChannels(EEG, VISED_CONFIG);

% otherwise, if you don't have a config file
EEG = markBadChannels(EEG);

% create an easy-to-read structure of marked channels
chanList = listBadChannels(EEG);
