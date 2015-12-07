function R = makeRecordingStruct()
% Create a basic structure for inputting recording data to be used with
% StructDlg 

R.RecordingDate      = { [date], 'Recording Date' };
R.RecordingStartTime = { datestr(now, 'HH:MM PM'), 'Recording Start Time' };
R.RecordingEndTime   = { datestr(now, 'HH:MM PM'), 'Recording End Time' };
R.TaskName           = { 'Uncorr|Corr', 'Task Name' };
R.TaskPhase          = { 'Reporting|Retrieval', 'Task Phase' };
R.TaskCompleted      = { 'Yes|No', 'Did patient complete the full task?' };
R.RecordingNotes     = { '', 'Recording Notes' };
