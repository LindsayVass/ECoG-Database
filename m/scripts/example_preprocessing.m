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
origDataPath = '/Users/Lindsay/Documents/ECoG Database/Sample Data/UCDMC14/UCDMC14_TeleporterB_unepoched_RHD.set';
EEG = pop_loadset(origDataPath);
eeglab redraw;

outputDir = '/Users/Lindsay/Documents/ECoG Database/Sample Data/UCDMC14/Single_Chan_Data/';
outputStem = 'UCDMC14_TeleporterB_';

% split data sets
log = splitDataset(EEG, outputDir, outputStem);

