function [vt_soLocations,nm_thres,vt_eegSignal] = fn_sleep_detect_SO(...
                                                vt_eegSignal,st_cnf)
% [vt_soLocations,vt_eegSignal] = fn_sleep_detect_SO(vt_eegSignal,st_cnf) 
% detect all slow oscillations from channel vt_eegSignal depending on the 
% settings in the structure st_cnf. 
%
% vt_soLocations corresponds to a vector indicating the locations (in
% samples) of each detected SO. st_cnf corresponds to a structure with the
% fields:
%
%   - st_cnf.freqband:	1 x 2 vector indicating the frequency band limits
%                       for SO detection, (default = [0.3 4])
%
%   - st_cnf.fsampling:	Sampling frequency in hertz
%
%   - st_cnf.threshold:	Negative amplitude threshold for detection of SO
%                       (default = -65) in microvolts
%   
%   - st_cnf.minthresh:	Value inidicating the minimum value for SO amplitude. 
%                       If the value is in the [0 1] interval, then
%                       corresponds to percentage of cumulative amplitude.
%                       If negative value, the it corresponds to raw
%                       amplitude. (default = -300);
%
%   - st_cnf.toFilter:	Filter input in SO band (default = false)
%
%   See also FINDEXTREMA (from Siyi Deng).
                        
%% GNU licence,
% Copyright (C) <2017>  <Miguel Navarrete>
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

%% Code starts here:

%%	- Check default inputs

if ~isvector(vt_eegSignal)
    error('fn_sleep_detect_SO:signalIsNotVector','Input must be a vector;'); 
end

if nargin < 2   % if not input arguments, then use arguments by default    
	st_cnf  = struct;
end
    
% Check whether st_cnf fileds exist
if ~isfield(st_cnf,'freqband') 
    st_cnf.freqband     = [0.5 2];
end

if ~isfield(st_cnf,'fsampling')
    st_cnf.fsampling	= 1;
end

if ~isfield(st_cnf,'threshold')
    st_cnf.threshold	= -65;
end

if ~isfield(st_cnf,'peakthreshold')
    st_cnf.peakthreshold	= 75;
end

if ~isfield(st_cnf,'minthresh')
    st_cnf.minthresh	= erf(4.5/sqrt(2));
end

if ~isfield(st_cnf,'toFilter')
    st_cnf.toFilter	= false;
end

% Check whether st_cnf fileds are empty
if isempty(st_cnf.freqband) 
    st_cnf.freqband     = [0.3 4];
end

if isempty(st_cnf.fsampling)
    st_cnf.fsampling	= 1;
end

if isempty(st_cnf.threshold)
    st_cnf.threshold	= -65;
end

if isempty(st_cnf.peakthreshold)
    st_cnf.peakthreshold	= 75;
end

if isempty(st_cnf.minthresh)
    st_cnf.minthresh	= -300;
end

if isempty(st_cnf.toFilter)
    st_cnf.toFilter	= false;
end

if ~isfield(st_cnf,'hypnogram')
    st_cnf.hypnogram	= [];
end

if ~isfield(st_cnf,'stage')
    st_cnf.stage	= [];
end

if ~isfield(st_cnf,'method')
    st_cnf.method	= 'threshold';
end

if ~isfield(st_cnf,'timebounds')
    st_cnf.timebounds	= 0.5./st_cnf.freqband;
end

%%	- Filter input if required

vt_eegSignal   = vt_eegSignal(:);

if st_cnf.toFilter
    st_FilterSO     = fn_filter_designIIR(st_cnf.fsampling,st_cnf.freqband,...
                    [st_cnf.freqband(1) - 0.3,st_cnf.freqband(1) + 0.5]);
    vt_eegSignal	= fn_filter_offline(vt_eegSignal,st_FilterSO);
end

%%	- Detect putative SO

% Detect minima and zero crossings
[vt_Hi,vt_Lo,vt_Cr]	= findextrema(vt_eegSignal);

vt_Lo	= vt_Lo(vt_eegSignal(vt_Lo) < 0);
vt_Hi	= vt_Hi(vt_eegSignal(vt_Hi) > 0);


if ~isempty(st_cnf.hypnogram) && ~isempty(st_cnf.stage)
   vt_validStage    = ismember(st_cnf.hypnogram,st_cnf.stage);
else
   vt_validStage    = true(size(vt_eegSignal));
end

st_cnf	= rmfield(st_cnf,{'hypnogram','stage'});

