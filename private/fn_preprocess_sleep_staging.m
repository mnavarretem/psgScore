% fn_preprocessSleepStaging

function st_dat	= fn_preprocess_sleep_staging(ch_filename,ch_savename,st_ch)

%% Database

vt_chName   = {ch_filename};

%% Settings
% Values based on Iber2007
vt_chEEG	= st_ch.EEG;
vt_chEOG	= st_ch.EOG;
vt_chEMG	= st_ch.EMG;

vt_tfLims       = [0.3,25];
vt_freqPassEEG  = [0.3,35];
vt_freqPassEMG  = [10,100];
vt_freqPassEOG  = [0.3,5];

vt_freqStopEEG  = [0.1,40];
vt_freqStopEMG  = [5,110];
vt_freqStopEOG  = [0.1,6];

vt_freqPassSO   = [0.3,2];
vt_freqStopSO	= [0.1,4];
nm_troughThres  = -35;
vt_freqPassSp	= [11,16]; 
vt_freqStopSp	= [9,18]; 
vt_timeSpindles	= [0.5,2];
vt_timeFreqEvn	= [2,60];
nm_minNumOsc	= 5; 
nm_scoreWind	= 30;

nm_numFreq      = 32;
vt_freqTF       = linspace(vt_tfLims(1),vt_tfLims(2),nm_numFreq);

nm_stepSpectrum	= 0.05;
vt_deltaFreq    = [0.5,3];
vt_thetaFreq    = [4,8];
vt_alphaFreq    = [8,13];
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

    if isfield(st_ch,'REF')
        vt_chREF        = st_ch.REF;
        st_cfg.channel	= horzcat(vt_chEEG,vt_chEOG,vt_chEMG,vt_chREF);
    else        
        st_cfg.channel	= horzcat(vt_chEEG,vt_chEOG,vt_chEMG);
    end
        
    st_dat	= ft_preprocessing(st_cfg);
    
    [~,vt_idDat]	= ismember(st_dat.label,st_cfg.channel);
    [~,vt_idDat]    = sort(vt_idDat);
    
    st_dat.trial{1} = st_dat.trial{1}(vt_idDat,:);
    st_dat.label	= st_dat.label(vt_idDat);
    
    %% Re-reference (if needed)
    
    if isfield(st_ch,'REF')
        vt_refId    = ismember(st_cfg.channel,vt_chREF);
        vt_refAvg	= st_dat.trial{1}(vt_refId,:);
        vt_refAvg   = mean(vt_refAvg);
        mx_data     = st_dat.trial{1} - repmat(vt_refAvg,numel(vt_refId),1);
        mx_data     = mx_data(~vt_refId,:);
        
        st_dat.trial{1}	= mx_data;        
        st_dat.label 	= st_dat.label(~vt_refId);
        st_cfg.channel  = st_cfg.channel(~vt_refId);
    end
    
    %% Remove unused fields
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
    ob_filterEOG	= fn_designIIRfilter(st_dat.fsample,vt_freqPassEOG,vt_freqStopEOG);
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
    vt_emgId = find(vt_id);
    
