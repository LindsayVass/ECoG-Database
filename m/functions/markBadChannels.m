function EEG = markBadChannels(EEG, VISED_CONFIG)

% Mark bad channels that exhibit gross signal abnormalities as well as the
% marker channel for data synchronization. These flags are stored in the
% marks structure (EEG.marks.chan_info).
%
% >> EEG = markBadChannels(EEG)
%
% Input:
%   EEG: EEGLAB struct
%
% Optional Input:
%   VISED_CONFIG: configuration structure for vised_marks plugin
%
% Output:
%   EEG: EEGLAB struct containing an updated marks structure with flags for
%       bad channels and the marker channel

eeglab redraw;

% load VISED_CONFIG if not specified
if ~exist('VISED_CONFIG', 'var')
    curPath = which('markBadChannels.m');
    tbInd = strfind(curPath, 'ECoG Database/');
    visedPath = [curPath(1:tbInd + 13) 'config/vised_config_marker_select.mat'];
    load(visedPath);
end

% initialize marks structure
if isfield(EEG, 'marks') == 0
    EEG.marks = marks_init(size(EEG.data), 1);
end

% add marker channel label
EEG.marks = marks_add_label(EEG.marks, 'chan_info', {'marker', [1 0 0], [1 0 0], 1, zeros(EEG.nbchan, 1)});

message = ['In the EEGLAB window, select Edit --> Visually edit in scroll plot. When the pop-up configuration window appears, select OK. \n\n' ...
    'Right click on any channels that exhibit gross signal abnormalities. Right click again to de-select a channel. \n\n' ...
    'To identify the marker channel, hold your cursor over the channel and press the M key. To de-select the channel, press M again. \n\n' ...
    'When complete, press Update EEG Structure button at bottom right.'];
h = msgbox(sprintf(message));