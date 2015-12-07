function Patient = addNewRecording(Patient)
% Present GUI that guides user through inputting information about this
% patient

R = makeRecordingStruct();
Recording = StructDlg(R, 'Add Recording Information');

behavDir = uipickfiles('Prompt', 'Select behavioral data folder');
ecogDir  = uipickfiles('Prompt', 'Select ECoG data folder');

Recording.BehavioralDataFolder = behavDir;
Recording.ECoGDataFolder = ecogDir;

numRecordings = length(Patient.Recordings);

if numRecordings == 0
    Patient.Recordings = Recording;
else
    Patient.Recordings(numRecordings + 1) = Recording;
end