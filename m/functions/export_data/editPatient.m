function updatedPatient = editPatient(Patient)
% Present GUI for updating fields of existing patient structure

P = makePatientStruct();
updatedPatient = StructDlg(P, 'Patient Information', Patient);