% pr_preprocessSleepStaging

%  psgScore is a graphical user interface (GUI) developed in MATLAB for
% scoring of human sleep.
% 
% psgScore is an extensive, flexible and open source sleep diagnostic 
% solution that simplifies the setup, review, analysis and reporting of 
% experimental sleep studies.
% 
% psgScore is Fieldtrip compatible and requires Fieldtrip toolbox for 
% reading files
% 
% psgScore implements different documented algorithms for sleep features 
% detection, it provides several tools for signal visualization and 
% manipulation, among which are found:
% 
% Channel(s) selection.
% Display of multiple signal at the same time.
% Several zoom and grid options (time, amplitude, etc.)
% Possibility to make time and amplitude measurements directly on the signals.
% Slow wave, spindle, eye movements, arousal detection.
% 
% 
%   Written by:
%   Miguel G. Navarrete Mejia, PhD
%   UNIVERSIDAD DE LOS ANDES
%   Colombia, 2021
%   mnavarretem@gmail.com
%   $Version: 0.5$ || $Date: 2021/11/13 10:30$
%   This file is part of the psgScore project.
%
%%     Copyright (C) 2020, Miguel Navarrete
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.

%% Settings

ch_rootPath	= 'C:\Users\sapmn3\Database\remStimulation\study-rawFiles';
ch_savePath	= 'C:\Users\sapmn3\Database\remStimulation\study-hypnoFiles';

nm_skipDone = true;

%% Read folder

vt_eegFiles = dir(ch_rootPath);
vt_eegFiles = extractfield(vt_eegFiles,'name');    
vt_eegFiles = vt_eegFiles(:);
vt_eegFiles = vt_eegFiles(3:end);

vt_id       = cellfun(@(x) strfind(x,'.eeg'),vt_eegFiles,...
            'UniformOutput',false);
vt_id       = ~cellfun(@isempty,vt_id);
vt_eegFiles = vt_eegFiles(vt_id);

%% Skip computed 
if nm_skipDone
    vt_matFiles = dir(ch_savePath);
    vt_matFiles = extractfield(vt_matFiles,'name');    
    vt_matFiles = vt_matFiles(:);
    vt_matFiles = vt_matFiles(3:end);

    vt_id       = cellfun(@(x) strfind(x,'.mat'),vt_matFiles,...
                'UniformOutput',false);
    vt_id       = ~cellfun(@isempty,vt_id);
    vt_matFiles = vt_matFiles(vt_id);
    
    [~,vt_rawFiles] = cellfun(@fileparts,vt_eegFiles,'UniformOutput',false);
    [~,vt_matFiles] = cellfun(@fileparts,vt_matFiles,'UniformOutput',false);
    
    vt_isDone   = ismember(vt_rawFiles,vt_matFiles);
    vt_eegFiles	= vt_eegFiles(~vt_isDone);
end

%% Read File

% vt_eegFiles   = {'overnight_pilot01.eeg'};            
% vt_saveFiles	= {'overnight_pilot01.mat'};

%% Process

st_ch.EEG	= {'F3','F4','C3','C4','O1','O2'};
st_ch.EOG	= {'REOG','LEOG'};
st_ch.EMG	= {'REMG','LEMG'};
st_ch.REF	= {'A1','A2'};

% st_ch.EEG	= {'F3','F4','C3','C4','O1','O2'};
% st_ch.EOG	= {'R_EOG','L_EOG'};
% st_ch.EMG	= {'R_EMG','L_EMG'};
% st_ch.REF	= {'A1','A2'};

for rr = 1:numel(vt_eegFiles) % loop for recordings    
    %% Select file and stim condition
    
    ch_filename     = vt_eegFiles{rr};
    [~,ch_fileCode] = fileparts(ch_filename); 
    ch_saveFile     = sprintf('%s.mat',ch_fileCode);
    
    ch_filename = fullfile(ch_rootPath,ch_filename);
    ch_savename = fullfile(ch_savePath,ch_saveFile);
    
%     ch_filename = fullfile(ch_rootPath,vt_eegFiles{rr});
%     ch_savename = fullfile(ch_savePath,vt_saveFiles{rr});
    
    fprintf('\n::::: Starting new file ::::\n')
    fprintf('Selected file: %s [%i/%i] \n',ch_filename,rr,numel(vt_eegFiles))
    fn_preprocess_sleep_staging(ch_filename,ch_savename,st_ch);
        
end
