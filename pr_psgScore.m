function pr_psgScore
%
% Copyright (C) <2018>  <Miguel Navarrete>
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.

%% Initialize
clc;clear;close all; close hidden

%% Variables
% All Figures Variables ...................................................

% st_figSet.BackColor     = [.86 .86 .86];
st_figSet.CurrentPath   = fileparts(mfilename('fullpath'));
st_figSet.BackColor     = [.94 .94 .94];
st_figSet.ActiveColor	= [0.9294 0.6902 0.1294];
st_figSet.SelectCHColor	= [0.9294 0.6902 0.1294];
st_figSet.AxisColor     = [1 1 1];
st_figSet.CtrlColor     = [1 1 1]; 
st_figSet.PatchColor    = [190 174 212]/255;
st_figSet.TextSize      = 12;
st_figSet.TextCtrlSize	= 6.5;

st_file     = struct;
st_dat      = struct;
st_hyp      = struct;
st_disp     = struct;
st_hLines   = struct;
st_spectrum = struct;
st_chann    = struct;
st_longTerm = struct;

st_hLines.chLines	= -1; 
st_hLines.LTLines	= -1;
st_hLines.chText	= -1;
st_hLines.Events	= -1;

st_hyp.isScoring    = 0;

st_disp.offsetValue     = 200;
st_disp.hypResolution	= 2000;
st_disp.backHypno       = true;

% Figures Variables ..................................................

st_ctrlSet.WindLab  = '1s|2s|5s|10s|20s|30s|60s|120s|Inf';
st_ctrlSet.WindVal  = [1;2;5;10;20;30;60;120;inf];

st_ctrlSet.AmpLab   = '5uV|10uV|20uV|50uV|80uV|100uV|200uV|500uV|1000uV';
st_ctrlSet.AmpVal   = [5;10;20;50;80;100;200;500;1000];

st_ctrlSet.ScaLab   = 'x0.1|x0.2|x0.3|x0.5|x1|x2|x5|x10|x100|x1000|x1e4|x1e5|x1e6|x1e7';
st_ctrlSet.ScaVal   = [0.1;0.2;0.3;0.5;1;2;5;10;100;1000;1e4;1e5;1e6;1e7];

st_ctrlSet.GridLab  = '0.2s|0.5s|1.0s|2.0s|5.0s|10s|20s|60s';
st_ctrlSet.GridVal  = [0.2;0.5;1;2;5;10;20;60];

st_ctrlSet.eventSet	= { 'Slow_Waves',   'SO',   false,  '#B52222';...
                        'Spindles',     'SP',   false,  '#6F33A3';...
                        'EyeMovements', 'EM',   false,  '#FF6929';...
                        'Arousals',     'AS',   false,  '#F5CF36';...
                        'eeg',          [],     [],     '#000000';...
                        'eog',          [],     [],     '#009BBD';...
                        'emg',          [],     [],     '#B746FF';...
                        'ecg',          [],     [],     '#FF0000';...
                        };
                    
st_ctrlSet.EventCol	= {'Event','Mark','Display','Color'};
                    
%% [Variable] --- Cursor Variables ---
st_cursors.hPatch_H1    = [];
st_cursors.hPatch_H2    = [];
st_cursors.hPatch_V1    = [];
st_cursors.hPatch_V2    = [];
st_cursors.hLine_H1     = [];
st_cursors.hLine_H2     = [];
st_cursors.hLine_V1     = [];
st_cursors.hLine_V2     = [];
st_cursors.size_H1      = 0.005;
st_cursors.size_H2      = 0.005;
st_cursors.size_V1      = 0.015;
st_cursors.size_V2      = 0.015;
st_cursors.pos_H1       = 0;
st_cursors.pos_H2       = 1;
st_cursors.pos_V1       = 0;
st_cursors.pos_V2       = 1;
st_cursors.colorCurH    = [0.0745 0.6235 1.0000];
st_cursors.colorCurV 	= [0.3922 0.8314 0.0745];
st_cursors.current_H	= [];
st_cursors.nm_idCur1	= [];
st_cursors.nm_idCur2   = [];
st_cursors.nm_ValXCur1  = [];
st_cursors.nm_ValXCur2  = [];
st_cursors.nm_ValYCur1  = [];
st_cursors.nm_ValYCur2  = [];

%% [Build] - Figures

st_hFigure.Main     = figure(...          
                    'ToolBar','None', ...
                    'MenuBar','None', ...
                    'NumberTitle','off', ...
                    'Name','PSGLab', ...
                    'Color',st_figSet.BackColor,...
                    'Units','normalized',...
                    'Position',[0 .05 1 .9],...
                    'Visible','on',...
                    'Renderer','OpenGL',...
                    'WindowButtonUpFcn',@fn_cursors_dragend,...
                    'CloseRequestFcn',@fn_control_closeall,...
                    'KeyReleaseFcn',@fn_control_key_release);
                
%% [Build] - Panels

st_panelMain.Ctrl   = uipanel(st_hFigure.Main,...
                    'BackgroundColor',st_figSet.BackColor,...
                    'Position',[0 .95 1 .05],...
                    'BorderType','etchedin',...
                    'BorderWidth',1);
                
st_panelMain.Hyp    = uipanel(st_hFigure.Main,...
                    'BackgroundColor',st_figSet.AxisColor,...
                    'Position',[0 .85 1 .1],...
                    'BorderType','etchedin',...
                    'BorderWidth',1);

st_panelMain.Ch     = uipanel(st_hFigure.Main,...
                    'BackgroundColor',st_figSet.AxisColor,...
                    'Position',[0 .15 1 .7],...
                    'BorderType','etchedin',...
                    'BorderWidth',1);
                
st_panelMain.TF     = uipanel(st_hFigure.Main,...
                    'BackgroundColor',st_figSet.AxisColor,...
                    'Position',[0 0 1 .15],...
                    'BorderType','etchedin',...
                    'BorderWidth',1);
                
st_panelMain.LT     = uipanel(st_hFigure.Main,...
                    'BackgroundColor',st_figSet.AxisColor,...
                    'Position',[.75 0 .25 .95],...
                    'BorderType','etchedin',...
                    'Visible','off',...
                    'BorderWidth',1);
        
%% [Build] - Control Buttons (MAIN)

% Open/Close ..............................................................
st_ctrl.OpenBut	= uicontrol(st_panelMain.Ctrl,...
                'Style','pushbutton',...
                'BackgroundColor',st_figSet.BackColor,...
                'HorizontalAlignment','center',...
                'FontSize',st_figSet.TextCtrlSize,...
                'String','OpenEEG',...
                'Units','normalized',...
                'Position',[.005 .05 .03 .9],...
                'CallBack',@fn_file_load);
                        
st_ctrl.OpenHyp	= uicontrol(st_panelMain.Ctrl,...
                'Style','pushbutton',...
                'BackgroundColor',st_figSet.BackColor,...
                'HorizontalAlignment','center',...
                'FontSize',st_figSet.TextCtrlSize,...
                'String','OpenHypno',...
                'Units','normalized',...
                'Position',[.04 .5 .03 .45],...
                'CallBack',@fn_file_load_hypno);
            
st_ctrl.SaveHyp	= uicontrol(st_panelMain.Ctrl,...
                'Style','pushbutton',...
                'BackgroundColor',st_figSet.BackColor,...
                'HorizontalAlignment','center',...
                'FontSize',st_figSet.TextCtrlSize,...
                'String','SaveHypno',...
                'Units','normalized',...
                'Position',[.04 .05 .03 .45],...
                'CallBack',@fn_file_save);
            
% Display Controls ........................................................

st_ctrl.WindLab	= uicontrol(st_panelMain.Ctrl,...
                'Style','text',...
                'BackgroundColor',st_figSet.BackColor,...
                'HorizontalAlignment','center',...
                'FontSize',st_figSet.TextCtrlSize,...
                'String','Window',...
                'Units','normalized',...
                'Position',[.08 .5 .035 .4],...
                'KeyPressFcn',@fn_control_key_release);

st_ctrl.WindPop	= uicontrol(st_panelMain.Ctrl,...
                'Style','popupmenu',...
                'BackgroundColor',st_figSet.CtrlColor,...
                'HorizontalAlignment','center',...
                'FontSize',st_figSet.TextCtrlSize,...
                'String',st_ctrlSet.WindLab,...
                'Value',6,...
                'Units','normalized',...
                'Position',[.08 .2 .035 .4],...
                'CallBack',@fn_display_process,...
                'KeyPressFcn',@fn_control_key_release);            
            
st_ctrl.AmpGLab	= uicontrol(st_panelMain.Ctrl,...
                'Style','text',...
                'BackgroundColor',st_figSet.BackColor,...
                'HorizontalAlignment','center',...
                'FontSize',st_figSet.TextCtrlSize,...
                'String','AmpGrid',...
                'Units','normalized',...
                'Position',[.12 .5 .035 .4],...
                'KeyPressFcn',@fn_control_key_release);

st_ctrl.AmpGPop	= uicontrol(st_panelMain.Ctrl,...
                'Style','popupmenu',...
                'BackgroundColor',st_figSet.CtrlColor,...
                'HorizontalAlignment','center',...
                'FontSize',st_figSet.TextCtrlSize,...
                'String',st_ctrlSet.AmpLab,...
                'Value',6,...
                'Units','normalized',...
                'Position',[.12 .2 .035 .4],...
                'CallBack',@fn_control_grid,...
                'KeyPressFcn',@fn_control_key_release);
            
st_ctrl.ScaLab	= uicontrol(st_panelMain.Ctrl,...
                'Style','text',...
                'BackgroundColor',st_figSet.BackColor,...
                'HorizontalAlignment','center',...
                'FontSize',st_figSet.TextCtrlSize,...
                'String','AmpScale',...
                'Units','normalized',...
                'Position',[.16 .5 .035 .4]);            

st_ctrl.ScaPop	= uicontrol(st_panelMain.Ctrl,...
                'Style','popupmenu',...
                'BackgroundColor',st_figSet.CtrlColor,...
                'HorizontalAlignment','center',...
                'FontSize',st_figSet.TextCtrlSize,...
                'String',st_ctrlSet.ScaLab,...
                'Value',5,...
                'Units','normalized',...
                'Position',[.16 .2 .035 .4],...
                'CallBack',@fn_display_process,...
                'KeyPressFcn',@fn_control_key_release);      
            
st_ctrl.GridLab	= uicontrol(st_panelMain.Ctrl,...
                'Style','text',...
                'BackgroundColor',st_figSet.BackColor,...
                'HorizontalAlignment','center',...
                'FontSize',st_figSet.TextCtrlSize,...
                'String','TimeGrid',...
                'Units','normalized',...
                'Position',[.20 .5 .035 .4]);            

st_ctrl.GridPop	= uicontrol(st_panelMain.Ctrl,...
                'Style','popupmenu',...
                'BackgroundColor',st_figSet.CtrlColor,...
                'HorizontalAlignment','center',...
                'FontSize',st_figSet.TextCtrlSize,...
                'String',st_ctrlSet.GridLab,...
                'Value',3,...
                'Units','normalized',...
                'Position',[.20 .2 .035 .4],...
                'CallBack',@fn_control_grid,...
                'KeyPressFcn',@fn_control_key_release);
            
st_ctrl.NuChLab	= uicontrol(st_panelMain.Ctrl,...
                'Style','text',...
                'BackgroundColor',st_figSet.BackColor,...
                'HorizontalAlignment','center',...
                'FontSize',st_figSet.TextCtrlSize,...
                'String','#Ch',...
                'Units','normalized',...
                'Position',[.24 .5 .035 .4]);            

st_ctrl.NuChPop	= uicontrol(st_panelMain.Ctrl,...
                'Style','popupmenu',...
                'BackgroundColor',st_figSet.CtrlColor,...
                'HorizontalAlignment','center',...
                'FontSize',st_figSet.TextCtrlSize,...
                'String',' ',...
                'Value',1,...
                'Units','normalized',...
                'Position',[.24 .2 .035 .4],...
                'CallBack',@fn_display_process,...
                'KeyPressFcn',@fn_control_key_release);      
            
% Display Buttons ......................................................    

st_ctrl.chDisp	= uicontrol(st_panelMain.Ctrl,...
                'Style','pushbutton',...
                'BackgroundColor',st_figSet.BackColor,...
                'HorizontalAlignment','center',...
                'FontSize',st_figSet.TextCtrlSize,...
                'String','DisplayCh',...
                'Units','normalized',...
                'Position',[.285 .1 .035 .8],...
                'CallBack',@fn_control_chSelection);              
           

st_ctrl.chEvent	= uicontrol(st_panelMain.Ctrl,...
                'Style','pushbutton',...
                'BackgroundColor',st_figSet.BackColor,...
                'HorizontalAlignment','center',...
                'FontSize',st_figSet.TextCtrlSize,...
                'String','Events',...
                'Units','normalized',...
                'Position',[.325 .1 .035 .8],...
                'CallBack',@fn_control_eventDisplay);        
            
st_ctrl.TFBut	= uicontrol(st_panelMain.Ctrl,...
                'Style','checkbox',...
                'BackgroundColor',st_figSet.BackColor,...
                'HorizontalAlignment','left',...
                'FontSize',st_figSet.TextCtrlSize,...
                'String','Display TimeFreq',...
                'Units','normalized',...
                'Position',[.365 .5 .05 .3],...
                'KeyPressFcn',@fn_control_key_release,...
                'CallBack',@fn_control_extrapanel);       

st_ctrl.LTBut	= uicontrol(st_panelMain.Ctrl,...
                'Style','checkbox',...
                'BackgroundColor',st_figSet.BackColor,...
                'HorizontalAlignment','left',...
                'FontSize',st_figSet.TextCtrlSize,...
                'String','Display LongTerm',...
                'Units','normalized',...
                'Position',[.365 .2 .05 .3],...
                'KeyPressFcn',@fn_control_key_release,...
                'CallBack',@fn_control_extrapanel);            

% Cursor view ........................................................    
       
                
st_ctrl.EpochNumLab	= uicontrol(st_panelMain.Ctrl,...
                    'Style','text',...
                    'BackgroundColor',st_figSet.BackColor,....
                    'HorizontalAlignment','center',...
                    'FontSize',st_figSet.TextCtrlSize,...
                    'String','Epoch',...
                    'FontWeight','bold',...
                    'ForegroundColor',[0.3,0.3,1],...
                    'Enable','inactive',...
                    'Units','normalized',...
                    'Position',[.44 .5 .035 .4]);             

st_ctrl.EpochNum	= uicontrol(st_panelMain.Ctrl,...
                    'Style','text',...
                    'BackgroundColor',st_figSet.CtrlColor,...
                    'HorizontalAlignment','center',...
                    'FontSize',st_figSet.TextCtrlSize * 1.5,...
                    'String',' ',...
                    'Value',1,...
                    'Enable','inactive',...
                    'Units','normalized',...
                    'Position',[.44 .2 .035 .4],...
                    'ButtonDownFcn',@fn_control_inputdlg);    
                
st_ctrl.xCurTLab    = uicontrol(st_panelMain.Ctrl,...
                    'Style','text',...
                    'BackgroundColor',st_figSet.BackColor,...
                    'HorizontalAlignment','center',...
                    'FontSize',st_figSet.TextCtrlSize,...
                    'String','x(s)',...
                    'Enable','inactive',...
                    'Units','normalized',...
                    'Position',[.48 .5 .035 .4]);            

st_ctrl.xCurTm      = uicontrol(st_panelMain.Ctrl,...
                    'Style','text',...
                    'BackgroundColor',st_figSet.CtrlColor,...
                    'HorizontalAlignment','center',...
                    'FontSize',st_figSet.TextCtrlSize * 1.5,...
                    'String',' ',...
                    'Value',1,...
                    'Enable','inactive',...
                    'Units','normalized',...
                    'Position',[.48 .2 .035 .4]);         
            
st_ctrl.xCurPLab    = uicontrol(st_panelMain.Ctrl,...
                    'Style','text',...
                    'BackgroundColor',st_figSet.BackColor,...
                    'HorizontalAlignment','center',...
                    'FontSize',st_figSet.TextCtrlSize,...
                    'String','x(%)',...
                    'Enable','inactive',...
                    'Units','normalized',...
                    'Position',[.52 .5 .035 .4]);            

st_ctrl.xCurPrc     = uicontrol(st_panelMain.Ctrl,...
                    'Style','text',...
                    'BackgroundColor',st_figSet.CtrlColor,...
                    'HorizontalAlignment','center',...
                    'FontSize',st_figSet.TextCtrlSize * 1.5,...
                    'String',' ',...
                    'Value',1,...
                    'Enable','inactive',...
                    'Units','normalized',...
                    'Position',[.52 .2 .035 .4]);                
            
st_ctrl.yCurLab     = uicontrol(st_panelMain.Ctrl,...
                    'Style','text',...
                    'BackgroundColor',st_figSet.BackColor,...
                    'HorizontalAlignment','center',...
                    'FontSize',st_figSet.TextCtrlSize,...
                    'ForegroundColor',[0.3,0.3,1],...
                    'String','y(uV)',...
                    'Enable','inactive',...
                    'Units','normalized',...
                    'Position',[.56 .5 .035 .4]);            

st_ctrl.yCur        = uicontrol(st_panelMain.Ctrl,...
                    'Style','text',...
                    'BackgroundColor',st_figSet.CtrlColor,...
                    'HorizontalAlignment','center',...
                    'FontSize',st_figSet.TextCtrlSize * 1.5,...
                    'String',' ',...
                    'Value',1,...
                    'Enable','inactive',...
                    'Units','normalized',...
                    'Position',[.56 .2 .035 .4],...
                    'ButtonDownFcn',@fn_control_inputdlg);         
            
% Analysis Buttons ........................................................

