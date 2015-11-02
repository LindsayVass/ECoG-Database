function [filePath] = saveEEG(EEG, outputDir, subjID, resID, chanVerID, refVerID, artVerID, epochVerID)
% Save EEG file using a filename that indicates the patient, researcher,
% and version of the file. The version of the file is indicated with
% respect to channel inclusion, referencing scheme, artifact exclusion, and
% epoching scheme.
%
% Ex: TS071_LV_C01_R02_A03_E01.set
%   - Patient = TS071
%   - Researcher = LV
%   - Channels = version 01
%   - Referencing = version 02
%   - Artifacts = version 03
%   - Epochs = version 01
%
% >> [filePath] = saveEEG(EEG, outputDir, subjID, resID, chanVerID, refVerID, artVerID, epochVerID)
%
% Inputs:
%   EEG: EEGLAB structure to be saved
%   outputDir: path to the output directory to save the data to
%   subjID: string indicating the patient ID (e.g., 'TS071')
%   resID: string indicating the researcher (e.g., 'LV')
%   chanVerID: integer indicating the current version of channel
%       inclusion/exclusion scheme
%   refVerID: integer indicating the current version of referencing scheme
%   artVerID: integer indicating the current version of artifact exclusion
%   epochVerID: integer indicating the current version of epoching
%
% Output:
%   filePath: path to the saved EEG dataset

%% format file name

% if outputDir does not end with '/' then add it
if outputDir(end) ~= '/'
    outputDir = [outputDir '/'];
end

% check that IDs are integers
if isnumeric(chanVerID) == 0
    error('chanVerID must be an integer');
end
if isnumeric(refVerID) == 0
    error('refVerID must be an integer');
end
if isnumeric(artVerID) == 0
    error('artVerID must be an integer');
end
if isnumeric(epochVerID) == 0
    error('epochVerID must be an integer');
end

% check that outputDir exists
if ~exist(outputDir, 'dir')
    error('Output directory (outputDir) does not exist.')
end

filePath = [outputDir subjID '_' resID '_C' num2str(chanVerID, '%02d') '_R' num2str(refVerID, '%02d') '_A' num2str(artVerID, '%02d'), '_E' num2str(epochVerID, '%02d') '.set'];

% check whether a file exists by this name
if exist(filePath, 'file')
    error('A file exists with this name already. Check your version IDs.');
end

pop_saveset(EEG, filePath);