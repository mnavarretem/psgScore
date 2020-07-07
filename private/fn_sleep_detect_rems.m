function [vt_remLoc,vt_semLoc] = fn_sleep_detect_rems(mx_eogSignal,st_cnf)
% [vt_remLoc,mx_eogSignal] = fn_detectsleepREM(mx_eogSignal,st_cnf) 
% detect all REM from channel mx_eogSignal depending on the 
% settings in the structure st_cnf. 
%
% vt_remLoc corresponds to a vector indicating the locations (in
% samples) of each detected REM. st_cnf corresponds to a structure with the
% fields:
%
%   - st_cnf.freqband:	1 x 2 vector indicating the frequency band limits
%                       for REM detection, (default = [0.3 4])
%
%   - st_cnf.fsampling:	Sampling frequency in hertz
%
%   - st_cnf.threshold:	Negative amplitude threshold for detection of REM
%                       (default = -65) in microvolts
%   
%   - st_cnf.maxthresh:	Value inidicating the maximum value for REM amplitude. 
%                       If the value is in the [0 1] interval, then
%                       corresponds to percentage of cumulative amplitude.
%                       If negative value, the it corresponds to raw
%                       amplitude. (default = -300);
%
%   - st_cnf.toFilter:	Filter input in REM band (default = false)

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

% Based on:
% R. Agarwal, T. Takeuchi, S. Laroche and J. Gotman, 
% "Detection of rapid-eye movements in sleep studies," 
% in IEEE Transactions on Biomedical Engineering, vol. 52, no. 8, 
% pp. 1390-1396, Aug. 2005, doi: 10.1109/TBME.2005.851512.

%%	- Check default inputs

if nargin < 2   % if not input arguments, then use arguments by default    
	st_cnf  = struct;
end
    
% Check whether st_cnf fileds exist
if ~isfield(st_cnf,'freqband') 
    st_cnf.freqband     = [0.3 5];
end

if ~isfield(st_cnf,'fsampling')
    st_cnf.fsampling	= 1;
end

if ~isfield(st_cnf,'window')
    st_cnf.window	= st_cnf.fsampling;
end

if ~isfield(st_cnf,'windowDeflection')
    st_cnf.winDefl	= 3*st_cnf.fsampling;
end

if ~isfield(st_cnf,'timeDeflection')
    st_cnf.tDeflect	= round(0.5*st_cnf.fsampling);
end

if ~isfield(st_cnf,'threshold')
    st_cnf.threshold	= -65;
end

if ~isfield(st_cnf,'minthresh')
    st_cnf.maxthresh	= 500;
end

if ~isfield(st_cnf,'toFilter')
    st_cnf.toFilter	= false;
end

if ~isfield(st_cnf,'hypnogram')
    st_cnf.hypnogram	= [];
end

if ~isfield(st_cnf,'stage')
    st_cnf.stage	= [];
end

%%	- Filter input if required

if size(mx_eogSignal,1) < size(mx_eogSignal,2)
    mx_eogSignal	= mx_eogSignal';
end

if st_cnf.toFilter
    st_filterREM	= fn_filter_designIIR(st_cnf.fsampling,st_cnf.freqband,...
                    [st_cnf.freqband(1) - 0.1,st_cnf.freqband(1) + 1]);
    mx_eogSignal	= fn_filter_offline(mx_eogSignal,st_filterREM);
end

%%	- Detect putative REM

% Candidate REM Detection:
vt_chProduct	= -mx_eogSignal(:,1).*mx_eogSignal(:,2);
% vt_chProduct    = fn_rmstimeseries(vt_chProduct,st_cnf.fsampling);

% Threshold selection
vt_Hi       = findextrema(vt_chProduct);
vt_Hi       = vt_Hi(vt_chProduct(vt_Hi) > 0);
vt_values	= vt_chProduct(vt_Hi);

nm_minThr	= prctile(vt_values,100*erf(1.5/sqrt(2))); 
nm_maxThr	= prctile(vt_values,100*erf(3/sqrt(2)));

vt_eoi	= nm_minThr < vt_values & vt_values < nm_maxThr;
vt_eoi	= vt_Hi(vt_eoi);

%% REM detection features
vt_featEidx     = nan(size(vt_eoi));
vt_featEval     = nan(size(vt_eoi));
vt_featMaxVal	= nan(size(vt_eoi));
vt_featCorr     = nan(size(vt_eoi));
vt_featMaxRatio	= nan(size(vt_eoi));
vt_featSlope	= nan(size(vt_eoi));
vt_featDeflect	= nan(size(vt_eoi));