%     if sum(vt_id) == 2
%         vt_emgId = find(vt_id);
%         
%         st_dat.trial{1}(vt_emgId(1),:)	= diff(st_dat.trial{1}(vt_emgId,:));
%         st_dat.trial{1}(vt_emgId(2),:)	= [];
%         st_dat.label(vt_emgId(2))    	= [];
%         st_dat.chtype(vt_emgId(2))      = [];
%         
%         vt_emgId    = vt_emgId(1);
%     end
    
    toc

    vt_id   = ismember(st_dat.label,vt_chEOG);
    
    fprintf('Filtering EOG for movements: ')
    tic
    mx_chREM	= fn_filterOffline(st_dat.trial{1}(vt_id,:)',ob_filterEOG)'; 
    toc
    
    %% REM detection
    fprintf('Detecting eye movements: ')
    tic
    st_Cnf              = struct;
    st_Cnf.fsampling    = st_dat.fsample;
    
    [vt_remLoc,vt_semLoc]	= fn_detectsleepREM(mx_chREM,st_Cnf);
    toc
    
    fprintf('Obtain EOG density: ')
    tic
    
    st_patterns.EM      = zeros(2,numel(vt_timeStage),'single');
    st_patterns.EyeEvents.SEM	= vt_semLoc/st_dat.fsample;
    st_patterns.EyeEvents.REM	= vt_remLoc/st_dat.fsample;
    
    for tt = 2:numel(vt_timeStage)
        
        vt_id   = find(vt_timeStage(tt-1) <= st_dat.time{1} & ...
                st_dat.time{1} <= vt_timeStage(tt));                            
                 
        st_patterns.EM(1,tt)	= sum(vt_id(1) < vt_remLoc &...
                                vt_remLoc < vt_id(end));
        st_patterns.EM(2,tt)	= sum(vt_id(1) < vt_semLoc &...
                                vt_semLoc < vt_id(end));
                            
    end
    toc
    
    %% EMG timeline
    
    fprintf('Obtain EMG std time-line: ')
    tic
    st_patterns.rmsEMG	= single(zeros(...
                        numel(vt_emgId),numel(vt_timeStage)));
    
    for tt = 2:numel(vt_timeStage)
        
        vt_id   = vt_timeStage(tt-1) <= st_dat.time{1} & ...
                st_dat.time{1} <= vt_timeStage(tt);
        
        for kk = 1:numel(vt_emgId)

            vt_sgm	= abs(st_dat.trial{1}(vt_emgId(kk),vt_id));
            vt_hi   = findextrema(vt_sgm);
            vt_sgm	= vt_sgm(vt_hi);
            st_patterns.rmsEMG(kk,tt)	= single(median(vt_sgm));   
        end
                            
    end
    toc
            
    %% Pattern selection
    st_spectrum.freq	= vt_freqTF;  
    st_spectrum.labels  = vt_chEEG;
    st_spectrum.data	= cell(numel(st_spectrum.labels),1);  

    st_patterns.SOevent	= cell(numel(st_spectrum.labels),1); 
    st_patterns.SPevent	= cell(numel(st_spectrum.labels),1); 
    st_patterns.arousal	= cell(numel(st_spectrum.labels),1);  
    st_patterns.alphaTr	= cell(numel(st_spectrum.labels),1);  
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
        
        [mx_TF,vt_T]	= fn_gaborwavelet(...
                        vt_signalCh,...
                        st_dat.fsample,....
                        vt_freqTF,...
                        [],[],[],[],[],...
                        nm_stepSpectrum);
        toc

        mx_TF   = single(mx_TF);
        vt_T    = single(vt_T);

        st_spectrum.data{ch}	= mx_TF; 
        st_spectrum.time        = vt_T;
        
        %% Obtain Ch alpha and theta trains
        
        
        fprintf('   ** Detect theta trains: ')
        tic
        st_Cnf              = struct;
        st_Cnf.fsampling	= st_dat.fsample;
        st_Cnf.minnumosc	= nm_minNumOsc;
        st_Cnf.timebounds	= vt_timeFreqEvn;
        st_Cnf.rawEEG       = vt_signalCh;
        st_Cnf.freqband     = vt_thetaFreq;
        st_Cnf.method       = 'fixed';
        st_Cnf.toFilter     = true;

        st_patterns.thetaTr{ch}	= fn_detectfreqtrain(vt_signalCh,st_Cnf);    
        toc         
        
        fprintf('   ** Detect alpha trains: ')
        tic
        st_Cnf              = struct;
        st_Cnf.fsampling	= st_dat.fsample;
        st_Cnf.minnumosc	= nm_minNumOsc;
        st_Cnf.timebounds	= vt_timeFreqEvn;
        st_Cnf.rawEEG       = vt_signalCh;
        st_Cnf.freqband     = vt_alphaFreq;
        st_Cnf.method       = 'fixed';
        st_Cnf.toFilter     = true;

        st_patterns.alphaTr{ch}	= fn_detectfreqtrain(vt_signalCh,st_Cnf);    
        toc         
        
        %% Obtain Ch arousals
        
        fprintf('   ** Detect arousal events: ')
        tic
        st_Cnf   	= struct;
        st_Cnf.time	= vt_T;
        st_Cnf.freq	= vt_freqTF;
        st_Cnf.tEEG	= st_dat.time{1};

        st_patterns.arousal{ch}	= fn_detectsleeparousal(mx_TF,st_Cnf);    
        toc               
         
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
    %% Convert to uint16 and reduce data size
    % Reduce eeg data size
    mx_sig	= st_dat.trial{1};
    
    mx_scale	= [min(mx_sig(:)),max(mx_sig(:));0,nm_resolution];
    vt_linCoef  = fn_linecoef(mx_scale(1,:),mx_scale(2,:));
    mx_sig      = mx_sig.*vt_linCoef(1) + vt_linCoef(2);
    mx_sig      = uint16(mx_sig);
    
    st_dat.trial{1}     = mx_sig;
    st_dat.hdr.scale	= fn_linecoef(mx_scale(2,:),mx_scale(1,:));
    st_dat.hdr.chantype	= st_dat.chtype;
    st_dat.hdr.label	= st_dat.label;
    st_dat.hdr.nChans   = numel(st_dat.label);
    st_dat.hdr.nSamples	= size(mx_sig,2);
    
    st_dat  = rmfield(st_dat,'chtype');
    
    % Reduce patterns size
    
    % Get patterns
    st_patt     = st_patterns;
    vt_fields	= fieldnames(st_patt);
    
    for nn = 1:numel(vt_fields)
        ch_fName	= vt_fields{nn};
        vt_data     = st_patt.(ch_fName);
        
        switch ch_fName
            case 'EM'
                nm_scale    = NaN;
                vt_data     = uint8(vt_data);
            case 'EyeEvents'
                nm_max      = max([max(vt_data.REM(:)),...
                    max(vt_data.SEM(:))]);
                nm_scale	= nm_resolution/nm_max;
                vt_data.REM	= vt_data.REM * nm_scale;
                vt_data.SEM	= vt_data.SEM * nm_scale;
                
                vt_data.REM = uint16(vt_data.REM);
                vt_data.SEM = uint16(vt_data.SEM);
            otherwise
                if iscell(vt_data)
                    nm_max      = cellfun(@(x) max(x(:)),vt_data,...
                                'UniformOutput',false);
                    nm_max      = max(cell2mat(nm_max(:)));
                    nm_scale	= nm_resolution/nm_max;
                    
                    vt_data	= cellfun(@(x) x * nm_scale,...
                            vt_data,'UniformOutput',false);
                    vt_data	= cellfun(@uint16,vt_data,...
                            'UniformOutput',false);
                else
                    nm_max      = max(vt_data(:));
                    nm_scale	= nm_resolution/nm_max;
                    vt_data     = vt_data * nm_scale;
                    vt_data     = uint16(vt_data);
                end
                
        end
        
        st_patt.(ch_fName)	=  vt_data;
        st_scale.(ch_fName)	=  1/nm_scale;
    end
    
    st_patt.scale	= st_scale;
    
    % Get spectrum
    st_spect	= st_spectrum;
    vt_scale    = nan(size(st_spect.data));
    
    for nn = 1:numel(vt_scale)
        vt_data     = st_spect.data{nn};
        nm_max      = max(vt_data(:));
        nm_scale	= nm_resolution/nm_max;
        vt_data     = vt_data * nm_scale;
        vt_data     = uint16(vt_data);
        
        vt_scale(nn)        = 1/nm_scale;
        st_spect.data{nn}   = vt_data;
    end
    
    st_spect.scale	= vt_scale;
    
    % Set saving structure
    st_extras.patterns	= st_patt;
    st_extras.spectrum	= st_spect;
    
    %% Save signal data

    [ch_rootPath,ch_dataName] = fileparts(ch_savename);

    ch_dataName     = sprintf('%s.mat',ch_dataName);
    ch_extrasName	= sprintf('psgExtra-%s',ch_dataName);

    fprintf('Saving preprocessed data for %s: ',ch_savename)
    tic
    save(fullfile(ch_rootPath,ch_dataName),'-struct','st_dat')
    toc

    fprintf('Saving preprocessed data for %s: ',ch_extrasName)
    tic
    save(fullfile(ch_rootPath,ch_extrasName),'-struct','st_extras')
    toc

end

