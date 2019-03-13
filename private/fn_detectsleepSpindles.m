function [mx_eventLims,vt_centFreq,vt_eeg] = ...
                                           fn_detectsleepSpindles(vt_eeg,st_Cnf)
% [mx_eventLims,vt_centFreq,vt_eeg] = fn_detectsleepSO(vt_eeg,st_Cnf) 
% detect all sleep spindles from channel vt_eeg depending on the 
% settings in the structure st_Cnf. 
%
% mx_eventLims corresponds to a matrix indicating the locations (in
% samples) of each detected SO. st_Cnf corresponds to a structure with the
% fields:
%
%   - st_Cnf.freqband:	1 x 2 vector indicating the frequency band limits
%                       for SO detection, (default = [9 16])
%
%   - st_Cnf.fsampling:	Sampling frequency in hertz
%   
%   - st_Cnf.window:	Window time in seconds to compute spindle energy
%                       (default: 0.3)
%   
%   - st_Cnf.minnumosc:	Minimum number of oscillations (default: 4)
%   
%   - st_Cnf.timebounds:    [min,max] time duration in seconds (default: [0.3,3])
% 
%   - st_Cnf.dynamics:	slow dynamics in seconds for spindle
%                           thresholding (default: 30)
%
%   - st_Cnf.hypnogram:	vector of the hypnogram in samples 
%                       (numel(st_Cnf.hypnogram) == numel(vt_eeg)), By
%                       default this field is empty
%
%   - st_Cnf.stage:     scalar indicating the sleep stage (as stated in
%                       the hypnogram) in which the spindles should be
%                       identified (default = [])
% 
%   - st_Cnf.toFilter:	Filter input in SO band (default = false)
% 
%   - st_Cnf.timeFreq:	Time-frequency correction (default = true)
%
%   - st_Cnf.rawEEG:	Raw EEG wheter the signal is filtered
%                       beforehand
%                           
%   - st_Cnf.method         Method for spindle detection ('adaptative',
%                           'fixed'). 
%

%% BSD license;
% Copyright (c) 2017, Miguel Navarrete;
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
%     * Redistributions of source code must retain the above copyright 
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright 
%       notice, this list of conditions and the following disclaimer in 
%       the documentation and/or other materials provided with the distribution
%       
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE.

%% Code starts here:

%%	- Check default inputs

if ~isvector(vt_eeg)
    error('fn_detectsleepSO:signalIsNotVector','Input must be a vector;'); 
end

if nargin < 2   % if not input arguments, then use arguments by default    
	st_Cnf  = struct;
end

% Check whether st_Cnf fileds are empty
if ~isfield(st_Cnf,'freqband') 
    st_Cnf.freqband     = [9 16];
end

if ~isfield(st_Cnf,'fsampling')
    st_Cnf.fsampling	= 1;
end

if ~isfield(st_Cnf,'window')
    st_Cnf.window       = 0.3;
end

if ~isfield(st_Cnf,'minnumosc')
    st_Cnf.minnumosc	= 4;
end

if ~isfield(st_Cnf,'timebounds')
    st_Cnf.timebounds	= [0.3,3];
end

if ~isfield(st_Cnf,'dynamics')
    st_Cnf.dynamics	= [1,30];
end

if ~isfield(st_Cnf,'hypnogram')
    st_Cnf.hypnogram	= [];
end

if ~isfield(st_Cnf,'stage')
    st_Cnf.stage	= [];
end

if ~isfield(st_Cnf,'timeFreq')
    st_Cnf.timeFreq	= true;
end

if ~isfield(st_Cnf,'rawEEG')
    st_Cnf.rawEEG	= [];
end

if ~isfield(st_Cnf,'toFilter')
    st_Cnf.toFilter	= false;
end

if ~isfield(st_Cnf,'method')
    st_Cnf.method	= 'adapted';
end

if ~isfield(st_Cnf,'rms')
    st_Cnf.rms	= [];
end

%%	- Filter input if required

vt_eeg      = vt_eeg(:);
vt_rawEEG	= st_Cnf.rawEEG;
nm_fSample  = st_Cnf.fsampling;	
vt_fSpindle = st_Cnf.freqband;

st_Cnf      = rmfield(st_Cnf,{'rawEEG','fsampling','freqband'});

