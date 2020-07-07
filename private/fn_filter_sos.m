function v_SigFilt  = fn_filter_sos(pst_Filter,pv_Signal)
% v_SigFilt  = fn_filter_sos(pst_Filter,pv_Signal) filters signal using 
% a secod order section filter when no signal processing toolbox is 
% installed
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


s_Scale                 = double(pst_Filter.G);
pst_Filter              = double(pst_Filter.SOS);
[s_SecNum,s_CoefNum]	= size(pst_Filter);

if s_CoefNum ~= 6
    error('[ERROR - fn_filter_sos] - Filter Matrix is not SOS')
end
v_SigFilt	= double(pv_Signal);

for kk = 1:s_SecNum
    v_bCoef	= pst_Filter(kk,1:3);
    v_aCoef	= pst_Filter(kk,4:6);
    
    v_SigFilt   = filter(v_bCoef,v_aCoef,v_SigFilt);
end

% v_SigFilt	= v_SigFilt.*s_Scale;