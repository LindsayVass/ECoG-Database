function marks_struct = marks_remove_label(marks_struct,info_type,mark_label)

if isempty(marks_struct)
    error('No marks to remove. EEG.marks is empty.');
end

switch info_type

    case 'chan_info'
        if ~isempty(marks_struct);
            if isfield(marks_struct,'chan_info')
                flagind=find(strcmpi(mark_label,{marks_struct.chan_info.label}));
                if ~isempty(flagind)
                    marks_struct.(info_type)(flagind) = [];
                else
                    warning('Requested mark not found. Returning the same marks structure.');
                end
            end
        end
        
    case 'comp_info'
        if ~isempty(marks_struct);
            if isfield(marks_struct,'comp_info')
                flagind=find(strcmpi(mark_label,{marks_struct.comp_info.label}));
                if ~isempty(flagind)
                    marks_struct.(info_type)(flagind) = [];
                else
                    warning('Requested mark not found. Returning the same marks structure.');
                end
            end
        end
    
    case 'time_info'
        if ~isempty(marks_struct);
            if isfield(marks_struct,'time_info')
                flagind=find(strcmpi(mark_label,{marks_struct.time_info.label}));
                if ~isempty(flagind)
                    marks_struct.(info_type)(flagind) = [];
                else
                    warning('Requested mark not found. Returning the same marks structure.');
                end
            end
        end
        
    otherwise
        disp('info_type must be either ''chan_info'', ''comp_info'', or ''time_info''');
end