% vt_extrema   = vt_extrema(vt_validStage(vt_Lo));
vt_extrema  = sort(vertcat(vt_Lo(:),vt_Hi(:)));
% vt_extrema  = sort(vertcat(vt_Lo(:)));
vt_extrema  = vt_extrema(vt_validStage(vt_extrema));

switch st_cnf.method
    case 'threshold'
        % Select minima over lowest threshold
        if st_cnf.minthresh > 0 && st_cnf.minthresh < 1
            st_cnf.minthresh	= prctile(vt_eegSignal(vt_Lo),...
                                st_cnf.minthresh * 100);
        end  
                
    case 'set_percentile'        
        vt_values           = -vt_eegSignal(vt_extrema);
        st_cnf.threshold    = -prctile(abs(vt_values),...
                            st_cnf.threshold); % fix percentile
        st_cnf.minthresh    = - prctile(vt_values,...
                            100*erf(3.5/sqrt(2)));
        
    case 'percentile'
        vt_values           = -vt_eegSignal(vt_extrema);
        st_cnf.threshold    = -prctile(abs(vt_values),...
                            100*erf(1.5/sqrt(2))); % percentile 90
%                             100*erf(1.6448/sqrt(2))); % percentile 90
        st_cnf.minthresh    = - prctile(vt_values,...
                            100*erf(3.5/sqrt(2)));
        
    case 'parametric'
        vt_values           = -vt_eegSignal(vt_extrema);
        st_cnf.threshold    = -(mean(vt_values) + 1.5*std(vt_values));
        st_cnf.minthresh    = -(mean(vt_values) + 4.5*std(vt_values));
        
    case 'logarithmic'
        vt_values           = log10(abs(vt_eegSignal(vt_extrema)));
        st_cnf.threshold    = mean(vt_values) + 1.5*std(vt_values);
        st_cnf.minthresh    = mean(vt_values) + 4.5*std(vt_values);
        st_cnf.threshold    = -10^(st_cnf.threshold);
        st_cnf.minthresh    = -10^(st_cnf.minthresh);
end

% Select minima under detection threshold
vt_Lo   = vt_Lo(vt_validStage(vt_Lo));
vt_Lo	= vt_Lo(vt_eegSignal(vt_Lo) < st_cnf.threshold);
vt_Lo	= vt_Lo(vt_eegSignal(vt_Lo) > st_cnf.minthresh);

if st_cnf.threshold > -10 && strcmpi(st_cnf.method,'threshold')
    vt_values	= -vt_eegSignal(vt_extrema);
    nm_thres    = -prctile(abs(vt_values),...
                            80); % fix percentile
else
    nm_thres	= st_cnf.threshold;
end

%%	- Select SOs

% Compute half wave samples 
vt_halfWave     = sort(round(st_cnf.timebounds * st_cnf.fsampling));

% Preallocate variables
vt_soLocations  = nan(size(vt_Lo));
vt_lastCr       = [0,0];

% Check each SO characteristics
for kk = 1:numel(vt_Lo)
    
    nm_curLo    = vt_Lo(kk);
    
    % Find previous and posterior zero-crossings
    nm_preCr    = vt_Cr(find(vt_Cr < nm_curLo,1,'last'));
    nm_posCr    = vt_Cr(find(vt_Cr > nm_curLo,2,'first'));
    
    if isempty(nm_preCr) || isempty(nm_posCr)
        continue
    end
    
    nm_posCrHi	= nm_posCr(end);
    nm_posCr    = nm_posCr(1); 
    
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
    [nm_neg,nm_idx]  = min(vt_eegSignal(vt_curLo));
    nm_curLo    = vt_curLo(nm_idx);
    
    % FUTURE UPDATE: Include the possibility of hard-detection where the
    % amplitude and  duration of positive waves are also taken in account
    % (Valderrama et al 2012)
    vt_curHi    = vt_Hi(vt_Hi > nm_posCr & vt_Hi < nm_posCrHi);
    
    if isempty(vt_curHi)        
        nm_pos	= 0;
    else
        nm_pos	= max(vt_eegSignal(vt_curHi));
    end
    
    
    % If peak-to-peak amplitude is lower than peakthreshold, then skip
    % current wave
    nm_peak2peak	= nm_pos - nm_neg;
    
    if nm_peak2peak < st_cnf.peakthreshold
        continue
    end
    
    % Save current value
    vt_soLocations(kk)	= nm_curLo;
    
end

%%	- Select only detected waves

vt_soLocations(isnan(vt_soLocations))	= [];

