function varargout = flyflyDataMerger(varargin)
% FLYFLYDATAMERGER M-file for flyflyDataMerger.fig
%      FLYFLYDATAMERGER, by itself, creates a new FLYFLYDATAMERGER or raises the existing
%      singleton*.
%
%      H = FLYFLYDATAMERGER returns the handle to a new FLYFLYDATAMERGER or the handle to
%      the existing singleton*.
%
%      FLYFLYDATAMERGER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FLYFLYDATAMERGER.M with the given input arguments.
%
%      FLYFLYDATAMERGER('Property','Value',...) creates a new FLYFLYDATAMERGER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before flyflyDataMerger_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property
%      application
%      stop.  All inputs are passed to flyflyDataMerger_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only
%      one`
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help flyflyDataMerger

% Last Modified by GUIDE v2.5 11-Aug-2017 12:59:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @flyflyDataMerger_OpeningFcn, ...
    'gui_OutputFcn',  @flyflyDataMerger_OutputFcn, ...
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


% --- Executes just before flyflyDataMerger is made visible.
function flyflyDataMerger_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to flyflyDataMerger (see VARARGIN)

% Choose default command line output for flyflyDataMerger
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes flyflyDataMerger wait for user response (see UIRESUME)
% uiwait(handles.figure1);


%
%
addpath('subfunctions');

%init data
localData.pathNameParameters  = ''; %path name to parameter folder
localData.pathNameData        = ''; %path name to data file

localData.blockList           = {}; %cell array with names for listbox
localData.dataBlock           = []; %current loaded data block for plot
localData.triggerBlock        = []; %current loaded trigger block for plot
localData.chosenBlock         = 1;  %array with numbers of block in listbox.

localData.startTimesData      = 0;  %array with starting times of all data blocks

localData.startTimesParmeters = 0;  %array with starting times of all parameter trials
localData.fileNameList        = {}; %filenames corresponding to start times
localData.trialList           = {}; %trials counted as single block (no pauses)

localData.indiceList          = []; %list of indice for matched parameter files
localData.errorList           = []; %difference between starting times

localData.cellList            = []; %cell tag added to block
localData.positionList            = []; %cell tag added to block
localData.animalList            = []; %cell tag added to block
localData.tagList             = {}; %custom tag added to block

localData.exportPathName      = 'exported/'; %path name to export merged files to

localData.intracellular         = true; % intra vs extra determines options for adding cells/animals/positions

%turn off axis
axis(handles.axes1, 'off');
axis(handles.axes2, 'off');

%save data
setappdata(gcf, 'localData', localData);

updateFigure(handles);


function updateFigure(handles)
%updates all objects in figure

localData = getappdata(gcf, 'localData');

listboxIndex = get(handles.listbox1, 'Value');
index        = localData.chosenBlock(listboxIndex);

%chosen datafile and folder
set(handles.pathNameData, 'String', localData.pathNameData);
set(handles.pathNameParameters, 'String', localData.pathNameParameters);

%list of blocks (listbox1)
if localData.startTimesData %false if no data loaded
    for n = 1:length(localData.startTimesData);
        tmp = datestr(localData.startTimesData(n));
        tmp = tmp(end-8:end); %pick out time from datestring
        
        P = coolSpacer(localData.chosenBlock(n));
        spacing = '';
        for p = 1:P spacing = [spacing ' ']; end
        if localData.intracellular
            localData.blockList{n} = ['Block ' num2str(localData.chosenBlock(n)) ':' spacing tmp '   Cell: ' num2str(localData.cellList(n))];
        else
            localData.blockList{n} = ['Block ' num2str(localData.chosenBlock(n)) ':' spacing tmp '   Animal: ' num2str(localData.animalList(n)) '   Position: ' num2str(localData.positionList(n))];
        end
    end
    set(handles.listbox1, 'String', localData.blockList);
end

%plot of chosen datablock (axes1)
if ~isempty(localData.dataBlock)
    
    plot(handles.axes1, localData.dataBlock);
    axis(handles.axes1, 'tight');
    %xlabel(handles.axes1, 'Time');
    %ylabel(handles.axes1, 'Voltage [V]');
end

%plot of chosen datablock trigger (axes2)
if ~isempty(localData.triggerBlock) && get(handles.loadTrigger, 'Value')
    
    plot(handles.axes2, localData.triggerBlock);
    axis(handles.axes2, [0 length(localData.triggerBlock) -0.2*max(localData.triggerBlock) 1.2*max(localData.triggerBlock)]);
    %xlabel(handles.axes1, 'Time');
    %ylabel(handles.axes1, 'Voltage [V]');
end

%enable/disable match button
if isempty(localData.pathNameParameters) || isempty(localData.pathNameData)
    set(handles.matchData, 'Enable', 'off');
else
    set(handles.matchData, 'Enable', 'on');
end

%enable/disable merge button
if isempty(localData.pathNameParameters) || isempty(localData.pathNameData) || isempty(localData.indiceList)
    set(handles.mergeFiles, 'Enable', 'off');
else
    set(handles.mergeFiles, 'Enable', 'on');
    
    parIndex = localData.indiceList(index);
    
    if parIndex
        matchedString = [num2str(localData.fileNameList{parIndex}), ' , trial ' num2str(localData.trialList{parIndex}) ];
    else %no match
        matchedString = 'No match found for this block';
    end
    
    set(handles.matchedParameter, 'String', matchedString);    
end

%display tag
set(handles.customTag, 'String', '');
if ~isempty(localData.tagList)
    if ~isempty(localData.tagList{listboxIndex})
        set(handles.customTag, 'String', localData.tagList{listboxIndex});
    end
end

setappdata(gcf, 'localData', localData);


% --- Outputs from this function are returned to the command line.
function varargout = flyflyDataMerger_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




% --- Executes on button press in setPathNameDataWrap.
function setPathNameDataWrap_Callback(hObject, eventdata, handles)
% hObject    handle to setPathNameDataWrap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

updated = setPathNameData(handles);

if updated
    updateFigure(handles);
end

function updated = setPathNameData(handles)
localData = getappdata(gcf, 'localData');

[fileName pathName]    = uigetfile('Choose file with exported MatLab data', '*.mat');

if fileName %fileName == 0 if press on cancel
    
    localData.pathNameData = [pathName fileName];
    
    startTimesData           = tickTimes2timeString([pathName fileName]);
    localData.startTimesData = startTimesData;
    N                        = length(localData.startTimesData);
    
    localData.dataBlock      = getDataBlock(localData.pathNameData, 0001, 2);   %REVERSED
    
    if get(handles.loadTrigger, 'Value')
        localData.triggerBlock = getDataBlock(localData.pathNameData, 0001, 1); %REVERSED
    end
    
    %array with indice of blocks. if a block is removed from blockList the
    %corresponding entry in this array will also be removed which makes it
    %possible to keep track of which files is still active.
    localData.chosenBlock    = 1:N;
    localData.cellList       = ones(1, N);
    localData.animalList       = ones(1, N);
    localData.positionList       = ones(1, N);
    localData.tagList        = cell(1, N);
    
    setappdata(gcf, 'localData', localData);
    updated = 1;
else
    updated = 0;
end

function n = coolSpacer(n)

if n >= 10000
    n = 1;
else
    n = 2 + coolSpacer(n*10);
end


% --- Executes on button press in setPathNameParametersWrap.
function setPathNameParametersWrap_Callback(hObject, eventdata, handles)
% hObject    handle to setPathNameParametersWrap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

updated = setPathNameParameters();
if updated
    updateFigure(handles);
end


function updated = setPathNameParameters()
%aquires pathname of folder with parameter data

localData = getappdata(gcf, 'localData');

pathName = uigetdir('Choose folder with parameter files corresponding to chosen data file');

if pathName %pathname == 0 if press on cancel
    localData.pathNameParameters  = [pathName '/'];
    
    date = getRecordingDate(localData.pathNameData);
    disp('THE DATA RECORDING DATE IS:');
    disp(date);
    [startTimesParameters, fileNameList, trialList] = paramFile2timeString(localData.pathNameParameters, date);
    
    localData.startTimesParameters = startTimesParameters;
    localData.fileNameList         = fileNameList;
    localData.trialList            = trialList;
    
    setappdata(gcf, 'localData', localData);
    updated = 1;
else
    updated = 0;
end
% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1

localData = getappdata(gcf, 'localData');

if get(handles.updatePlot, 'Value') && ~isempty(localData.dataBlock)
    
    
    index = get(hObject,'Value');
    localData.dataBlock    = getDataBlock(localData.pathNameData, localData.chosenBlock(index), 2); %reversed
    
    if get(handles.loadTrigger, 'Value')
        localData.triggerBlock = getDataBlock(localData.pathNameData, localData.chosenBlock(index), 1); %reversed
    end
    
    setappdata(gcf, 'localData', localData);    
end
updateFigure(handles);

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in previous.
function previous_Callback(hObject, eventdata, handles)
% hObject    handle to previous (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

localData = getappdata(gcf, 'localData');
newIndex = get(handles.listbox1, 'Value') ;

if newIndex > 1
    newIndex = newIndex -1;
    localData.dataBlock    = getDataBlock(localData.pathNameData, localData.chosenBlock(newIndex), 2); %erversed
    
    if get(handles.loadTrigger, 'Value')
        localData.triggerBlock = getDataBlock(localData.pathNameData, localData.chosenBlock(newIndex), 1); %reversed
    end
end

set(handles.listbox1, 'Value', newIndex);

setappdata(gcf, 'localData', localData);
updateFigure(handles);


% --- Executes on button press in next.
function next_Callback(hObject, eventdata, handles)
% hObject    handle to next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%next: displays the next block in the file.
%button should be grayed out if no file is loaded yet

localData = getappdata(gcf, 'localData');
newIndex = get(handles.listbox1, 'Value') ;

if newIndex < length(localData.startTimesData)
    newIndex = newIndex +1;
    localData.dataBlock    = getDataBlock(localData.pathNameData, localData.chosenBlock(newIndex), 2); %Reversed
    
    if get(handles.loadTrigger, 'Value')
        localData.triggerBlock = getDataBlock(localData.pathNameData, localData.chosenBlock(newIndex), 1); %reversed
    end
end

set(handles.listbox1, 'Value', newIndex);

setappdata(gcf, 'localData', localData);
updateFigure(handles);

% --- Executes on button press in mergeFiles.
function mergeFiles_Callback(hObject, eventdata, handles)
% hObject    handle to mergeFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

localData = getappdata(gcf, 'localData');
load(localData.pathNameData); %load file with data_blocks

disp('--Merging parameters with data blocks-- ');

for n = 1:length(localData.indiceList)
    
    
    index = localData.indiceList(n); %index of parameterfile corresponding to current block
    blockIndex = localData.chosenBlock(n);
    
    if index ~= 0 %match exist
        parameterFile = [localData.pathNameParameters localData.fileNameList{index}];
        load(parameterFile);
        
        %dataBlock  = getDataBlock(localData.pathNameData, n, 1);
        
        % sampsamp convention
         dataBlock = eval(['data_block' num2str(n) '(2,:)']); %REVERSED
        unitBlock = [];
        if exist('unit_block1', 'var')
            unitBlock = eval(['unit_block' num2str(n)]); 
        end;
        
        %frankfrank convention
        %dataBlock = eval(['data_block' num2str(n,'%04.0f') '(2,:)']);
        
        dataBlock = dataBlock(~isnan(dataBlock)); %remove NaN
        
        trial      = localData.trialList{index};
        
        parameterFileName = localData.fileNameList{index}; %name of parameter file excluding path
        
        experimentName = parameterFileName(1:end-25); %remove .mat in end of filename
        dateTime = parameterFileName(end-23:end-4);
        
        blockNumber = num2str(blockIndex);
        if length(blockNumber) == 3
            blockNumber = ['0' blockNumber];
        elseif length(blockNumber) == 2
            blockNumber = ['00' blockNumber];
        elseif length(blockNumber) == 1
            blockNumber = ['000' blockNumber];
        end
        blockNumber = ['Block' blockNumber];
        
        if length(trial) == 1
            trialNumber = num2str(trial);
            %his code section adds zeros so trialNumber always has the same
            %length (up to 9999 trials).
            
            %             if length(trialNumber) == 3
            %                 trialNumber = ['0' trialNumber];
            %             elseif length(trialNumber) == 2
            %                 trialNumber = ['00' trialNumber];
            %             elseif length(trialNumber) == 1
            %                 trialNumber = ['000' trialNumber];
            %             end
        else
            trialNumber = [num2str(trial(1)) '-' num2str(trial(end))];
        end
        
        path = localData.exportPathName;

        tag = localData.tagList{n};

        exportName = experimentName;
        
        if localData.intracellular
            cellNumber = num2str(localData.cellList(n));
            if length(cellNumber) == 1
                cellNumber = ['0' cellNumber];
            end
            exportName = [exportName '-Cell'  cellNumber];
        else
            animalNumber = num2str(localData.animalList(n));
            if length(animalNumber) == 1
                animalNumber = ['0' animalNumber];
            end
            positionNumber = num2str(localData.positionList(n));
            if length(positionNumber) == 1
                positionNumber = ['0' positionNumber];
            end
            exportName = [exportName '-N'  animalNumber '-P'  positionNumber];
        end
        
        exportName = [exportName '-Trial' trialNumber  ];
        
        % ---------------------------------------------------
        
        savedName = saveStimulus(path, exportName, dataBlock, unitBlock, parameterFile, trial, tag);
        
        disp(['Parameters saved to ' savedName]);
    end
    
end
disp('--Parameter merging finished-- ');

updateFigure(handles);


% 
% % --- Executes on button press in mergeFiles.
% function mergeFiles_Callback(hObject, eventdata, handles)
% % hObject    handle to mergeFiles (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% localData = getappdata(gcf, 'localData');
% load(localData.pathNameData); %load file with data_blocks
% 
% disp('--Merging parameters with data blocks-- ');
% 
% for n = 1:length(localData.indiceList)
%     
%     
%     index = localData.indiceList(n); %index of parameterfile corresponding to current block
%     blockIndex = localData.chosenBlock(n);
%     
%     if index ~= 0 %match exist
%         parameterFile = [localData.pathNameParameters localData.fileNameList{index}];
%         load(parameterFile);
%         
%         %dataBlock  = getDataBlock(localData.pathNameData, n, 1);
%         dataBlock = eval(['data_block' num2str(n) '(1,:)']);
%         dataBlock = dataBlock(~isnan(dataBlock)); %remove NaN
%         
%         trial      = localData.trialList{index};
%         
%         parameterFileName = localData.fileNameList{index}; %name of parameter file excluding path
%         
%         experimentName = parameterFileName(1:end-25); %remove .mat in end of filename
%         dateTime = parameterFileName(end-23:end-4);
%         
%         blockNumber = num2str(blockIndex);
%         if length(blockNumber) == 3
%             blockNumber = ['0' blockNumber];
%         elseif length(blockNumber) == 2
%             blockNumber = ['00' blockNumber];
%         elseif length(blockNumber) == 1
%             blockNumber = ['000' blockNumber];
%         end
%         blockNumber = ['Block' blockNumber];
%         
%         if length(trial) == 1
%             trialNumber = num2str(trial);
%             %his code section adds zeros so trialNumber always has the same
%             %length (up to 9999 trials).
%             
%             %             if length(trialNumber) == 3
%             %                 trialNumber = ['0' trialNumber];
%             %             elseif length(trialNumber) == 2
%             %                 trialNumber = ['00' trialNumber];
%             %             elseif length(trialNumber) == 1
%             %                 trialNumber = ['000' trialNumber];
%             %             end
%         else
%             trialNumber = [num2str(trial(1)) '-' num2str(trial(end))];
%         end
%         
%         cellNumber = num2str(localData.cellList(n));
%         if length(cellNumber) == 1
%             cellNumber = ['0' cellNumber];
%         end
%         tag = localData.tagList{n};
%         
%         path = localData.exportPathName;
%         
%         % ---------------------------------------------------
%         % USER SETTINGS
%         % DEFINE FILE NAME HERE
%         
%         exportName = [path blockNumber '-Cell'  cellNumber '-' experimentName '-Trial' trialNumber];
%         
%         % ---------------------------------------------------
%         
%         savedName  = saveStimulus(exportName, dataBlock, parameterFile, trial, cellNumber, tag);
%         
%         disp(['Parameters saved to ' savedName]);
%     end
%     
% end
% disp('--Parameter merging finished-- ');
% 
% updateFigure(handles);




% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in mergeDown.
function mergeDown_Callback(hObject, eventdata, handles)
% hObject    handle to mergeDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in trash.
function trash_Callback(hObject, eventdata, handles)
% hObject    handle to trash (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%trash: removes the selected block from the list of block to be correlated with parameter files
%button should be grayed out if no file is loaded yet

localData = getappdata(gcf, 'localData');
index = get(handles.listbox1, 'Value') ; %selected block

if get(handles.updatePlot, 'Value')
    localData.dataBlock    = getDataBlock(localData.pathNameData, localData.chosenBlock(index), 2); %reversed
    
    if get(handles.loadTrigger, 'Value')
        localData.triggerBlock = getDataBlock(localData.pathNameData, localData.chosenBlock(index), 1); %reversed
    end
end

if index == length(localData.chosenBlock)
    set(handles.listbox1, 'Value', index-1);
end

%remove data
localData.startTimesData = localData.startTimesData([1:index-1 index+1:end]);
localData.blockList      = localData.blockList([1:index-1 index+1:end]);
localData.chosenBlock    = localData.chosenBlock([1:index-1 index+1:end]);

localData.tagList        = localData.tagList([1:index-1 index+1:end]);
localData.cellList       = localData.cellList([1:index-1 index+1:end]);

if ~isempty(localData.indiceList)  %if correlation is already made
    localData.indiceList = localData.indiceList([1:index-1 index+1:end]);
    localData.errorList  = localData.errorList ([1:index-1 index+1:end]);
end

setappdata(gcf, 'localData', localData);
updateFigure(handles);

function matchedParameter_Callback(hObject, eventdata, handles)
% hObject    handle to matchedParameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of matchedParameter as text
%        str2double(get(hObject,'String')) returns contents of matchedParameter as a double


% --- Executes during object creation, after setting all properties.
function matchedParameter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to matchedParameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in parameterInfo.
function parameterInfo_Callback(hObject, eventdata, handles)
% hObject    handle to parameterInfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in matchData.
function matchData_Callback(hObject, eventdata, handles)
% hObject    handle to matchData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

localData = getappdata(gcf, 'localData');

startTimesData       = localData.startTimesData;
startTimesParameters = localData.startTimesParameters;

%find indice of parameter files corresponding to data block

shift = str2num(get(handles.shiftTime,'String'))/(60*60*24); %Frank edit

[indice error] = corrDataParam(startTimesData, startTimesParameters,shift);

tolerance      = str2num(get(handles.tolerance, 'String'));

missed = abs(error)> tolerance;
K = sum(missed);
if K>0
    missedIndex = find(missed);
    
    disp('  --Match Report--');
    disp('No matches found for the following blocks: ');
    for k = 1:K
        blockNo = missedIndex(k);
        %disp(['Block ' num2str(blockNo) ', starting at ' datestr(localData.startTimesData(blockNo)) ': Closest time is ' datestr(localData.startTimesParameters) localData.fileNameList{indice(blockNo)} ' (error: ' num2str(error(missedIndex(k))) 's)']);
        disp(['Block ' num2str(blockNo) ', starting at ' datestr(localData.startTimesData(blockNo)) ': Error: ' num2str(error(missedIndex(k))) 's']);
        indice(missedIndex(k)) = 0;
    end
    disp(['  --Match Report Finished: ' num2str(K) ' unmatched blocks']);
else
    disp(['Matches found for all blocks. Tolerance of ' num2str(tolerance) 's used.']);
end

localData.indiceList = indice;
localData.errorList  = error;

setappdata(gcf, 'localData', localData);
updateFigure(handles);

figure;
subplot(3, 1, 1);
plot(sort(localData.startTimesParameters)); hold on;
plot(localData.startTimesData, 'r');
%{
bb = max(localData.startTimesParameters)-min(localData.startTimesParameters)
rr=localData.startTimesData(end)-localData.startTimesData(1)
ratio = bb/rr
%}
title('Raw data, Parameters(blue), Data(red)');

subplot(3, 1, 2);
plot(localData.startTimesParameters(localData.indiceList(localData.indiceList>0))); hold on;
plot(localData.startTimesData(localData.indiceList>0), 'r');
title('Fitted data, Parameters(blue), Data(red)');

subplot(3, 1, 3);
plot(localData.errorList)
title('Error including excluded blocks.');


% --- Executes on button press in loadTrigger.
function loadTrigger_Callback(hObject, eventdata, handles)
% hObject    handle to loadTrigger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of loadTrigger


% --- Executes on button press in setExportFolder.
function setExportFolder_Callback(hObject, eventdata, handles)
% hObject    handle to setExportFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

localData = getappdata(gcf, 'localData');

pathName = uigetdir('Choose folder to export data to');

if pathName %false if press on cancel
    localData.exportPathName = [pathName '/'];
end

setappdata(gcf, 'localData', localData);



function cellTag_Callback(hObject, eventdata, handles)
% hObject    handle to cellTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cellTag as text
%        str2double(get(hObject,'String')) returns contents of cellTag as a double


% --- Executes during object creation, after setting all properties.
function cellTag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cellTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in newCell.
function newCell_Callback(hObject, eventdata, handles)
% hObject    handle to newCell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

localData = getappdata(gcf, 'localData');

index     = get(handles.listbox1, 'Value'); %chosen block

%change cellList:
cell = str2num(get(handles.cellNo, 'String'));
localData.cellList(index:end) = cell;

set(handles.cellNo, 'String', num2str(cell+1));

setappdata(gcf, 'localData', localData);
updateFigure(handles);


function cellNo_Callback(hObject, eventdata, handles)
% hObject    handle to cellNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cellNo as text
%        str2double(get(hObject,'String')) returns contents of cellNo as a double


% --- Executes during object creation, after setting all properties.
function cellNo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cellNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tolerance_Callback(hObject, eventdata, handles)
% hObject    handle to tolerance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tolerance as text
%        str2double(get(hObject,'String')) returns contents of tolerance as a double


% --- Executes during object creation, after setting all properties.
function tolerance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tolerance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in updatePlot.
function updatePlot_Callback(hObject, eventdata, handles)
% hObject    handle to updatePlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of updatePlot



function customTag_Callback(hObject, eventdata, handles)
% hObject    handle to customTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of customTag as text
%        str2double(get(hObject,'String')) returns contents of customTag as a double

localData = getappdata(gcf, 'localData');

if ~isempty(localData.blockList)
    index = get(handles.listbox1, 'Value');
    localData.tagList{index} = get(handles.customTag, 'String');
    
    setappdata(gcf, 'localData', localData);
    disp(['Tag added to block ' num2str(localData.chosenBlock(index))]);
end

% --- Executes during object creation, after setting all properties.
function customTag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to customTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function shiftTime_Callback(hObject, eventdata, handles)
% hObject    handle to shiftTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of shiftTime as text
%        str2double(get(hObject,'String')) returns contents of shiftTime as a double


% --- Executes during object creation, after setting all properties.
function shiftTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shiftTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected object is changed in intra_or_extra_button_group.
function intra_or_extra_button_group_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in intra_or_extra_button_group 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
localData = getappdata(gcf, 'localData');
i_or_e = get(eventdata.NewValue,'Tag');
if strcmp(i_or_e, 'Intracellular')
    localData.intracellular = true
else
    localData.intracellular = false
end
setappdata(gcf, 'localData', localData);

% --- Executes on key press with focus on cellNo and none of its controls.
function cellNo_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to cellNo (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in new_position_button.
function new_position_button_Callback(hObject, eventdata, handles)
% hObject    handle to new_position_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

localData = getappdata(gcf, 'localData');

index     = get(handles.listbox1, 'Value'); %chosen block

%change cellList:
position = str2num(get(handles.positionNo, 'String'));
localData.positionList(index:end) = position;

set(handles.positionNo, 'String', num2str(position+1));

setappdata(gcf, 'localData', localData);
updateFigure(handles)



function positionNo_Callback(hObject, eventdata, handles)
% hObject    handle to positionNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of positionNo as text
%        str2double(get(hObject,'String')) returns contents of positionNo as a double


% --- Executes during object creation, after setting all properties.
function positionNo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to positionNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in new_animal_button.
function new_animal_button_Callback(hObject, eventdata, handles)
% hObject    handle to new_animal_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

localData = getappdata(gcf, 'localData');

index     = get(handles.listbox1, 'Value'); %chosen block

%change cellList:
animal = str2num(get(handles.animalNo, 'String'));
localData.positionList(index:end) = 1;
localData.animalList(index:end) = animal;

set(handles.positionNo, 'String', '2');
set(handles.animalNo, 'String', num2str(animal+1));

setappdata(gcf, 'localData', localData);
updateFigure(handles)


function animalNo_Callback(hObject, eventdata, handles)
% hObject    handle to animalNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of animalNo as text
%        str2double(get(hObject,'String')) returns contents of animalNo as a double


% --- Executes during object creation, after setting all properties.
function animalNo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to animalNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over newCell.
function newCell_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to newCell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
