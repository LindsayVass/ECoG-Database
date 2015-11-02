function EEG = nkdata2eeg(nkdata, filepath)

% Convert Houston data from nkdata structure to EEGLAB structure. No
% changes are made to the data itself (i.e., no referencing).
%
% >> EEG = importNkData(nkdata, filepath)
% Input:
%   nkdata: output struct from Houston; contains the following fields:
%       pt_code
%       task
%       eeg
%       multiplier
%       num_dpoints
%       nchannels
%       bsweep
%       ms_per_sample
%       binsuV
%       start_time
%       sampHz
%       ch_names
%       pulse_on
%       pulse_off
%       articulation
%       rxn_time
%       accuracy
%       ref_vec
%       ref_tseries
%
% Optional Input:
%   filepath: path to the .mat file containing the nkdata struct
%
% Output:
%   EEG: EEGLAB struct

% make an empty EEGLAB struct
EEG = eeg_emptyset();

% populate patient info
EEG.setname = nkdata.pt_code;
EEG.subject = nkdata.pt_code;
if exist('filepath', 'var')
    EEG.filepath = filepath;
end
EEG.task = nkdata.task;
% may want to use the "session" field for info from the database
% (sessionID)

% populate EEG info
EEG.nbchan = nkdata.nchannels;
EEG.srate  = nkdata.sampHz;
EEG.start_time = nkdata.start_time;
EEG.chan_history.chanVerID = 0;
EEG.chan_history.date = datestr(now);
EEG.chan_history.good_chans.electrode_name = [];
EEG.chan_history.good_chans.electrode_ind = [];
EEG.chan_history.bad_chans.label = [];
EEG.chan_history.bad_chans.electrode_name = [];
EEG.chan_history.bad_chans.electrode_ind = [];

% insert electrode-wise info
multiWaitbar('Inputting electrode data', 0);
for thisElec = 1:EEG.nbchan
    multiWaitbar('Inputting electrode data', thisElec / EEG.nbchan);
    
    EEG.data(thisElec, :)         = double(nkdata.eeg(thisElec, :));
    EEG.chanlocs(thisElec).labels = strtrim(nkdata.ch_names(thisElec, :));
    EEG.chanlocs(thisElec).hemisphere = [];
    EEG.chanlocs(thisElec).lobe = [];
    EEG.chanlocs(thisElec).gyrus = [];
    EEG.chanlocs(thisElec).X = [];
    EEG.chanlocs(thisElec).Y = [];
    EEG.chanlocs(thisElec).Z = [];
    EEG.chanlocs(thisElec).type = [];
end
multiWaitbar('Inputting electrode data', 'Close');

% populate good_chans
for thisLabel = 1:EEG.nbchan
    EEG.chan_history.good_chans(thisLabel).electrode_ind = thisLabel;
    EEG.chan_history.good_chans(thisLabel).electrode_name = {EEG.chanlocs(thisLabel).labels}';
end