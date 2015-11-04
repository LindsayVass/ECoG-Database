function B = makeBipolarStruct(stripList)
% Create a basic structure for inputting strip/grid/depth data for bi-polar
% referencing. Used with StructDlg.
%
% Input:
%   stripList: cell array of strings containing the names of each
%       grid/strip/depth

for thisStrip = 1:length(stripList)
    B.(stripList{thisStrip}).Include = { {'{0}' '1'} };
    B.(stripList{thisStrip}).Type = { '1xN Strip/Depth|MxN Grid' };
end
