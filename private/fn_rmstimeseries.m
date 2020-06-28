function vt_rms = fn_rmstimeseries(vt_signal,nm_window)
% vt_rms = fn_rmstimeseries(vt_signal,nm_window) computes the rms (vt_rms)
% timeseries of signal vt_signal using an sliding window of nm_window
% samples                    

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

%% 
nm_window   = round(nm_window);
if mod(nm_window, 2) == 0
    nm_window = nm_window + 1;
end

vt_signal	= vt_signal(:);
vt_cutId	= [nm_window + 1, numel(vt_signal)+nm_window];

vt_signal	= vertcat(...
            flipud(vt_signal(1:nm_window)),vt_signal,...
            flipud(vt_signal(end-nm_window+1:end)));
        
vt_signal   = vt_signal .* conj(vt_signal);

vt_signal   = filter(ones(1,nm_window),1,vt_signal)./nm_window;

vt_rms      = zeros(size(vt_signal));

vt_rms(1:end-ceil(nm_window/2)+1)	= sqrt(vt_signal(ceil(nm_window / 2):end));

vt_rms      = vt_rms(vt_cutId(1):vt_cutId(end));
