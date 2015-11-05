% TEST1: 3x3 full
geom1 = ones(3,3);
elecPairs1 = findAdjacentElectrodes(geom1);
if length(elecPairs1) ~= 12
    error('Test1 returned incorrect number of pairs.')
end

% TEST2: 3x3 with zero in middle
geom2 = geom1;
geom2(2,2) = 0;
elecPairs2 = findAdjacentElectrodes(geom2);
if length(elecPairs2) ~= 8
    error('Test2 returned incorrect number of pairs.')
end

% TEST3: 3x3 with 2x2 of zeros
geom3 = geom1;
geom3(2:3, 2:3) = 0;
elecPairs3 = findAdjacentElectrodes(geom3);
if length(elecPairs3) ~= 4
    error('Test3 returned incorrect number of pairs.')
end

% TEST4: 2x2 of zeros
geom4 = zeros(2,2);
elecPairs4 = findAdjacentElectrodes(geom4);
if length(elecPairs4) ~= 0
    error('Test4 returned incorrect number of pairs.')
end
