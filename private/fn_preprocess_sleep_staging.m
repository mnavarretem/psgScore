% fn_preprocessSleepStaging

function st_dat	= fn_preprocess_sleep_staging(ch_filename)
%% Database

% ch_rootPath	= '\\PSYCH-121412\Database\REM_stimulation\REM_pilot\rawFiles\Room1';
% vt_chName   = {'mgnmPilot_Room1_0001.eeg'};
% ch_filename = fullfile(ch_rootPath,vt_chName{1});
vt_chName   = {ch_filename};

%% Settings
% Values based on Iber2007
vt_chEEG	= {'F3','F4','C3','C4','P3','P4','O1','O2'};
vt_chEOG	= {'REOG','LEOG'};
vt_chEMG	= {'EMG1','EMG2'};

vt_tfLims       = [0.3,25];
vt_freqPassEEG  = [0.3,35];
vt_freqPassEMG  = [10,100];

vt_freqStopEEG  = [0.1,40];
vt_freqStopEMG  = [5,110];

vt_freqPassSO   = [0.3,2];
vt_freqStopSO	= [0.1,4];
nm_troughThres  = -40;
vt_freqPassSp	= [11,16]; 
vt_freqStopSp	= [9,18]; 
vt_timeSpindles	= [0.5,2];
nm_minNumOsc	= 5; 
nm_scoreWind	= 30;

nm_numFreq      = 32;
vt_freqTF       = linspace(vt_tfLims(1),vt_tfLims(2),nm_numFreq);

nm_stepSpectrum	= 0.05;
vt_deltaFreq    = [0.3,3];
vt_thetaFreq    = [4,8];
vt_alphaFreq    = [8,12];
vt_muFreq       = [12,16];
vt_betaFreq     = [16,30];


vt_deltaId	= vt_deltaFreq(1) <= vt_freqTF & vt_freqTF <= vt_deltaFreq(2);
vt_thetaId	= vt_thetaFreq(1) <= vt_freqTF & vt_freqTF <= vt_thetaFreq(2);
vt_alphaId	= vt_alphaFreq(1) <= vt_freqTF & vt_freqTF <= vt_alphaFreq(2);
vt_muId    	= vt_muFreq(1) <= vt_freqTF & vt_freqTF <= vt_muFreq(2);
vt_betaId  	= vt_betaFreq(1) <= vt_freqTF & vt_freqTF <= vt_betaFreq(2);

%% Process

for ff = 1:numel(vt_chName)
        
    %% Load data

    fprintf('Loading file %s: \n',ch_filename)
    st_cfg          = struct;
    st_cfg.dataset	= ch_filename;
    st_cfg.channel	= horzcat(vt_chEEG,vt_chEOG,vt_chEMG);

    st_dat	= ft_preprocessing(st_cfg);

    st_dat.time{1}  = single(st_dat.time{1});
    st_dat.trial{1} = single(st_dat.trial{1}); 
    st_dat.chtype	= cell(size(st_cfg.channel));

    st_dat	= rmfield(st_dat,'cfg');
    st_dat	= rmfield(st_dat,'sampleinfo'); 

    vt_timeStage = st_dat.time{1}(1):nm_scoreWind:st_dat.time{1}(end);
    
    %% Create filters
    fprintf('Design filters: ')
    tic
    ob_filterEEG    = fn_designIIRfilter(st_dat.fsample,vt_freqPassEEG,vt_freqStopEEG);
    ob_filterEMG	= fn_designIIRfilter(st_dat.fsample,vt_freqPassEMG,vt_freqStopEMG);
    ob_filterSO     = fn_designIIRfilter(st_dat.fsample,vt_freqPassSO,vt_freqStopSO);
    ob_filterSP     = fn_designIIRfilter(st_dat.fsample,vt_freqPassSp,vt_freqStopSp);
    toc

    %% Filter Channels


    vt_id                   = ismember(st_dat.label,vt_chEEG) ;
    st_dat.chtype(vt_id) 	= {'eeg'};

    vt_id                   = ismember(st_dat.label,vt_chEOG) ;
    st_dat.chtype(vt_id) 	= {'eog'};

    vt_id                   = ismember(st_dat.label,vt_chEMG) ;
    st_dat.chtype(vt_id) 	= {'emg'};

    % Filter EEG and EOG
    vt_id   = ismember(st_dat.label,vt_chEEG) | ismember(st_dat.label,vt_chEOG);

    fprintf('Filtering EEG and EOG: ')
    tic
    st_dat.trial{1}(vt_id,:)	= fn_filterOffline(st_dat.trial{1}(vt_id,:)',...
                                ob_filterEEG)'; 
    toc

    % Filter EMG
    vt_id   = ismember(st_dat.label,vt_chEMG);
    fprintf('Filtering EMG: ')
    tic
    st_dat.trial{1}(vt_id,:)	= fn_filterOffline(st_dat.trial{1}(vt_id,:)',....
                                ob_filterEMG)'; 
                            
    if sum(vt_id) == 2
        vt_emgId = find(vt_id);
        
        st_dat.trial{1}(vt_emgId(1),:)	= diff(st_dat.trial{1}(vt_emgId,:));
        st_dat.trial{1}(vt_emgId(2),:)	= [];
        st_dat.label(vt_emgId(2))    	= [];
        st_dat.chtype(vt_emgId(2))      = [];
        
        vt_emgId    = vt_emgId(1);
    end
    toc

    %% Pattern selection
    st_spectrum.freq	= vt_freqTF;  
    st_spectrum.labels  = vt_chEEG;
    st_spectrum.data	= cell(numel(st_spectrum.labels),1);  

    st_patterns.SOevent	= cell(numel(st_spectrum.labels),1); 
    st_patterns.SPevent	= cell(numel(st_spectrum.labels),1);  
    st_patterns.delta	= cell(numel(st_spectrum.labels),1);  
    st_patterns.theta	= cell(numel(st_spectrum.labels),1);  
    st_patterns.alpha	= cell(numel(st_spectrum.labels),1);  
    st_patterns.mu      = cell(numel(st_spectrum.labels),1);   
    st_patterns.beta	= cell(numel(st_spectrum.labels),1);   

    for ch = 1:numel(st_spectrum.labels)        
        %% Obtain time-frequency transform
        nm_curCh    = ismember(st_dat.label,st_spectrum.labels{ch});
        vt_signalCh	= st_dat.trial{1}(nm_curCh,:)';

        fprintf('Computing TF for %s: ',st_spectrum.labels{ch})
        tic
        [mx_TF,vt_T]	= fn_gaborwavelet(vt_signalCh,st_dat.fsample,vt_freqTF,...
                        [],[],[],[],[],nm_stepSpectrum);
        toc

        mx_TF   = flipud(single(mx_TF));
        vt_T    = single(vt_T);

        st_spectrum.data{ch}	= mx_TF; 
        st_spectrum.time        = vt_T;
        
        %% Obtain frequency band time-line
                
        fprintf('Obtain frequency band time-line for %s: ',st_spectrum.labels{ch})
        tic
        st_patterns.delta{ch}	= zeros(size(vt_timeStage),'single');  
        st_patterns.theta{ch}   = zeros(size(vt_timeStage),'single'); 
        st_patterns.alpha{ch}   = zeros(size(vt_timeStage),'single'); 
        st_patterns.mu{ch}      = zeros(size(vt_timeStage),'single'); 
        st_patterns.beta{ch}	= zeros(size(vt_timeStage),'single'); 

        for tt = 2:numel(vt_timeStage)
            
            vt_id   = vt_timeStage(tt-1) <= vt_T & vt_T <= vt_timeStage(tt);
            
            st_patterns.delta{ch}(tt)	= median(mean(mx_TF(vt_deltaId,vt_id)));  
            st_patterns.theta{ch}(tt)   = median(mean(mx_TF(vt_thetaId,vt_id)));
            st_patterns.alpha{ch}(tt)   = median(mean(mx_TF(vt_alphaId,vt_id))); 
            st_patterns.mu{ch}(tt)      = median(mean(mx_TF(vt_muId,vt_id)));
            st_patterns.beta{ch}(tt)	= median(mean(mx_TF(vt_betaId,vt_id)));
                                    
        end
        toc
