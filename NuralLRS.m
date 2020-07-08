 function varargout = NuralLRS(varargin)
% NURALLRS MATLAB code for NuralLRS.fig
%      NURALLRS, by itself, creates a new NURALLRS or raises the existing
%      singleton*.
%
%      H = NURALLRS returns the handle to a new NURALLRS or the handle to
%      the existing singleton*.
%
%      NURALLRS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NURALLRS.M with the given input arguments.
%
%      NURALLRS('Property','Value',...) creates a new NURALLRS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NuralLRS_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NuralLRS_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NuralLRS

% Last Modified by GUIDE v2.5 14-Apr-2020 12:42:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NuralLRS_OpeningFcn, ...
                   'gui_OutputFcn',  @NuralLRS_OutputFcn, ...
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


% --- Executes just before NuralLRS is made visible.
function NuralLRS_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NuralLRS (see VARARGIN)

% Choose default command line output for NuralLRS
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes NuralLRS wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = NuralLRS_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.    打开图片D:\math work\我的识别系统
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc;
clear global exactarea;
global I;    % 全局变量 I  
global doce; 
global L1;
[filename,pathname] = uigetfile('*jpg');  %打开文件对话框并读取文件
if isequal(filename,0)              
    msgbox('未选择图片','注意','error')
else
    pathfile=fullfile(pathname,filename);    %连接得到完整路径名
    handles.filename=filename;
    guidata(hObject,handles);
    I=imread(pathfile);
    handles.figure1;
    axes(handles.axes1);
    imshow(I);
    title('车辆照片');
    axes(handles.axes2);
    cla;
    doce='';  %清空字符数组
    L1=0;     %清空计时器
    set(handles.text6,'string','');   %清空显示框
    set(handles.text5,'string','');
    set(handles.text4,'string','');
end


% --- Executes on button press in pushbutton3.  定位
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% global exactarea;
% global L1;
global shibie;    %单独定位标志
shibie=0;    %弹窗开启
Dingwei();   %执行定位命令



% --- Executes on button press in pushbutton4.  模板配合神经网络识别
function pushbutton4_Callback(hObject, eventdata, handles)  
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global doce;
global L1;
global exactarea;
global shibie;   
shibie=2;    %弹窗关闭
Dingwei();   %执行车牌定位

handles.figure1;
axes(handles.axes2);
cla;
imshow(exactarea);
title('车牌区域');     %显示车牌

piccrop();       %剪切字符
recognition2();   %识别字符
set(handles.text5,'string',doce);    %输出结果
filename=handles.filename;
right=0;
for i=1:7
    if filename(i)==doce(i*2-1)
        right=right+1;
    end
end
if right==7
    set(handles.text6,'string','正确');
    set(handles.text6,'ForegroundColor','blue');
else
    set(handles.text6,'string','错误');
    set(handles.text6,'ForegroundColor','red');
end
L=num2str(L1);
set(handles.text4,'string',L);


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1
set(hObject,'xTick',[]);
set(hObject,'ytick',[]);
set(hObject,'box','on');


% --- Executes during object creation, after setting all properties.
function axes2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'xTick',[]);
set(hObject,'ytick',[]);
set(hObject,'box','on');
% Hint: place code in OpeningFcn to populate axes2


% --- Executes on button press in pushbutton5.  退出
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1);


% --- Executes on button press in pushbutton6.  字符分割
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global shibie;   %弹窗标志
% global L1;
shibie=1;   %弹窗开启
Dingwei();  
piccrop();   %执行字符剪切
