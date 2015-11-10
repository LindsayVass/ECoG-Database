function log = splitDataset(EEG, outputDir, outputStem)
% Split one EEG dataset containing N channels into N datasets containing
% one channel each.
%
% >> log = splitDataset(EEG, outputDir, outputStem)
%
% Inputs:
%   EEG: EEGLAB struct
%   outputDir: string containing the path to the directory in which to save
%       the newly created datasets
%   outputStem: string containing a stem for the filename for each new
%       dataset; the channel name will be appended to the end of the stem;
%       for example:
%       outputStem: 'UCDMC14_Session1_ReRef_Strip_'
%       fileName:   'UCDMC14_Session1_ReRef_Strip_LHD1.set'
%
% Output:
%   log: cell array containing the paths to the newly created data sets

% check that outputDir ends with '/'
if strcmpi(outputDir(end), '/') == 0
    outputDir = [outputDir '/'];
end

% if outputDir doesn't exist, create it
if ~exist(outputDir, 'dir')
    outputDirNoSpace = strrep(outputDir, ' ', '\ ');
    system(['mkdir ' outputDirNoSpace]);
end

% check that outputStem ends with '_'
if strcmpi(outputStem(end), '_') == 0
    outputStem = [outputStem '_'];
end

% get list of good channels from marks structure
if isfield(EEG, 'marks')
    allFlags  = [EEG.marks.chan_info.flags];
    allFlags  = sum(allFlags, 2);
    goodChans = find(allFlags == 0);
else
    warning('EEG.marks structure not found. Will create a new data set for every channel.')
    goodChans = 1:1:size(EEG.data,1);
end

% initialize log
log = cell(length(goodChans), 1);

for thisChan = 1:length(goodChans)
    % initialize new EEG structure
    newEEG = EEG;
    
    thisChanName = EEG.chanlocs(thisChan).labels;
    outputPath = [outputDir outputStem thisChanName '.set'];
    log{thisChan} = outputPath;
    
    % update EEG structure
    newEEG.filename = [outputStem thisChanName '.set'];
    newEEG.filepath = outputPath;
    newEEG.nbchan   = 1;
    newEEG.data     = [];
    newEEG.data     = EEG.data(thisChan, :);
    newEEG.chanlocs = [];
    newEEG.chanlocs = EEG.chanlocs(thisChan);
    newEEG.datfile  = [outputStem thisChanName '.fdt'];
    
    % update chan_history
    if isfield(newEEG, 'chan_history')
        histInd = length(newEEG.chan_history) + 1;
    else
        histInd = 1;
    end
    
    newEEG.chan_history(histInd).date = datestr(now);
    newEEG.chan_history(histInd).good_chans.electrode_name = thisChanName;
    newEEG.chan_history(histInd).good_chans.electrode_ind = 1;
    newEEG.chan_history(histInd).bad_chans = [];
    
    % initialize new marks structure
    if isfield(newEEG, 'marks')
        newEEG = rmfield(newEEG, 'marks');
    end
    newEEG.marks = marks_init(size(newEEG.data), 1);
    
    % save new dataset
    pop_saveset(newEEG, outputPath);
end