function [vt_soLocations,nm_thres,vt_eegSignal] = fn_detectsleepSO(vt_eegSignal,st_Cnf)
% [vt_soLocations,vt_eegSignal] = fn_detectsleepSO(vt_eegSignal,st_Cnf) 
% detect all slow oscillations from channel vt_eegSignal depending on the 
% settings in the structure st_Cnf. 
%
% vt_soLocations corresponds to a vector indicating the locations (in
% samples) of each detected SO. st_Cnf corresponds to a structure with the
% fields:
%
%   - st_Cnf.freqband:	1 x 2 vector indicating the frequency band limits
%                       for SO detection, (default = [0.3 4])
%
%   - st_Cnf.fsampling:	Sampling frequency in hertz
%
%   - st_Cnf.threshold:	Negative amplitude threshold for detection of SO
%                       (default = -65) in microvolts
%   
%   - st_Cnf.minthresh:	Value inidicating the minimum value for SO amplitude. 
%                       If the value is in the [0 1] interval, then
%                       corresponds to percentage of cumulative amplitude.
%                       If negative value, the it corresponds to raw
%                       amplitude. (default = -300);
%
%   - st_Cnf.toFilter:	Filter input in SO band (default = false)
%
%   See also FINDEXTREMA (from Siyi Deng).

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

if ~isvector(vt_eegSignal)
    error('fn_detectsleepSO:signalIsNotVector','Input must be a vector;'); 
end

if nargin < 2   % if not input arguments, then use arguments by default    
	st_Cnf  = struct;
end
    
% Check whether st_Cnf fileds exist
if ~isfield(st_Cnf,'freqband') 
    st_Cnf.freqband     = [0.5 2];
end

if ~isfield(st_Cnf,'fsampling')
    st_Cnf.fsampling	= 1;
end

if ~isfield(st_Cnf,'threshold')
    st_Cnf.threshold	= -65;
end

if ~isfield(st_Cnf,'minthresh')
    st_Cnf.minthresh	= erf(4.5/sqrt(2));
end

if ~isfield(st_Cnf,'toFilter')
    st_Cnf.toFilter	= false;
end

% Check whether st_Cnf fileds are empty
if isempty(st_Cnf.freqband) 
    st_Cnf.freqband     = [0.3 4];
end

if isempty(st_Cnf.fsampling)
    st_Cnf.fsampling	= 1;
end

if isempty(st_Cnf.threshold)
    st_Cnf.threshold	= -65;
end

if isempty(st_Cnf.minthresh)
    st_Cnf.minthresh	= -300;
end

if isempty(st_Cnf.toFilter)
    st_Cnf.toFilter	= false;
end

if ~isfield(st_Cnf,'hypnogram')
    st_Cnf.hypnogram	= [];
end

if ~isfield(st_Cnf,'stage')
    st_Cnf.stage	= [];
end

if ~isfield(st_Cnf,'method')
    st_Cnf.method	= 'threshold';
end

if ~isfield(st_Cnf,'timebounds')
    st_Cnf.timebounds	= 0.5./st_Cnf.freqband;
end

%%	- Filter input if required

vt_eegSignal   = vt_eegSignal(:);

if st_Cnf.toFilter
    st_FilterSO     = fn_designIIRfilter(st_Cnf.fsampling,st_Cnf.freqband,...
                    [st_Cnf.freqband(1) - 0.3,st_Cnf.freqband(1) + 0.5]);
    vt_eegSignal	= fn_filterOffline(vt_eegSignal,st_FilterSO);
end

%%	- Detect putative SO

% Detect minima and zero crossings
[vt_Hi,vt_Lo,vt_Cr]	= findextrema(vt_eegSignal);

vt_Lo	= vt_Lo(vt_eegSignal(vt_Lo) < 0);
vt_Hi	= vt_Hi(vt_eegSignal(vt_Hi) > 0);


if ~isempty(st_Cnf.hypnogram) && ~isempty(st_Cnf.stage)
   vt_validStage    = ismember(st_Cnf.hypnogram,st_Cnf.stage);
else
   vt_validStage    = true(size(vt_eegSignal));
end

st_Cnf	= rmfield(st_Cnf,{'hypnogram','stage'});

% vt_extrema   = vt_extrema(vt_validStage(vt_Lo));
vt_extrema  = sort(vertcat(vt_Lo(:),vt_Hi(:)));
% vt_extrema  = sort(vertcat(vt_Lo(:)));
vt_extrema  = vt_extrema(vt_validStage(vt_extrema));

