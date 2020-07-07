% Function: fn_sleep_eventdensity.m
% 
% Description:
% Computes the event density from events timestamps based on sleep stages
% selected by the user 
% 
% Use as: 
% [nm_density,nm_counts]	= fn_sleep_eventdensity(...
%                           vt_tevents,st_hypno,vt_stage,nm_hNum)  
%
% Input Parameters:
% 
%   vt_tevents:   Events timestamps
%   st_hypno:     hypnogram structure:% 
%       st_hypno.dat:       Hipnogram array (h x e), 
%                           (h) hipnograms x (e) epochs ;
%       st_hypno.arousals:  Cell array with arousal timestamps;
%       st_hypno.timeEpoch: Timestamp for epochs 1 x e;
%       st_hypno.epoch:     Time in secods for each epoch 

%   vt_stage:	Sleep stages to consider [0: wake, 1: n1, 2: n2, 3: n3,
%               5: REM]   
% 
%   nm_hNum:	Index position of hypnogram to use from st_hypno (deault: 1)
%
% Output Parameters:
%
% 	nm_density:	Event density (events/min)
% 	nm_counts:	Event counts 
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

function [nm_density,nm_counts]	= fn_sleep_eventdensity(...
                                vt_tevents,st_hypno,vt_stage,nm_hNum)

%% Code starts here     
        
if nargin < 3
    vt_stage	= [];
end             

if nargin < 4
    nm_hNum	= 1;
end             
% Get hypnogram data
vt_hypno	= st_hypno.dat(nm_hNum,:);
vt_hTime	= st_hypno.timeEpoch(:);
nm_hEpoch   = st_hypno.epoch;


vt_nStage	= ~ismember(vt_hypno,vt_stage);
vt_eCounts	= histcounts(vt_tevents,vt_hTime);
vt_nStage   = vt_nStage(1:numel(vt_eCounts));
vt_eCounts(vt_nStage) = [];

nm_counts   = sum(vt_eCounts); 
nm_density	= mean(vt_eCounts);
nm_density	= nm_density * (60 / nm_hEpoch);
