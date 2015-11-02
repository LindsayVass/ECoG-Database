function id = makeIdStruct(patient, researcher)
% Create a basic structure for storing file ID information.
%
% >> id = makeIdStruct(patient, researcher)
%
% Inputs:
%   patient: string indicating the patient number ('TS071')
%   researcher: string indicating the researcher's initials ('LV')
%
% Output:
%   id: structure containing the following fields:
%       - patient
%       - researcher
%       - channels (version number for channel exclusion
%       - rereference (type of re-referencing scheme)
%       - artifacts (version number for artifact exclusion)
%       - epoch (type of epoching scheme)

id.patient = patient;
id.researcher = researcher;
id.channels = 0;
id.rereference = 'Common';
id.artifacts = 0;
id.epoch = '';