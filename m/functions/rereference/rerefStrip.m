function EEGreref = rerefStrip(EEG)

% Re-reference the data separately for each strip/depth. The mean of all
% good channels on the strip/depth will be subtracted from each electrode.
% For example, for depth LAD, containing LAD1 LAD2 LAD3, the re-referenced
% LAD1 signal is: LAD1 - mean(LAD1, LAD2, LAD3).
%
% Input:
%   EEG: EEGLAB structure containing data to be re-referenced. By default,
%       this function will not re-reference any channels flagged in
%       EEG.marks.chan_info. These channels also will not contribute to the
%       mean time series used to re-reference the data. If the EEGLAB data
%       does not contain the EEG.marks structure, it will produce a warning
%       and use all channels for re-referencing.
%
% Output:
%   EEGreref: EEGLAB structure containing the re-referenced data.

%% check for EEG.marks
if isfield(EEG, 'marks') == 0
    warning('EEG does not contain marks structure and goodChanInds has not been specified. Using all channels for re-referencing.')
    goodChanInds = [1:1:EEG.nbchan];
else
    allFlags = [EEG.marks.chan_info.flags];
    allFlags = sum(allFlags, 2);
    goodChanInds = find(allFlags == 0);
end

%% check if data has been previously re-referenced
if isfield(EEG, 'reref') == 0
    warning('Unable to determine if this data set has already been re-referenced. Proceed with caution!');
else
    if strcmpi(EEG.reref.scheme, 'common') == 0
        error('According to EEG.reref, this dataset has already been referenced.')
    end
end

%% identify channels on each strip/depth

% assumes each strip/depth has same character string (e.g., LAD), but
% varying integers (e.g., LAD1 LAD2 LAD3)

chanNames  = {EEG.chanlocs.labels};
stripNames = cellfun(@(x) x(regexp(x, '[^\d]')), chanNames, 'UniformOutput', false);
stripList  = unique(stripNames);


%% update EEG.reref
EEGreref = EEG;
EEGreref.reref.scheme = 'Strip/Depth';
EEGreref.reref.date   = datestr(now);
EEGreref.reref.chan.electrode_name = deal(chanNames)';
EEGreref.reref.chan.electrode_ind  = deal(1:1:EEG.nbchan)';
EEGreref.reref.chan.ref_ind = cell(EEG.nbchan, 1);

%% re-reference the data
multiWaitbar('Re-referencing each strip/depth...', 0);
for thisStrip = 1:length(stripList)
    multiWaitbar('Re-referencing each strip/depth...', thisStrip / length(stripList));
    
    % indices on this strip
    stripInds     = find(strcmpi(stripNames, stripList(thisStrip)));
    goodStripInds = intersect(stripInds, goodChanInds);
    
    % calculate ref data
    refData = mean(EEG.data(goodStripInds, :), 1);
    EEGreref.data(goodStripInds, :) = EEGreref.data(goodStripInds, :) - repmat(refData, [length(goodStripInds) 1]);
    
    % update EEG.reref.chan.ref_ind
    EEGreref.reref.chan.ref_ind(goodStripInds) = {goodStripInds};
end
multiWaitbar('Re-referencing each strip/depth...', 'Close');

