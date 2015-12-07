function EEG = edf2eeg(filepath, patientID)

% Convert Sacramento data from EDF to EEGLAB structure. No
% changes are made to the data itself (i.e., no referencing).
%
% >> EEG = edf2eeg(filepath)
%
% Input:
%   filepath: path to the .edf file
%   patientID: string with the patient ID (e.g., 'UCDMC14')
%
% Output:
%   EEG: EEGLAB struct

% make an empty EEGLAB struct
EEG = eeg_emptyset();

% load data
[hdr, data] = edfread(filepath);

% populate patient info
EEG.setname = patientID;
EEG.subject = patientID;
EEG.filepath = filepath;


% may want to use the "session" field for info from the database
% (sessionID)

% populate EEG info
EEG.nbchan = hdr.ns;
EEG.srate  = hdr.samples(1);
EEG.start_date = hdr.startdate;
EEG.start_time = hdr.starttime;
EEG.chan_history.date = datestr(now);
EEG.chan_history.good_chans.electrode_name = [];
EEG.chan_history.good_chans.electrode_ind = [];
EEG.chan_history.bad_chans.label = [];
EEG.chan_history.bad_chans.electrode_name = [];
EEG.chan_history.bad_chans.electrode_ind = [];

EEG.reref.scheme = 'Common';
EEG.reref.date = datestr(now);
EEG.reref.chan.electrode_name = [];
EEG.reref.chan.electrode_ind = [];
EEG.reref.chan.ref_ind = [];

% insert electrode-wise info
multiWaitbar('Inputting electrode data', 0);
for thisElec = 1:EEG.nbchan
    multiWaitbar('Inputting electrode data', thisElec / EEG.nbchan);
    
    EEG.data(thisElec, :) = double(data(thisElec, :));
    
    chanName = hdr.label{thisElec};
    chanName = strrep(chanName, 'EEG', '');
    chanName = strrep(chanName, 'Ref', '');
    
    EEG.chanlocs(thisElec).labels = chanName;
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

% check EEG
EEG = eeg_checkset(EEG);