st_ctrlScore.Predict	= uicontrol(st_panelMain.Ctrl,...
                'Style','pushbutton',...
                'BackgroundColor',st_figSet.BackColor,...
                'HorizontalAlignment','center',...
                'FontSize',st_figSet.TextCtrlSize,...
                'String','Predict',...
                'Units','normalized',...
                'Position',[.66 .2 .05 .6],...
                'KeyPressFcn',@fn_control_key_release,...
                'CallBack',@fn_control_scorepredict);
            
st_ctrlScore.OkScBut	= uicontrol(st_panelMain.Ctrl,...
                'Style','togglebutton',...
                'BackgroundColor',st_figSet.BackColor,...
                'HorizontalAlignment','center',...
                'FontSize',st_figSet.TextCtrlSize,...
                'String','Score',...
                'Units','normalized',...
                'Position',[.73 .2 .05 .6],...
                'KeyPressFcn',@fn_control_key_release,...
                'CallBack',@fn_control_scorestate);
            
% Stages Controls ........................................................

st_ctrlScore.UBut	= uicontrol(st_panelMain.Ctrl,...
                'Style','pushbutton',...
                'BackgroundColor',st_figSet.BackColor,...
                'HorizontalAlignment','center',...
                'FontSize',st_figSet.TextCtrlSize,...
                'String','Unkn',...
                'Units','normalized',...
                'Position',[.79 .1 .025 .8],...
                'KeyPressFcn',@fn_control_key_release,...
                'CallBack',@fn_control_stagebutton);
            
st_ctrlScore.WBut	= uicontrol(st_panelMain.Ctrl,...
                'Style','pushbutton',...
                'BackgroundColor',st_figSet.BackColor,...
                'HorizontalAlignment','center',...
                'FontSize',st_figSet.TextCtrlSize,...
                'String','Wake',...
                'Units','normalized',...
                'Position',[.815 .1 .025 .8],...
                'KeyPressFcn',@fn_control_key_release,...
                'CallBack',@fn_control_stagebutton);

st_ctrlScore.N1But	= uicontrol(st_panelMain.Ctrl,...
                'Style','pushbutton',...
                'BackgroundColor',st_figSet.BackColor,...
                'HorizontalAlignment','center',...
                'FontSize',st_figSet.TextCtrlSize,...
                'String','N1',...
                'Units','normalized',...
                'Position',[.84 .1 .025 .8],...
                'KeyPressFcn',@fn_control_key_release,...
                'CallBack',@fn_control_stagebutton);
            
st_ctrlScore.N2But	= uicontrol(st_panelMain.Ctrl,...
                'Style','pushbutton',...
                'BackgroundColor',st_figSet.BackColor,...
                'HorizontalAlignment','center',...
                'FontSize',st_figSet.TextCtrlSize,...
                'String','N2',...
                'Units','normalized',...
                'Position',[.865 .1 .025 .8],...
                'KeyPressFcn',@fn_control_key_release,...
                'CallBack',@fn_control_stagebutton);
            
st_ctrlScore.N3But	= uicontrol(st_panelMain.Ctrl,...
                'Style','pushbutton',...
                'BackgroundColor',st_figSet.BackColor,...
                'HorizontalAlignment','center',...
                'FontSize',st_figSet.TextCtrlSize,...
                'String','N3',...
                'Units','normalized',...
                'Position',[.89 .1 .025 .8],...
                'KeyPressFcn',@fn_control_key_release,...
                'CallBack',@fn_control_stagebutton);
            
st_ctrlScore.RBut	= uicontrol(st_panelMain.Ctrl,...
                'Style','pushbutton',...
                'BackgroundColor',st_figSet.BackColor,...
                'HorizontalAlignment','center',...
                'FontSize',st_figSet.TextCtrlSize,...
                'String','REM',...
                'Units','normalized',...
                'Position',[.915 .1 .025 .8],...
                'KeyPressFcn',@fn_control_key_release,...
                'CallBack',@fn_control_stagebutton);

st_ctrlScore.MBut	= uicontrol(st_panelMain.Ctrl,...
                'Style','pushbutton',...
                'BackgroundColor',st_figSet.BackColor,...
                'HorizontalAlignment','center',...
                'FontSize',st_figSet.TextCtrlSize,...
                'String','MT',...
                'Units','normalized',...
                'Position',[.94 .1 .025 .8],...
                'KeyPressFcn',@fn_control_key_release,...
                'CallBack',@fn_control_stagebutton);

st_ctrlScore.ABut	= uicontrol(st_panelMain.Ctrl,...
                'Style','pushbutton',...
                'BackgroundColor',st_figSet.BackColor,...
                'HorizontalAlignment','center',...
                'FontSize',st_figSet.TextCtrlSize,...
                'String','ArsSet',...
                'Units','normalized',...
                'Position',[.965 .5 .025 .4],...
                'KeyPressFcn',@fn_control_key_release,...
                'CallBack',@fn_control_stagebutton);

st_ctrlScore.CBut	= uicontrol(st_panelMain.Ctrl,...
                'Style','pushbutton',...
                'BackgroundColor',st_figSet.BackColor,...
                'HorizontalAlignment','center',...
                'FontSize',st_figSet.TextCtrlSize,...
                'String','ArsClr',...
                'Units','normalized',...
                'Position',[.965 .1 .025 .4],...
                'KeyPressFcn',@fn_control_key_release,...
                'CallBack',@fn_control_stagebutton);
            
%% [Build] - Hypnogram Axes (MAIN)

st_ctrHyp.TextHyp	= uicontrol(st_panelMain.Hyp,...
                    'Style','text',...
                    'BackgroundColor',st_figSet.AxisColor,...
                    'HorizontalAlignment','center',...
                    'FontSize',st_figSet.TextCtrlSize,...
                    'String','Hypnogram',...
                    'Units','normalized',...
                    'Position',[0.96 .85 .04 .15]); 
                
st_ctrHyp.SelHyp	= uicontrol(st_panelMain.Hyp,...
                    'Style','pop',...
                    'BackgroundColor',st_figSet.AxisColor,...
                    'HorizontalAlignment','left',...
                    'FontSize',st_figSet.TextCtrlSize,...
                    'String',' ',...
                    'Units','normalized',...
                    'Position',[0.96 .70 .04 .15],...
                    'CallBack',@fn_control_hypnopopup); 
                
st_ctrHyp.HideHyp	= uicontrol(st_panelMain.Hyp,...
                    'Style','togglebutton',...
                    'BackgroundColor',st_figSet.AxisColor,...
                    'HorizontalAlignment','left',...
                    'FontSize',st_figSet.TextCtrlSize,...
                    'String','HideBack',...
                    'Units','normalized',...
                    'Position',[0.96 .40 .04 .2],...
                    'CallBack',@fn_control_hypnohide); 
                
st_ctrHyp.RemoveHyp	= uicontrol(st_panelMain.Hyp,...
                    'Style','pushbutton',...
                    'BackgroundColor',st_figSet.AxisColor,...
                    'HorizontalAlignment','left',...
                    'FontSize',st_figSet.TextCtrlSize,...
                    'String','DeleteHyp',...
                    'Units','normalized',...
                    'Position',[0.96 .20 .04 .2],...
                    'CallBack',@fn_control_hypnoremove); 
                
st_ctrHyp.VoteHyp	= uicontrol(st_panelMain.Hyp,...
                    'Style','pushbutton',...
                    'BackgroundColor',st_figSet.AxisColor,...
                    'HorizontalAlignment','left',...
                    'FontSize',st_figSet.TextCtrlSize,...
                    'String','VoteHyp',...
                    'Units','normalized',...
                    'Position',[0.96 .0 .04 .2],...
                    'CallBack',@fn_control_hypnovote); 
            
st_ctrHyp.AxesPatch	= axes(...
                    'Parent',st_panelMain.Hyp,... 
                    'FontSize',st_figSet.TextCtrlSize,...
                    'Color','none',...
                    'Position',[.05 0 .9 1],...
                    'XTick',[],...
                    'YTick',[],...
                    'YAxisLocation','Right');
                     
st_ctrHyp.AxesHyp	= axes(...
                    'Parent',st_panelMain.Hyp,... 
                    'FontSize',st_figSet.TextCtrlSize,...
                    'Position',[.05 .05 .9 .95],...
                    'Color','none',...
                    'XTick',[],...
                    'YLim',[0 8],...
                    'YTick',0:8,...
                    'YTickLabel',[{' '},{'N3'},{'N2'},{'N1'},...
                                {'REM'},{'WAKE'},{'MT'},{'Ars'},{' '}],...
                    'YGrid','on',...
                    'ButtonDownFcn',@fn_control_skiptoclick);
                
%% [Build] - Channel Axes (MAIN)

st_ctrCh.TextCh	= uicontrol(st_panelMain.Ch,...
                    'Style','text',...
                    'BackgroundColor',st_figSet.AxisColor,...
                    'HorizontalAlignment','left',...
                    'FontSize',st_figSet.TextCtrlSize,...
                    'String',' Channels',...
                    'Units','normalized',...
                    'Position',[0 .95 .03 .05]); 
                
st_ctrCh.AxesGrid	= axes(...
                    'Parent',st_panelMain.Ch,... 
                    'FontSize',st_figSet.TextCtrlSize,...
                    'Position',[.05 .05 .92 .93],...
                    'XTick',1:30,...
                    'XLim',[1 30],...
                    'XTickLabel',[],...
                    'XGrid','on',...
                    'YLim',[1 10],...
                    'YTick',1:10,...
                    'YGrid','on');
                
st_ctrCh.AxesCurH	= axes(...
                    'Parent',st_panelMain.Ch,... 
                    'FontSize',st_figSet.TextSize,...
                    'Position',[.05 .98 .92 .02],...
                    'Color','none',...
                    'Box','on',...
                    'XTick',[],...
                    'YTick',[],...
                    'XLimMode','manual',...
                    'YLimMode','manual',...
                    'XLim',[0 1],...
                    'YLim',[0 1],...
                    'ButtonDownFcn',@fn_cursorH_axisdrag);
                
st_ctrCh.AxesCurV	= axes(...
                    'Parent',st_panelMain.Ch,... 
                    'FontSize',st_figSet.TextSize,...
                    'Position',[.97 .05 .01 .93],...
                    'Color','none',...
                    'Box','on',...
                    'XTick',[],...
                    'YTick',[],...
                    'XLimMode','manual',...
                    'YLimMode','manual',...
                    'XLim',[0 1],...
                    'YLim',[0 1],...
                    'ButtonDownFcn',@fn_cursorV_axisdrag);
                
st_ctrCh.axesCh     = axes(...
                    'Parent',st_panelMain.Ch,... 
                    'FontSize',st_figSet.TextSize,...
                    'Position',[.05 .05 .92 .93],...
                    'Color','none',...
                    'XTick',[],...
                    'YTick',1:10); 
                
st_ctrCh.SliderH  = uicontrol(st_panelMain.Ch,...
                    'Style','slider',...
                    'Units','normalized',...
                    'Value',0,...
                    'Enable','off',...
                    'Interruptible','off',... 
                    'Position',[.05 0 .87 .05],...
                    'CallBack',@fn_control_sliderwork);                
                
st_ctrCh.SliderV  = uicontrol(st_panelMain.Ch,...
                    'Style','slider',...
                    'Units','normalized',...
                    'Value',0,...
                    'Enable','off',...
                    'Interruptible','off',... 
                    'Position',[.98 .05 .02 .93],...
                    'CallBack',@fn_control_sliderwork,...
                    'KeyPressFcn',@fn_control_key_release);
                
st_ctrCh.FBBut	= uicontrol(st_panelMain.Ch,...
                'Style','pushbutton',...
                'BackgroundColor',st_figSet.BackColor,...
                'HorizontalAlignment','center',...
                'FontSize',st_figSet.TextCtrlSize,...
                'String','|<',...
                'Units','normalized',...
                'Position',[.92 0 .02 .05],...
                'CallBack',@fn_display_advance,...
                'KeyPressFcn',@fn_control_key_release);
            
st_ctrCh.BBut	= uicontrol(st_panelMain.Ch,...
                'Style','pushbutton',...
                'BackgroundColor',st_figSet.BackColor,...
                'HorizontalAlignment','center',...
                'FontSize',st_figSet.TextCtrlSize,...
                'String','<',...
                'Units','normalized',...
                'Position',[.94 0 .02 .05],...
                'CallBack',@fn_display_advance,...
                'KeyPressFcn',@fn_control_key_release);
                        
st_ctrCh.FBut	= uicontrol(st_panelMain.Ch,...
                'Style','pushbutton',...
                'BackgroundColor',st_figSet.BackColor,...
                'HorizontalAlignment','center',...
                'FontSize',st_figSet.TextCtrlSize,...
                'String','>',...
                'Units','normalized',...
                'Position',[.96 0 .02 .05],...
                'CallBack',@fn_display_advance,...
                'KeyPressFcn',@fn_control_key_release);
                        
st_ctrCh.FFBut	= uicontrol(st_panelMain.Ch,...
                'Style','pushbutton',...
                'BackgroundColor',st_figSet.BackColor,...
                'HorizontalAlignment','center',...
                'FontSize',st_figSet.TextCtrlSize,...
                'String','>|',...
                'Units','normalized',...
                'Position',[.98 0 .02 .05],...
                'CallBack',@fn_display_advance,...
                'KeyPressFcn',@fn_control_key_release);
            
%% [Build] - TF Axes (MAIN)

st_ctrlTF.TextTF    = uicontrol(st_panelMain.TF,...
                    'Style','text',...
                    'BackgroundColor',st_figSet.AxisColor,...
                    'HorizontalAlignment','left',...
                    'FontSize',st_figSet.TextCtrlSize,...
                    'String',' Spectrum',...
                    'Units','normalized',...
                    'Position',[0 .80 .03 .19]); 
            
st_ctrlTF.AxesTF	= axes(...
                    'Parent',st_panelMain.TF,... 
                    'FontSize',st_figSet.TextCtrlSize,...
                    'Position',[.05 .05 .92 .93],...
                    'XTickLabel',[]);
        
st_ctrlTF.chanPop	= uicontrol(st_panelMain.TF,...
                    'Style','popupmenu',...
                    'BackgroundColor',st_figSet.CtrlColor,...
                    'HorizontalAlignment','center',...
                    'FontSize',st_figSet.TextCtrlSize,...
                    'String',' ',...
                    'Value',1,...
                    'Units','normalized',...
                    'Position',[0 .6 .03 .2],...
                    'CallBack',@fn_control_chView);    
        
st_ctrlTF.psdBut	= uicontrol(st_panelMain.TF,...
                    'Style','push',...
                    'BackgroundColor',st_figSet.CtrlColor,...
                    'HorizontalAlignment','center',...
                    'FontSize',st_figSet.TextCtrlSize,...
                    'String','PSD',...
                    'Value',1,...
                    'Units','normalized',...
                    'Position',[0 .4 .03 .2],...
                    'CallBack',@fn_display_psd);          

st_ctrlTF.sliderV  = uicontrol(st_panelMain.TF,...
                    'Style','slider',...
                    'Units','normalized',...
                    'Value',1,...
                    'SliderStep',[0.002,0.01],...    
                    'Min',0.001,...                  
                    'Max',1,...
                    'Enable','off',...
                    'Interruptible','off',... 
                    'Position',[.98 .05 .02 .93],...
                    'CallBack',@fn_display_drawspectrum);                 
                
%% [Build] - ExtraInfo Axes (MAIN)
 
st_ctrlExtra.TextCh        = uicontrol(st_panelMain.LT,...
                        'Style','text',...
                        'BackgroundColor',st_figSet.AxisColor,...
                        'HorizontalAlignment','left',...
                        'FontSize',2*st_figSet.TextCtrlSize,...
                        'String','EEG Ch:   ',...
                        'Units','normalized',...
                        'Position',[.05 .95 .15 .04]);
                    
st_ctrlExtra.chanPop	= uicontrol(st_panelMain.LT,...
                        'Style','popupmenu',...
                        'BackgroundColor',st_figSet.CtrlColor,...
                        'HorizontalAlignment','center',...
                        'FontSize',st_figSet.TextCtrlSize,...
                        'String',' ',...
                        'Value',1,...
                        'Units','normalized',...
                        'Position',[.20 .95 .1 .04],...
                        'CallBack',@fn_control_chView);        
                      
st_ctrlExtra.ZoomBut     = uicontrol(st_panelMain.LT,...
                        'Style','togglebutton',...
                        'BackgroundColor',st_figSet.AxisColor,...
                        'HorizontalAlignment','center',...
                        'FontSize',st_figSet.TextCtrlSize,...
                        'String','Vertical_Zoom',...
                        'Units','normalized',...
                        'Position',[.85 .97 .15 .03],...
                        'CallBack',@fn_display_zoominfo);
            
st_ctrlExtra.AxesPatch	= axes(...
                        'Parent',st_panelMain.LT,... 
                        'FontSize',st_figSet.TextCtrlSize,...
                        'Color','none',...
                        'Position',[.1 0 .9 .9],...
                        'XTick',[],...
                        'YTick',[],...
                        'YAxisLocation','Right',...
                        'ButtonDownFcn',@fn_control_skiptoclick);
                
st_ctrlExtra.AxesDelta	= axes(...
                        'Parent',st_panelMain.LT,... 
                        'FontSize',st_figSet.TextCtrlSize,...
                        'Color','none',...
                        'XTick',[],...
                        'Position',[.1 .85 .9 .05],...
                        'ButtonDownFcn',@fn_control_skiptoclick);
  
set(get(st_ctrlExtra.AxesDelta,'YLabel'),'String','Delta')  

st_ctrlExtra.AxesTheta	= axes(...
                        'Parent',st_panelMain.LT,... 
                        'FontSize',st_figSet.TextCtrlSize,...
                        'Color','none',...
                        'XTick',[],...
                        'Position',[.1 .80 .9 .05],...
                        'ButtonDownFcn',@fn_control_skiptoclick);
  
set(get(st_ctrlExtra.AxesTheta,'YLabel'),'String','Theta')   

