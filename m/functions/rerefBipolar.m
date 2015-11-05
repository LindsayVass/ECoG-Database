function [EEGreref, B] = rerefBipolar(EEG, B)

% Re-reference the data using a bi-polar referencing scheme that creates
% virtual electrodes by differencing the signals from adjacent pairs of
% electrodes. For example, if you have electrodes 1-5 arranged on a strip,
% this will produce virtual electrodes A-D.
%
% Original: 1---2---3---4---5
% Re-ref:   --A---B---C---D--
%
% For grids with two dimensions, you will be asked to input a geometry
% scheme, and virtual electrodes will be constructed for all horizontal and
% vertical pairs of electrodes (see Figure 1C Burke et al. (2013) J Neuro).
%
% Input:
%   EEG: EEGLAB structure containing data to be re-referenced. By default,
%       this function will not re-reference any channels flagged in
%       EEG.marks.chan_info. These channels also will not contribute to the
%       mean time series used to re-reference the data. If the EEGLAB data
%       does not contain the EEG.marks structure, it will produce a warning
%       and use all channels for re-referencing.
%
% Optional Input:
%   B: structure containing bi-polar data (output by this file); if
%       supplied, will be used instead of asking for user input
%
% Outputs:
%   EEGreref: EEGLAB structure containing the re-referenced data.
%   B: structure containing bi-polar type (strip vs grid), geometry (grids
%   only)

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

%% create bipolar structure
if ~exist('B', 'var')
    createB = 1;
end

%% ask user which strips/depths to perform bi-polar referencing on
if createB
    B = makeBipolarStruct(stripList);
    B = StructDlg(B);
end
%% get user input for grid geometry
if createB
    global geomData;
    rerefStrips = {};
    for thisStrip = 1:length(stripList);
        if B.(stripList{thisStrip}).Include == 1
            rerefStrips(end + 1) = stripList(thisStrip);
            
            % make new geomGui window
            geomGui(stripList(thisStrip));
            h = findobj('Tag', 'GeomFigure');
            uiwait(h);
            
            % check that there are no non-zero duplicate entries
            geomDataNoZero = geomData(geomData ~= 0);
            if length(unique(geomDataNoZero)) < length(geomDataNoZero(:))
                error('Duplicate electrode entry in table.')
            end
            
            % check that the inputted values match the electrode numbers
            gridInds = find(strcmpi(stripNames, stripList{thisStrip}));
            gridList = chanNames(gridInds);
            gridNums = cellfun(@(x) str2num(x(regexp(x, '\d'))), gridList, 'UniformOutput', false);
            gridNums = cat(1, gridNums{:});
            if length(intersect(geomDataNoZero, gridNums)) < length(gridNums)
                error('Inputted electrode numbers do not match those in EEG.')
            end
            
            B.(stripList{thisStrip}).Geometry = geomData;
            
        end
    end
end


% %% update EEG.reref
EEGreref = EEG;
% EEGreref.reref.scheme = 'Strip/Depth';
% EEGreref.reref.date   = datestr(now);
% EEGreref.reref.chan.electrode_name = deal(chanNames)';
% EEGreref.reref.chan.electrode_ind  = deal(1:1:EEG.nbchan)';
% EEGreref.reref.chan.ref_ind = cell(EEG.nbchan, 1);
%
% %% re-reference the data
% multiWaitbar('Re-referencing each strip/depth...', 0);
% for thisStrip = 1:length(stripList)
%     multiWaitbar('Re-referencing each strip/depth...', thisStrip / length(stripList));
%
%     % indices on this strip
%     stripInds     = find(strcmpi(stripNames, stripList(thisStrip)));
%     goodStripInds = intersect(stripInds, goodChanInds);
%
%     % calculate ref data
%     refData = mean(EEG.data(goodStripInds, :), 1);
%     EEGreref.data(goodStripInds, :) = EEGreref.data(goodStripInds, :) - repmat(refData, [length(goodStripInds) 1]);
%
%     % update EEG.reref.chan.ref_ind
%     EEGreref.reref.chan.ref_ind(goodStripInds) = {goodStripInds};
% end
% multiWaitbar('Re-referencing each strip/depth...', 'Close');

