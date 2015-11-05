function elecPairs = findAdjacentElectrodes(thisGeom)
% Given a rectangular matrix, return the indices of all pairs of adjacent
% electrodes. Includes only horizontally and vertically adjacent pairs.
% Will exclude any electrodes with zero values (i.e., cannot participate in
% a pair).
%
% Input: 
%   thisGeom: MxN matrix of integers
%
% Output:
%   elecPairs: Px2 matrix of indices

% make grid
[x, y] = meshgrid(1:size(thisGeom, 2), 1:size(thisGeom, 1));

% get valid points
goodVert = find(thisGeom);

% loop through points
elecPairs = [];
for thisVert = 1:length(goodVert)
    [y0, x0]  = ind2sub(size(thisGeom), goodVert(thisVert));
    
    % find adjacent points
    thisDist = sqrt((x - x0).^2 + (y - y0).^2);
    adjInd   = find(thisDist == 1);
    
    % exclude bad verts
    goodAdj = intersect(goodVert, adjInd);
    vertPairs = cat(2, repmat(goodVert(thisVert), [length(goodAdj) 1]), goodAdj);
    
    % remove duplicate pairs
    if thisVert > 1
        oppPairs = cat(2, vertPairs(:,2), vertPairs(:, 1));
        [~, dupRows, ~]  = intersect(oppPairs, elecPairs, 'rows');
        vertPairs(dupRows, :) = [];
    end
    
    elecPairs  = cat(1, elecPairs, vertPairs);
end