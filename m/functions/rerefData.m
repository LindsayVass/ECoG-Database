function timeseriesReref = rerefData(timeseriesOrig, timeseriesRef)

% Re-reference a time series of data (timeseriesOrig) using the mean of the
% data in timeseriesRef.
%
% Inputs:
%   timeseriesOrig: 1xN vector of EEG data to be re-referenced
%   timeseriesRef: MxN vector of EEG data to be used as the reference
%
% Output:
%   timeseriesReref: 1xN vector of EEG data where each time point is the
%       difference between timeseriesOrig and the mean signal for
%       timeseriesRef
%

if size(timeseriesOrig, 2) ~= size(timeseriesRef, 2)
    error('EEG data and reference data have different numbers of time points.')
end

meanRef = mean(timeseriesRef, 1);

timeseriesReref = timeseriesOrig - meanRef;