% Code to preprocess all subjects for temporal dynamics project
% All subject specific UDIs are located here!
% 10/10/14

%clear all
%close all

%%% UDIs

%addpath(genpath('/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Code'))
%addpath('/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Subjects')

subjects = {'TA434','TA436','TA439','TA441','TA451','TA501','TA517','TA627',...
    'TA633','TA641','TS028','TS033','TS038','TS043','TS048','TS050','TS050B',...
    'TS067','TS068','TS071'};
sub_proc = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0];
% Note: Extract sync event may need to be modified for '.' and ':'

create_eeg = 0;
insert_trigger = 0;
choose_chan = 0;
filter_data = 0;
no_rereference = 0;
reference = 1;
remove_epoch = 0;

%%%

subjects = subjects(find(sub_proc));

for i_sub = 1:length(subjects)
    
    switch subjects{i_sub}
        case 'TA434'
            old_sub = 1;
            preprocess = 1;
            grids = 1;
            depths = 0;
            recode_behavior = 0;
            subject_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Subjects/TA434/';
            save_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Temporal_Dynamics/Ekstrom_434/';
            unepoch_savefile = 'unepoch_434';
            epoch_savefile = 'epoch_434';
            bad_chans = [3 15 17 21 25 43 52 53 57 59 60 62:64 58 81:83 89 92:98];
            bad_epoch = [33];
        case 'TA436'
            old_sub = 1;
            preprocess = 0;
            grids = 1;
            depths = 0;
            recode_behavior = 0; %93 spat, 100 temp
            subject_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Subjects/TA436/';
            save_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Temporal_Dynamics/Ekstrom_436/';
            unepoch_savefile = 'unepoch_436';
            epoch_savefile = 'epoch_436';
            bad_chans = [1 9 17 65 67 90 95 96 105 107:109 111 117];
            bad_epoch = [9 22 36 44 49 54 56 58 61 67 69 70];
        case 'TA439'
            old_sub = 1;
            preprocess = 0;
            grids = 1;
            depths = 0;
            recode_behavior = 0; %83 spat, 88 temp
            subject_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Subjects/TA439/';
            save_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Temporal_Dynamics/Ekstrom_439/';
            unepoch_savefile = 'unepoch_439';
            epoch_savefile = 'epoch_439';
            bad_chans = [40 52 84 88 92 102 111:120 122];
            bad_epoch = [4 12 13 18 30 33 40 43 52 66 69];
        case 'TA441'
            old_sub = 1;
            preprocess = 1;
            grids = 1;
            depths = 0;
            recode_behavior = 0; %67 spat, 75 temp
            subject_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Subjects/TA441/';
            save_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Temporal_Dynamics/Ekstrom_441/';
            unepoch_savefile = 'unepoch_441';
            epoch_savefile = 'epoch_441';
            bad_chans = [4:8 10:12 14:20 24 25 32 33 36:39 41 47:49 57 61:63 77:80 89:92 97:100 103 109 112 114];
            bad_epoch = [33 44 46 48 51 57 58 70];
        case 'TA451'
            old_sub = 1;
            preprocess = 0;
            grids = 1;
            depths = 0;
            recode_behavior = 0;
            subject_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Subjects/TA451/';
            save_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Temporal_Dynamics/Ekstrom_451/';
            unepoch_savefile = 'unepoch_451';
            epoch_savefile = 'epoch_451';
            bad_chans = [2:7 10:12 15 18 22 23 25 26 31 32 42 45 52 56 58:63 71 72 82:85 89 94:96 98];
            bad_epoch = [4 18 21 47];
        case 'TA501'
            old_sub = 1;
            preprocess = 1;
            grids = 1;
            depths = 0;
            recode_behavior = 0;
            subject_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Subjects/TA501/';
            save_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Temporal_Dynamics/Ekstrom_501/';
            unepoch_savefile = 'unepoch_501';
            epoch_savefile = 'epoch_501';
            %bad_chans = [1 9 32 33 37 46 47 60 65:75 81 85 87:108]; %Maybe a typo?
            bad_chans = [1 9 32 33 37 46 47 60 64:75 81 85 97:108];
            bad_epoch = [70];
        case 'TA517'
            old_sub = 1;
            preprocess = 1;
            grids = 1;
            depths = 1; 
            recode_behavior = 1;
            subject_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Subjects/TA517/';
            save_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Temporal_Dynamics/Ekstrom_517/';
            unepoch_savefile = 'unepoch_517';
            epoch_savefile = 'epoch_517';
            bad_chans = [31 32 64];
            bad_epoch = [4 8 16 19 25 34 36 41 51 62];
        case 'TA627'
            % Spike artifact around marker -> ignore this time bin
            old_sub = 0;
            preprocess = 1;
            grids = 0;
            depths = 1;
            recode_behavior = 0;
            subject_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Subjects/TA627/';
            save_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Temporal_Dynamics/Ekstrom_627/';
            unepoch_savefile = 'unepoch_627';
            epoch_savefile = 'epoch_627';
            bad_chans = [2 55 65 66 151 183 189:256];
            bad_epoch = [];
        case 'TA633'
            % CORRELATED
            old_sub = 0;
            preprocess = 1;
            grids = 1;
            depths = 0;
            recode_behavior = 0;
            subject_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Subjects/TA633/';
            save_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Temporal_Dynamics/Ekstrom_633/';
            unepoch_savefile = 'unepoch_633';
            epoch_savefile = 'epoch_633';
            bad_chans = [2 4 64:66 80 85 88 89 95 108 114 143];
            bad_epoch = [4:7 12 18 28 46 59 64 66 67 72 73 79];
        case 'TA641'
            old_sub = 0;
            preprocess = 1;
            grids = 0;
            depths = 1;
            recode_behavior = 0;
            subject_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Subjects/TA641/';
            save_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Temporal_Dynamics/Ekstrom_641/';
            unepoch_savefile = 'unepoch_641';
            epoch_savefile = 'epoch_641';
            bad_chans = [2 4 21 33 65 66 97 130 171 191 192];
            bad_epoch = [1 4 9 10 14 21 25 29 34 47 49 50 62 63];
        case 'TS028'
            % No localization info and questionable behavior => wait to process
            old_sub = 1;
            preprocess = 1;
            grids = 1;
            depths = 1;
            recode_behavior = 1;
            subject_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Subjects/TS028/';
            save_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Temporal_Dynamics/Ekstrom_028/';
            unepoch_savefile = 'unepoch_028';
            epoch_savefile = 'epoch_028';
            bad_chans = [];
            bad_epoch = [];
        case 'TS033'
            % Bad HPC elecs -> only a grids patient
            old_sub = 0;
            preprocess = 1;
            grids = 1;
            depths = 0;
            recode_behavior = 1;
            subject_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Subjects/TS033/';
            save_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Temporal_Dynamics/Ekstrom_33/';
            unepoch_savefile = 'unepoch_033';
            epoch_savefile = 'epoch_033';
            bad_chans = [53:56 80 125:128 157 158 160];
            bad_epoch = [46 61 68 70];
        case 'TS038'
            old_sub = 0;
            preprocess = 0;
            grids = 0;
            depths = 1;
            recode_behavior = 0;
            subject_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Subjects/TS038/';
            save_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Temporal_Dynamics/Ekstrom_038/';
            unepoch_savefile = 'unepoch_038';
            epoch_savefile = 'epoch_038';
            bad_chans = [];
            bad_epoch = [];
        case 'TS043'
            old_sub = 0;
            preprocess = 1;
            grids = 0;
            depths = 1;
            recode_behavior = 0;
            subject_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Subjects/TS043/';
            save_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Temporal_Dynamics/Ekstrom_43/';
            unepoch_savefile = 'unepoch_043';
            epoch_savefile = 'epoch_043';
            bad_chans = [5 6 14 21:24 66 89 100 117 193:256];
            bad_epoch = [];
        case 'TS048'
            old_sub = 0;
            preprocess = 1;
            grids = 0;
            depths = 1;
            recode_behavior = 0; % Spat: 42.5% Temp: 90%
            subject_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Subjects/TS048/';
            save_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Temporal_Dynamics/Ekstrom_48/';
            unepoch_savefile = 'unepoch_48';
            epoch_savefile = 'epoch_48';
            bad_chans = [2 66 87 88 89 153:256];
            bad_epoch = [1 16 21 41 43 50 59 71];
        case 'TS050'
            old_sub = 0;
            preprocess = 1;
            grids = 0;
            depths = 1;
            uncorr = 1;
            recode_behavior = 0;
            subject_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Subjects/TS050/';
            save_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Temporal_Dynamics/Ekstrom_50/';
            unepoch_savefile = 'unepoch_050';
            epoch_savefile = 'epoch_050';
            bad_chans = [2 31 32 63:68 78 85 106 163:256];
            bad_epochs = [];
        case 'TS050B'
            old_sub = 0;
            preprocess = 1;
            grids = 0;
            depths = 1; %Only put 1 because no localization info (coordinates)
            uncorr = 1;
            recode_behavior = 0;
            subject_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Subjects/TS050B/';
            save_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Temporal_Dynamics/Ekstrom_50B/';
            unepoch_savefile = 'unepoch_050B';
            epoch_savefile = 'epoch_050B';
            if uncorr
                bad_chans = [];
                bad_epoch = [6 36 37 43 44 72 79];
            else
                bad_chans = [];
                bad_epoch = [];
            end
        case 'TS067'
            old_sub = 0;
            preprocess = 1;
            grids = 0;
            depths = 1; %Only put 1 because no localization info (coordinates)
            uncorr = 1;
            recode_behavior = 0; % Spat 88% Temp 88%
            %subject_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Subjects/TS067/';
            subject_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Subjects/TS067/';
            save_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Temporal_Dynamics/Ekstrom_67/';
            unepoch_savefile = 'unepoch_67';
            epoch_savefile = 'epoch_67';
            bad_chans = [1 2 4 8 9 33 34 65 66 97 130];
            wm_chans = [];
            bad_epoch = [];
        case 'TS068'
            old_sub = 0;
            preprocess = 1;
            grids = 0;
            depths = 1; %Only put 1 because no localization info (coordinates)
            uncorr = 1;
            recode_behavior = 0; % Spat 62.5% Temp 72.5%
            subject_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Subjects/TS068/';
            save_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Temporal_Dynamics/Ekstrom_68/';
            unepoch_savefile = 'unepoch_68';
            epoch_savefile = 'epoch_68';
            bad_chans = [1 2 4 16 32 34 56:58 64:66 97 130 151];
            chosen_chans = [10 14 29 47 50 62 78 80 95 105 107 109 112 116 127 131 139 153];
            %plot_labels = {'ACC','SFG','IFG','MFG','ACC','MFG','IPL','Calc','AMY','TP','HPC','HPC',...
            %    'HPC','HPC','HPC','ITG','MTG','MTG','PHG','PHG','PHG','MTG','TP','TP'};
            %wm_chans = [1 14 17 18 22 42 56:58 64 72:74 101:104 136 137 159];
            %bad_chans = unique([bad_chans wm_chans]);
            %bad_epoch = [19 36 47 50 51 57 64 65 74 79 80];
        case 'TS071'
            old_sub = 0;
            preprocess = 1;
            grids = 0;
            depths = 1;
            uncorr = 1;
            recode_behavior = 0; % Spat 77.5% Temp 97.5%
            subject_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Subjects/TS071/';
            save_dir = '/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Temporal_Dynamics/Ekstrom_71/';
            unepoch_savefile = 'unepoch_71';
            epoch_savefile = 'epoch_71';
            bad_chans = [37:39 61:63 95:97 129 130 132];
            wm_chans = [15 16 37:43 47 48 57:61 63 70 77 78 82:86 93 115:118 136:138 175];
            %bad_chans = unique([bad_chans wm_chans]);
            bad_epoch = [];
    end
    
    if create_eeg
        
        cd (subject_dir)
        
        % Find behavioral file
        all_files = rdir('**/*.mat');
        cd_files = {all_files.name};
        [s,v] = listdlg('PromptString','Select Subject#_Data.mat file','SelectionMode','single','ListString',cd_files,'ListSize',[500 500]);
        behav_filename = [subject_dir,cd_files{s}]; % full path and file name
        load(behav_filename)
        
        % Recode behavior because of wrong response keys used
        if recode_behavior
            load(behav_filename)
            [spat_acc,temp_acc] = recode_houston_retrieval_behavior(behav_filename,'L','R');
        else
            temp_acc = temporal_acc;
        end
        
        % Load patient LFP data converted to mat format (nkdata structure)
        [s,v] = listdlg('PromptString','Select nkdata file','SelectionMode','single','ListString',cd_files,'ListSize',[500 500]);
        LFP_filename = [subject_dir,cd_files{s}]; % full path and file name
        load(LFP_filename)
        
        % Load localization info
        if grids && ~depths
            
            local_files = strfind(cd_files,'localization');
            local_files = cd_files(find(~cellfun(@isempty,local_files)));
            [s,v] = listdlg('PromptString','Select Subject#_localization.mat file','SelectionMode','single','ListString',local_files,'ListSize',[500 500]);
            local_filename = [subject_dir,local_files{s}]; % full path and file name
            if ~isempty(s)
                load(local_filename)
                foo = who('*localization');
                localization = eval(foo{1});
            end
            
            coord_files = strfind(cd_files,'coords');
            coord_files = cd_files(find(~cellfun(@isempty,coord_files)));
            [s,v] = listdlg('PromptString','Select Subject#_localization.mat file','SelectionMode','single','ListString',coord_files,'ListSize',[500 500]);
            coord_filename = [subject_dir,coord_files{s}]; % full path and file name
            if ~isempty(s)
                load(coord_filename)
                foo = who('*_coord*');
                coords = eval(foo{1});
            end
            
        elseif depths && ~grids
            localization = [];
            coords = ones(size(nkdata.eeg,1),3);
        elseif depths && grids
            
            local_files = strfind(cd_files,'localization');
            local_files = cd_files(find(~cellfun(@isempty,local_files)));
            [s,v] = listdlg('PromptString','Select Subject#_localization.mat file','SelectionMode','single','ListString',local_files,'ListSize',[500 500]);
            local_filename = [subject_dir,local_files{s}]; % full path and file name
            if ~isempty(s)
                load(local_filename)
                foo = who('*localization');
                localization = eval(foo{1});
            end
            coords = ones(size(nkdata.eeg,1),3);
        end
        
        % Ensures the bad channels are not included in the average
        nkdata.ref_vec(bad_chans) = 0;
        %nkdata.ref_vec([1 3:5 11:15 21:25 31 32 34 35 67:81 84:90],1) = 1;
        
        % Put in EEG struct
        EEG = eeg_emptyset;
        EEG.setname = nkdata.pt_code;
        EEG.filename = nkdata.pt_code;
        EEG.srate = nkdata.sampHz;
        EEG.start_time = nkdata.start_time;
        EEG.ref_vec = nkdata.ref_vec;
        ctr=1;
        
        %COI = [1:114 127:128]; %TA441
        
        for istruct = 1:size(nkdata.eeg,1) %COI
            
            %if isempty(strfind(nkdata.ch_names(istruct,:),'empty')) ; %only use real channels
                
                EEG.data(ctr,:) = double(nkdata.eeg(istruct,:)); %Comment out for TA434 TA436 TA441 TA501
                %EEG.chanlocs(ctr).labels = nkdata.ch_names{istruct,:};
                EEG.chanlocs(ctr).labels = nkdata.ch_names(istruct,:);
                %EEG.chanlocs(ctr).theta = 1;
                %EEG.chanlocs(ctr).radius = 1;
                EEG.chanlocs(ctr).X = coords(istruct,1);
                EEG.chanlocs(ctr).Y = coords(istruct,2);
                EEG.chanlocs(ctr).Z = coords(istruct,3);
                EEG.chanlocs(ctr).type = istruct;
                %EEG.chanlocs(ctr).lobe = localization.lobe(istruct);
                %EEG.chanlocs(ctr).gyrus = localization.gyrus(ctr);
                %EEG.chanlocs(ctr).hemisphere = localization.elec_hemisphere(istruct);
                %EEG.chanlocs(ctr).spikes = NaN;
                %EEG.chanlocs(ctr).seizure_onsets = NaN;
                ctr=ctr+1;
                
            %end
            
        end
        
        %nkdata.eeg = nkdata.eeg./nkdata.multiplier; %TA434 TA436 TA441 TA501
        %EEG.data = double(nkdata.eeg); %TA434 TA436 TA441 TA501
        %EEG.data = EEG.data(COI,:); %TA441
        EEG.nbchan = size(EEG.data,1);
        ch_names = nkdata.ch_names;
        %ch_names = mat2cell(ch_names,ones(size(nkdata.ch_names,1),1));
        %[EEG,~] = eeg_checkset(EEG);
        
        clear nkdata
        
        pop_eegplot(EEG,1,1,1);

        cd(save_dir)
        
        if exist('retrieval_onsets.mat','file') ~=2
            
            % Request pulse channel #
            chz = {EEG.chanlocs.labels};
            [pulse_channel_number] = listdlg('PromptString','Select pulse channel:','SelectionMode','single','ListString',chz);
            
            % Extract pulses
            % User needs to have found the time of the first pulse in the
            % plot output above.
            [realonset,interpolated] = Extract_sync_event_Houston_v3(EEG,pulse_channel_number,master_event_list,2);
            
            save('retrieval_onsets','realonset','interpolated','pulse_channel_number');
            
        else
            load('retrieval_onsets.mat')
        end
        
    end
    
    if insert_trigger
        
        % Make vector of accuracy by duplicating and concatenating temporal and spatial_acc
        full_spat_acc_vector = repmat(spat_acc,2,1);
        full_spat_acc_vector = full_spat_acc_vector(:)';
        
        full_temp_acc_vector = repmat(temp_acc,2,1);
        full_temp_acc_vector = full_temp_acc_vector(:)';
        
        if strcmp(master_event_list.block{1},'Space')
            all_acc = [full_spat_acc_vector full_temp_acc_vector];
        else
            all_acc = [full_temp_acc_vector full_spat_acc_vector];
        end
        
        % Insert trigger events into data and get indices for different conditions
        event_counter = 1;
        cue_spat_corr_idx = [];
        cue_spat_incorr_idx = [];
        cue_temp_corr_idx = [];
        cue_temp_incorr_idx = [];
        resp_spat_corr_idx = [];
        resp_spat_incorr_idx = [];
        resp_temp_corr_idx = [];
        resp_temp_incorr_idx = [];
        
        for n = 1:length(realonset)
            
            EEG.event(event_counter).latency = realonset(n);
            
            if strcmp(master_event_list.eventtype{event_counter},'Stores_onset') && strcmp(master_event_list.block{event_counter},'Space') && all_acc(event_counter) == 1 %cue spatial correct
                EEG.event(event_counter).type = '111';
                cue_spat_corr_idx = [cue_spat_corr_idx;event_counter];
            elseif strcmp(master_event_list.eventtype{event_counter},'Stores_onset') && strcmp(master_event_list.block{event_counter},'Space') && all_acc(event_counter) == 0 %cue spatial incorrect
                EEG.event(event_counter).type = '112';
                cue_spat_incorr_idx = [cue_spat_incorr_idx;event_counter];
            elseif strcmp(master_event_list.eventtype{event_counter},'Stores_onset') && strcmp(master_event_list.block{event_counter},'Time') && all_acc(event_counter) == 1 %cue temporal correct
                EEG.event(event_counter).type = '121';
                cue_temp_corr_idx = [cue_temp_corr_idx;event_counter];
            elseif strcmp(master_event_list.eventtype{event_counter},'Stores_onset') && strcmp(master_event_list.block{event_counter},'Time') && all_acc(event_counter) == 0 %cue temporal incorrect
                EEG.event(event_counter).type = '122';
                cue_temp_incorr_idx = [cue_temp_incorr_idx;event_counter];
            elseif strcmp(master_event_list.eventtype{event_counter},'Response') && strcmp(master_event_list.block{event_counter},'Space') && all_acc(event_counter) == 1 %response spatial correct
                EEG.event(event_counter).type = '211';
                resp_spat_corr_idx = [resp_spat_corr_idx;event_counter];
            elseif strcmp(master_event_list.eventtype{event_counter},'Response') && strcmp(master_event_list.block{event_counter},'Space') && all_acc(event_counter) == 0 %response spatial incorrect
                EEG.event(event_counter).type = '212';
                resp_spat_incorr_idx = [resp_spat_incorr_idx;event_counter];
            elseif strcmp(master_event_list.eventtype{event_counter},'Response') && strcmp(master_event_list.block{event_counter},'Time') && all_acc(event_counter) == 1 %response temporal correct
                EEG.event(event_counter).type = '221';
                resp_temp_corr_idx = [resp_temp_corr_idx;event_counter];
            elseif strcmp(master_event_list.eventtype{event_counter},'Response') && strcmp(master_event_list.block{event_counter},'Time') && all_acc(event_counter) ==0 %response temporal incorrect
                EEG.event(event_counter).type = '222';
                resp_temp_incorr_idx = [resp_temp_incorr_idx;event_counter];
            end
            
            event_counter = event_counter + 1;
        end
        
        [EEG,~] = eeg_checkset(EEG);
        cd(save_dir)
        save('original_EEG_struct','EEG','-v7.3');
        
    end
    
    %keyboard
    %EEG = pop_loadset('cue_unepoch_67_noreref_filter.set');
    %load('original_EEG_struct.mat')
    
    % Ensure all subjects have the same sampling rate
    if (EEG.srate ~= 1000)
        EEG = pop_resample(EEG,1000);
    end
    
    % Bandpass and bandstop filters
    if filter_data
        pop_eegplot(EEG,1,1,1)
        rmpath('/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Code/eeglab13_4_4b/')
        
        % Lowpass filter to attenuate frequencies > 70 Hz
        d = designfilt('lowpassfir','PassbandFrequency',70,'StopbandFrequency',120,'PassbandRipple',1,'StopbandAttenuation',60,'SampleRate',EEG.srate);
        % fvtool(d) %Look at filter reponse
        if numel(size(EEG.data))
            [row col depth] = size(EEG.data);
            EEG.data = reshape(EEG.data,row,col*depth);
            EEG.data = filtfilt(d,double(EEG.data)');
            EEG.data = EEG.data';
            EEG.data = reshape(EEG.data,row,col,depth);
        else
            EEG.data = filtfilt(d,double(EEG.data)');
            EEG.data = EEG.data';
        end
        
        % Filter 60 Hz line noise, but Houston may already do this because
        % this filter does not seem to have a large effect on the data.
        d_60 = designfilt('bandstopiir','FilterOrder',2,'HalfPowerFrequency1',58,'HalfPowerFrequency2',62,'DesignMethod','butter','SampleRate',1000);
       if numel(size(EEG.data))
            [row col depth] = size(EEG.data);
            EEG.data = reshape(EEG.data,row,col*depth);
            EEG.data = filtfilt(d_60,double(EEG.data)');
            EEG.data = EEG.data';
            EEG.data = reshape(EEG.data,row,col,depth);
        else
            EEG.data = filtfilt(d_60,double(EEG.data)');
            EEG.data = EEG.data';
        end
        addpath(genpath('/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Code'))
        pop_eegplot(EEG,1,1,1) % plots the data
        
        filter_name = '_filter';
    else
        filter_name = '_nofilter';
    end
    
    if choose_chan
    % Localiztion that is used for determining which electrodes to analyze and
    % which channels are used for the average reference
        if old_sub && grids
            [good_chans,good_chan_names] = houston_gyrus(EEG,1);% Gyrii of interest determined by me but can be changed in this function
            good_chans = setdiff(good_chans,bad_chans);
            elim_chans = setdiff(1:EEG.nbchan,good_chans);
        elseif ~old_sub && grids
            [good_chans,good_chan_names] = houston_gyrus(EEG,0);
            good_chans = setdiff(good_chans,bad_chans);
            elim_chans = setdiff(1:EEG.nbchan,good_chans);
        elseif strcmp(subjects,'TS043')
            load('/Users/amberschedlbauer/Documents/MATLAB/EEG/iEEG/Subjects/TS043/ECoG_data/ts043_wm_channels.mat', 'ts043_wm_mat')
            CSF = find(ts043_wm_mat == 3); % 1 == gray matter, 3 = CSF
            bad_chans = [bad_chans CSF'];
            ch_names = reshape([EEG.chanlocs.labels],7,257)'; %TS043
        else
            ch_names = reshape([EEG.chanlocs.labels],6,EEG.nbchan)';
            elim_chans = [bad_chans EEG.nbchan]; %Assumes last channel is marker channel
        end
    end

    % Can't remember this subject
    %COI = [45 55:63 67 68 71:74 77:81 85:88 91:96];
    %elim_chans = 1:EEG.nbchan;
    %elim_chans = setdiff(elim_chans,COI);
    %grids = 1;
    %depths = 0;
    %
    
    if no_rereference
        
        % Save unepoched data from entire file with all triggers
        EEG = pop_saveset(EEG,'filename',['cue_',unepoch_savefile,'_noreref',filter_name]);
        
%         % Save unepoched data from entire file with all triggers and channels of interest
%         EEG2 = pop_select(EEG,'nochannel',elim_chans);
%         [EEG2,~] = eeg_checkset(EEG2);
%         EEG2 = pop_saveset(EEG2,'filename',['cue_',unepoch_savefile,'_noreref_nobadchan',filter_name]);
%         pop_eegplot(EEG2,1,1,1)
%         %
        
%         % Make epochs
%         EEG = pop_epoch(EEG,{'111','121','112','122'},[-1 2.2]);
%         [EEG,~] = eeg_checkset(EEG);
%         EEG = pop_saveset(EEG,'filename',['cue_',epoch_savefile,'_noreref',filter_name]);
%         pop_eegplot(EEG,1,1,1)
%         EEG2 = pop_epoch(EEG2,{'111','121','112','122'},[-1 2.2]);
%         [EEG2,~] = eeg_checkset(EEG2);
%         EEG2 = pop_saveset(EEG2,'filename',['cue_',epoch_savefile,'_noreref_nobadchan',filter_name]);
%         pop_eegplot(EEG2,1,1,1)
%         %
        
        clear EEG EEG2
        
    end
    
    if reference
        
        EEG = pop_loadset(['cue_',unepoch_savefile,'_noreref_filter.set']);

        if depths
            
            % Bipolar referencing
            %ch_names = reshape([EEG.chanlocs.labels],6,EEG.nbchan)';
            [EEG2,bad_chans] = bipolar_reference_nospace(EEG,ch_names,bad_chans);
            elim_chans = [bad_chans EEG.nbchan];
            save('Removed_channels','elim_chans')
            
            % Average referencing in strip
            [EEG,bad_chans] = average_reference_strip(EEG,ch_names,bad_chans);
            
            % Save data
            EEG = pop_saveset(EEG,'filename',['cue_',unepoch_savefile,'_reref',filter_name]);
            pop_eegplot(EEG,1,1,1)
            
            EEG2 = pop_select(EEG,'nochannel',elim_chans);
            [EEG2,~] = eeg_checkset(EEG2);
            EEG2 = pop_saveset(EEG2,'filename',['cue_',unepoch_savefile,'_reref_nobadchan',filter_name]);
            pop_eegplot(EEG2,1,1,1)
            
            % Make epochs
            EEG2 = pop_epoch(EEG2,{'111','121','112','122'},[-1 2.2]);
            [EEG2,~] = eeg_checkset(EEG2);
            EEG2 = pop_saveset(EEG2,'filename',['cue_',epoch_savefile,'_reref_nobadchan',filter_name]);
            pop_eegplot(EEG2,1,1,1)
            
        elseif grids
            
            %%% Average reference with only analyzed electrodes
%             EEG.ref_vec = zeros(length(EEG.ref_vec),1);
%             EEG.ref_vec(good_chans) = 1;
%             EEG.ref_tseries = mean(EEG.data(good_chans,:));
%             marker = EEG.data(end,:);
            %%%
            
            %%% Average reference with frontal and lateral grids only
%             ref_series = mean(EEG.data(find(EEG.ref_vec),:),1);
%             marker = EEG.data(end,:);
%             EEG.data = EEG.data - repmat(ref_series,EEG.nbchan,1);
%             EEG.data(end,:) = marker;
%             [EEG,~] = eeg_checkset(EEG);
            %%%
            
            %%% Average reference within grid/strip
            grid_names = {'LT','OF','LP','LF','PST','LO','TP','AST','MST','SO','MO','STO'};
            which_grid = zeros(1,EEG.nbchan);
            EEG_temp = EEG;
            EEG_temp = pop_select(EEG_temp,'nochannel',bad_chans); % Remove bad channels so not included in average reference
            [EEG_temp,~] = eeg_checkset(EEG_temp);
            
            for i_series = 1:length(grid_names)
                grid_foo = strfind({EEG.chanlocs.labels},grid_names{i_series});
                grid_foo = ~cellfun(@isempty,grid_foo)';
                which_grid(find(grid_foo)) = i_series;
                str_idx = strfind({EEG_temp.chanlocs.labels},grid_names{i_series});
                ref_vec(:,i_series) = ~cellfun(@isempty,str_idx)';
                ref_series(i_series,:) = mean(EEG_temp.data(find(ref_vec(:,i_series)),:),1);
            end
            
            EEG2 = pop_select(EEG,'nochannel',elim_chans);
            [EEG2,~] = eeg_checkset(EEG2);
            if numel(size(EEG2.data)) == 3 %Checking to see if already epoched. If so, I need to reshape EEG.data after subtracting reference series.
                [row,col,epochs] = size(EEG2.data);
            end
            
            which_grid(elim_chans) = [];
            
            for i_ref = 1:EEG2.nbchan
                EEG2.data(i_ref,:) = EEG2.data(i_ref,:) - ref_series(which_grid(i_ref),:);
            end
            
            if numel(find(EEG2.data(:) == 0)) > 100
                error('Suspicious reference series!')
            end
            %%%
            
            % Save unepoched data from entire file with all triggers
            %EEG = pop_saveset(EEG,'filename',['cue_',unepoch_savefile,'_rerefgrid',filter_name]);
            
            % Save unepoched data from entire file with all triggers and channels of
            % interest
            EEG2 = pop_select(EEG,'nochannel',elim_chans);
            [EEG2,~] = eeg_checkset(EEG2);
            EEG2 = pop_saveset(EEG2,'filename',['cue_',unepoch_savefile,'_reref_nobadchan',filter_name]);
            pop_eegplot(EEG2,1,1,1)
            
            % Make epochs
            %EEG = pop_epoch(EEG,{'111','121','112','122'},[-1 2.2]);
            %[EEG,~] = eeg_checkset(EEG);
            %EEG = pop_saveset(EEG,'filename',['cue_',epoch_savefile,'_rerefgrid',filter_name]);
            %pop_eegplot(EEG,1,1,1)
            EEG2 = pop_epoch(EEG2,{'111','121','112','122'},[-1 2.2]);
            [EEG2,~] = eeg_checkset(EEG2);
            EEG2 = pop_saveset(EEG2,'filename',['cue_',epoch_savefile,'_reref_nobadchan',filter_name]);
            pop_eegplot(EEG2,1,1,1)
            
        end
        
    end
    
    if remove_epoch
        EEG2 = pop_loadset(['cue_',epoch_savefile,'_reref_nobadchan.set'],save_dir);
        EEG2 = pop_select(EEG2,'notrial',bad_epoch);
        EEG2 = pop_saveset(EEG2,['cue_',epoch_savefile,'_reref_nobadchan',filter_name,'_handAR']);
    end

end