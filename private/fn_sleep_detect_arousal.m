function [mx_eventSample] = fn_sleep_detect_arousal(mx_tf,st_cnf)
% [mx_eventLims,vt_centFreq,vt_eeg] = fn_sleep_detect_arousal(vt_eeg,st_cnf) 
% detect all sleep arousals from eeg Time-Freq mx_tf depending on the 
% settings in the structure st_cnf. 
%
% mx_eventLims corresponds to a matrix indicating the locations (in
% samples) of each detected SO. st_cnf corresponds to a structure with the
% fields:
%
%   - st_cnf.freqband:	1 x 2 vector indicating the frequency band limits
%                       for arousal detection, (default = [4 35])
%   
%   - st_cnf.tEEG:      time vector for original eeg samples
%   - st_cnf.time:      time vector for mx_tf

%   - st_cnf.freq:      frequency vector for mx_tf
%   
%   - st_cnf.mintime:	Minimum number time duration in seconds
%   
%   - st_cnf.timeFreq:	Time-frequency correction (default = true)
%
%   - st_cnf.threshold:	percentil threshold for arousal detection (SD)
%                       default = 1.5 SD
%                           

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

if any(size(mx_tf)==1)
    error('fn_sleep_detect_arousal:signalIsNotVector','Input must be a vector;'); 
end

if nargin < 2   % if not input arguments, then use arguments by default    
	st_cnf  = struct;
end

% Check whether st_cnf fileds are empty
if ~isfield(st_cnf,'freqband') 
    st_cnf.freqband     = [3 35];
end

if ~isfield(st_cnf,'mintime')
    st_cnf.mintime	= 2.5;
end

if ~isfield(st_cnf,'threshold')
    st_cnf.threshold	= 1.5;
end

%%	- Detect putative arousals

vt_idFreq	= st_cnf.freq >= st_cnf.freqband(1) & ...
            st_cnf.freq <= st_cnf.freqband(2);

% Determine freq variability
vt_data     = mean(mx_tf(vt_idFreq,:));
vt_hiPos	= findextrema(vt_data);
vt_hiVal    = vt_data(vt_hiPos);
nm_thres	= prctile(vt_hiVal,100*erf(st_cnf.threshold/sqrt(2)));

vt_overThreshold	= vt_data(:) > nm_thres;
vt_overThreshold	= diff(vertcat(0,vt_overThreshold,0));
mx_eventDetect      = [find(vt_overThreshold == 1),...
                    find(vt_overThreshold == -1)-1];
                
mx_eventBorder	= st_cnf.time(mx_eventDetect);

%% - Select arousals

vt_timeEvents   = diff(mx_eventBorder,1,2);
vt_idEvents     = vt_timeEvents >= st_cnf.mintime ;

mx_eventBorder  = mx_eventBorder(vt_idEvents,:);
mx_eventSample  = nan(size(mx_eventBorder));

for kk = 1:size(mx_eventSample,1)
    [~,nm_posBeg]  = min(abs(mx_eventBorder(kk,1)-st_cnf.tEEG));
    [~,nm_posEnd]  = min(abs(mx_eventBorder(kk,2)-st_cnf.tEEG));
    
    mx_eventSample(kk,:) = [nm_posBeg,nm_posEnd];
end