st_ctrlExtra.AxesAlpha	= axes(...
                        'Parent',st_panelMain.LT,... 
                        'FontSize',st_figSet.TextCtrlSize,...
                        'Color','none',...
                        'XTick',[],...
                        'Position',[.1 .75 .9 .05],...
                        'ButtonDownFcn',@fn_control_skiptoclick);
  
set(get(st_ctrlExtra.AxesAlpha,'YLabel'),'String','Alpha')   

st_ctrlExtra.AxesSigma	= axes(...
                        'Parent',st_panelMain.LT,... 
                        'FontSize',st_figSet.TextCtrlSize,...
                        'Color','none',...
                        'XTick',[],...
                        'Position',[.1 .70 .9 .05],...
                        'ButtonDownFcn',@fn_control_skiptoclick);
  
set(get(st_ctrlExtra.AxesSigma,'YLabel'),'String','Sigma') 

st_ctrlExtra.AxesBeta	= axes(...
                        'Parent',st_panelMain.LT,... 
                        'FontSize',st_figSet.TextCtrlSize,...
                        'Color','none',...
                        'XTick',[],...
                        'Position',[.1 .65 .9 .05],...
                        'ButtonDownFcn',@fn_control_skiptoclick);
  
set(get(st_ctrlExtra.AxesBeta,'YLabel'),'String','Beta')   

st_ctrlExtra.AxesEMGsd	= axes(...
                        'Parent',st_panelMain.LT,... 
                        'FontSize',st_figSet.TextCtrlSize,...
                        'Color','none',...
                        'XTick',[],...
                        'Position',[.1 .55 .9 .05],...
                        'ButtonDownFcn',@fn_control_skiptoclick);
  
set(get(st_ctrlExtra.AxesEMGsd,'YLabel'),'String','EMG')     
                
st_ctrlExtra.AxesDensSO	= axes(...
                        'Parent',st_panelMain.LT,... 
                        'FontSize',st_figSet.TextCtrlSize,...
                        'Color','none',...
                        'XTick',[],...
                        'Position',[.1 .50 .9 .05],...
                        'ButtonDownFcn',@fn_control_skiptoclick);
                    
set(get(st_ctrlExtra.AxesDensSO,'YLabel'),'String','SO_d')     
                
st_ctrlExtra.AxesDensSP	= axes(...
                        'Parent',st_panelMain.LT,... 
                        'FontSize',st_figSet.TextCtrlSize,...
                        'Color','none',...
                        'XTick',[],...
                        'Position',[.1 .45 .9 .05],...
                        'ButtonDownFcn',@fn_control_skiptoclick);
                    
set(get(st_ctrlExtra.AxesDensSP,'YLabel'),'String','SS_d')   

st_ctrlExtra.AxesEM     = axes(...
                        'Parent',st_panelMain.LT,... 
                        'FontSize',st_figSet.TextCtrlSize,...
                        'Color','none',...
                        'XTick',[],...
                        'Position',[.1 .40 .9 .05],...
                        'ButtonDownFcn',@fn_control_skiptoclick);
  
set(get(st_ctrlExtra.AxesEM,'YLabel'),'String','REM_d')    

st_ctrlExtra.AxesThetaD	= axes(...
                        'Parent',st_panelMain.LT,... 
                        'FontSize',st_figSet.TextCtrlSize,...
                        'Color','none',...
                        'XTick',[],...
                        'Position',[.1 .30 .9 .05],...
                        'ButtonDownFcn',@fn_control_skiptoclick);
  
set(get(st_ctrlExtra.AxesThetaD,'YLabel'),'String','theta_d')   

st_ctrlExtra.AxesAlphaD	= axes(...
                        'Parent',st_panelMain.LT,... 
                        'FontSize',st_figSet.TextCtrlSize,...
                        'Color','none',...
                        'XTick',[],...
                        'Position',[.1 .25 .9 .05],...
                        'ButtonDownFcn',@fn_control_skiptoclick);
  
set(get(st_ctrlExtra.AxesAlphaD,'YLabel'),'String','alpha_d') 

st_ctrlExtra.AxesArousal= axes(...
                        'Parent',st_panelMain.LT,... 
                        'FontSize',st_figSet.TextCtrlSize,...
                        'Color','none',...
                        'XTick',[],...
                        'Position',[.1 .20 .9 .05],...
                        'ButtonDownFcn',@fn_control_skiptoclick);
  
set(get(st_ctrlExtra.AxesArousal,'YLabel'),'String','Arousal')  

st_ctrlExtra.AxesBPM	= axes(...
                        'Parent',st_panelMain.LT,... 
                        'FontSize',st_figSet.TextCtrlSize,...
                        'Color','none',...
                        'XTick',[],...
                        'Position',[.1 .10 .9 .05],...
                        'ButtonDownFcn',@fn_control_skiptoclick);
  
set(get(st_ctrlExtra.AxesBPM,'YLabel'),'String','BPM') 
                                
linkaxes([st_ctrlExtra.AxesPatch,...
        st_ctrlExtra.AxesDelta,...
        st_ctrlExtra.AxesTheta,...
        st_ctrlExtra.AxesAlpha,...
        st_ctrlExtra.AxesSigma,...
        st_ctrlExtra.AxesBeta,...
        st_ctrlExtra.AxesEMGsd,...
        st_ctrlExtra.AxesDensSO,...
        st_ctrlExtra.AxesDensSP,...
        st_ctrlExtra.AxesEM,...
        st_ctrlExtra.AxesThetaD,...
        st_ctrlExtra.AxesAlphaD,...
        st_ctrlExtra.AxesArousal,...
        st_ctrlExtra.AxesBPM],'x')
   
%% [Build] - Set panels

fn_control_extrapanel()

