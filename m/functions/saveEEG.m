function [verID, filePath] = saveEEG(EEG, outputDir, subjID, resID, verID)
% Save EEG file using a filename that indicates the patient, researcher,
% and version of the file.
%
% >> verID = saveEEG(EEG, outputDir, subjID, resID, verID)
%
% Inputs:
%   EEG: EEGLAB structure to be saved
%   outputDir: path to the output directory to save the data to
%   subjID: string indicating the patient ID (e.g., 'TS071')
%   resID: string indicating the researcher (e.g., 'LV')
%   verID: integer indicating the current version of the file (e.g., [1])
%
% Output:
%   verID: incremented version number
%   filePath: path to the saved EEG dataset

%% format file name

% if outputDir does not end with '/' then add it
if outputDir(end) ~= '/'
    outputDir = [outputDir '/'];
end

% check that verID is an integer
if isnumeric(verID) == 0
    error('verID must be an integer');
end

% check that outputDir exists
if ~exist(outputDir, 'dir')
    error('Output directory (outputDir) does not exist.')
end

filePath = [outputDir subjID '_' resID '_' num2str(verID, '%03d') '.set'];

% check whether a file exists by this name. if so, increment verID
while exist(filePath, 'file')
    warning('A file exists with this name already. Incrementing the version number before saving.');
    verID = verID + 1;
    filePath = [outputDir subjID '_' resID '_' num2str(verID, '%03d') '.set'];
end

pop_saveset(EEG, filePath);

verID = verID + 1;