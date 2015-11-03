function [EEG, varargout] = markBadChannels(EEG, varargin)

% Mark bad channels that exhibit gross signal abnormalities as well as the
% marker channel for data synchronization. These flags are stored in the
% marks structure (EEG.marks.chan_info).
%
% Minimal example:
% >> [EEG] = markBadChannels(EEG)
%
% Maximal example:
% >> [EEG, id] = markBadChannels(EEG, id, VISED_CONFIG)
%
% Inputs:
%   EEG: EEGLAB struct
%
% Optional Inputs:
%   id: structure created by makeIdStruct.m
%   VISED_CONFIG: configuration structure for vised_marks plugin; must be
%       named 'VISED_CONFIG'
%
% Output:
%   EEG: EEGLAB struct containing an updated marks structure with flags for
%       bad channels and the marker channel
%
% Optional Output:
%   id: updated id structure

eeglab redraw;

if nargin == 3
    VISED_CONFIG = varargin{2};
else
    if nargin == 2
        id = varargin{1};
    end
    % load default VISED_CONFIG
    curPath = which('markBadChannels.m');
    tbInd = strfind(curPath, 'ECoG Database/');
    visedPath = [curPath(1:tbInd + 13) 'config/vised_config_marker_select.mat'];
    load(visedPath);
end

% check that id.channels is an integer
if exist('id', 'var')
    if isnumeric(id.channels) == 0
        error('id.channels must be an integer');
    end
    % increment channel version
    id.channels = id.channels + 1;
    varargout{1} = id;
end

% initialize marks structure
if isfield(EEG, 'marks') == 0
    EEG.marks = marks_init(size(EEG.data), 1);
end

% add marker channel label
if sum(strcmpi({EEG.marks.chan_info.label}, 'marker')) == 0
    EEG.marks = marks_add_label(EEG.marks, 'chan_info', {'marker', [1 0 0], [1 0 0], 1, zeros(EEG.nbchan, 1)});
end

origMarks = EEG.marks;
message = ['In the EEGLAB window, select Edit --> Visually edit in scroll plot. When the pop-up configuration window appears, select OK. \n\n' ...
    'Right click on any channels that exhibit gross signal abnormalities. Right click again to de-select a channel. \n\n' ...
    'To identify the marker channel, hold your cursor over the channel and press the M key. To de-select the channel, press M again. \n\n' ...
    'When complete, press Update EEG Structure button at bottom right. \n\n'...
    'DO NOT CLOSE THIS BOX OR PRESS OK UNTIL FINISHED!'];
h = msgbox(sprintf(message), 'Mark Bad Channels', 'help');



% after done marking channels...
waitfor(h);

% if anything changed 
if isequal(origMarks, EEG.marks) == 0
    
    % create easy-to-read structures of good and bad channels
    [goodChanList, badChanList] = makeChannelLists(EEG);
    
    % update chan_history
    EEG = updateChanHistory(EEG, goodChanList, badChanList);
else
    warning('No channels marked. Returning the same EEG.')
end



