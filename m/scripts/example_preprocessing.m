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
visedConfigPath = '/Users/Lindsay/Documents/ECoG Database/vised_config.mat';
load(visedConfigPath);
eeglab redraw;

EEG = markBadChannels(EEG, VISED_CONFIG);

