function st_sleep	= fn_sleep_architecture(st_hypno,vt_rems,nm_hNum)
% st_sleep	= fn_sleep_architecture(st_hypno,vt_rems,nm_hNum) computes the
% sleep architecture based on the structure st_hypno from pr_psgScore. For
% computing time in phasic and tonic REM, include the timestamps of
% detected eye movements. If st_hypno includes more than one hypnogram,
% then set nm_hNum as te index of the hypnogram and arousals to use.
%
% INPUT VARIABLES
% st_hypno: hypnogram structure:% 
% 	st_hypno.dat:       Hipnogram array (h x e), (h) hipnograms x (e) epochs ;
%	st_hypno.arousals:  Cell array with arousal timestamps;
% 	st_hypno.timeEpoch: Timestamp for epochs 1 x e;
% 	st_hypno.epoch:     Time in secods for each epoch     
% 
% vt_rems: rems timestamps for phasic and tonic rem. Leave empty otherwise
% nm_hNum: index position of hypnogram to use from st_hypno (deault: 1)
%
% OUTPUT STRUCTURE:
% st_sleep.recording:   Recording duration	
% st_sleep.duration:    Sleep duration (total sleep time + latency to sleep)
% st_sleep.efficiency:  (total sleep time) / (sleep duration)     
% st_sleep.totalTime:   Total sleep time
% st_sleep.awakenings:  Number of awekinings
% st_sleep.latency:     Sleep latency 
% 
% st_sleep.WASOTime:    Time awake after sleep onset 
% st_sleep.N1time:      Time in N1 
% st_sleep.N2time:      Time in N2
% st_sleep.N3time:      Time in N3
% st_sleep.REMtime:     Time in REM
% 
% st_sleep.WASOBlock:   Time intervals in WASO
% st_sleep.N1block:    	Time intervalse in N1 
% st_sleep.N2block:     Time intervalse in N2 
% st_sleep.N3block:     Time intervalse in N3 
% st_sleep.REMblock:    Time intervalse in REM 
% 
% st_sleep.arousalCount: Number of arousales 
% st_sleep.arousaltime : Time in arousales
% 
% st_sleep.REMphasic:   Time in phasic REM   
% st_sleep.REMtonic:    Time in tonic REM

% Copyright (C) <2020>  <Miguel Navarrete>
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

%% Code starts here
if nargin < 2
    vt_rems     = [];
end

if nargin < 3
    nm_hNum     = 1;
end

%% Set defaults
vt_stagesID   = [0 1 2 3 5];

% Get hypnogram data
vt_hypno	= st_hypno.dat(nm_hNum,:);
mx_arousals	= st_hypno.arousals{nm_hNum};
vt_hTime	= st_hypno.timeEpoch(:);
nm_hEpoch   = st_hypno.epoch;

%% Compute sleep values

% Set sleep interval
vt_cId 	=  vt_hypno == 0;
vt_diff	= diff([0,vt_cId,0]);
vt_sInt	= (find(vt_diff(:)==-1,1,'first')-1):...
            find(vt_diff(:)==1,1,'last')-1;

vt_sPeriod          = false(size(vt_hypno));
vt_sPeriod(vt_sInt) = true;

vt_stageTim	= nan(numel(vt_stagesID),1);
vt_stageBlk = cell(numel(vt_stagesID),1);

% Compute times in sleep
for ss = 1:numel(vt_stagesID)
    vt_cId	= vt_hypno == vt_stagesID(ss);
    vt_cId  = vt_cId .* vt_sPeriod;
    vt_diff	= diff([0,vt_cId,0]);
    mx_int  = [find(vt_diff(:)==1),find(vt_diff(:)==-1)-1];
        
    vt_stageTim(ss)	= nm_hEpoch * sum(vt_cId);
    vt_stageBlk{ss} = vt_hTime(mx_int);
end

nm_latency  = nm_hEpoch * (find(~vt_sPeriod == 0,1,'first')-1);
nm_dTime	= nm_hEpoch * sum(vt_sPeriod);
nm_sTime	= nm_dTime - vt_stageTim(vt_stagesID == 0);

% Compute arousal info
if ~isempty(mx_arousals)
    nm_arslCount	= size(mx_arousals,1);
    nm_arslTime     = sum(diff(mx_arousals,1,2));
else
    nm_arslCount	= 0;
    nm_arslTime     = 0;
end

% Compute REM info
if ~isempty(vt_rems)
    nm_REMstage = 5;
    vt_nStage	= find(vt_hypno == nm_REMstage);
    
    if vt_nStage(end) == numel(vt_hTime)
        nm_end = vt_nStage(end);
    else
        nm_end = vt_nStage(end) + 1;        
    end
    
    vt_remTime  = [vt_hTime(vt_nStage);vt_hTime(nm_end)];
    vt_remTime  = unique(vt_remTime);
    vt_eCounts	= histcounts(vt_rems,vt_remTime);
    
    vt_inPhasic = vt_eCounts > 0;
    vt_inTonic  = vt_eCounts == 0;
    
    nm_phasicTime	= nm_hEpoch * sum(vt_inPhasic);
    nm_tonicTime	= nm_hEpoch * sum(vt_inTonic);
    
else
    nm_phasicTime = nan;
    nm_tonicTime  = nan;
end
%% Save values
% All time in seconds
st_sleep.recording	= nm_hEpoch * numel(vt_hypno);
st_sleep.duration	= nm_dTime + nm_latency;
st_sleep.efficiency	= 100 * nm_sTime / (nm_dTime + nm_latency); % (Reed & Sacco, 2016)
st_sleep.totalTime	= nm_sTime;
st_sleep.period     = nm_dTime;
st_sleep.awakenings	= size(vt_stageBlk{vt_stagesID == 0},1);
st_sleep.latency	= nm_latency;

st_sleep.WASOTime	= vt_stageTim(vt_stagesID == 0);
st_sleep.N1time     = vt_stageTim(vt_stagesID == 1);
st_sleep.N2time     = vt_stageTim(vt_stagesID == 2);
st_sleep.N3time     = vt_stageTim(vt_stagesID == 3);
st_sleep.REMtime	= vt_stageTim(vt_stagesID == 5);

st_sleep.WASOBlock	= vt_stageBlk(vt_stagesID == 0);
st_sleep.N1block  	= vt_stageBlk(vt_stagesID == 1);
st_sleep.N2block    = vt_stageBlk(vt_stagesID == 2);
st_sleep.N3block    = vt_stageBlk(vt_stagesID == 3);
st_sleep.REMblock	= vt_stageBlk(vt_stagesID == 5);

st_sleep.arousalCount	= nm_arslCount;
st_sleep.arousaltime	= nm_arslTime;

st_sleep.REMphasic	= nm_phasicTime;
st_sleep.REMtonic	= nm_tonicTime;

