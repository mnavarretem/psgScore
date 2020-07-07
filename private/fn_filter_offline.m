% Function: fn_filter_offline.m
% 
% Description:
% Applies a digital IIR/FIR filter ob_filter to a vector signal vt_signal. 
% The logical flag nm_backForw indicates whether the filter is applied with 
% backwards-forward filtering (default: true)
% 
% Use as: 
% vt_fSignal  = fn_filter_offline(vt_signal,ob_filter,nm_backForw)  
%
% Input Parameters:
% 
%  - vt_signal:     Data to filter (as a vector or vt_signal(:))
%  - ob_filter:     Filter object
%  - nm_backForw:	Backwards-forward filtering (default: true)
%
% Output Parameters:
%
%  - vt_fSignal:	Filtered data
% 
% This function requires the signal processing toolbox 
%
% Copyright (C) <2015>  <Miguel Navarrete>
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

function vt_fSignal  = fn_filter_offline(vt_signal,ob_filter,nm_backForw)

if nargin < 2
    error('[fn_filterOffline] - ERROR: wrong number of input parameters!')
end

if nargin < 3 || isempty(nm_backForw)
    nm_backForw   = true;
end

if size(vt_signal, 1) == 1
    vt_signal = vt_signal(:);
end

if isstruct(ob_filter)
    vt_fSignal   = fn_filter_sos(ob_filter,vt_signal);
else
    vt_fSignal   = filter(ob_filter,vt_signal);
end

if nm_backForw
    
    if isstruct(ob_filter)
        vt_fSignal	= fn_filter_sos(ob_filter,flipud(vt_fSignal));
    else
        vt_fSignal	= filter(ob_filter, flipud(vt_fSignal));
    end

    vt_fSignal = flipud(vt_fSignal);
end
