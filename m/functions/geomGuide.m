function varargout = geomGuide(varargin)
% GEOMGUIDE MATLAB code for geomGuide.fig
%      GEOMGUIDE, by itself, creates a new GEOMGUIDE or raises the existing
%      singleton*.
%
%      H = GEOMGUIDE returns the handle to a new GEOMGUIDE or the handle to
%      the existing singleton*.
%
%      GEOMGUIDE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GEOMGUIDE.M with the given input arguments.
%
%      GEOMGUIDE('Property','Value',...) creates a new GEOMGUIDE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before geomGuide_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to geomGuide_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help geomGuide

% Last Modified by GUIDE v2.5 05-Nov-2015 16:50:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @geomGuide_OpeningFcn, ...
    'gui_OutputFcn',  @geomGuide_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before geomGuide is made visible.
function geomGuide_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to geomGuide (see VARARGIN)

% Choose default command line output for geomGuide
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Put grid name in text box
set(handles.gridName, 'String', varargin{1});

% UIWAIT makes geomGuide wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = geomGuide_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = get(handles.table, 'data');

close(handles.figure1);



function rows_Callback(hObject, eventdata, handles)
% hObject    handle to rows (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rows as text
%        str2double(get(hObject,'String')) returns contents of rows as a double


% --- Executes during object creation, after setting all properties.
function rows_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rows (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cols_Callback(hObject, eventdata, handles)
% hObject    handle to cols (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cols as text
%        str2double(get(hObject,'String')) returns contents of cols as a double


% --- Executes during object creation, after setting all properties.
function cols_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cols (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in createTable.
function createTable_Callback(hObject, eventdata, handles)
% hObject    handle to createTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% create table using rows and cols specified by user input
rows = str2double(get(handles.rows, 'string'));
cols = str2double(get(handles.cols, 'string'));
initdata = zeros(rows, cols);
handles.table = uitable('Data', initdata, ...
    'Units', 'characters', ...
    'Position', [2 2 106 26], ...
    'ColumnEditable', logical(ones(1, cols)), ...
    'Tag', 'table');
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in done
function done_Callback(hObject, eventdata, handles)
uiresume(handles.figure1);
