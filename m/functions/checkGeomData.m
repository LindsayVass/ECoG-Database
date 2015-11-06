function [dupCheck, elecCheck] = checkGeomData(geomData, stripName, chanNames)

% Check whether the geometric data input by the user meets two criteria:
%   1. No duplicate non-zero entries
%   2. Electrode numbers in geomData match electrode numbers in chanNames
%
% >> [dupCheck, elecCheck] = checkGeomData(geomData, stripName, chanNames)
%
% Inputs:
%   geomData: NxM matrix of integers, indicating the positions of
%       electrodes on the grid
%   stripName: string indicating the current grid (e.g. 'LAD')
%   chanNames: cell array of strings containing all channel names for the
%       recording
%
% Output:
%   dupCheck: boolean (true/false) indicating whether geomData passes the
%       no duplicate values check (true = good)
%   elecCheck: boolean (true/false) indicating whether geomData passes the
%       electrode number check (true = good)

%% check for duplicate non-zero entries
geomDataNoZero = geomData(geomData ~= 0);
if length(unique(geomDataNoZero)) < length(geomDataNoZero(:))
    dupCheck = false;
else
    dupCheck = true;
end

%% check that electrode numbers match those in chanNames

% strip numbers from the chan names
chanNamesNoNums = cellfun(@(x) x(regexp(x, '[^\d]')), chanNames, 'UniformOutput', false);
gridInds = find(strcmpi(chanNamesNoNums, stripName));
gridList = chanNames(gridInds);
gridNums = cellfun(@(x) str2num(x(regexp(x, '\d'))), gridList, 'UniformOutput', false);
gridNums = cat(1, gridNums{:});
if isequal(sort(geomDataNoZero(:)), sort(gridNums(:))) == 0
    elecCheck = false;
else
    elecCheck = true;
end