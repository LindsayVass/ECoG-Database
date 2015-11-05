% Test whether checkGeomData.m is working as expected

% load chanNames
load('/Users/Lindsay/Documents/ECoG Database/m/test/test_checkGeomData.mat');

% TEST1: too few electrodes
% Should PASS dupCheck
% Should FAIL elecCheck
stripName1 = 'PC';
geomData1  = [1 2 3 4; 0 0 7 8; 9 10 11 12];
[dupCheck1, elecCheck1] = checkGeomData(geomData1, stripName1, chanNames);
if dupCheck1 == false
    error('Test1 dupCheck should be true, but is false.')
end
if elecCheck1 == true
    error('Test1 elecCheck should be false, but is true.')
end

% TEST2: too many electrodes
% Should PASS dupCheck
% Should FAIL elecCheck
stripName2 = 'PC';
geomData2  = [1 2 3 4; 0 0 7 8; 9 10 11 12; 13 14 15 16; 17 18 19 20];
[dupCheck2, elecCheck2] = checkGeomData(geomData2, stripName2, chanNames);
if dupCheck2 == false
    error('Test2 dupCheck should be true, but is false.')
end
if elecCheck2 == true
    error('Test2 elecCheck should be false, but is true.')
end

% TEST3: duplicate electrodes
% Should FAIL dupCheck
% Should FAIL elecCheck
stripName3 = 'PC';
geomData3  = [1 2 3 4; 7 0 7 8; 9 10 11 12];
[dupCheck3, elecCheck3] = checkGeomData(geomData3, stripName3, chanNames);
if dupCheck3 == true
    error('Test3 dupCheck should be false, but is true.')
end
if elecCheck3 == true
    error('Test3 elecCheck should be false, but is true.')
end

% TEST4: wrong electrode numbers
% Should PASS dupCheck
% Should FAIL elecCheck
stripName4 = 'PC';
geomData4  = [1 2 3 4; 7 8 9 10; 11 12 13 14; 18 19 0 0];
[dupCheck4, elecCheck4] = checkGeomData(geomData4, stripName4, chanNames);
if dupCheck4 == false
    error('Test4 dupCheck should be true, but is false.')
end
if elecCheck4 == true
    error('Test4 elecCheck should be false, but is true.')
end

% TEST5: good data
% Should PASS dupCheck
% Should PASS elecCheck
stripName5 = 'PC';
geomData5  = [1 2 3 4; 0 0 7 8; 9 10 11 12; 13 14 15 16];
[dupCheck5, elecCheck5] = checkGeomData(geomData5, stripName5, chanNames);
if dupCheck5 == false
    error('Test5 dupCheck should be true, but is false.')
end
if elecCheck5 == false
    error('Test5 elecCheck should be true, but is false.')
end
