function Patient = addNewPatient()
% Present GUI that guides user through inputting information about this
% patient

P = makePatientStruct();
Patient = StructDlg(P, 'Patient Information');
