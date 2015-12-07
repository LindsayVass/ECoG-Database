function [filePath] = saveEEG(EEG, outputDir, id)
% Save EEG file using a filename that indicates the patient, researcher,
% and version of the file. The version of the file is indicated with
% respect to channel inclusion, referencing scheme, artifact exclusion, and
% epoching scheme.
%
% Ex: TS071_LV_C01_Ref_Common_A03_Ep_Cue.set
%   - Patient = TS071
%   - Researcher = LV
%   - Channels = version 01
%   - Referencing = 'Common'
%   - Artifacts = version 03
%   - Epochs = 'Cue'
%
% >> [filePath] = saveEEG(EEG, outputDir, id)
%
% Inputs:
%   EEG: EEGLAB structure to be saved
%   outputDir: path to the output directory to save the data to
%   id: structure created by makeIdStruct.m
%
% Output:
%   filePath: path to the saved EEG dataset

%% format file name

% if outputDir does not end with '/' then add it
if outputDir(end) ~= '/'
    outputDir = [outputDir '/'];
end

% check that IDs are integers
if isnumeric(id.channels) == 0
    error('id.channels must be an integer');
end
if isnumeric(id.artifacts) == 0
    error('id.artifacts must be an integer');
end
if ischar(id.patient) == 0
    error('id.patient must be a string');
end
if ischar(id.researcher == 0)
    error('id.researcher must be a string');
end
if ischar(id.rereference == 0)
    error('id.rereference must be a string');
end
if ischar(id.epoch == 0)
    error('id.epoch must be a string');
end

% check that outputDir exists
if ~exist(outputDir, 'dir')
    error('Output directory does not exist.')
end

if strcmpi(id.epoch, '') == 1
    filePath = [outputDir id.patient '_' id.researcher '_C' num2str(id.channels, '%02d') '_Ref_' id.rereference '_A' num2str(id.artifacts, '%02d') '.set'];
else
    filePath = [outputDir id.patient '_' id.researcher '_C' num2str(id.channels, '%02d') '_Ref_' id.rereference '_A' num2str(id.artifacts, '%02d') '_Ep_' id.epoch '.set'];
end
    
% check whether a file exists by this name
if exist(filePath, 'file')
    error('A file exists with this name already. Check your id structure.');
end

pop_saveset(EEG, filePath);