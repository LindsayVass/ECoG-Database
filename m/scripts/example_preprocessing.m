
% load raw .mat data from houston
subjDir = '/Users/Lindsay/Documents/ECoG Database/Sample Data/TS071/';
rawMat  = [subjDir 'ECoG_data/Retrieval_data_uncorr/ts071_EkstromRetrievalUncorr_sEEG.mat'];
load(rawMat);

% convert from nkdata structure to EEGLAB structure
EEG = nkdata2eeg(nkdata);