function [vt_remLoc,vt_semLoc] = fn_detectsleepREM(mx_eogSignal,st_Cnf)
% [vt_remLoc,mx_eogSignal] = fn_detectsleepREM(mx_eogSignal,st_Cnf) 
% detect all REM from channel mx_eogSignal depending on the 
% settings in the structure st_Cnf. 
%
% vt_remLoc corresponds to a vector indicating the locations (in
% samples) of each detected REM. st_Cnf corresponds to a structure with the
% fields:
%
%   - st_Cnf.freqband:	1 x 2 vector indicating the frequency band limits
%                       for REM detection, (default = [0.3 4])
%
%   - st_Cnf.fsampling:	Sampling frequency in hertz
%
%   - st_Cnf.threshold:	Negative amplitude threshold for detection of REM
%                       (default = -65) in microvolts
%   
%   - st_Cnf.maxthresh:	Value inidicating the maximum value for REM amplitude. 
%                       If the value is in the [0 1] interval, then
%                       corresponds to percentage of cumulative amplitude.
%                       If negative value, the it corresponds to raw
%                       amplitude. (default = -300);
%
%   - st_Cnf.toFilter:	Filter input in REM band (default = false)
%
%   See alREM FINDEXTREMA (from Siyi Deng).

%% BSD license;
% Copyright (c) 2017, Miguel Navarrete;
% All rights reserved.
% 
% Redistribution and use in REMurce and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
%     * Redistributions of REMurce code must retain the above copyright 
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright 
%       notice, this list of conditions and the following disclaimer in 
%       the documentation and/or other materials provided with the distribution
%       
% THIS REMFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS REMFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE.

%% Code starts here:

% Based on Agarwal wt al 2005

%%	- Check default inputs

if nargin < 2   % if not input arguments, then use arguments by default    
	st_Cnf  = struct;
end
    
% Check whether st_Cnf fileds exist
if ~isfield(st_Cnf,'freqband') 
    st_Cnf.freqband     = [0.3 5];
end

if ~isfield(st_Cnf,'fsampling')
    st_Cnf.fsampling	= 1;
end

if ~isfield(st_Cnf,'window')
    st_Cnf.window	= st_Cnf.fsampling;
end

if ~isfield(st_Cnf,'windowDeflection')
    st_Cnf.winDefl	= 3*st_Cnf.fsampling;
end

if ~isfield(st_Cnf,'timeDeflection')
    st_Cnf.tDeflect	= round(0.7*st_Cnf.fsampling);
end

if ~isfield(st_Cnf,'threshold')
    st_Cnf.threshold	= -65;
end

if ~isfield(st_Cnf,'minthresh')
    st_Cnf.maxthresh	= 500;
end

if ~isfield(st_Cnf,'toFilter')
    st_Cnf.toFilter	= false;
end

if ~isfield(st_Cnf,'hypnogram')
    st_Cnf.hypnogram	= [];
end

if ~isfield(st_Cnf,'stage')
    st_Cnf.stage	= [];
end

%%	- Filter input if required

if size(mx_eogSignal,1) < size(mx_eogSignal,2)
    mx_eogSignal	= mx_eogSignal';
end

if st_Cnf.toFilter
    st_filterREM	= fn_designIIRfilter(st_Cnf.fsampling,st_Cnf.freqband,...
                    [st_Cnf.freqband(1) - 0.1,st_Cnf.freqband(1) + 1]);
    mx_eogSignal	= fn_filterOffline(mx_eogSignal,st_filterREM);
end

%%	- Detect putative REM

% Candidate REM Detection:
vt_chProduct	= -mx_eogSignal(:,1).*mx_eogSignal(:,2);
% vt_chProduct    = fn_rmstimeseries(vt_chProduct,st_Cnf.fsampling);

% Threshold selection
vt_Hi       = findextrema(vt_chProduct);
vt_Hi       = vt_Hi(vt_chProduct(vt_Hi) > 0);
vt_values	= vt_chProduct(vt_Hi);

nm_minThr	= prctile(vt_values,100*erf(1.5/sqrt(2))); 
nm_maxThr	= prctile(vt_values,100*erf(3/sqrt(2)));

vt_eoi	= nm_minThr < vt_values & vt_values < nm_maxThr;
vt_eoi	= vt_Hi(vt_eoi);

%% REM detection features
vt_featEidx	= nan(size(vt_eoi));
vt_featEval	= nan(size(vt_eoi));
vt_featMax	= nan(size(vt_eoi));
vt_featCorr	= nan(size(vt_eoi));
vt_featDef	= nan(size(vt_eoi));

for kk = 1:numel(vt_eoi)
    
    vt_idi  = -st_Cnf.winDefl:st_Cnf.winDefl;
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
    
    vt_ceoi         = vt_chProduct(nm_eventBeg:nm_eventEnd);
    [nm_val,nm_idt]	= max(vt_ceoi);
    nm_ceoiId       = nm_idt + nm_eventBeg - 1;
    
    if any(ismember(vt_featEidx,nm_ceoiId))
        continue;
    end
    
    vt_idi  = -st_Cnf.window:st_Cnf.window;
    vt_id   = vt_idi + nm_ceoiId;
    
    mx_ceog	= mx_eogSignal(vt_id,:);
    mx_corr = corr(mx_ceog);    
    
    if mx_corr(2) >0
        continue
    end
                    
    vt_featEidx(kk)	= nm_ceoiId;
    vt_featEval(kk)	= nm_val;
    vt_featMax(kk)	= max(abs(mx_ceog(:)));
    vt_featCorr(kk)	= mx_corr(2);
    vt_featDef(kk)	= nm_idt;
    
end

vt_isEOI	= ~isnan(vt_featEidx) & vt_featMax < st_Cnf.maxthresh;

vt_featEidx	= vt_featEidx(vt_isEOI);
vt_featEval	= vt_featEval(vt_isEOI);
vt_featMax	= vt_featMax(vt_isEOI);
vt_featCorr	= vt_featCorr(vt_isEOI);
vt_featDef	= vt_featDef(vt_isEOI);
    

vt_remLoc	= vt_featEidx(vt_featDef <= st_Cnf.tDeflect);
vt_semLoc	= vt_featEidx(vt_featDef > st_Cnf.tDeflect);

%% Plot REM events
% for kk = 1:numel(vt_remLoc)
%     
%     vt_idi  = -2*st_Cnf.window:2*st_Cnf.window;
%     vt_id   = vt_idi + vt_remLoc(kk);
%     
%     mx_ceog	= mx_eogSignal(vt_id,:);
%     plot(vt_idi/st_Cnf.fsampling,mx_ceog)
% end

%% Plot SEM events
% for kk = 1:numel(vt_semLoc)
%     
%     vt_idi  = -2*st_Cnf.window:2*st_Cnf.window;
%     vt_id   = vt_idi + vt_semLoc(kk);
%     
%     
%     if any(vt_id < 1) || any(vt_id > length(mx_eogSignal))
%         continue
%     end
%     mx_ceog	= mx_eogSignal(vt_id,:);
%     plot(vt_idi/st_Cnf.fsampling,mx_ceog)
% end