if st_Cnf.toFilter
    
    vt_rawEEG	= vt_eeg;
    
    nm_fNyquist = nm_fSample / 2;    
    nm_fStopLo  = (vt_fSpindle(1) - 1) / nm_fNyquist;
    nm_fPassLo  = vt_fSpindle(1) / nm_fNyquist;
    nm_fPassHi  = vt_fSpindle(2) / nm_fNyquist;
    nm_fStopHi  = (vt_fSpindle(2) + 1) / nm_fNyquist;
    nm_dbPass   = 0.5;
    nm_dbStopLo	= 40;
    nm_dbStopHi	= 40;

    ob_filter	= fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2', ...
                nm_fStopLo,nm_fPassLo,nm_fPassHi,nm_fStopHi,...
                nm_dbStopLo,nm_dbPass,nm_dbStopHi);

    ob_filter   = design(ob_filter,'equiripple');

    vt_eeg	= fn_filterOffline(vt_eeg,ob_filter);
end

%% Define auxiliary variables

% Variables for stage constrains
if ~isempty(st_Cnf.hypnogram) && ~isempty(st_Cnf.stage)
   nm_isStage       = true;
   vt_validStage    = ismember(st_Cnf.hypnogram,st_Cnf.stage);
else
   nm_isStage       = false;
   vt_validStage    = [];
end

st_Cnf      = rmfield(st_Cnf,{'hypnogram','stage'});

% Variables for time-frequency constrains
if ~isempty(vt_rawEEG) && st_Cnf.timeFreq
    nm_isTimeFreq	= true;
    % Evaluate frequence in 0.1Hz steps form 0.5 to 20Hz
    vt_freq         = 4:0.05:20;
%     vt_iFreq        = vt_freq >= vt_fSpindle(1) & vt_freq <= vt_fSpindle(2);
    % Compute TF with 1 second of signal around the detected event
    nm_tFill        = nm_fSample;
else
   nm_isTimeFreq	= false;
end

%%	- Detect putative spindles

% Determine spindle rms energy
if isempty(st_Cnf.rms)
    nm_windowRMS	= round(nm_fSample * st_Cnf.window);
    st_Cnf.rms          = fn_rmstimeseries(vt_eeg,nm_windowRMS);    
end

switch st_Cnf.method
    case 'adapted'

        % Determine dynamics of spindle activity
        nm_windowFast   = round(nm_fSample * st_Cnf.dynamics(1));
        nm_windowSlow   = round(nm_fSample * st_Cnf.dynamics(2));

        vt_fastDynamics = fn_rmstimeseries(st_Cnf.rms,nm_windowFast);
        vt_slowDynamics = fn_rmstimeseries(st_Cnf.rms,nm_windowSlow);

        % Determine overcrossing events  
        vt_overcrossing     = st_Cnf.rms > vt_fastDynamics & ...
                            vt_fastDynamics > vt_slowDynamics;
        vt_overcrossing     = diff(vertcat(0,vt_overcrossing,0));
        mx_eventDetect         = [find(vt_overcrossing == 1),...
                            find(vt_overcrossing == -1)-1];

        vt_overThreshold   = st_Cnf.rms > vt_slowDynamics;
        vt_overThreshold	= diff(vertcat(0,vt_overThreshold,0));
        mx_eventBorder      = [find(vt_overThreshold == 1),...
                            find(vt_overThreshold == -1)-1];
    case 'fixed'        
        % Determine threshold        
                
        if ~isempty(vt_validStage)
            vt_rmsCurrent	= st_Cnf.rms(vt_validStage); 
        else            
            vt_rmsCurrent   = st_Cnf.rms;
        end
                
        nm_thresArtif	= prctile(vt_rmsCurrent,100*erf(3.5/sqrt(2)));
        vt_rmsCurrent   = vt_rmsCurrent(vt_rmsCurrent<nm_thresArtif);
        nm_thresDetect	= prctile(vt_rmsCurrent,100*erf(1.5/sqrt(2)));
        nm_thresBorder	= prctile(vt_rmsCurrent,100*erf(1.5/sqrt(2)));
        clear vt_rmsCurrent
        % 86.6 >> https://en.wikipedia.org/wiki/68%E2%80%9395%E2%80%9399.7_rule
            
        vt_overThreshold	= st_Cnf.rms > nm_thresDetect;
        vt_overThreshold	= diff(vertcat(0,vt_overThreshold,0));
        mx_eventDetect      = [find(vt_overThreshold == 1),...
                            find(vt_overThreshold == -1)-1];
                        
        vt_overThreshold	= st_Cnf.rms > nm_thresBorder;
        vt_overThreshold	= diff(vertcat(0,vt_overThreshold,0));
        mx_eventBorder      = [find(vt_overThreshold == 1),...
                            find(vt_overThreshold == -1)-1];
                        
        vt_overThreshold	= st_Cnf.rms > nm_thresArtif;
        vt_overThreshold	= diff(vertcat(0,vt_overThreshold,0));
        mx_eventArtifact	= [find(vt_overThreshold == 1),...
                            find(vt_overThreshold == -1)-1];
