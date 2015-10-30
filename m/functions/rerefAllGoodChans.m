function EEGreref = rerefAllGoodChans(EEG, goodChanInds)

% Re-reference the data by subtracting from each electrode the mean time
% series across all good channels. 

% Input:
%   EEG: EEGLAB structure containing data to be re-referenced. By default,
%       this function will not re-reference any channels flagged in
%       EEG.marks.chan_info. These channels also will not contribute to the
%       mean time series used to re-reference the data. If the EEGLAB data
%       does not contain the EEG.marks structure, it will produce a warning
%       and use all channels for re-referencing.
%
% Optional Input:
%   goodChanInds: If you wish to use a different set of channels than the
%       ones not flagged in EEG.marks.chan_info, you can submit it as a
%       vector of indices here.
%
% Output:
%   EEGreref: EEGLAB structure containing the re-referenced data.

%% identify good channels
if exist('goodChanInds', 'var')
else
    if isfield(EEG, 'marks') == 0
        warning('EEG does not contain marks structure and goodChanInds has not been specified. Using all channels for re-referencing.')
        goodChanInds = [1:1:EEG.nbchan];
    else
        allFlags = [EEG.marks.chan_info.flags];
        allFlags = sum(allFlags, 2);
        goodChanInds = find(allFlags == 0);
    end
end

%% re-reference the data
origData  = EEG.data(goodChanInds, :);
refData   = mean(EEG.data(goodChanInds, :), 1);
refData   = repmat(refData, [size(origData, 1) 1]);
rerefData = origData - refData;

%% put the new data into the new EEG structure
EEGreref  = EEG;
EEGreref.data(goodChanInds, :) = rerefData(:, :);