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

filePath = [outputDir subjID '_' resID '_' num2str(verID, '%03d') '.set'];

pop_saveset(EEG, filePath);

verID = verID + 1;