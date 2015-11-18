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

% setup vised configuration
VISED_CONFIG                  = visedconfig_obj;
VISED_CONFIG.marks_y_loc      = 0.8;
VISED_CONFIG.inter_mark_int   = 0.04;
VISED_CONFIG.inter_tag_int    = 0.002;
VISED_CONFIG.marks_col_int    = 0.1;
VISED_CONFIG.marks_col_alpha  = 0.7;
VISED_CONFIG.spacing          = 1000;
VISED_CONFIG.winlength        = 10;
VISED_CONFIG.dispchans        = 15;
VISED_CONFIG.command          = 'EEG=ve_update(EEG);EEG.saved = ''no'';EEG=updateChannels(EEG);';
VISED_CONFIG.butlabel         = 'Update EEG structure';
VISED_CONFIG.wincolor         = [0.7, 1, 0.9];
VISED_CONFIG.selectcommand    = {'ve_eegplot(''defdowncom'',gcbf);', 've_eegplot(''defmotioncom'',gcbf);', 've_eegplot(''defupcom'', gcbf);'};
VISED_CONFIG.altselectcommand = {'ve_edit(''quick_chanflag'',''manual'');', 've_eegplot(''defmotioncom'', gcbf);', ''};
VISED_CONFIG.extselectcommand = {'ve_edit;', 've_eegplot(''defmotioncom'', gcbf);', ''};
VISED_CONFIG.keyselectcommand = {'t,ve_eegplot(''topoplot'',gcbf)'; 'r,ve_eegplot(''drawp'',0)'; 'm,ve_edit(''quick_chanflag'',''marker'');'};


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