%% [Functions] - File
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_file_load(~,~)
                
        nm_resp	= exist(fullfile(st_figSet.CurrentPath,'psgHystory.mat'),'file');
        ch_path	= [];
        
        if logical(nm_resp)
            try 
            ch_path = load(fullfile(st_figSet.CurrentPath,'psgHystory.mat'));
            ch_path = ch_path.ch_path;
            [st_file.name,st_file.path]	= uigetfile('*.mat',...
                                        'Select EEG .Mat file',ch_path);
            catch
                ch_path = [];
            end
        end
        
        if isempty(ch_path)            
            [st_file.name,st_file.path]	= uigetfile('*.mat',...
                                        'Select EEG .Mat file');
        end
        
        if st_file.name == 0
            return
        end
          
        if isfield(st_dat,'trial')
            fn_controls_reset()
        end
        
        ch_path	= fullfile(st_file.path,st_file.name); 
        save(fullfile(st_figSet.CurrentPath,'psgHystory.mat'),'ch_path');

        nm_hDlg	= msgbox({'Data is loading and processing';...
                'This can take some time'},'Data loading','help');
            
        st_file.objTimer    = [];
        
        [~,st_file.fileName,ch_fileExt]	= fileparts(st_file.name);
        
        st_file.hypnoFile	= sprintf('psgHypno-%s.mat',...
                            st_file.fileName);
        st_file.extraFile	= sprintf('psgExtra-%s.mat',...
                            st_file.fileName);
        
        switch ch_fileExt
            case '.mat'
                ch_fullFileName	= fullfile(st_file.path,st_file.name);
                            
                st_dat	= load(ch_fullFileName);
                if isfield(st_dat,'trial')
                    % fieldtrip file version        
                    
                    % Check for channel types
                    if isfield(st_dat,'hdr') && ~isfield(st_dat,'chtype')
                        st_dat.chtype	= st_dat.hdr.chantype;
                    end
                    
                    % Check for scaling conversion
                    if isfield(st_dat,'hdr') 
                        if isfield(st_dat.hdr,'scale')
                            fn_file_convert_eeg(st_dat.hdr.scale)                            
                        end
                    end
                    
                elseif isfield(st_dat,'st_dat')
                    % First psgScore version                     
                    st_dat	= st_dat.st_dat;
                else
                    warndlg(sprintf(...
                        '%s is not an eeg file. Please select onther file',...
                        st_file.name))
                    return
                end

            otherwise
                
                ch_resp	= questdlg(sprintf('%s. %s',...
                        'You are going to load non-processed raw data',...
                        'Do you want to continue?'),'Raw data dialog',...
                        'Yes','No','No');
                
                switch ch_resp
                    case 'Yes'
                        
                        st_cfg          = struct;
                        st_cfg.dataset	=  fullfile(...
                                        st_file.path,st_file.name);

                        st_dat	= ft_preprocessing(st_cfg);

                        st_dat.time{1}  = single(st_dat.time{1});
                        st_dat.trial{1} = single(st_dat.trial{1}); 
                        st_dat.chtype	= st_dat.hdr.chantype;

                        st_dat	= rmfield(st_dat,'cfg');
                        st_dat	= rmfield(st_dat,'sampleinfo'); 
                        
                    otherwise
                        return
                end
        end     
                
        nm_resp	= exist(fullfile(st_file.path,st_file.hypnoFile),'file');
                
        if logical(nm_resp)
            st_hyp	= load(fullfile(st_file.path,st_file.hypnoFile));
        else
            st_disp.window	= st_ctrlSet.WindVal(...
                            get(st_ctrl.WindPop,'Value'));   
            st_hyp.epoch    = st_disp.window;
            
            st_hyp.timeEpoch	= single(st_dat.time{1}(1):st_hyp.epoch:...
                                st_dat.time{1}(end)-st_hyp.epoch);
            st_hyp.dat          = int8(-ones(1,numel(st_hyp.timeEpoch)));
            st_hyp.arousals     = cell(1);
        end
        
        st_hyp.id       = 1;
        st_hyp.isScoring= false;
        
        if ~iscell(st_hyp.arousals)
            mx_tmp              = st_hyp.arousals;
            st_hyp.arousals     = cell(size(st_hyp.dat,1),1);
            st_hyp.arousals{1}  = mx_tmp;
        end
        
        vt_stringCnt	=  num2cell(num2str((1:size(st_hyp.dat,1))'));
        vt_stringCnt    =  vertcat(vt_stringCnt,{'new'});
        
        set(st_ctrHyp.SelHyp,'String',vt_stringCnt)
        set(st_ctrHyp.SelHyp,'Value',st_hyp.id)
        
        vt_stringCnt	=  num2str((1:numel(st_dat.label))');
        
        set(st_ctrl.NuChPop,'String', vt_stringCnt)
        set(st_ctrl.NuChPop,'Value',numel(st_dat.label))
        
        st_disp.idCh    = 1:numel(st_dat.label);
        st_disp.curTime	= st_dat.time{1}(1);
        st_disp.chPos 	= 1;
                
        st_file.objTimer     = timer('ExecutionMode', 'fixedSpacing', ...
                            'Period', 600, ...
                            'TimerFcn', @fn_file_autosave);
            
        fn_compute_chselection()
        fn_file_load_extras()   
        fn_compute_longterm()
        fn_control_chlist()
        
        fn_display_readvalues()
        fn_control_sliderhorz() 
        fn_control_slidervert() 
        
        fn_display_process()
        fn_display_drawpatch()
        fn_display_drawhypnogram()        
        fn_display_drawlongterm()
        fn_display_rename()
        
        if ishandle(nm_hDlg)
            delete(nm_hDlg)
        end
        
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_file_load_hypno(~,~)
        
        if ~isfield(st_dat,'trial')
            return
        end
        
        nm_resp	= exist(fullfile(st_figSet.CurrentPath,'psgHystory.mat'),'file');
        ch_path	= [];
        
        if logical(nm_resp)
            try
                ch_path = load(fullfile(st_figSet.CurrentPath,'psgHystory.mat'));
                ch_path = ch_path.ch_path;
                [st_file.hypnoList,st_file.path]    = uigetfile('*.mat',...
                                                'Select Hypnogram .mat file',...
                                                ch_path,'MultiSelect','on');
            catch
                ch_path = [];
            end
        end
        
        if st_file.name == 0
            return
        end
        
        if isnumeric(st_file.hypnoList)
            return
        end
        
        if isempty(ch_path)            
            [st_file.hypnoList,st_file.path]    = uigetfile('*.mat',...
                                            'Select Hypnogram .mat file',...
                                            'MultiSelect','on');
        end
        
        if ischar(st_file.hypnoList)
            st_file.hypnoList	= {st_file.hypnoList};
        end                                          
                        
        vt_idLst	= ismember(st_file.hypnoList,st_file.hypnoFile);
        
        if any(vt_idLst)
            ch_answ	= questdlg(...
                    [{'This option will load an hypnogram with the same filename.'};...
                    {'Would you like to continue?'}],...
                    'Repeated hypnogram','Yes','No','No');
                
            switch ch_answ
                case 'Yes'
                    % Do nothing
                case 'No'   
                    % Remove repeated filename hypnogram
                    vt_idLst	= ~ismember(st_file.hypnoList,st_file.hypnoFile);
                    st_file.hypnoList   = st_file.hypnoList(vt_idLst);
            end
        end
                
        st_hypBulk.dat      = {};
        st_hypBulk.arousals	= {};
        st_hypBulk.timeEpoch= {};
        st_hypBulk.epoch	= {};
            
        for ff = 1:numel(st_file.hypnoList)
                        
            st_hypLst	= load(fullfile(st_file.path,st_file.hypnoList{ff}));
                    
            if ~isfield(st_hypLst,'dat')
                continue
            end            
            
            if ~iscell(st_hypLst.arousals)
                mx_tmp                  = st_hypLst.arousals;
                st_hypLst.arousals   	= cell(size(st_hypLst.dat,1),1);
                st_hypLst.arousals{1}	= mx_tmp;
            end
            
            st_hypBulk.dat{ff,1}        = st_hypLst.dat;
            st_hypBulk.arousals{ff,1}   = st_hypLst.arousals; 
            st_hypBulk.timeEpoch{ff,1}	= st_hypLst.timeEpoch; 
            st_hypBulk.epoch{ff,1}      = st_hypLst.epoch; 
        end
        
        vt_numEpoch	= cellfun(@numel,st_hypBulk.dat); 
        vt_idLst	= vt_numEpoch > 0;
        
        if ~any(vt_idLst)
            ob_f	= warndlg('None hypnogram was imported',...
                    'Hypnogram warning'); %#ok<NASGU>
            return
        end
        
        st_hypBulk.dat      = st_hypBulk.dat(vt_idLst);
        st_hypBulk.arousals	= st_hypBulk.arousals(vt_idLst);
        st_hypBulk.timeEpoch= st_hypBulk.timeEpoch(vt_idLst);
        st_hypBulk.epoch    = st_hypBulk.epoch(vt_idLst);
        st_file.hypnoList   = st_file.hypnoList(vt_idLst);
        
        vt_numEpoch	= cellfun(@(x) size(x,2),st_hypBulk.dat); 
        vt_idLst    = vt_numEpoch == vt_numEpoch(1);
        
        st_hypBulk.dat      = st_hypBulk.dat(vt_idLst);
        st_hypBulk.arousals	= st_hypBulk.arousals(vt_idLst);
        st_hypBulk.timeEpoch= st_hypBulk.timeEpoch(vt_idLst);
        st_hypBulk.epoch    = st_hypBulk.epoch(vt_idLst);
        st_file.hypnoList   = st_file.hypnoList(vt_idLst);
        
        st_hyp.dat      = vertcat(st_hyp.dat,cell2mat(st_hypBulk.dat));
        st_hyp.arousals	= vertcat(st_hyp.arousals,st_hypBulk.arousals{:});
        st_hyp.timeEpoch= st_hypBulk.timeEpoch{1};
        st_hyp.epoch    = st_hypBulk.epoch{1};
        st_hyp.id       = 1;
        st_hyp.isScoring= false;
                
        vt_stringCnt	=  num2cell(num2str((1:size(st_hyp.dat,1))'));
        vt_stringCnt    =  vertcat(vt_stringCnt,{'new'});
        
        set(st_ctrHyp.SelHyp,'String',vt_stringCnt)
        set(st_ctrHyp.SelHyp,'Value',st_hyp.id)
        
        fn_display_drawhypnogram()   
        
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_file_load_extras()
        
        nm_resp	= exist(fullfile(st_file.path,st_file.extraFile),'file');
                
        if logical(nm_resp)
            % Check psg-Extras version
            vt_file	= matfile(fullfile(st_file.path,st_file.extraFile));
            vt_file	= who(vt_file);
            
            % Load long term data
            if ismember('st_patterns',vt_file)
                st_longTerm	= load(fullfile(st_file.path,st_file.extraFile),....
                            'st_patterns');
                st_longTerm	= st_longTerm.st_patterns;
            else
                st_longTerm	= load(fullfile(st_file.path,st_file.extraFile),....
                            'patterns');
                st_longTerm	= st_longTerm.patterns;
            end
                        
            % Load spectrum data
            if ismember('st_spectrum',vt_file)
                st_spectrum	= load(fullfile(st_file.path,st_file.extraFile),....
                            'st_spectrum');
                st_spectrum	= st_spectrum.st_spectrum; 
            else
                st_spectrum	= load(fullfile(st_file.path,st_file.extraFile),....
                            'spectrum'); 
                st_spectrum	= st_spectrum.spectrum;                
            end
            
        else    
            
            [ch_fileName,ch_filePath]	= uigetfile('*.mat',...
                                        'Select TF associated .mat file');
                                    
            try 
                if isnumeric(ch_fileName)
                    error('No data')
                end
                
                st_longTerm	= load(fullfile(ch_filePath,ch_fileName),...
                            'st_patterns');
                st_spectrum	= load(fullfile(ch_filePath,ch_fileName),...
                            'st_spectrum');
            catch
                st_disp.curCh   = '';
                set(st_ctrlExtra.chanPop,'Value',1)
                set(st_ctrlTF.chanPop,'Value',1)
                set(st_ctrlExtra.chanPop,'String',' ')
                set(st_ctrlTF.chanPop,'String',' ')
                st_longTerm     = struct;
                st_spectrum.TF	= struct;
                return
            end         
        end
             
        if isfield(st_longTerm,'scale')
            fn_file_convert_longterm(st_longTerm.scale)
        end
             
        if isfield(st_spectrum,'scale')
            fn_file_convert_spectrum(st_spectrum.scale)
        end
        
        
        nm_id           = get(st_ctrlTF.chanPop,'Value');
        st_disp.curCh	= st_chann.EEGlabels{nm_id};
        
        set(st_ctrlExtra.chanPop,'Value',nm_id)
        set(st_ctrlTF.sliderV,'Enable','on')
        
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_file_save(~,~)
        
        if ~isfield(st_dat,'trial')
            return
        end
        
        [ch_FileName,ch_PathName]	= uiputfile('*.mat','Save hypnogram file',...
                                    fullfile(st_file.path,st_file.hypnoFile));
                
        save(fullfile(ch_PathName,ch_FileName),...
        '-struct', 'st_hyp', '-v7.3');
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_file_autosave(~,~)
        
        if ~isfield(st_dat,'trial') || ~st_hyp.isScoring
            return
        end
                
        nm_hMsg	= msgbox('Saving recovery file');
        save(fullfile(st_file.path,sprintf('~%s',st_file.hypnoFile)),...
        '-struct', 'st_hyp', '-v7.3');
        delete(nm_hMsg)
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_file_convert_eeg(vt_scale)
        st_dat.trial{1} = single(st_dat.trial{1}) * vt_scale(1) ...
                        + vt_scale(2);
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_file_convert_longterm(st_scale)
        vt_fields	= fieldnames(st_scale);
        
        for ff = 1:numel(vt_fields)
            
            ch_fName	= vt_fields{ff};
            vt_data     = st_longTerm.(ch_fName);
            nm_scale    = st_scale.(ch_fName);  
            
            switch ch_fName
                case 'EM'
                    % do nothing
                case 'EyeEvents'
                    vt_data.REM	= single(vt_data.REM) * nm_scale;
                    vt_data.SEM	= single(vt_data.SEM) * nm_scale;
                                        
                otherwise
                    if iscell(vt_data)                                
                        vt_data	= cellfun(@(x) single(x) * nm_scale,...
                                vt_data,'UniformOutput',false);
                    else
                      	vt_data	= single(vt_data) * nm_scale;
                    end
            end
            st_longTerm.(ch_fName)	=  vt_data;
        end
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_file_convert_spectrum(vt_scale)
        
        for nn = 1:numel(vt_scale)            
            st_spectrum.data{nn}	= single(st_spectrum.data{nn}) ...
                                    * vt_scale(nn);
        end
    end

%% [Functions] - Display
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_display_process(~,~)
                
        if ~isfield(st_dat,'trial')
            return
        end
        
        fn_display_readvalues()
        fn_control_slidervert() 
        fn_display_drawlines() 
        fn_display_drawevents() 
        fn_control_sliderhorz() 
        
        if isfield(st_hLines,'Patch')
            fn_control_patch()
        end   
        
        fn_display_drawspectrum()
        fn_display_drawcursorsH()
        fn_display_drawcursorsV() 
        fn_cursors_updatevalues()
        fn_display_identifystage()
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_display_readvalues()
        
        st_disp.window    = st_ctrlSet.WindVal(...
                            get(st_ctrl.WindPop,'Value'));   
                        
        if isinf(st_disp.window)
            st_disp.window	= st_dat.time{1}(end)-st_dat.time{1}(1);
        end
        
        st_disp.ampScale	= st_ctrlSet.ScaVal(...
                            get(st_ctrl.ScaPop,'Value'));
                        
        st_disp.gridX       = st_ctrlSet.GridVal(...
                            get(st_ctrl.GridPop,'Value'));
                        
        st_disp.gridY       = st_ctrlSet.AmpVal(...
                            get(st_ctrl.AmpGPop,'Value'));
                        
        st_disp.showCh      = get(st_ctrl.NuChPop,'Value');
                
        if st_hyp.isScoring && isfield(st_hyp,'timeEpoch')
            st_disp.stepTime	= st_hyp.timeEpoch;
            st_disp.window      = st_hyp.epoch;
        else
            st_disp.stepTime	= single(st_dat.time{1}(1):st_disp.window:...
                                st_dat.time{1}(end)-st_disp.window);
        end
        if st_disp.stepTime(end) == st_dat.time{1}(end)
            st_disp.stepTime(end) = [];
        end
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_display_advance(hObject,~)
        nm_currIdx       = get(st_ctrCh.AxesGrid,'Xlim');
        nm_currIdx       = nm_currIdx(1);
        [~,nm_currIdx]	= min(abs(st_disp.stepTime-nm_currIdx));
        
        switch hObject
            case st_ctrCh.FBBut
                nm_currIdx	= 1;
            case st_ctrCh.BBut   
                nm_currIdx	= nm_currIdx - 1;
                if nm_currIdx < 1
                    nm_currIdx = 1;
                end
            case st_ctrCh.FBut
                nm_currIdx	= nm_currIdx + 1;
                if nm_currIdx > numel(st_disp.stepTime)
                    nm_currIdx = numel(st_disp.stepTime);
                end
            case st_ctrCh.FFBut
                nm_currIdx	= numel(st_disp.stepTime);
        end
        st_disp.curTime  = st_disp.stepTime(nm_currIdx);
        
        fn_display_process()
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_display_drawlines()
        
        % Get begining and ending ponits to plot
        st_disp.posBeg	= numel(st_dat.time{1}(1):1/st_dat.fsample:...
                        st_disp.curTime);
                    
        st_disp.posEnd  = numel(st_dat.time{1}(1):1/st_dat.fsample:...
                        st_disp.curTime+st_disp.window);
                        
        if st_disp.posEnd > numel(st_dat.time{1})
            st_disp.posEnd = numel(st_dat.time{1});
            %return
        end
        
        nm_tPos = sum(st_hyp.timeEpoch <= st_disp.curTime);
        
        set(st_ctrl.EpochNum,...
            'String',sprintf('%i',nm_tPos))
        
        fn_control_sliderposition()
        
        % Get channels to plot
        vt_curIdCh      = st_disp.chPos:st_disp.chPos + st_disp.showCh - 1;
        
        if any(vt_curIdCh > numel(st_disp.idCh))
            vt_curIdCh      = (numel(st_disp.idCh) - st_disp.showCh +1): ...
                            numel(st_disp.idCh);
            st_disp.chPos   = vt_curIdCh(1);
        end
        
        vt_curIdCh      = st_disp.idCh(vt_curIdCh);
        nm_curShowCh   	= numel(vt_curIdCh);
                
        st_disp.ampOffset 	= st_disp.offsetValue * (1:numel(vt_curIdCh));
        
        % Set axes settinggs
        cla(st_ctrCh.axesCh)
        
        for kk = 1:numel(st_hLines.chLines)
            if ishandle(st_hLines.chLines(kk)) && st_hLines.chLines(kk) ~= 0
                delete(st_hLines.chLines(kk))
            end
        end
       
        set(st_ctrCh.axesCh,...
            'YTick',st_disp.ampOffset,...
            'YTickLabel',flipud(st_dat.label(vt_curIdCh)),...
            'YLim',[st_disp.ampOffset(1)-st_disp.offsetValue ...
                   st_disp.ampOffset(end)+ st_disp.offsetValue],...            
            'XLim',[st_dat.time{1}(st_disp.posBeg),...
                    st_dat.time{1}(st_disp.posEnd)])
        
        set(st_ctrCh.AxesGrid,...
            'YLim',[st_disp.ampOffset(1)-st_disp.offsetValue ...
                   st_disp.ampOffset(end)+ st_disp.offsetValue],...
            'XLim',[st_dat.time{1}(st_disp.posBeg),...
                    st_dat.time{1}(st_disp.posEnd)],...
            'YTick',st_disp.ampOffset(1)-st_disp.offsetValue: ...
                    st_disp.gridY: ...
                   st_disp.ampOffset(end)+ st_disp.offsetValue,...
            'XTick',st_dat.time{1}(st_disp.posBeg): ...
                    st_disp.gridX: ...
                   st_dat.time{1}(st_disp.posEnd),...
            'YTickLabel',[],'XTickLabel',[])
               
        % Plot channels' lines
        st_hLines.chLines	= -ones(numel(vt_curIdCh),1);
        nm_cnt              = 0;
        
        for kk = vt_curIdCh
            % Get data signal to plot
            nm_cnt      = nm_cnt + 1;
            vt_curCh    = st_dat.trial{1}(kk,...
                        st_disp.posBeg:st_disp.posEnd)*...
                        st_disp.ampScale + st_disp.ampOffset(...
                        nm_curShowCh+1-nm_cnt);
            
            % Get signal color
            try
                vt_id       = ismember(st_ctrlSet.eventSet(:,1),...
                            st_dat.chtype{kk});
                vt_color    = st_ctrlSet.eventSet{vt_id,4};
                vt_color    = hex2rgb(vt_color);
                
            catch
                vt_color	= 'k';
            end
            
            % Plot lines
            st_hLines.chLines(kk)  = line(...
                                    'Xdata',st_dat.time{1}(...
                                            st_disp.posBeg:st_disp.posEnd),...
                                    'Ydata',vt_curCh,...
                                    'Parent',st_ctrCh.axesCh,...
                                    'Color',vt_color);
                                
        end
                
        % Identify selected channel      
        if ishandle(st_hLines.chText)
            delete(st_hLines.chText)
        end
                
        nm_idCh = find(ismember(st_dat.label,st_disp.curCh));
        if ~isempty(nm_idCh)
            nm_cnt  = find(vt_curIdCh == nm_idCh);
            nm_xPos	= double(st_dat.time{1}(st_disp.posBeg));
            nm_yPos = st_disp.ampOffset(nm_curShowCh+1-nm_cnt);

            st_hLines.chText	= text(st_ctrCh.AxesGrid,...
                                nm_xPos,nm_yPos,'        ',...
                                'BackgroundColor',st_figSet.SelectCHColor,...
                                'HorizontalAlignment','right');
        end
        
        % Look for arousals
        if ~isfield(st_hyp,'dat')
            return
        end
        
        if isempty(st_hyp.arousals)
            return
        end
        
        if st_hyp.id > numel(st_hyp.arousals)
            return
        end
        % Select arousals within time limits
        vt_evId	= st_hyp.arousals{st_hyp.id} >= ...
                st_dat.time{1}(st_disp.posBeg) & ...
                st_hyp.arousals{st_hyp.id} <= ...
                st_dat.time{1}(st_disp.posEnd);
        vt_evId = find(sum(vt_evId,2) > 0);
                
        st_hLines.ArsLines = [];
        
        if isempty(vt_evId)
            return
        end
        
        % Plot arousals within time limits
        for kk = 1:numel(vt_evId)
            st_hLines.ArsLines(kk)	= line(...
                                    'Xdata',st_hyp.arousals{st_hyp.id}(vt_evId(kk),:),...
                                    'Ydata',st_disp.offsetValue.*[1,1]/2,...
                                    'Parent',st_ctrCh.axesCh,...
                                    'color','y',...
                                    'LineWidth',6,...
                                    'LineStyle','-');
            
        end
        
        
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_display_drawevents() 
        
        if isfield(st_hLines,'Events')
            if iscell(st_hLines.Events)
                for kk = 1:numel(st_hLines.Events)
                    if ishandle(st_hLines.Events{kk})
                        delete(st_hLines.Events{kk})
                    end
                end
            end
        end
        
        % Prepare ch position
        vt_curIdCh      = st_disp.chPos:st_disp.chPos + st_disp.showCh - 1;
        vt_curIdCh      = st_disp.idCh(vt_curIdCh);
        nm_curShowCh   	= numel(vt_curIdCh);
                        
        % Identify selected channel 
        vt_idView	= ismember(st_ctrlSet.EventCol,'Display');
        nm_idCh     = find(ismember(st_dat.label,st_disp.curCh));
        nm_cnt      = find(vt_curIdCh == nm_idCh);
        nm_yPos     = st_disp.ampOffset(nm_curShowCh+1-nm_cnt) +...
                    st_disp.offsetValue/2;
                
        nm_l        = 0;
        vt_eventLab	= st_ctrlSet.eventSet(:,1);
        vt_eventCnt	= st_ctrlSet.eventSet(:,vt_idView);
        
        st_hLines.Events = cell(4,1);
        
        nm_l	= nm_l + 1;
        nm_idEv	= ismember(vt_eventLab,'Slow_Waves');
        
        if isfield(st_longTerm,'SOevent') && vt_eventCnt{nm_idEv}
            vt_events	= st_longTerm.SOevent{nm_idCh};
            vt_idView   = vt_events >= st_dat.time{1}(st_disp.posBeg) & ...
                        vt_events <= st_dat.time{1}(st_disp.posEnd);
            vt_events   = double(vt_events(vt_idView));
            
            if ~isempty(vt_events)
                
                vt_color    = st_ctrlSet.eventSet{nm_idEv,4};
                vt_color    = hex2rgb(vt_color);
                
                ch_txt  = st_ctrlSet.eventSet{nm_idEv,2};
                vt_yPos = nm_yPos + (st_disp.offsetValue/2)*(nm_l*10)/100;
                vt_yPos	= repmat(vt_yPos,size(vt_events));
                
                st_hLines.Events{nm_l}	= text(st_ctrCh.AxesGrid,...
                                        vt_events,vt_yPos,ch_txt,...
                                        'Color',vt_color,...
                                        'HorizontalAlignment','center');
            end
        end
        
        nm_l	= nm_l + 1;
        nm_idEv	= ismember(vt_eventLab,'Spindles');
        if isfield(st_longTerm,'SPevent') && vt_eventCnt{nm_idEv}            
            vt_events	= st_longTerm.SPevent{nm_idCh};
            vt_idView   = vt_events >= st_dat.time{1}(st_disp.posBeg) & ...
                        vt_events <= st_dat.time{1}(st_disp.posEnd);
            vt_events   = double(vt_events(vt_idView));
            
            if ~isempty(vt_events)
                
                vt_color    = st_ctrlSet.eventSet{nm_idEv,4};
                vt_color    = hex2rgb(vt_color);
                
                ch_txt  = st_ctrlSet.eventSet{nm_idEv,2};
                vt_yPos = nm_yPos + (st_disp.offsetValue/2)*(nm_l*10)/100;
                vt_yPos	= repmat(vt_yPos,size(vt_events));
                
                st_hLines.Events{nm_l}	= text(st_ctrCh.AxesGrid,...
                                        vt_events,vt_yPos,ch_txt,...
                                        'Color',vt_color,...
                                        'HorizontalAlignment','center');
            end
        end
        
        
        nm_l	= nm_l + 1;
        nm_idEv	= ismember(vt_eventLab,'Arousals');
        if isfield(st_longTerm,'arousal') && vt_eventCnt{nm_idEv}         
            vt_events	= st_longTerm.arousal{nm_idCh};
            vt_events   = mean(vt_events/st_dat.fsample,2);
            vt_idView   = vt_events >= st_dat.time{1}(st_disp.posBeg) & ...
                        vt_events <= st_dat.time{1}(st_disp.posEnd);
            vt_events   = double(vt_events(vt_idView));
            
            if ~isempty(vt_events)
                
                vt_color    = st_ctrlSet.eventSet{nm_idEv,4};
                vt_color    = hex2rgb(vt_color);
                
                ch_txt  = st_ctrlSet.eventSet{nm_idEv,2};
                vt_yPos = nm_yPos + (st_disp.offsetValue/2)*(nm_l*10)/100;
                vt_yPos	= repmat(vt_yPos,size(vt_events));
                
                st_hLines.Events{nm_l}	= text(st_ctrCh.AxesGrid,...
                                        vt_events,vt_yPos,ch_txt,...
                                        'BackgroundColor',vt_color,...
                                        'HorizontalAlignment','center');
            end
        end
        
        nm_l	= nm_l + 1;
        nm_idEv	= ismember(vt_eventLab,'EyeMovements');
        
        if isfield(st_longTerm,'EyeEvents') && vt_eventCnt{nm_idEv}
            % Obtain EOG channels            
            nm_idCh	= find(ismember(st_dat.chtype,'eog'));
            nm_cnt	= find(ismember(vt_curIdCh,nm_idCh));
            
            if isempty(nm_cnt)
                return
            end
            nm_cnt  = nm_cnt(1);
            nm_yPos	= st_disp.ampOffset(nm_curShowCh+1-nm_cnt) +...
                    st_disp.offsetValue/2;
                     
            % Find SEM events
            vt_events	= st_longTerm.EyeEvents.SEM;
            vt_idView   = vt_events >= st_dat.time{1}(st_disp.posBeg) & ...
                        vt_events <= st_dat.time{1}(st_disp.posEnd);
            vt_events   = double(vt_events(vt_idView));
            
            if ~isempty(vt_events)
                
                vt_color    = st_ctrlSet.eventSet{nm_idEv,4};
                vt_color    = hex2rgb(vt_color);
                
                ch_txt  = 'SEM';
                vt_yPos = nm_yPos + (st_disp.offsetValue/2)*(nm_l*10)/100;
                vt_yPos	= repmat(vt_yPos,size(vt_events));
                
                st_hLines.Events{nm_l}	= text(st_ctrCh.AxesGrid,...
                                        vt_events,vt_yPos,ch_txt,...
                                        'BackgroundColor',vt_color,...
                                        'HorizontalAlignment','center');
            end
              
            % Find REM events
            vt_events	= st_longTerm.EyeEvents.REM;
            vt_idView   = vt_events >= st_dat.time{1}(st_disp.posBeg) & ...
                        vt_events <= st_dat.time{1}(st_disp.posEnd);
            vt_events   = double(vt_events(vt_idView));
            
            if ~isempty(vt_events)
                
                vt_color    = st_ctrlSet.eventSet{nm_idEv,4};
                vt_color    = hex2rgb(vt_color);
                
                ch_txt  = 'REM';
                vt_yPos = nm_yPos + (st_disp.offsetValue/2)*(nm_l*10)/100;
                vt_yPos	= repmat(vt_yPos,size(vt_events));
                
                st_hLines.Events{nm_l}	= text(st_ctrCh.AxesGrid,...
                                        vt_events,vt_yPos,ch_txt,...
                                        'BackgroundColor',vt_color,...
                                        'HorizontalAlignment','center');
            end
        end
        
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_display_drawcursorsH()
        
        % Delete previous Lines
        if ~isempty(st_cursors.hLine_H1)
            if ishandle(st_cursors.hLine_H1(1))
                delete(st_cursors.hLine_H1(1))
            end
            if ishandle(st_cursors.hLine_H1(2))
                delete(st_cursors.hLine_H1(2))
            end
        end
        
        if ~isempty(st_cursors.hLine_H2)
            if ishandle(st_cursors.hLine_H2(1))
                delete(st_cursors.hLine_H2(1))
            end
            if ishandle(st_cursors.hLine_H2(2))
                delete(st_cursors.hLine_H2(2))
            end
        end
        
        if ~isempty(st_cursors.hPatch_H1)
            if ishandle(st_cursors.hPatch_H1)
                delete(st_cursors.hPatch_H1)
            end
        end
        
        if ~isempty(st_cursors.hPatch_H2)
            if ishandle(st_cursors.hPatch_H2)
                delete(st_cursors.hPatch_H2)
            end
        end
                
        
        st_cursors.hPatch_H1 = patch('Parent',st_ctrCh.AxesCurH,...
                            'XData',[st_cursors.pos_H1 ...
                            st_cursors.pos_H1 - st_cursors.size_H1 ...
                            st_cursors.pos_H1 - st_cursors.size_H1 ...
                            st_cursors.pos_H1 + st_cursors.size_H1 ...
                            st_cursors.pos_H1 + st_cursors.size_H1],...
                            'YData',[0 .5 1 1 .5],...
                            'FaceColor',st_cursors.colorCurH,...
                            'Visible','on',...
                            'EdgeColor','none',...
                            'ButtonDownFcn',@fn_cursorH_click);
                        
        st_cursors.hPatch_H2 = patch('Parent',st_ctrCh.AxesCurH,...
                            'XData',[st_cursors.pos_H2 ...
                            st_cursors.pos_H2 - st_cursors.size_H2 ...
                            st_cursors.pos_H2 - st_cursors.size_H2 ...
                            st_cursors.pos_H2 + st_cursors.size_H2 ...
                            st_cursors.pos_H2 + st_cursors.size_H2],...
                            'YData',[0 .5 1 1 .5],...
                            'FaceColor',st_cursors.colorCurH,...
                            'Visible','on',...
                            'EdgeColor','none',...
                            'ButtonDownFcn',@fn_cursorH_click);
                        
        vt_xLims     = get(st_ctrCh.axesCh,'XLim');        
        nm_XposCur1  = vt_xLims(1) + diff(vt_xLims) * st_cursors.pos_H1;  
        nm_XposCur2  = vt_xLims(1) + diff(vt_xLims) * st_cursors.pos_H2;
        
        st_cursors.hLine_H1(1)  = line(...
                            'Xdata',[nm_XposCur1 nm_XposCur1],...
                            'Ydata',get(st_ctrCh.axesCh,'YLim'),...
                            'Parent',st_ctrCh.axesCh,...
                            'Color',st_cursors.colorCurH);
        
        st_cursors.hLine_H2(1)  = line(...
                            'Xdata',[nm_XposCur2 nm_XposCur2],...
                            'Ydata',get(st_ctrCh.axesCh,'YLim'),...
                            'Parent',st_ctrCh.axesCh,...
                            'Color',st_cursors.colorCurH);
        
        vt_xLims     = get(st_ctrlTF.AxesTF,'XLim');        
        nm_XposCur1  = vt_xLims(1) + diff(vt_xLims) * st_cursors.pos_H1;  
        nm_XposCur2  = vt_xLims(1) + diff(vt_xLims) * st_cursors.pos_H2;
        
        st_cursors.hLine_H1(2)  = line(...
                            'Xdata',[nm_XposCur1 nm_XposCur1],...
                            'Ydata',get(st_ctrlTF.AxesTF,'YLim'),...
                            'Parent',st_ctrlTF.AxesTF,...
                            'Color',st_cursors.colorCurH);
        
        st_cursors.hLine_H2(2)  = line(...
                            'Xdata',[nm_XposCur2 nm_XposCur2],...
                            'Ydata',get(st_ctrlTF.AxesTF,'YLim'),...
                            'Parent',st_ctrlTF.AxesTF,...
                            'Color',st_cursors.colorCurH);
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_display_drawcursorsV()
        
        % Delete previous Lines
        if ~isempty(st_cursors.hLine_V1)
            if ishandle(st_cursors.hLine_V1(1))
                delete(st_cursors.hLine_V1(1))
            end
        end
        
        if ~isempty(st_cursors.hLine_V2)
            if ishandle(st_cursors.hLine_V2(1))
                delete(st_cursors.hLine_V2(1))
            end
        end
        
        if ~isempty(st_cursors.hPatch_V1)
            if ishandle(st_cursors.hPatch_V1)
                delete(st_cursors.hPatch_V1)
            end
        end
        
        if ~isempty(st_cursors.hPatch_V2)
            if ishandle(st_cursors.hPatch_V2)
                delete(st_cursors.hPatch_V2)
            end
        end
                
        
        st_cursors.hPatch_V1 = patch('Parent',st_ctrCh.AxesCurV,...
                            'XData',[0 .5 1 1 .5],...
                            'YData',[st_cursors.pos_V1 ...
                            st_cursors.pos_V1 - st_cursors.size_V1 ...
                            st_cursors.pos_V1 - st_cursors.size_V1 ...
                            st_cursors.pos_V1 + st_cursors.size_V1 ...
                            st_cursors.pos_V1 + st_cursors.size_V1],...
                            'FaceColor',st_cursors.colorCurV,...
                            'Visible','on',...
                            'EdgeColor','none',...
                            'ButtonDownFcn',@fn_cursorV_click);
                        
        st_cursors.hPatch_V2 = patch('Parent',st_ctrCh.AxesCurV,...
                            'XData',[0 .5 1 1 .5],...
                            'YData',[st_cursors.pos_V2 ...
                            st_cursors.pos_V2 - st_cursors.size_V2 ...
                            st_cursors.pos_V2 - st_cursors.size_V2 ...
                            st_cursors.pos_V2 + st_cursors.size_V2 ...
                            st_cursors.pos_V2 + st_cursors.size_V2],...
                            'FaceColor',st_cursors.colorCurV,...
                            'Visible','on',...
                            'EdgeColor','none',...
                            'ButtonDownFcn',@fn_cursorV_click);
                        
        vt_yLims     = get(st_ctrCh.axesCh,'YLim');        
        nm_yPosCur1  = vt_yLims(1) + diff(vt_yLims) * st_cursors.pos_V1;  
        nm_yPosCur2  = vt_yLims(1) + diff(vt_yLims) * st_cursors.pos_V2;
        
        st_cursors.hLine_V1(1)  = line(...
                            'Xdata',get(st_ctrCh.axesCh,'XLim'),...
                            'Ydata',[nm_yPosCur1 nm_yPosCur1],...
                            'Parent',st_ctrCh.axesCh,...
                            'Color',st_cursors.colorCurV);
        
        st_cursors.hLine_V2(1)  = line(...
                            'Xdata',get(st_ctrCh.axesCh,'XLim'),...
                            'Ydata',[nm_yPosCur2 nm_yPosCur2],...
                            'Parent',st_ctrCh.axesCh,...
                            'Color',st_cursors.colorCurV);
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_display_drawpatch()

        set(st_ctrHyp.AxesHyp,...
            'XLim',[st_dat.time{1}(1) st_dat.time{1}(end)])
        set(st_ctrHyp.AxesPatch,...
            'XLim',[st_dat.time{1}(1) st_dat.time{1}(end)])
        set(st_ctrlExtra.AxesPatch,...
            'XLim',[st_dat.time{1}(1) st_dat.time{1}(end)])
        
        vt_xLim	= get(st_ctrCh.AxesGrid,'XLim');
        vt_yLim	= get(st_ctrHyp.AxesPatch,'YLim');        
        nm_tPos = sum(st_hyp.timeEpoch <= st_disp.curTime);
        
        st_hLines.Patch	= patch('Parent',st_ctrHyp.AxesPatch,...
                                'XData',[vt_xLim(1) vt_xLim(1) ...
                                       	vt_xLim(2) vt_xLim(2)],...
                                'YData',[vt_yLim(1) vt_yLim(2) ...
                                        vt_yLim(2) vt_yLim(1)],...
                                'FaceColor',st_figSet.PatchColor,...
                                'FaceAlpha',0.8,...
                                'EdgeColor','none');         

        st_hLines.EpochTxt  = text(double(vt_xLim(1)),0.9,...
                            sprintf('Ep:%i',nm_tPos),...
                            'Parent',st_ctrHyp.AxesPatch);

        st_hLines.LineLT	= line(...
                                'XData',[vt_xLim(1) vt_xLim(1)],...
                                'YData',[vt_yLim(1) vt_yLim(2)],...
                                'Parent',st_ctrlExtra.AxesPatch,...
                                'Color','r');         
        
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_display_drawspectrum(~,~)
        
        if isfield(st_hLines,'Spect')
            if ishandle(st_hLines.Spect)
                delete(st_hLines.Spect)
            end
        end
                
        if ~isfield(st_spectrum,'labels')
            return
        end
        
        nm_chId	= find(ismember(st_spectrum.labels,st_disp.curCh));
        
        if isempty(nm_chId)
            return
        end
        
        mx_spectrumCh   = st_spectrum.data{nm_chId};
        
        
        [~,st_spectrum.posBeg]	= min(abs(...
                                st_dat.time{1}(st_disp.posBeg) -...
                                st_spectrum.time));
        [~,st_spectrum.posEnd]	= min(abs(...
                                st_dat.time{1}(st_disp.posEnd) -...
                                st_spectrum.time));
                                
        vt_limits(1)	= min(mx_spectrumCh(:));
        vt_limits(2)    = 0.8*max(mx_spectrumCh(:)) * ...
                        get(st_ctrlTF.sliderV,'Value');
%         vt_limits(2)    = prctile(mx_spectrumCh(:),...
%                         100*get(st_ctrlTF.sliderV,'Value'));
                                                  
        set(st_ctrlTF.AxesTF,...
            'XLim',st_dat.time{1}(...
                [st_disp.posBeg st_disp.posEnd]),...
            'YLim',[0.5 25])
            
        axes(st_ctrlTF.AxesTF); 
                
        st_hLines.Spect	= fn_imagearray(...
                        mx_spectrumCh(:,...
                                st_spectrum.posBeg:st_spectrum.posEnd),...            
                        st_spectrum.time(...
                            st_spectrum.posBeg:st_spectrum.posEnd),...         
                        st_spectrum.freq,...
                        'Limits',vt_limits,...
                        'Colormap','hot','ColorLevels',64);        
                           
        set(st_ctrlTF.AxesTF,...
            'YLim',[0.5 25],...
            'XTick',[])
        
        clear mx_spectrumCh
                
        fn_display_drawcursorsH()
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_display_drawhypnogram(~,~)
        % Prepare data
        
        mx_plotHypno	= single(st_hyp.dat + 100);
        mx_plotHypno(mx_plotHypno < 100)	= nan;
        mx_plotHypno(mx_plotHypno == 100)	= 5;
        mx_plotHypno(mx_plotHypno == 101)	= 3;
        mx_plotHypno(mx_plotHypno == 102)	= 2;
        mx_plotHypno(mx_plotHypno == 103)	= 1;
        mx_plotHypno(mx_plotHypno == 104)	= 0;
        mx_plotHypno(mx_plotHypno == 105)	= 4;
        mx_plotHypno(mx_plotHypno == 110)	= 6;
%         mx_plotHypno	= single(st_hyp.dat);
        
        % Clean previous lines
        if isfield(st_hLines,'hypLines')
            for kk = 1:numel(st_hLines.hypLines)
                if ishandle(st_hLines.hypLines(kk)) && ...
                    st_hLines.hypLines(kk) ~= 0
                    delete(st_hLines.hypLines(kk))
                end
            end
        end
        
        cla(st_ctrHyp.AxesHyp)
        st_disp.backHypno	= get(st_ctrHyp.HideHyp,'value');
        st_hLines.hypLines  = nan(1,2);
        vt_idPlots  = 1:size(st_hyp.dat,1);
        vt_idPlots(st_hyp.id)	= [];
        vt_idPlots  = [vt_idPlots,st_hyp.id];
        
        % Plot data
        for kk = vt_idPlots
            if kk == st_hyp.id
                nm_lineWidth = 1.5;
                vt_lineColor = [0.929,0.694,0.125];
                vt_artfColor = 'r';
                vt_fillColor = 'r';
                
            else
                
                if st_disp.backHypno
                    continue
                end
                
                nm_lineWidth = 0.7;
                vt_lineColor = [0,0.447,0.741];
                vt_artfColor = [0.9020,0.6039,0.6039];
                vt_fillColor = 'none';
            end
            
            [vt_xStairs,vt_yStairs]	= stairs(st_hyp.timeEpoch,...
                                    mx_plotHypno(kk,:));
            
            st_hLines.hypLines(kk,1)	= line(...
                                        'Xdata',vt_xStairs,...
                                        'Ydata',vt_yStairs,...
                                        'Parent',st_ctrHyp.AxesHyp,...
                                        'Color',vt_lineColor,...
                                        'LineWidth',nm_lineWidth);
            clear vt_xStairs vt_yStairs
                    
            if kk <= numel(st_hyp.arousals)                
                if ~isempty(st_hyp.arousals{kk})
                    st_hLines.hypLines(kk,2)	= line(...
                                                'Xdata',st_hyp.arousals{kk}(:,1),...
                                                'Ydata',7 * ...
                                                        ones(1,size(...
                                                        st_hyp.arousals{kk},1)),...
                                                'Parent',st_ctrHyp.AxesHyp,...
                                                'LineStyle','none',...
                                                'Marker','s',...
                                                'MarkerFaceColor',vt_fillColor,...
                                                'MarkerEdgeColor',vt_artfColor,...
                                                'MarkerSize',3);
                end
            end
        end
        pause(0.001)
        set(st_ctrHyp.AxesPatch,'Color','none')
        set(st_ctrHyp.AxesHyp,'Color','none')
        
        fn_display_identifystage()
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_display_drawlongterm()
        
        for kk = 1:numel(st_hLines.LTLines)
            if ishandle(st_hLines.LTLines(kk)) && st_hLines.LTLines(kk)~=0
                delete(st_hLines.LTLines(kk))
            end
        end
        
        if ~isfield(st_spectrum,'labels')
            return
        end
        
        % Get Frequency band color
        vt_eventLabel	= st_ctrlSet.eventSet(:,1);
        vt_eventColor	= st_ctrlSet.eventSet(:,4);
        
        nm_idEv     = ismember(vt_eventLabel,'eeg');
        vt_color    = vt_eventColor{nm_idEv};
        vt_color    = hex2rgb(vt_color);
        
        % Get longterm
        vt_idCh	= ismember(st_spectrum.labels,st_disp.curCh);
        st_hLines.LTLines = nan(9,1);
        
        nm_l	= 1;
        if isfield(st_longTerm,'delta')
            
            st_hLines.LTLines(nm_l)	= line(...
                                    'Xdata',st_longTerm.time,...
                                    'Ydata',st_longTerm.delta{vt_idCh},...
                                    'Parent',st_ctrlExtra.AxesDelta,...
                                    'Color',vt_color);
                                
            vt_lims	= [0,prctile(st_longTerm.delta{vt_idCh},98)];
            
            set(st_ctrlExtra.AxesDelta,'YLim',vt_lims)
        end
        
        nm_l	= nm_l + 1;
        if isfield(st_longTerm,'theta')
            
            st_hLines.LTLines(nm_l)	= line(...
                                    'Xdata',st_longTerm.time,...
                                    'Ydata',st_longTerm.theta{vt_idCh},...
                                    'Parent',st_ctrlExtra.AxesTheta,...
                                    'Color',vt_color);
                                
            vt_lims	= [0,prctile(st_longTerm.theta{vt_idCh},98)];
            
            set(st_ctrlExtra.AxesTheta,'YLim',vt_lims)
        end
        
        nm_l	= nm_l + 1;
        if isfield(st_longTerm,'alpha')
            
            st_hLines.LTLines(nm_l)	= line(...
                                    'Xdata',st_longTerm.time,...
                                    'Ydata',st_longTerm.alpha{vt_idCh},...
                                    'Parent',st_ctrlExtra.AxesAlpha,...
                                    'Color',vt_color);
                                
            vt_lims	= [0,prctile(st_longTerm.alpha{vt_idCh},98)];
            
            set(st_ctrlExtra.AxesAlpha,'YLim',vt_lims)
        end
        
        nm_l	= nm_l + 1;
        if isfield(st_longTerm,'mu')
            
            st_hLines.LTLines(nm_l)	= line(...
                                    'Xdata',st_longTerm.time,...
                                    'Ydata',st_longTerm.mu{vt_idCh},...
                                    'Parent',st_ctrlExtra.AxesSigma,...
                                    'Color',vt_color);
                                
            vt_lims	= [0,prctile(st_longTerm.mu{vt_idCh},98)];
            
            set(st_ctrlExtra.AxesSigma,'YLim',vt_lims)
        end
        
        nm_l	= nm_l + 1;
        if isfield(st_longTerm,'beta')
            
            st_hLines.LTLines(nm_l)	= line(...
                                    'Xdata',st_longTerm.time,...
                                    'Ydata',st_longTerm.beta{vt_idCh},...
                                    'Parent',st_ctrlExtra.AxesBeta,...
                                    'Color',vt_color);
                                
            vt_lims	= [0,prctile(st_longTerm.beta{vt_idCh},98)];
            
            set(st_ctrlExtra.AxesBeta,'YLim',vt_lims)
        end
        
        % Get EMG        
        nm_idEv     = ismember(vt_eventLabel,'emg');
        vt_color    = vt_eventColor{nm_idEv};
        vt_color    = hex2rgb(vt_color);
        
        nm_l	= nm_l + 1;
        if isfield(st_longTerm,'rmsEMG')
            
            for kk = 1:size(st_longTerm.rmsEMG,1)
                
                nm_l	= nm_l + 1;
                st_hLines.LTLines(nm_l)	= line(...
                                        'Xdata',st_longTerm.time,...
                                        'Ydata',st_longTerm.rmsEMG(kk,:),...
                                        'Parent',st_ctrlExtra.AxesEMGsd,...
                                        'Color',vt_color.*...
                                                (0.3+(.25/kk)));
                                    
            end
                                
            vt_lims	= [0,prctile(st_longTerm.rmsEMG(:),95)];
            
            if vt_lims(1) == vt_lims(2)
                vt_lims(2) = vt_lims(1) + 1;
            end
            
            set(st_ctrlExtra.AxesEMGsd,'YLim',vt_lims)
        end
        
        % Get SO        
        nm_idEv     = ismember(vt_eventLabel,'Slow_Waves');
        vt_color    = vt_eventColor{nm_idEv};
        vt_color    = hex2rgb(vt_color);
        
        nm_l	= nm_l + 1;
        if isfield(st_longTerm,'soRate')
            
            st_hLines.LTLines(nm_l)	= line(...
                                    'Xdata',st_longTerm.time(1:end-1),...
                                    'Ydata',st_longTerm.soRate{vt_idCh},...
                                    'Parent',st_ctrlExtra.AxesDensSO,...
                                    'Color',vt_color);
        end
        
        % Get spindle        
        nm_idEv     = ismember(vt_eventLabel,'Spindles');
        vt_color    = vt_eventColor{nm_idEv};
        vt_color    = hex2rgb(vt_color);
        
        nm_l	= nm_l + 1;
        if isfield(st_longTerm,'spRate')
            
            st_hLines.LTLines(nm_l)	= line(...
                                    'Xdata',st_longTerm.time(1:end-1),...
                                    'Ydata',st_longTerm.spRate{vt_idCh},...
                                    'Parent',st_ctrlExtra.AxesDensSP,...
                                    'Color',vt_color);
        end
        
        % Get EM        
        nm_idEv     = ismember(vt_eventLabel,'EyeMovements');
        vt_color    = vt_eventColor{nm_idEv};
        vt_color    = hex2rgb(vt_color);
        
        if isfield(st_longTerm,'EM')
            for kk = 1:size(st_longTerm.EM,1)
                
                nm_l	= nm_l + 1;
                st_hLines.LTLines(nm_l)	= line(...
                                        'Xdata',st_longTerm.time,...
                                        'Ydata',st_longTerm.EM(kk,:),...
                                        'color',vt_color.*...
                                                (0.3+(.25/kk)),...
                                        'Parent',st_ctrlExtra.AxesEM);  
                                    
            end
            
            vt_lims	= [0,max(st_longTerm.EM(:))];
            
            if vt_lims(1) == vt_lims(2)
                vt_lims(2) = vt_lims(1) + 1;
            end
            
            set(st_ctrlExtra.AxesEM,'YLim',vt_lims)
        end
                
        nm_l	= nm_l + 1;
        if isfield(st_longTerm,'thetaRate')
            
            st_hLines.LTLines(nm_l)	= line(...
                                    'Xdata',st_longTerm.time(1:end-1),...
                                    'Ydata',st_longTerm.thetaRate{vt_idCh},...
                                    'Parent',st_ctrlExtra.AxesThetaD,...
                                    'Color',[0.39,0.83,0.08]);
        end
                
        nm_l	= nm_l + 1;
        if isfield(st_longTerm,'alphaRate')
            
            st_hLines.LTLines(nm_l)	= line(...
                                    'Xdata',st_longTerm.time(1:end-1),...
                                    'Ydata',st_longTerm.alphaRate{vt_idCh},...
                                    'Parent',st_ctrlExtra.AxesAlphaD,...
                                    'Color',[0,0.45,0.74]);
        end
        
        % Get spindle        
        nm_idEv     = ismember(vt_eventLabel,'Arousals');
        vt_color    = vt_eventColor{nm_idEv};
        vt_color    = hex2rgb(vt_color);
        
        nm_l	= nm_l + 1;
        if isfield(st_longTerm,'arousalRate')
            
            st_hLines.LTLines(nm_l)	= line(...
                                    'Xdata',st_longTerm.time(1:end-1),...
                                    'Ydata',st_longTerm.arousalRate{vt_idCh},...
                                    'Parent',st_ctrlExtra.AxesArousal,...
                                    'Color',vt_color);
        end
        
        nm_l	= nm_l + 1;
        if isfield(st_longTerm,'bpm')
            
            st_hLines.LTLines(nm_l)	= line(...
                                    'Xdata',st_longTerm.time,...
                                    'Ydata',st_longTerm.bpm,...
                                    'Parent',st_ctrlExtra.AxesBPM,...
                                    'Color','r');
                                
            set(st_ctrlExtra.AxesBPM,'YLim',[50 120])
        end
        
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_display_identifystage()
        
        if ~isfield(st_hyp,'dat')
            return
        end
        
        fn_control_getstage()
        fn_control_resetcolor()
        
        switch st_disp.hypStage
            case 0                
                set(st_ctrlScore.WBut,...
                    'BackgroundColor',st_figSet.ActiveColor)
            case 1            
                set(st_ctrlScore.N1But,...
                    'BackgroundColor',st_figSet.ActiveColor)
                
            case 2             
                set(st_ctrlScore.N2But,...
                    'BackgroundColor',st_figSet.ActiveColor)
                
            case 3             
                set(st_ctrlScore.N3But,...
                    'BackgroundColor',st_figSet.ActiveColor)
                
            case 5            
                set(st_ctrlScore.RBut,...
                    'BackgroundColor',st_figSet.ActiveColor)
                
            case 10              
                set(st_ctrlScore.MBut,...
                    'BackgroundColor',st_figSet.ActiveColor)
                
            otherwise                                
                set(st_ctrlScore.UBut,...
                    'BackgroundColor',st_figSet.ActiveColor)
        end
        
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_display_zoominfo(hObject,~)
        if get(hObject,'Value')
            h_zoom	= zoom;
            set(h_zoom,...
                'Direction','in',...
                'Motion','Vertical',...
                'Enable','on')
            setAllowAxesZoom(h_zoom,...
                [st_ctrHyp.AxesPatch,st_ctrHyp.AxesHyp,st_ctrCh.AxesGrid,...
                st_ctrCh.axesCh,st_ctrlTF.AxesTF],false)
        else
            h_zoom	= zoom;            
            set(h_zoom,'Enable','off')            
        end
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_display_rename()
        ch_newName	= sprintf('psgScore - [%s]',st_file.fileName);
        set(st_hFigure.Main,'Name',ch_newName);
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_display_psd(~,~)
                        
        if ~isfield(st_dat,'label')
            return
        end
        
        vt_chId	= ismember(st_dat.label,st_disp.curCh);
        
        if isempty(vt_chId)
            return
        end
        
        
        vt_xLims  	= get(st_ctrCh.axesCh,'XLim');        
        nm_XposCur1	= vt_xLims(1) + diff(vt_xLims) * st_cursors.pos_H1;  
        nm_XposCur2	= vt_xLims(1) + diff(vt_xLims) * st_cursors.pos_H2;
        
        if nm_XposCur2 > nm_XposCur1
            nm_xBeg     = find(st_dat.time{1} >= nm_XposCur1,1);  
            nm_xEnd     = find(st_dat.time{1} >= nm_XposCur2,1);  
        else
            nm_xBeg     = find(st_dat.time{1} >= nm_XposCur2,1);  
            nm_xEnd     = find(st_dat.time{1} >= nm_XposCur1,1);  
        end
                
        vt_signal	= st_dat.trial{1}(vt_chId,nm_xBeg:nm_xEnd);
        nm_window	= round(numel(vt_signal)/5);
        vt_freq     = 0:0.25:35;
        [vt_pxx,vt_f]	= pwelch(vt_signal,nm_window,[],...
                        vt_freq,st_dat.fsample);
        
        figure        
        plot(vt_f,10*log10(vt_pxx))
        xlabel('Frequency (Hz)')
        ylabel('Magnitude (dB)')
        title(sprintf('PSD for %s between cursors',st_disp.curCh))
        grid
    end
    
%% [Functions] - Cursors
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_cursors_dragend(~,~)
        % In this function the cursors stop moving
        
        set(st_hFigure.Main,'WindowButtonMotionFcn','')
        st_cursors.current_H = [];
        st_cursors.current_V = [];
        
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_cursors_updatevalues
        % In this function the cursors stop moving
        nm_vertDistance	= abs(st_cursors.pos_V2 - st_cursors.pos_V1);
        nm_horzDistance	= abs(st_cursors.pos_H2 - st_cursors.pos_H1);
                
        nm_vertWindow   = abs(diff(get(st_ctrCh.axesCh,'YLim')));
        nm_horzWindow	= abs(diff(get(st_ctrCh.axesCh,'XLim'))); 
        
        ch_cursorsTime  = sprintf('%3.3f',...
                        nm_horzDistance .* nm_horzWindow);
        ch_cursorsPerc  = sprintf('%3.2f',...
                        100 * nm_horzDistance);
        ch_cursorsVlt  = sprintf('%3.3f',...
                        (nm_vertWindow .* nm_vertDistance)/st_disp.ampScale);
        
        set(st_ctrl.xCurTm,'String',ch_cursorsTime);
        set(st_ctrl.xCurPrc,'String',ch_cursorsPerc);
        set(st_ctrl.yCur,'String',ch_cursorsVlt);
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_cursorH_axisdrag(hObject,~)   
        
        if isempty(st_cursors.hLine_H1)
            return
        end
                
        nm_currentPoint	= get(hObject,'CurrentPoint');
        nm_currentPoint	= nm_currentPoint(1);
                
        if nm_currentPoint < 0
            nm_currentPoint = 0;
        elseif nm_currentPoint > 1
            nm_currentPoint = 1;
        end
        
        % Set position of first cursor on click        
        st_cursors.pos_H1 = nm_currentPoint;
        set(st_cursors.hPatch_H1,...
            'XData',[st_cursors.pos_H1 ...
            st_cursors.pos_H1 - st_cursors.size_H1 ...
            st_cursors.pos_H1 - st_cursors.size_H1 ...
            st_cursors.pos_H1 + st_cursors.size_H1 ...
            st_cursors.pos_H1 + st_cursors.size_H1]);
        
        fn_cursorH_process()  
                
        % Set second cursor for dragging    
        st_cursors.current_H	= st_cursors.hPatch_H2;
        set(st_hFigure.Main,'WindowButtonMotionFcn',@fn_cursorH_dragbeg)
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_cursorH_click(hObject,~)        
        st_cursors.current_H	= hObject;
        set(st_hFigure.Main,'WindowButtonMotionFcn',@fn_cursorH_dragbeg)
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_cursorH_dragbeg(~,~)
        
        nm_currentPoint  = get(st_ctrCh.AxesCurH,'CurrentPoint');
        nm_currentPoint  = nm_currentPoint(1);
                
        if nm_currentPoint < 0
            nm_currentPoint = 0;
        elseif nm_currentPoint > 1
            nm_currentPoint = 1;
        end
        
        switch st_cursors.current_H
            case st_cursors.hPatch_H1
                st_cursors.pos_H1 = nm_currentPoint;
                set(st_cursors.hPatch_H1,...
                    'XData',[st_cursors.pos_H1 ...
                            st_cursors.pos_H1 - st_cursors.size_H1 ...
                            st_cursors.pos_H1 - st_cursors.size_H1 ...
                            st_cursors.pos_H1 + st_cursors.size_H1 ...
                            st_cursors.pos_H1 + st_cursors.size_H1]);
                        
            case st_cursors.hPatch_H2
                st_cursors.pos_H2 = nm_currentPoint;
                set(st_cursors.hPatch_H2,...
                    'XData',[st_cursors.pos_H2 ...
                            st_cursors.pos_H2 - st_cursors.size_H2 ...
                            st_cursors.pos_H2 - st_cursors.size_H2 ...
                            st_cursors.pos_H2 + st_cursors.size_H2 ...
                            st_cursors.pos_H2 + st_cursors.size_H2]);
        end
        
        fn_cursorH_process()    
        
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_cursorH_process()
        fn_cursorH_position()  
        fn_cursors_updatevalues()
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_cursorH_position()
        
        vt_xLims     = get(st_ctrCh.axesCh,'XLim');        
        nm_XposCur1  = vt_xLims(1) + diff(vt_xLims) * st_cursors.pos_H1;  
        nm_XposCur2  = vt_xLims(1) + diff(vt_xLims) * st_cursors.pos_H2;
        
        set(st_cursors.hLine_H1(1),...
            'Xdata',[nm_XposCur1 nm_XposCur1],...
            'Ydata',get(st_ctrCh.axesCh,'YLim'));
        
        set(st_cursors.hLine_H2(1),...
            'Xdata',[nm_XposCur2 nm_XposCur2],...
            'Ydata',get(st_ctrCh.axesCh,'YLim'));
                                
        vt_xLims     = get(st_ctrlTF.AxesTF,'XLim');        
        nm_XposCur1  = vt_xLims(1) + diff(vt_xLims) * st_cursors.pos_H1;  
        nm_XposCur2  = vt_xLims(1) + diff(vt_xLims) * st_cursors.pos_H2;        
        
        set(st_cursors.hLine_H1(2),...
            'Xdata',[nm_XposCur1 nm_XposCur1],...
            'Ydata',get(st_ctrlTF.AxesTF,'YLim'));
        
        set(st_cursors.hLine_H2(2),...
            'Xdata',[nm_XposCur2 nm_XposCur2],...
            'Ydata',get(st_ctrlTF.AxesTF,'YLim'));
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_cursorV_axisdrag(hObject,~)   
        
        if isempty(st_cursors.hLine_V1)
            return
        end
                
        nm_currentPoint	= get(hObject,'CurrentPoint');
        nm_currentPoint  = nm_currentPoint(1,:);
        nm_currentPoint  = nm_currentPoint(2);
                
        if nm_currentPoint < 0
            nm_currentPoint = 0;
        elseif nm_currentPoint > 1
            nm_currentPoint = 1;
        end
        
        % Set position of first cursor on click   
        st_cursors.pos_V1 = nm_currentPoint;
        set(st_cursors.hPatch_V1,...
            'YData',[st_cursors.pos_V1 ...
            st_cursors.pos_V1 - st_cursors.size_V1 ...
            st_cursors.pos_V1 - st_cursors.size_V1 ...
            st_cursors.pos_V1 + st_cursors.size_V1 ...
            st_cursors.pos_V1 + st_cursors.size_V1]);
        
        fn_cursorV_process()          
        
        % Set second cursor for dragging    
        st_cursors.current_V	= st_cursors.hPatch_V2;
        set(st_hFigure.Main,'WindowButtonMotionFcn',@fn_cursorV_dragbeg)
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_cursorV_click(hObject,~)        
        st_cursors.current_V	= hObject;   
        st_cursors.last_V       = hObject;
        set(st_hFigure.Main,'WindowButtonMotionFcn',@fn_cursorV_dragbeg)
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_cursorV_dragbeg(~,~)
        
        nm_currentPoint  = get(st_ctrCh.AxesCurV,'CurrentPoint');
        nm_currentPoint  = nm_currentPoint(1,:);
        nm_currentPoint  = nm_currentPoint(2);
                
        if nm_currentPoint < 0
            nm_currentPoint = 0;
        elseif nm_currentPoint > 1
            nm_currentPoint = 1;
        end
        
        switch st_cursors.current_V
            case st_cursors.hPatch_V1
                st_cursors.pos_V1 = nm_currentPoint;
                set(st_cursors.hPatch_V1,...
                    'YData',[st_cursors.pos_V1 ...
                            st_cursors.pos_V1 - st_cursors.size_V1 ...
                            st_cursors.pos_V1 - st_cursors.size_V1 ...
                            st_cursors.pos_V1 + st_cursors.size_V1 ...
                            st_cursors.pos_V1 + st_cursors.size_V1]);
                        
            case st_cursors.hPatch_V2
                st_cursors.pos_V2 = nm_currentPoint;
                set(st_cursors.hPatch_V2,...
                    'YData',[st_cursors.pos_V2 ...
                            st_cursors.pos_V2 - st_cursors.size_V2 ...
                            st_cursors.pos_V2 - st_cursors.size_V2 ...
                            st_cursors.pos_V2 + st_cursors.size_V2 ...
                            st_cursors.pos_V2 + st_cursors.size_V2]);
        end
        
        fn_cursorV_process()    
        
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_cursorV_process()
        fn_cursorV_position()   
        fn_cursors_updatevalues()     
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_cursorV_position()
        
        vt_yLims     = get(st_ctrCh.axesCh,'YLim');        
        nm_yPosCur1  = vt_yLims(1) + diff(vt_yLims) * st_cursors.pos_V1;  
        nm_yPosCur2  = vt_yLims(1) + diff(vt_yLims) * st_cursors.pos_V2;
        
        set(st_cursors.hLine_V1(1),...
            'Ydata',[nm_yPosCur1 nm_yPosCur1],...
            'Xdata',get(st_ctrCh.axesCh,'XLim'));
        
        set(st_cursors.hLine_V2(1),...
            'Ydata',[nm_yPosCur2 nm_yPosCur2],...
            'Xdata',get(st_ctrCh.axesCh,'XLim'));
        
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_cursorV_inputposition(nm_currentPoint)
                     
        switch st_cursors.last_V                
            case st_cursors.hPatch_V1
                st_cursors.pos_V2 = nm_currentPoint;
                set(st_cursors.hPatch_V2,...
                    'YData',[st_cursors.pos_V2 ...
                    st_cursors.pos_V2 - st_cursors.size_V2 ...
                    st_cursors.pos_V2 - st_cursors.size_V2 ...
                    st_cursors.pos_V2 + st_cursors.size_V2 ...
                    st_cursors.pos_V2 + st_cursors.size_V2]);
                
            case st_cursors.hPatch_V2
                st_cursors.pos_V1 = nm_currentPoint;
                set(st_cursors.hPatch_V1,...
                    'YData',[st_cursors.pos_V1 ...
                    st_cursors.pos_V1 - st_cursors.size_V1 ...
                    st_cursors.pos_V1 - st_cursors.size_V1 ...
                    st_cursors.pos_V1 + st_cursors.size_V1 ...
                    st_cursors.pos_V1 + st_cursors.size_V1]);
        end
        
        fn_cursorV_process()
    end

%% [Functions] - Control
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_control_extrapanel(~,~)
        
        nm_isTF     = get(st_ctrl.TFBut,'Value');
        nm_isExtras	= get(st_ctrl.LTBut,'Value');
        
        
        if nm_isTF && nm_isExtras
            set(st_panelMain.Hyp,'Position',[0 .85 .75 .1])
            set(st_panelMain.Ch,'Position',[0 .15 .75 .7])
            set(st_panelMain.TF,'Position',[0 0 .75 .15])
            set(st_panelMain.TF,'Visible','on')
            set(st_panelMain.LT,'Visible','on')
        elseif nm_isTF && ~nm_isExtras
            set(st_panelMain.Hyp,'Position',[0 .85 1 .1])
            set(st_panelMain.Ch,'Position',[0 .15 1 .7])
            set(st_panelMain.TF,'Position',[0 0 1 .15])
            set(st_panelMain.TF,'Visible','on')
            set(st_panelMain.LT,'Visible','off')
        elseif ~nm_isTF && nm_isExtras
            set(st_panelMain.Hyp,'Position',[0 .85 .75 .1])
            set(st_panelMain.Ch,'Position',[0 0 .75 .85])
            set(st_panelMain.TF,'Position',[0 0 .75 .15])
            set(st_panelMain.TF,'Visible','off')
            set(st_panelMain.LT,'Visible','on')
        else
            set(st_panelMain.Hyp,'Position',[0 .85 1 .1])
            set(st_panelMain.Ch,'Position',[0 0 1 .85])
            set(st_panelMain.TF,'Position',[0 0 1 .15])
            set(st_panelMain.TF,'Visible','off')
            set(st_panelMain.LT,'Visible','off')
        
        end    
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_control_eventDisplay(~,~)
        
    st_hFigure.Events	= figure(...          
                        'ToolBar','None', ...
                        'MenuBar','None', ...
                        'NumberTitle','off', ...
                        'Name','Display Events', ...
                        'WindowStyle','modal',...
                        'Units','normalized',...
                        'Position',[0.5 .5 0.2 .2],...
                        'Color',st_figSet.BackColor);
                    
    st_ctrl.eventTable	= uitable(st_hFigure.Events,...
                        'Data',st_ctrlSet.eventSet,...
                        'ColumnEditable',[false,false,true,true],...
                        'ColumnName',st_ctrlSet.EventCol,...
                        'RowName',[],...
                        'Units','normalized',...
                        'Position',[0.05 .2 0.9 .8],...
                        'CellSelectionCallback',@fn_control_clickEvents); 
                    
            
    st_ctrl.eventSet	= uicontrol(st_hFigure.Events,...
                        'Style','pushbutton',...
                        'BackgroundColor',st_figSet.BackColor,...
                        'HorizontalAlignment','center',...
                        'FontSize',st_figSet.TextCtrlSize,...
                        'String','OK',...
                        'Units','normalized',...
                        'Position',[.25 .05 .5 .10],...
                        'CallBack',@fn_control_setEvents);
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_control_clickEvents(hObject,tb)
        
        if isempty(tb.Indices)
            return
        end
        nm_idColor	= find(ismember(hObject.ColumnName,'Color'));
        
        if nm_idColor == tb.Indices(2)
            
            vt_color	= uisetcolor;
            if numel(vt_color) == 1
                return
            end
            
            vt_color	= rgb2hex(vt_color);
            hObject.Data{tb.Indices(1),tb.Indices(2)}	= vt_color;
        end
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_control_setEvents(~,~)
        
        tb_eventTable	= get(st_ctrl.eventTable,'Data');
        vt_idColor      = ismember(st_ctrlSet.EventCol,'Color');
        
        for kk = 1:size(tb_eventTable,1)
            vt_curColor	= tb_eventTable{kk,vt_idColor};
            try
                vt_curColor	= hex2rgb(vt_curColor);
                
                if isempty(vt_curColor)
                    error('color_error');
                end
            catch 
                vt_curColor	= hex2rgb(st_ctrlSet.eventSet{kk,vt_idColor});
            end
            
            tb_eventTable{kk,vt_idColor}	= rgb2hex(vt_curColor);
        end
        
        st_ctrlSet.eventSet	= tb_eventTable;
        
        close(st_hFigure.Events)
        
        fn_display_process()
        fn_display_drawlongterm()
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_control_skiptoclick(hObject,~)
        if ~isfield(st_dat,'time')            
            set(st_ctrCh.SliderH,'Enable','off')
            return
        end
        
        vt_pos	= get(hObject,'CurrentPoint');
        vt_pos  = vt_pos(1,[1,2]);
        
        if vt_pos(1) > st_hyp.timeEpoch(end)
            nm_curEpoch = numel(st_hyp.timeEpoch);
        elseif vt_pos(1) < st_hyp.timeEpoch(1) 
            nm_curEpoch = 1;
        else
            nm_curEpoch	= discretize(vt_pos(1),st_hyp.timeEpoch);
        end       
        
        fn_control_gotoepoch(nm_curEpoch)
        
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_control_inputdlg(hObject,~)
        
        if ~isfield(st_dat,'time')            
            set(st_ctrCh.SliderH,'Enable','off')
            return
        end
        
        switch hObject
            case st_ctrl.EpochNum
                ch_prompt	= 'Epoch Number: ';
                ch_title    = 'Go to';
                ch_definput	= {'1'};
                st_opts.Interpreter	= 'tex';
            case st_ctrl.yCur
                ch_prompt	= 'Set cursor at (\muV): ';
                ch_title    = 'Set cursor';
                ch_definput	= {'-75'};
                st_opts.Interpreter	= 'tex';
        end
        
        nm_answer = inputdlg(ch_prompt,ch_title,[1 30],ch_definput,st_opts);
        
        if isempty(nm_answer)
            return
        end
        
        nm_answer = str2double(nm_answer{1});
                
        if isnan(nm_answer)
            return
        end
                
        switch hObject
            case st_ctrl.EpochNum
                
                if nm_answer > numel(st_hyp.timeEpoch)
                    nm_answer	= numel(st_hyp.timeEpoch);
                elseif nm_answer < 1
                    nm_answer	= 1;
                end 
                
                fn_control_gotoepoch(nm_answer)
                
            case st_ctrl.yCur
                if ~isfield(st_cursors,'last_V')
                    st_cursors.last_V	= st_cursors.hPatch_V1;
                end
                
                vt_yLims    = get(st_ctrCh.axesCh,'YLim');        
                nm_yPos     = nm_answer/diff(vt_yLims);  
                
                switch st_cursors.last_V
                    case st_cursors.hPatch_V1
                        nm_currentPoint	= st_cursors.pos_V1;
                    case st_cursors.hPatch_V2
                        nm_currentPoint	= st_cursors.pos_V2;
                end
                   
                nm_currentPoint = nm_currentPoint + nm_yPos;
        
                if nm_currentPoint < 0
                    nm_currentPoint = 0;
                elseif nm_currentPoint > 1
                    nm_currentPoint = 1;
                end
                
                fn_cursorV_inputposition(nm_currentPoint)
        end
        
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_control_sliderhorz()
        if ~isfield(st_dat,'time')            
            set(st_ctrCh.SliderH,'Enable','off')
            return
        end
        nm_sliderRange	= st_dat.time{1}(end)-st_disp.window;
        vt_sliderStep   = [st_disp.window/3,st_disp.window]./nm_sliderRange;
        
        if st_dat.time{1}(1) == nm_sliderRange || st_hyp.isScoring
            set(st_ctrCh.SliderH,...
                'Enable','off')            
        elseif vt_sliderStep(2) > vt_sliderStep(1)
            set(st_ctrCh.SliderH,...
                'Enable','on',...
                'Min',st_dat.time{1}(1),...
                'Max',nm_sliderRange,...
                'Value',st_disp.curTime,...
                'SliderStep',double(vt_sliderStep))
        else
            set(st_ctrCh.SliderH,...
                'Enable','off',...
                'Min',st_dat.time{1}(1),...
                'Max',nm_sliderRange,...
                'Value',st_disp.curTime,...
                'SliderStep',[0.01 0.10])            
        end
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_control_slidervert()
        nm_curVal   = st_disp.chPos;
        nm_curMin	= 1;
        nm_curMax	= numel(st_disp.idCh) - st_disp.showCh + 1;
        vt_scale	= nm_curMax:-1:nm_curMin;
        
        if nm_curVal > nm_curMax
            nm_curVal = nm_curMax;
        end
        
        if st_disp.showCh == numel(st_disp.idCh) 
            
            set(st_ctrCh.SliderV,...
                'Value',1,...
                'Enable','off')
        else
            set(st_ctrCh.SliderV,...
                'Enable','on',...
                'Min',nm_curMin,...
                'Max',nm_curMax,...
                'Value',vt_scale(nm_curVal),...
                'SliderStep',[st_disp.showCh/numel(st_disp.idCh),...
                st_disp.showCh/numel(st_disp.idCh)])
        end
                 
        fn_control_sliderposition()
                
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_control_sliderwork(hObject,~)
        switch hObject
            case st_ctrCh.SliderH                
                st_disp.curTime	= get(hObject,'Value');
            case st_ctrCh.SliderV                
                fn_control_sliderposition()
        end
        fn_display_process()
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_control_sliderposition()
        nm_curVal   	= round(get(st_ctrCh.SliderV,'Value'));
        nm_curMin       = get(st_ctrCh.SliderV,'Min');
        nm_curMax       = get(st_ctrCh.SliderV,'Max');
        vt_scale        = nm_curMax:-1:nm_curMin;
        st_disp.chPos	= vt_scale(nm_curVal);
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_control_grid(hObject,~)
        switch hObject
            case st_ctrl.AmpGPop 
                vt_yLims     = get(st_ctrCh.AxesGrid,'YLim');
                nm_GridVal	= st_ctrlSet.AmpVal(get(hObject,'Value'));
                set(st_ctrCh.AxesGrid,...
                    'YTick',vt_yLims(1):nm_GridVal:vt_yLims(end),...
                    'YTickLabel',[],...
                    'YGrid','on')
            case st_ctrl.GridPop
                vt_xLims     = get(st_ctrCh.AxesGrid,'XLim');
                nm_GridVal	= st_ctrlSet.GridVal(get(hObject,'Value'));
                set(st_ctrCh.AxesGrid,...
                    'XTick',vt_xLims(1):nm_GridVal:vt_xLims(end),...
                    'XTickLabel',[],...
                    'XGrid','on')
        end
    end 
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_control_patch()
        vt_xLim	= get(st_ctrCh.AxesGrid,'XLim');
        vt_yLim	= get(st_ctrHyp.AxesPatch,'YLim');
        nm_tPos = sum(st_hyp.timeEpoch <= st_disp.curTime);
        
        set(st_hLines.Patch,...
            'XData',[vt_xLim(1) vt_xLim(1) vt_xLim(2) vt_xLim(2)],...
            'YData',[vt_yLim(1) vt_yLim(2) vt_yLim(2) vt_yLim(1)])
        
        set(st_hLines.EpochTxt,...
            'string',sprintf('Ep:%i',nm_tPos),...
            'position',[vt_xLim(1),0.9]);
                        
        vt_yLim	= get(st_ctrlExtra.AxesPatch,'YLim');
        set(st_hLines.LineLT,...
            'XData',[vt_xLim(1) vt_xLim(1)],...
            'YData',[vt_yLim(1) vt_yLim(2)])
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_control_chView(hObject,~)
        
        nm_id              = get(hObject,'Value');
        st_disp.curCh	= st_chann.EEGlabels{nm_id};
        
        set(st_ctrlTF.chanPop,'Value',nm_id);
        set(st_ctrlExtra.chanPop,'Value',nm_id);
        
        fn_display_process()
        fn_display_drawlongterm()
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_control_closeall(~,~)
        delete(st_hFigure.Main)
        
        vt_Out = timerfindall;
        
        if isobject(vt_Out)
            stop(vt_Out)
            delete(vt_Out)
        end
        
        %clear functions
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_control_chlist()
        
        set(st_ctrlTF.chanPop,...
            'String',st_chann.EEGlabels)
        set(st_ctrlExtra.chanPop,...
            'String',st_chann.EEGlabels)
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_control_chSelection(~,~)
        try
            [vt_id,nm_exit]	= listdlg(...
                            'PromptString','Channels to display: ',...
                            'ListString',st_dat.label,...
                            'InitialValue',st_disp.idCh);
                        
            if ~nm_exit
                return
            end
            
            
            st_disp.idCh	= vt_id;
            st_disp.chPos   = 1;
            st_disp.showCh  = numel(st_disp.idCh);
            
            set(st_ctrl.NuChPop,'String',num2str((1:numel(st_disp.idCh))'))
            set(st_ctrl.NuChPop,'Value',numel(st_disp.idCh));
            
            fn_control_slidervert()
            fn_control_sliderwork(st_ctrCh.SliderV);
            
            fn_display_process()
            
        catch
            return
        end
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_control_scorepredict(~,~)
        
        % Check inputs
        if ~isfield(st_dat,'trial')
            return            
        end
        
        if ~isfield(st_spectrum,'labels')
            warndlg({'Hypnogram prediction is not possible without';...
                'the preprocessed psg-Extras file'},...
                'Prediction warning'); 
            return            
        end
        
        vt_prompt	= {'Frontal ch:','Central ch:','Occipital ch:'};
        ch_title	= 'Prediction Inputa';
        vt_dims     = [1 35];
        vt_definput	= {'F3,F4','C3,C4','O1,O2'};
        vt_answer   = inputdlg(vt_prompt,ch_title,vt_dims,vt_definput);
        vt_answer   = cellfun(@(x) split(x,','),vt_answer,...
                    'UniformOutput',false);
                
        if isempty(vt_answer)
            return
        end
        
        vt_numel    = cellfun(@numel,vt_answer);
        
        mx_predCh   = cell(numel(vt_answer),max(vt_numel));
        
        for cc = 1:size(mx_predCh,2)
            for rr = 1:size(mx_predCh,1)
                if cc > vt_numel(rr)
                    nm_col = vt_numel(rr);
                else
                    nm_col = cc;
                end
                
                mx_predCh{rr,nm_col} = vt_answer{rr}{nm_col};
            end
        end
        
        try
            mx_ismember = ismember(mx_predCh,st_spectrum.labels);
            
            if any(sum(mx_ismember,2) < 1)
                error('channel fix')
            end
            
        catch
            warndlg({'Please check that channels names correspond';...
                'to channels within the EEG file'},...
                'Prediction warning'); 
            return
        end
                
        % Check channels
        
        st_cfg.chRead	= mx_predCh;
        st_cfg.chIdx    = mx_ismember;        
        st_cfg.patterns = st_longTerm;
        st_cfg.spectrum = st_spectrum;

        ob_dlg = msgbox('Please wait while predictions are done');
        mx_features	= fn_hypnogram_prepare(st_cfg);
        st_hyp      = fn_hypnogram_predict(mx_features,st_hyp);
        
        if ishandle(ob_dlg)
            close(ob_dlg)
        end
        
        % Update Hypnogram panel
        
        vt_stringCnt	=  num2cell(num2str((1:size(st_hyp.dat,1))'));
        vt_stringCnt    =  vertcat(vt_stringCnt,{'new'});
        
        set(st_ctrHyp.SelHyp,'String',vt_stringCnt)
        set(st_ctrHyp.SelHyp,'Value',st_hyp.id)
        
        fn_display_drawhypnogram()
        
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_control_scorestate(hObject,~)
        switch get(hObject,'Value')
            case 0 
                
                fn_file_autosave()
                
                set(st_ctrl.WindPop,'Enable','on')
                st_hyp.isScoring	= 0;
                                
                if isfield(st_file,'objTimer')
                    if isobject(st_file.objTimer)
                        stop(st_file.objTimer)
                    end
                end
            case 1
                set(st_ctrl.WindPop,'Enable','off')   
         
                if isfield(st_file,'objTimer')
                    start(st_file.objTimer);
                end       
                  
                st_hyp.isScoring	= 1;
                fn_control_scorestart()
        end
        fn_control_sliderhorz()
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_control_scorestart()
        
        if ~isfield(st_dat,'trial')
            set(st_ctrlScore.OkScBut,'Value',0)
            set(st_ctrl.WindPop,'Enable','on')
            return            
        end
        
        if ~isfield(st_hyp,'dat')
            st_hyp.isScoring	= 0;
            set(st_ctrl.WindPop,'Enable','on')
            if isobject(st_file.objTimer)
                stop(st_file.objTimer)
            end
            return
        end
        
        st_disp.window      = st_ctrlSet.WindVal(...
                            get(st_ctrl.WindPop,'Value'));
        st_disp.stepTime	= single(st_dat.time{1}(1):st_disp.window:...
                            st_dat.time{1}(end)-st_disp.window);
                            
        st_hyp.epoch        = st_disp.window;        
        
        if ~isfield(st_hyp,'timeEpoch')
            st_hyp.timeEpoch	= st_disp.stepTime;
        end
        
        if numel(st_disp.stepTime) ~= numel(st_hyp.timeEpoch)
            st_hyp.dat          = int8(interp1(...
                                st_hyp.timeEpoch,single(st_hyp.dat)',...
                                st_disp.stepTime,'nearest'));
            st_hyp.timeEpoch	= st_disp.stepTime;
        end
                    
                    
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_control_gotoepoch(nm_epoch)
        if ~isnumeric(nm_epoch) && ischar(nm_epoch)
            vt_curScore = find(st_hyp.dat(st_hyp.id,:)== -1);
            nm_tPos     = sum(st_hyp.timeEpoch <= st_disp.curTime);
            
            switch nm_epoch
                case 'next'
                    nm_epoch	= find(vt_curScore > nm_tPos,1,'first');
                    nm_epoch    = vt_curScore(nm_epoch);
                    
                    if isempty(nm_epoch)
                        nm_epoch	= numel(st_hyp.timeEpoch); 
                    end
                    
                case 'previous'
                    nm_epoch	= find(vt_curScore < nm_tPos,1,'last');
                    nm_epoch    = vt_curScore(nm_epoch);
                    
                    if isempty(nm_epoch)
                        nm_epoch	= 1; 
                    end
                    
                otherwise
                    return
            end
        end
        
        st_disp.curTime	= st_hyp.timeEpoch(nm_epoch);
        
        fn_display_process()
                
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_control_key_release(~,hEvent)
                        
        ch_modif	= 'null';
        
        if ~isempty(hEvent.Modifier)
            ch_modif	= hEvent.Modifier{1,1};
        end
        
        switch hEvent.Key
            case {'leftarrow','downarrow'}
                st_cursors.pos_H1 = 0;
                st_cursors.pos_H2 = 1;
                
                switch ch_modif                    
                    case 'control'
                        fn_control_gotoepoch('previous')
                    case 'alt'
                        fn_display_advance(st_ctrCh.FBBut);
                    otherwise
                        fn_display_advance(st_ctrCh.BBut);
                end
                return
            case {'rightarrow','uparrow'}
                st_cursors.pos_H1 = 0;
                st_cursors.pos_H2 = 1; 
                
                switch ch_modif                    
                    case 'control'
                        fn_control_gotoepoch('next')                        
                    case 'alt'
                        fn_display_advance(st_ctrCh.FFBut);
                    otherwise
                        fn_display_advance(st_ctrCh.FBut);
                end
                
                return
            otherwise
        end
        
        if ~st_hyp.isScoring 
            return
        end
                
        nm_isAdvance    = true;
        switch lower(hEvent.Character)
            case {'w','0'}
                fn_control_stagebutton(st_ctrlScore.WBut);
            case '1'
                fn_control_stagebutton(st_ctrlScore.N1But);
            case '2'
                fn_control_stagebutton(st_ctrlScore.N2But);
            case '3'
                fn_control_stagebutton(st_ctrlScore.N3But);
            case {'r','5'}
                fn_control_stagebutton(st_ctrlScore.RBut);
            case {'m','6'}
                fn_control_stagebutton(st_ctrlScore.MBut);
            case {'u','7'}
                fn_control_stagebutton(st_ctrlScore.UBut);
            case {'a','8'}
                fn_control_stagebutton(st_ctrlScore.ABut);
                nm_isAdvance	= false;
            case {'c'}
                fn_control_stagebutton(st_ctrlScore.CBut);
                nm_isAdvance	= false;
            otherwise
                return
        end
        
        if nm_isAdvance
            fn_display_advance(st_ctrCh.FBut);
        else            
            fn_display_process()
        end
        
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_control_stagebutton(hObject,~)
        if ~st_hyp.isScoring 
            return
        end
        
        set(st_hFigure.Main,'Pointer','watch')
                
        if st_cursors.pos_H1 < st_cursors.pos_H2
            nm_curMinPos = st_cursors.pos_H1;
            nm_curMaxPos = st_cursors.pos_H2;
        else
            nm_curMinPos = st_cursors.pos_H2;
            nm_curMaxPos = st_cursors.pos_H1;
        end
        
        nm_scoreWind	= st_disp.posEnd - st_disp.posBeg;
        nm_scoreId      = st_dat.time{1}(st_disp.posBeg);
        [~,nm_scoreId]	= min(abs(st_hyp.timeEpoch-nm_scoreId));
        
        nm_scoreBeg     = round(st_disp.posBeg + nm_curMinPos * nm_scoreWind);
        nm_scoreEnd     = round(st_disp.posBeg + nm_curMaxPos * nm_scoreWind);
        
        switch hObject
            case st_ctrlScore.WBut
                st_hyp.dat(st_hyp.id,nm_scoreId)	= 0;
                
            case st_ctrlScore.N1But
                st_hyp.dat(st_hyp.id,nm_scoreId)	= 1;
                
            case st_ctrlScore.N2But
                st_hyp.dat(st_hyp.id,nm_scoreId)	= 2;
                
            case st_ctrlScore.N3But
                st_hyp.dat(st_hyp.id,nm_scoreId)	= 3;
                
            case st_ctrlScore.RBut
                st_hyp.dat(st_hyp.id,nm_scoreId)	= 5;
                
            case st_ctrlScore.MBut
                st_hyp.dat(st_hyp.id,nm_scoreId)	= 10;
                
            case st_ctrlScore.UBut                
                st_hyp.dat(st_hyp.id,nm_scoreId)	= -1;
                
            case st_ctrlScore.ABut    
                vt_evId	= size(st_hyp.arousals{st_hyp.id},1);
                vt_evId	= vt_evId + 1;
                st_hyp.arousals{st_hyp.id}(vt_evId,1)	= st_dat.time{1}(nm_scoreBeg);
                st_hyp.arousals{st_hyp.id}(vt_evId,2)	= st_dat.time{1}(nm_scoreEnd);
                
            case st_ctrlScore.CBut  
                if ~isempty(st_hyp.arousals{st_hyp.id})
                    vt_evId	= st_hyp.arousals{st_hyp.id} >= st_dat.time{1}(nm_scoreBeg) & ...
                            st_hyp.arousals{st_hyp.id} <= st_dat.time{1}(nm_scoreEnd);
                    vt_evId = sum(vt_evId,2) > 1;    

                    st_hyp.arousals{st_hyp.id}(vt_evId,:)	= [];
                end
            otherwise
                set(st_hFigure.Main,'Pointer','arrow')
                return
        end
                   
        fn_display_drawhypnogram()
        
        set(st_hFigure.Main,'Pointer','arrow')
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_control_getstage()
        nm_scoreId      = st_dat.time{1}(st_disp.posBeg);
        [~,nm_scoreId]	= min(abs(st_hyp.timeEpoch-nm_scoreId));
        
        st_disp.hypStage	= st_hyp.dat(st_hyp.id,nm_scoreId);
                
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_control_resetcolor()
        
        set(st_ctrlScore.WBut,...
            'BackgroundColor',st_figSet.BackColor)
        
        set(st_ctrlScore.N1But,...
            'BackgroundColor',st_figSet.BackColor)
        
        set(st_ctrlScore.N2But,...
            'BackgroundColor',st_figSet.BackColor)
        
        set(st_ctrlScore.N3But,...
            'BackgroundColor',st_figSet.BackColor)
        
        set(st_ctrlScore.RBut,...
            'BackgroundColor',st_figSet.BackColor)
        
        set(st_ctrlScore.MBut,...
            'BackgroundColor',st_figSet.BackColor)
        
        set(st_ctrlScore.UBut,...
            'BackgroundColor',st_figSet.BackColor)
    end    
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_control_hypnopopup(hObject,~)
        
        if ~isfield(st_hyp,'dat')
            return
        end
        vt_hypnoList= get(hObject,'String'); 
        st_hyp.id	= get(hObject,'Value');
        
        if strcmpi(vt_hypnoList{st_hyp.id},'new')
            fn_control_hypnoaddnew()
        end
        
        fn_display_drawhypnogram()
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_control_hypnohide(hObject,~)
        
        st_disp.backHypno	= ~logical(get(hObject,'Value'));
        fn_display_drawhypnogram()
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_control_hypnovote(~,~)
       
        if ~isfield(st_hyp,'dat')
            return
        end
        
        if size(st_hyp.dat,1) == 1
            return
        end
        
        
        ch_answer	= questdlg(...
                    {'You are going to vote for agreement between hypnograms';...
                    'This option will delete the current hypnogram.';...
                    'Would you like to continue?'},...
                    'Vote for hypnogram', ...
                    'Yes','No','No');
                
        switch ch_answer
            case 'Yes'
                % do nothing
            case 'No'
                return
        end
        
        [vt_score,vt_f]	= mode(st_hyp.dat);
        
        vt_id           = vt_f == 1;
        vt_score(vt_id) = -1;
        
        st_hyp.dat(st_hyp.id,:)	= vt_score;
        
        fn_display_drawhypnogram()
        
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_control_hypnoremove(~,~)
        
        ch_answer	= questdlg(...
                    'Would you like to delete the current hypnogram?', ...
                    'Delete hypnogram', ...
                    'Yes','No','No');
        
        switch ch_answer
            case 'Yes'
                % do nothing
            case 'No'
                return
        end
        
        try     % This is no adequate
            st_hyp.dat(st_hyp.id,:)	= [];
        catch
            % do nothing
        end
        
        try
            st_hyp.arousals(st_hyp.id,:)= [];
        catch
            % do nothing
        end
        
        if st_hyp.id > size(st_hyp.dat,1) && ~isempty(st_hyp.dat)
            st_hyp.id = size(st_hyp.dat,1);
        elseif  isempty(st_hyp.dat)
            st_hyp.id	= 1;
            st_hyp.dat(st_hyp.id,:)     = int8(-ones(size(st_hyp.timeEpoch))); 
            st_hyp.arousals(st_hyp.id,:)= {[]};
        end
                        
        vt_stringCnt	=  num2cell(num2str((1:size(st_hyp.dat,1))'));
        vt_stringCnt    =  vertcat(vt_stringCnt,{'new'});
        
        set(st_ctrHyp.SelHyp,'String',vt_stringCnt)
        set(st_ctrHyp.SelHyp,'Value',st_hyp.id)
        
        fn_display_drawhypnogram()
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_control_hypnoaddnew()
        
        ch_answer	= questdlg(...
                    'Would you like to add a new hypnogram?', ...
                    'Add hypnogram', ...
                    'Yes','No','No');
        
        switch ch_answer
            case 'Yes'
                % do nothing
            case 'No'                
                if st_hyp.id > size(st_hyp.dat,1)
                    st_hyp.id = size(st_hyp.dat,1);
                    set(st_ctrHyp.SelHyp,'Value',st_hyp.id)
                end                
                return
        end
        
        st_hyp.dat(st_hyp.id,:)     = int8(-ones(size(st_hyp.timeEpoch)));
        st_hyp.arousals{st_hyp.id,:}= []; 
        
        vt_stringCnt	=  num2cell(num2str((1:size(st_hyp.dat,1))'));
        vt_stringCnt    =  vertcat(vt_stringCnt,{'new'});
        
        set(st_ctrHyp.SelHyp,'String',vt_stringCnt)
        set(st_ctrHyp.SelHyp,'Value',st_hyp.id)
        
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_controls_reset()
       
        st_dat      = struct;
        st_hyp      = struct;
        st_disp     = struct;
        st_hLines   = struct;
        st_spectrum = struct;
        st_chann    = struct;
        st_longTerm = struct; 
        

        st_hLines.chLines	= -1; 
        st_hLines.LTLines	= -1;
        st_hLines.chText	= -1;
        st_hLines.Events	= -1;
        st_hyp.isScoring    = 0;

        st_disp.offsetValue   = 200;
        st_disp.hypResolution = 2000;

        cla(st_ctrHyp.AxesPatch)
        cla(st_ctrHyp.AxesHyp)
        cla(st_ctrCh.AxesGrid)
        cla(st_ctrCh.AxesCurV)
        cla(st_ctrCh.axesCh)
        cla(st_ctrlTF.AxesTF)
        cla(st_ctrlExtra.AxesPatch)
        cla(st_ctrlExtra.AxesDelta)
        cla(st_ctrlExtra.AxesTheta)
        cla(st_ctrlExtra.AxesAlpha)
        cla(st_ctrlExtra.AxesSigma)
        cla(st_ctrlExtra.AxesBeta)
        cla(st_ctrlExtra.AxesEMGsd)
        cla(st_ctrlExtra.AxesDensSO)
        cla(st_ctrlExtra.AxesDensSP)
        cla(st_ctrlExtra.AxesEM)
        cla(st_ctrlExtra.AxesThetaD)
        cla(st_ctrlExtra.AxesAlphaD)
        cla(st_ctrlExtra.AxesArousal)
        cla(st_ctrlExtra.AxesBPM)
        
        set(st_ctrlTF.chanPop,'String',' ')
        set(st_ctrlTF.chanPop,'Value', 1)
        set(st_ctrlExtra.chanPop,'String',' ');
        set(st_ctrlExtra.chanPop,'Value', 1)
        set(st_ctrl.NuChPop,'String', ' ')
        set(st_ctrl.NuChPop,'Value', 1)
        set(st_ctrlScore.OkScBut,'Value', 0)
        
    end
        
%% [Functions] - Compute
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_compute_chselection()
        
        st_chann.ECG = find(ismember(st_dat.chtype,'ecg'));
        st_chann.EMG = find(ismember(st_dat.chtype,'emg'));
        st_chann.EOG = find(ismember(st_dat.chtype,'eog'));
        st_chann.EEG = find(ismember(st_dat.chtype,'eeg'));
                
        st_chann.EEGlabels    = st_dat.label(st_chann.EEG);
                
    end
%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    function fn_compute_longterm()
        if isempty(fieldnames(st_longTerm))
            return
        end
        
        st_longTerm.time	= linspace(...
                            st_dat.time{1}(1),st_dat.time{1}(end),...
                            numel(st_longTerm.delta{1}));
           
           
        if ~isfield(st_longTerm,'delta')
            st_longTerm.delta	= zeros(1,numel(st_longTerm.time),'single');
        end
        
           
        if ~isfield(st_longTerm,'theta')
            st_longTerm.theta	= zeros(1,numel(st_longTerm.time),'single');
        end
        
           
        if ~isfield(st_longTerm,'alpha')
            st_longTerm.alpha	= zeros(1,numel(st_longTerm.time),'single');
        end
        
           
        if ~isfield(st_longTerm,'mu')
            st_longTerm.mu      = zeros(1,numel(st_longTerm.time),'single');
        end
                   
        if ~isfield(st_longTerm,'beta')
            st_longTerm.beta	= zeros(1,numel(st_longTerm.time),'single');
        end
                
        if ~isfield(st_longTerm,'EM')
            st_longTerm.EM     = zeros(1,numel(st_longTerm.time),'single');
        end
        
        if ~isfield(st_longTerm,'bpm')
            st_longTerm.bpm     = zeros(1,numel(st_longTerm.time),'single');
        end
        
        if ~isfield(st_longTerm,'rmsEMG')
            st_longTerm.rmsEMG	= zeros(1,numel(st_longTerm.time),'single');
        end                   
        
        if isfield(st_longTerm,'SOevent')
            st_longTerm.soRate	= cellfun(...
                                @(x) histcounts(x,st_longTerm.time),...
                                st_longTerm.SOevent,'UniformOutput',false);
        else
            st_longTerm.soRate	= zeros(1,numel(st_longTerm.time),'single');
        end   
        
        if isfield(st_longTerm,'SPevent')
            st_longTerm.spRate	=  cellfun(...
                                @(x) histcounts(x,st_longTerm.time),...
                                st_longTerm.SPevent,'UniformOutput',false);
        else
            st_longTerm.spRate	= zeros(1,numel(st_longTerm.time),'single');
        end               
        
        if isfield(st_longTerm,'arousal')
            st_longTerm.arousalRate	= cellfun(...
                                    @(x) mean(x/st_dat.fsample,2),...
                                    st_longTerm.arousal,'UniformOutput',false);
            st_longTerm.arousalRate	= cellfun(...
                                    @(x) histcounts(x,st_longTerm.time),...
                                    st_longTerm.arousalRate,'UniformOutput',false);
        else
            st_longTerm.arousalRate	= {zeros(1,numel(st_longTerm.time),'single')};
            st_longTerm.arousalRate	= repmat(st_longTerm.arousalRate,...
                                    size(st_longTerm.delta,1),...
                                    size(st_longTerm.delta,2));
        end             
        
        if isfield(st_longTerm,'alphaTr')
            st_longTerm.alphaRate	= cellfun(...
                                    @(x) mean(x/st_dat.fsample,2),...
                                    st_longTerm.alphaTr,'UniformOutput',false);
            st_longTerm.alphaRate	= cellfun(...
                                    @(x) histcounts(x,st_longTerm.time),...
                                    st_longTerm.alphaRate,'UniformOutput',false);
        else
            st_longTerm.alphaRate	= {zeros(1,numel(st_longTerm.time),'single')};
            st_longTerm.alphaRate	= repmat(st_longTerm.alphaRate,...
                                    size(st_longTerm.delta,1),...
                                    size(st_longTerm.delta,2));
        end             
        
        if isfield(st_longTerm,'thetaTr')
            st_longTerm.thetaRate	= cellfun(...
                                    @(x) mean(x/st_dat.fsample,2),...
                                    st_longTerm.thetaTr,'UniformOutput',false);
            st_longTerm.thetaRate	= cellfun(...
                                    @(x) histcounts(x,st_longTerm.time),...
                                    st_longTerm.thetaRate,'UniformOutput',false);
        else
            st_longTerm.thetaRate	= {zeros(1,numel(st_longTerm.time),'single')};
            st_longTerm.thetaRate	= repmat(st_longTerm.thetaRate,...
                                    size(st_longTerm.delta,1),...
                                    size(st_longTerm.delta,2));
        end
    end   

end
