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
    for thisStrip = 1:length(stripList);
        
        stripName = stripList{thisStrip};
        
        if B.(stripName).Include
            
            % get grid geometry using GUI
            geomData = geomGuide(stripList(thisStrip));
            
            % check that geomData structure is valid
            [dupCheck, elecCheck] = checkGeomData(geomData, stripName, chanNames);
            
            if dupCheck == true && elecCheck == true
                B.(stripName).Geometry = geomData;
            elseif dupCheck == false
                error('There are duplicate entries in the supplied geometry data.')
            elseif elecCheck == false
                error('The values supplied in the geometry data do not match the values in the list of channel names.')
            end
            
        end
    end
end

%% perform bipolar referencing

% prepare new EEG structure
EEGreref = EEG;
EEGreref.data = [];
EEGreref.chanlocs(:) = [];
EEGreref.reref.scheme = 'Bipolar';
EEGreref.reref.date   = datestr(now);


for thisStrip = 1:length(stripList)
    
    stripName = stripList{thisStrip};
    
    % if included get geometry
    if B.(stripName).Include
        
        % get this grid's geometry
        thisGeom = B.(stripName).Geometry;
        
        % find indices of adjacent electrodes
        adjInds = findAdjacentElectrodes(thisGeom);
        
        % loop through pairs
        for thisPair = 1:length(adjInds)
            
            % get channel names
            chan1 = [stripName num2str(thisGeom(adjInds(thisPair, 1)))];
            chan2 = [stripName num2str(thisGeom(adjInds(thisPair, 2)))];
            newChanName = [chan1 '_' chan2];
            
            % get channel indices
            chan1Ind = find(strcmpi({EEG.chanlocs.labels}, chan1));
            chan2Ind = find(strcmpi({EEG.chanlocs.labels}, chan2));
            newChanInd = length(EEGreref.chanlocs) + 1;
            
            % update chan info in EEG struct
            EEGreref.chanlocs(newChanInd).labels = newChanName;
            EEGreref.chanlocs(newChanInd).index  = newChanInd;
            EEGreref.chanlocs(newChanInd).ref    = 'bipolar';
            EEGreref.reref.chan(newChanInd).electrode_name = newChanName;
            EEGreref.reref.chan(newChanInd).electrode_ind  = newChanInd;
            EEGreref.reref.chan(newChanInd).ref_ind = [chan1Ind chan2Ind];
            EEGreref.reref.chan(newChanInd).ref_name = {chan1, chan2};
            
            % insert new chan data into EEG
            EEGreref.data(newChanInd, :) = EEG.data(chan1Ind, :) - EEG.data(chan2Ind, :);
            
        end
    end
end