end

%% - Select spindles

% Select spindles by sleep stage if required %..............................
if nm_isStage
    vt_curStage	= vt_validStage(mx_eventBorder);
else
    vt_curStage	= true(size(mx_eventBorder));
end

vt_curStage = sum(vt_curStage,2);
vt_curStage = vt_curStage == 2;
   
mx_eventBorder	= mx_eventBorder(vt_curStage,:); 

% Determine time duration of overcrossing events and select those event
% inside time boundaries
vt_oscilPeaks   = findextrema(abs(vt_eeg));

nm_minDuration  = round(nm_fSample * st_Cnf.timebounds(1));
nm_maxDuration  = round(nm_fSample * st_Cnf.timebounds(2));

vt_timeEvents   = diff(mx_eventBorder,1,2);
vt_idEvents     = nm_minDuration <= vt_timeEvents & ...
                vt_timeEvents <= nm_maxDuration;

mx_eventBorder  = mx_eventBorder(vt_idEvents,:);
vt_centFreq     = nan(size(mx_eventBorder,1),1); 
vt_idEvents     = false(size(mx_eventBorder,1),1); 

for kk = 1:numel(vt_idEvents)
    % Ignore detectected events identified as artifacts:
    vt_curDetections	= mx_eventBorder(kk,1) <= mx_eventArtifact(:,1) & ...
                        mx_eventBorder(kk,2) >= mx_eventArtifact(:,2);
    
    if any(vt_curDetections)
        continue
    end
    
    % Select spindles by time duration and number of oscillations %.............
    vt_curDetections	= mx_eventBorder(kk,1) <= mx_eventDetect(:,1) & ...
                        mx_eventBorder(kk,2) >= mx_eventDetect(:,2);
            
	nm_numOscillations  = sum(vt_oscilPeaks >= mx_eventBorder(kk,1) & ...
                        vt_oscilPeaks <= mx_eventBorder(kk,2));
            
    if ~any(vt_curDetections) || nm_numOscillations < 2*st_Cnf.minnumosc
        continue
    end
        
    if nm_isTimeFreq
        
        % Prepare segment to analyze and indentify relative position of
        % detected spindle
        vt_idSamples	= mx_eventBorder(kk,1) - nm_tFill:...
                        mx_eventBorder(kk,2) + nm_tFill;
        
        vt_curIdEvent	= (nm_tFill + 1):(numel(vt_idSamples) - nm_tFill);  
        
        % Check that events are not in the borders
        if any(vt_idSamples < 1) || any(vt_idSamples > numel(vt_rawEEG))
            continue
        end
        
        % Compute time-frequency wavelet around the event
        vt_segment  = vt_rawEEG(vt_idSamples);
        mx_CurTF	= fn_gaborwavelet(vt_segment,nm_fSample,vt_freq);
        mx_CurTF    = flipud(mx_CurTF);
        
        % Determine main frequency components in detected spindle and check
        % whether they are into the spindle limits
        vt_frqEvent	= mean(mx_CurTF(:,vt_curIdEvent),2);
        
        vt_iPeaks   = findextrema(vt_frqEvent);
        vt_peakFreq	= vt_freq(vt_iPeaks);
        vt_peakCoef	= vt_frqEvent(vt_iPeaks);
        
        [~,vt_iPeaks]	= sort(vt_peakCoef,'descend');
        vt_peakFreq     = vt_peakFreq(vt_iPeaks); 
        
        vt_iPeaks   = find(vt_peakFreq >= vt_fSpindle(1) & ...
                    vt_peakFreq <= vt_fSpindle(2));
                
        if isempty(vt_iPeaks)
            continue
        end
        
        % Should be recomputed the spindle limits?
        
        vt_centFreq(kk)	= vt_peakFreq(vt_iPeaks(1)); 
    end
    
    vt_idEvents(kk)	= true; 
     
end

vt_centFreq     = vt_centFreq(vt_idEvents);
mx_eventLims	= mx_eventBorder(vt_idEvents,:);

[mx_eventLims,vt_idEvents]	= unique(mx_eventLims,'rows');
vt_centFreq                 = vt_centFreq(vt_idEvents);
