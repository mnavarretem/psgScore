% pr_preprocessSleepStaging

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