for kk = 1:numel(vt_eoi)
    
    vt_idi  = -st_cnf.winDefl:st_cnf.winDefl;
    vt_id   = vt_idi + vt_eoi(kk);
    
    if any(vt_id < 1) || any(vt_id > length(mx_eogSignal))
        continue
    end
    
    if mx_eogSignal(vt_eoi(kk),1) > 0 && mx_eogSignal(vt_eoi(kk),2) < 0
        nm_idPos    = 1;
        nm_idNeg    = 2;
    elseif mx_eogSignal(vt_eoi(kk),2) > 0 && mx_eogSignal(vt_eoi(kk),1) < 0
        nm_idPos    = 2;
        nm_idNeg    = 1;
    else
        continue
    end
    
    vt_eogPos	= mx_eogSignal(vt_id,nm_idPos);
    vt_eogNeg	= mx_eogSignal(vt_id,nm_idNeg);
    vt_eogDiff	= vt_eogPos > vt_eogNeg;
    nm_eventBeg	= find(~vt_eogDiff & vt_id(:) < vt_eoi(kk),1,'last')+1;
    nm_eventEnd	= find(~vt_eogDiff & vt_id(:) > vt_eoi(kk),1,'first')-1;
    nm_eventBeg	= vt_id(nm_eventBeg);
    nm_eventEnd	= vt_id(nm_eventEnd);
           
    if isempty(nm_eventBeg) || isempty(nm_eventEnd)
        continue
    end
    
    vt_cid      = nm_eventBeg:nm_eventEnd;
    vt_ceoi  	= vt_chProduct(vt_cid);
    
    [nm_val,nm_sTop]= max(vt_ceoi);
    [~,vt_cLo]      = findextrema(vt_ceoi);
        
    if isempty(vt_cLo)
        vt_cLo	= 1;
    end
    
    nm_minStep	= nm_val*2/3;
    vt_cLo      = vt_cLo(nm_val-vt_ceoi(vt_cLo) > nm_minStep);
    
    if isempty(vt_cLo)
        vt_cLo	= 1;
    end
    
    nm_sBeg         = vt_cLo(nm_sTop > vt_cLo);
    
    if isempty(nm_sBeg)
        nm_sBeg	= 1;
    end
    
    nm_sBeg         = nm_sBeg(end);
    
    vt_slope        = diff(vt_ceoi/max(vt_ceoi));
    
    vt_maxSlopeIdx	= findextrema(vt_slope);
    vt_maxSlopeIdx  = vt_maxSlopeIdx(...
                    vt_maxSlopeIdx > nm_sBeg & vt_maxSlopeIdx < nm_sTop);
                
    if isempty(vt_maxSlopeIdx)
        continue
    end
    
    [nm_maxSl,nm_id]= max(vt_slope(vt_maxSlopeIdx));
    nm_ceoiId       = nm_sTop + nm_eventBeg - 1;
    
    nm_idSlope      = vt_maxSlopeIdx(nm_id);
    mx_cEM          = mx_eogSignal(vt_cid,:);    
    
    if any(ismember(vt_featEidx,nm_ceoiId))
        continue;
    end
        
    vt_idi  = -st_cnf.window:st_cnf.window;
    vt_id   = vt_idi + nm_ceoiId;
    
    mx_ceog	= mx_eogSignal(vt_id,:);
    mx_corr = corr(mx_ceog);    
    
    if mx_corr(2) >0
        continue
    end
%     disp(nm_sBeg)
%     plot(vt_ceoi)
    vt_featEidx(kk)     = nm_ceoiId;
    vt_featEval(kk)     = nm_val;
    vt_featMaxVal(kk)	= max(abs(mx_ceog(:)));
    vt_featCorr(kk)     = mx_corr(2);
    vt_featMaxRatio(kk)	= nm_sTop/numel(vt_cid);
    vt_featSlope(kk)    = nm_maxSl;
    vt_featDeflect(kk)	= nm_sTop-nm_sBeg;
    
end

vt_isEOI	= ~isnan(vt_featEidx) & vt_featMaxVal < st_cnf.maxthresh;

vt_featEidx     = vt_featEidx(vt_isEOI);
vt_featEval     = vt_featEval(vt_isEOI);
vt_featMaxVal	= vt_featMaxVal(vt_isEOI);
vt_featCorr     = vt_featCorr(vt_isEOI);
vt_featMaxRatio	= vt_featMaxRatio(vt_isEOI);
vt_featSlope	= vt_featSlope(vt_isEOI);
vt_featDeflect	= vt_featDeflect(vt_isEOI);
    
vt_idCorrelated	= abs(vt_featCorr) > 0.25 & vt_featMaxVal > sqrt(nm_minThr);
vt_idDeflect	= vt_featDeflect > st_cnf.tDeflect;                
vt_idSlope      = vt_featSlope < prctile(vt_featSlope,25);

vt_isREM	= ~vt_idDeflect & ~vt_idSlope;
vt_isSEM    = ~vt_isREM & vt_idCorrelated;
vt_isREM    = vt_isREM & vt_idCorrelated;

vt_remLoc	= vt_featEidx(vt_isREM);
vt_semLoc	= vt_featEidx(vt_isSEM);
vt_nemLoc	= vt_featEidx(~vt_isSEM & ~vt_isREM);

%% Plot REM events
% for kk = 1:numel(vt_remLoc)
%     
%     vt_idi  = -2*st_cnf.window:2*st_cnf.window;
%     vt_id   = vt_idi + vt_remLoc(kk);
%     
%     mx_ceog	= mx_eogSignal(vt_id,:);
%     plot(vt_idi/st_cnf.fsampling,mx_ceog)
%     
%     pause
% end

%% Plot SEM events
% for kk = 1:numel(vt_semLoc)
%     
%     vt_idi  = -2*st_cnf.window:2*st_cnf.window;
%     vt_id   = vt_idi + vt_semLoc(kk);
%     
%     
%     if any(vt_id < 1) || any(vt_id > length(mx_eogSignal))
%         continue
%     end
%     mx_ceog	= mx_eogSignal(vt_id,:);
%     plot(vt_idi/st_cnf.fsampling,mx_ceog)
%     pause
% end


%% Plot non EM events
% for kk = 1:numel(vt_nemLoc)
%     
%     vt_idi  = -2*st_cnf.window:2*st_cnf.window;
%     vt_id   = vt_idi + vt_nemLoc(kk);
%     
%     
%     if any(vt_id < 1) || any(vt_id > length(mx_eogSignal))
%         continue
%     end
%     mx_ceog	= mx_eogSignal(vt_id,:);
%     plot(vt_idi/st_cnf.fsampling,mx_ceog)
%     pause
% end