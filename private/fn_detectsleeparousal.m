function [mx_eventSample] = fn_detectsleeparousal(mx_tf,st_Cnf)
% [mx_eventLims,vt_centFreq,vt_eeg] = fn_detectsleeparousal(vt_eeg,st_Cnf) 
% detect all sleep arousals from eeg Time-Freq mx_tf depending on the 
% settings in the structure st_Cnf. 
%
% mx_eventLims corresponds to a matrix indicating the locations (in
% samples) of each detected SO. st_Cnf corresponds to a structure with the
% fields:
%
%   - st_Cnf.freqband:	1 x 2 vector indicating the frequency band limits
%                       for arousal detection, (default = [4 35])
%   
%   - st_Cnf.tEEG:      time vector for original eeg samples
%   - st_Cnf.time:      time vector for mx_tf

%   - st_Cnf.freq:      frequency vector for mx_tf
%   
%   - st_Cnf.mintime:	Minimum number time duration in seconds
%   
%   - st_Cnf.timeFreq:	Time-frequency correction (default = true)
%
%   - st_Cnf.threshold:	percentil threshold for arousal detection (SD)
%                       default = 1.5 SD
%                           
%% BSD license;
% Copyright (c) 2020, Miguel Navarrete;
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

if any(size(mx_tf)==1)
    error('fn_detectsleeparousal:signalIsNotVector','Input must be a vector;'); 
end

if nargin < 2   % if not input arguments, then use arguments by default    
	st_Cnf  = struct;
end

% Check whether st_Cnf fileds are empty
if ~isfield(st_Cnf,'freqband') 
    st_Cnf.freqband     = [3 35];
end

if ~isfield(st_Cnf,'mintime')
    st_Cnf.mintime	= 2.5;
end

if ~isfield(st_Cnf,'threshold')
    st_Cnf.threshold	= 1.5;
end

%%	- Detect putative arousals

vt_idFreq	= st_Cnf.freq >= st_Cnf.freqband(1) & ...
            st_Cnf.freq <= st_Cnf.freqband(2);

% Determine freq variability
vt_data     = mean(mx_tf(vt_idFreq,:));
vt_hiPos	= findextrema(vt_data);
vt_hiVal    = vt_data(vt_hiPos);
nm_thres	= prctile(vt_hiVal,100*erf(st_Cnf.threshold/sqrt(2)));

vt_overThreshold	= vt_data(:) > nm_thres;
vt_overThreshold	= diff(vertcat(0,vt_overThreshold,0));
mx_eventDetect      = [find(vt_overThreshold == 1),...
                    find(vt_overThreshold == -1)-1];
                
mx_eventBorder	= st_Cnf.time(mx_eventDetect);

%% - Select arousals

vt_timeEvents   = diff(mx_eventBorder,1,2);
vt_idEvents     = vt_timeEvents >= st_Cnf.mintime ;

mx_eventBorder  = mx_eventBorder(vt_idEvents,:);
mx_eventSample  = nan(size(mx_eventBorder));

for kk = 1:size(mx_eventSample,1)
    [~,nm_posBeg]  = min(abs(mx_eventBorder(kk,1)-st_Cnf.tEEG));
    [~,nm_posEnd]  = min(abs(mx_eventBorder(kk,2)-st_Cnf.tEEG));
    
    mx_eventSample(kk,:) = [nm_posBeg,nm_posEnd];
end