%         clear mx_TF

        %% Filter in SO frequency band
        fprintf('Filtering in SO band for %s: ',st_spectrum.labels{ch})
        tic
        vt_signalSO	= fn_filterOffline(vt_signalCh,ob_filterSO);
        toc

        %% Detect SO events
        fprintf('   ** Detect SO events: ')
        tic
        st_Cnf              = struct;
        st_Cnf.freqband     = [];
        st_Cnf.fsampling	= st_dat.fsample;
        st_Cnf.threshold	= nm_troughThres;
        st_Cnf.minthresh	= [];
        st_Cnf.toFilter     = [];

        vt_SOwaves              = fn_detectsleepSO(vt_signalSO,st_Cnf);    
        st_patterns.SOevent{ch}	= st_dat.time{1}(vt_SOwaves);
        toc

        clear st_Cnf vt_SOwaves vt_signalSO

        %% Filter in the fast spindle band
        fprintf('Filtering in spindle band for %s: ',st_spectrum.labels{ch})
        tic
        vt_rmsFS	= single(fn_filterOffline(vt_signalCh,ob_filterSP));
        vt_rmsFS    = single(fn_rmstimeseries(vt_rmsFS,vt_timeSpindles(1)));
        toc

        %% Detect spindle events

        fprintf('	** Processing spindles: ')
        tic
        st_Cnf              = struct;
        st_Cnf.fsampling	= st_dat.fsample;
        st_Cnf.minnumosc	= nm_minNumOsc;
        st_Cnf.timebounds	= vt_timeSpindles;
        st_Cnf.rawEEG       = vt_signalCh;
        st_Cnf.freqband     = vt_freqPassSp;
        st_Cnf.method       = 'fixed';

        vt_spindle              = fn_detectsleepSpindles(vt_rmsFS,st_Cnf);
        vt_spindle              = round(mean(vt_spindle,2));
        st_patterns.SPevent{ch}	= st_dat.time{1}(vt_spindle);
        toc

        clear st_Cnf vt_rmsFS vt_spindle

    end

    %% EMG timeline
    
    fprintf('Obtain EMG std time-line: ')
    tic
    st_patterns.stdEMG	= zeros(size(vt_timeStage),'single');
    
    for tt = 2:numel(vt_timeStage)
        
        vt_id   = vt_timeStage(tt-1) <= st_dat.time{1} & ...
                st_dat.time{1} <= vt_timeStage(tt);
                
        st_patterns.stdEMG(tt)	= median(...
                                abs(st_dat.trial{1}(vt_emgId,vt_id)));
        
    end
    toc
     
    %% Save signal data

    [ch_rootPath,ch_dataName] = fileparts(ch_filename);

    ch_dataName     = sprintf('%s.mat',ch_dataName);
    ch_spectrumName	= sprintf('psgExtra-%s',ch_dataName);

    fprintf('Saving preprocessed data for %s: ',ch_filename)
    tic
    save(fullfile(ch_rootPath,ch_dataName),'st_dat')
    toc

    fprintf('Saving preprocessed data for %s: ',ch_filename)
    tic
    save(fullfile(ch_rootPath,ch_spectrumName),'st_patterns','st_spectrum')
    toc

end

