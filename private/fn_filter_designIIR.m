% Function: fn_filter_designIIR.m
% 
% Description:
% fn_filter_designIIR designs a Chebyshev Type II filter using second order
% sections for stability. 
% 
% Use as: 
% ob_filter  = fn_filter_designIIR(nm_fs,vt_pFreq,vt_sFreq,vt_gain) 
%
% Input Parameters:
% 
%  - nm_fs:     Sampling rate 
%  - vt_pFreq :	Band-pass frequencies
%  - vt_sFreq :	Band-stop frequencies
%  - vt_gain :  1 x 2 vector indicating gain for band-pass and band-stop
%               frequencies;
%
% Output Parameters:
%
%  - ob_filter:	Filter object describing filter desing
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

function ob_filter  = fn_filter_designIIR(nm_fs, vt_pFreq, vt_sFreq, vt_gain)

if nargin < 3 || isempty(nm_fs)
    error('[fn_filter_designIIR] - ERROR: bad parameters!')
end

if nargin < 4 
    nm_aPass = 1;
    nm_aStop = 100;
else
    if isempty(vt_gain) || numel(vt_gain) ~=2
        error('[fn_filter_designIIR] - ERROR: bad vt_gain parameters!')
    end
    nm_aPass = vt_gain(1);
    nm_aStop = vt_gain(2);
    clear vt_gain
end

if isempty(vt_pFreq) || numel(vt_pFreq) > 2
    error('[fn_filter_designIIR] - ERROR: bad CutFreq parameters!')
end

if isempty(vt_sFreq) || numel(vt_sFreq) > 2
    error('[fn_filter_designIIR] - ERROR: bad StopFreq parameters!')
end

if numel(vt_pFreq) ~= numel(vt_sFreq)
    error('[fn_filter_designIIR] - ERROR: numel CutFreqs and StopFreq mismatch!')
end

if numel(vt_pFreq) > 2
    error('[fn_filter_designIIR] - ERROR: bad CutFreq parameters!')
end

switch numel(vt_pFreq)
    case 1
        if vt_pFreq > vt_sFreq
            ch_Type    = 'Highpass';
        else
            ch_Type    = 'Lowpass';
        end
    case 2
        if vt_pFreq(1) > vt_sFreq(1) && ...
                vt_pFreq(2) < vt_sFreq(2)
            ch_Type    = 'Bandpass';
        elseif  vt_pFreq(1) < vt_sFreq(1) && ...
                vt_pFreq(2) > vt_sFreq(2)
            ch_Type    = 'Bandstop';
        else
            error('[fn_filter_designIIR] - ERROR: Frequencies mistmatch!')            
        end               
end

vt_wp    = vt_pFreq ./ (nm_fs/2);
vt_ws    = vt_sFreq ./ (nm_fs/2);
                    
if  numel(vt_wp) == 2
   if vt_wp(end) >= 1 
        
    ch_Type    = 'Highpass';
    vt_wp        = vt_wp(1);
    vt_ws        = vt_ws(1);
    
   elseif vt_wp(1) <= 0
        
    ch_Type    = 'Lowpass';
    vt_wp        = vt_wp(2);
    vt_ws        = vt_ws(2);
       
   end 
end
switch ch_Type
    case 'Highpass'                        
        ch_filTyp	= 'high';
    case 'Lowpass'                        
        ch_filTyp	= 'low';
    case 'Bandpass'                        
        ch_filTyp	= [];
    case 'Bandstop'                            
        ch_filTyp	= 'stop';  
end

try 
    ch_sigPath = toolboxdir('signal');
    
    [nm_Order,vt_wst]    = cheb2ord(vt_wp,vt_ws,nm_aPass,nm_aStop);

    if isempty(ch_filTyp)
        [vt_z, vt_p, nm_k] = cheby2(nm_Order, nm_aStop, vt_wst);
    else
        [vt_z, vt_p, nm_k] = cheby2(nm_Order, nm_aStop, vt_wst, ch_filTyp);
    end
        
    [vt_sos, nm_g]    = zp2sos(vt_z, vt_p, nm_k);
    ob_filter       = dfilt.df2sos(vt_sos, nm_g);
        
catch
    if isempty(ch_filTyp)                     
        ch_filTyp	= 'pass'; 
    end
    
    [nm_Order,vt_wst]   = fb_cheb2ord(vt_wp,vt_ws,nm_aPass,nm_aStop);
    [vt_z, vt_p, nm_k]  = fb_cheby2(nm_Order, nm_aStop, vt_wst, ch_filTyp);
    vt_sos              = fn_zp2sos(vt_z, vt_p, nm_k);
    
    ob_filter           = struct('SOS',vt_sos,'G',nm_k);
    
end