switch st_Cnf.method
    case 'threshold'
        % Select minima over lowest threshold
        if st_Cnf.minthresh > 0 && st_Cnf.minthresh < 1
            st_Cnf.minthresh	= prctile(vt_eegSignal(vt_Lo),...
                                st_Cnf.minthresh * 100);
        end  
                
    case 'set_percentile'        
        vt_values           = -vt_eegSignal(vt_extrema);
        st_Cnf.threshold    = -prctile(abs(vt_values),...
                            st_Cnf.threshold); % fix percentile
        st_Cnf.minthresh    = - prctile(vt_values,...
                            100*erf(3.5/sqrt(2)));
        
    case 'percentile'
        vt_values           = -vt_eegSignal(vt_extrema);
        st_Cnf.threshold    = -prctile(abs(vt_values),...
                            100*erf(1.5/sqrt(2))); % percentile 90
%                             100*erf(1.6448/sqrt(2))); % percentile 90
        st_Cnf.minthresh    = - prctile(vt_values,...
                            100*erf(3.5/sqrt(2)));
        
    case 'parametric'
        vt_values           = -vt_eegSignal(vt_extrema);
        st_Cnf.threshold    = -(mean(vt_values) + 1.5*std(vt_values));
        st_Cnf.minthresh    = -(mean(vt_values) + 4.5*std(vt_values));
        
    case 'logarithmic'
        vt_values           = log10(abs(vt_eegSignal(vt_extrema)));
        st_Cnf.threshold    = mean(vt_values) + 1.5*std(vt_values);
        st_Cnf.minthresh    = mean(vt_values) + 4.5*std(vt_values);
        st_Cnf.threshold    = -10^(st_Cnf.threshold);
        st_Cnf.minthresh    = -10^(st_Cnf.minthresh);
end

% Select minima under detection threshold
vt_Lo   = vt_Lo(vt_validStage(vt_Lo));
vt_Lo	= vt_Lo(vt_eegSignal(vt_Lo) < st_Cnf.threshold);
vt_Lo	= vt_Lo(vt_eegSignal(vt_Lo) > st_Cnf.minthresh);

if st_Cnf.threshold > -10 && strcmpi(st_Cnf.method,'threshold')
    vt_values	= -vt_eegSignal(vt_extrema);
    nm_thres    = -prctile(abs(vt_values),...
                            80); % fix percentile
else
    nm_thres	= st_Cnf.threshold;
end

%%	- Select SOs

% Compute half wave samples 
vt_halfWave     = sort(round(st_Cnf.timebounds * st_Cnf.fsampling));

% Preallocate variables
vt_soLocations  = nan(size(vt_Lo));
vt_lastCr       = [0,0];

% Check each SO characteristics
for kk = 1:numel(vt_Lo)
    
    nm_curLo    = vt_Lo(kk);
    
    % Find previous and posterior zero-crossings
    nm_preCr    = vt_Cr(find(vt_Cr < nm_curLo,1,'last'));
    nm_posCr    = vt_Cr(find(vt_Cr > nm_curLo,1,'first'));
    
    % If minimum position is not bounded by zero-crossings, then skip current 
    % wave
    if isempty(nm_preCr) || isempty(nm_posCr)
        continue
    end

    % If zero-crossings are the same than previous iteration, then skip
    % current wave
    if sum(abs(vt_lastCr - [nm_preCr,nm_posCr])) == 0
        continue
    end
    
    vt_lastCr	= [nm_preCr,nm_posCr];
    
    % If half wave time is out of SO frequency boundaries, then skip
    % current wave
    nm_waveTime	= nm_posCr - nm_preCr;
    
    if nm_waveTime < vt_halfWave(1) || nm_waveTime > vt_halfWave(2)
        continue
    end
    
    % If multiple negative peaks, then select the minimum peak
    vt_curLo    = vt_Lo(vt_Lo > nm_preCr & vt_Lo < nm_posCr);
    [~,nm_idx]  = min(vt_eegSignal(vt_curLo));
    nm_curLo    = vt_curLo(nm_idx);
    
    % FUTURE UPDATE: Include the possibility of hard-detection where the
    % amplitude and  duration of positive waves are also taken in account
    % (Valderrama et al 2012)
    
    % Save current value
    vt_soLocations(kk)	= nm_curLo;
    
end

%%	- Select only detected waves

vt_soLocations(isnan(vt_soLocations))	= [];

