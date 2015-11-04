function EEG = markBadChannels(EEG)

% Prepare EEG for marking bad channels. This function will do the
% following:
%   - Initialize EEG.marks structure if one does not exist
%   - Add "marker" label to EEG.marks.chan_info if one does not exist
%   - Create a popup window with instructions for marking channels
%   - Load the Vised EEG window
%
% After 'Update EEG Structure' is clicked in EEG window, it will update
% EEG.chan_history with the changes.
%
% >> EEG = setupMarkChannels(EEG)
%
% Inputs:
%   EEG: EEGLAB struct
%
% Output:
%   EEG: EEGLAB struct containing an updated marks structure with flags for
%       bad channels and the marker channel
%

eeglab redraw;

% load vised configuration
curPath = which('markBadChannels.m');
tbInd = strfind(curPath, 'ECoG Database/');
visedPath = [curPath(1:tbInd + 13) 'config/vised_config_marker_select.mat'];
load(visedPath);

% initialize marks structure
if isfield(EEG, 'marks') == 0
    EEG.marks = marks_init(size(EEG.data), 1);
end

% add marker channel label
if sum(strcmpi({EEG.marks.chan_info.label}, 'marker')) == 0
    EEG.marks = marks_add_label(EEG.marks, 'chan_info', {'marker', [1 0 0], [1 0 0], 1, zeros(EEG.nbchan, 1)});
end

origMarks = EEG.marks;
message = ['When the pop-up configuration window appears, select OK. \n\n' ...
    'Right click on any channels that exhibit gross signal abnormalities. Right click again to de-select a channel. \n\n' ...
    'To identify the marker channel, hold your cursor over the channel and press the M key. To de-select the channel, press M again. \n\n' ...
    'When complete, press Update EEG Structure button at bottom right. \n\n'];
h = msgbox(sprintf(message), 'Mark Bad Channels', 'help');

EEG = pop_vised(EEG);





