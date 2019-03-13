% fn_designIIRfilter.m
%
%     Copyright (C) 2015, Miguel Navarrete
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.

function st_filter  = fn_designIIRfilter(nm_sampleRate,vt_passFreqs,...
                    vt_stopFreqs,vt_gainVals)

if nargin < 3 || isempty(nm_sampleRate)
    error('[f_DesignIIRfilter] - ERROR: bad parameters!')
end

if nargin < 4 
    nm_aPass = 1;
    nm_aStop = 50;
else
    if isempty(vt_gainVals) || numel(vt_gainVals) ~=2
        error('[f_DesignIIRfilter] - ERROR: bad vt_gainVals parameters!')
    end
    nm_aPass = vt_gainVals(1);
    nm_aStop = vt_gainVals(2);
    clear vt_gainVals
end

if isempty(vt_passFreqs) || numel(vt_passFreqs) > 2
    error('[f_DesignIIRfilter] - ERROR: bad CutFreq parameters!')
end

if isempty(vt_stopFreqs) || numel(vt_stopFreqs) > 2
    error('[f_DesignIIRfilter] - ERROR: bad StopFreq parameters!')
end

if numel(vt_passFreqs) ~= numel(vt_stopFreqs)
    error('[f_DesignIIRfilter] - ERROR: numel CutFreqs and StopFreq mismatch!')
end

if numel(vt_passFreqs) > 2
    error('[f_DesignIIRfilter] - ERROR: bad CutFreq parameters!')
end

switch numel(vt_passFreqs)
    case 1
        if vt_passFreqs > vt_stopFreqs
            ch_Type    = 'Highpass';
        else
            ch_Type    = 'Lowpass';
        end
    case 2
        if vt_passFreqs(1) > vt_stopFreqs(1) && ...
                vt_passFreqs(2) < vt_stopFreqs(2)
            ch_Type    = 'Bandpass';
        elseif  vt_passFreqs(1) < vt_stopFreqs(1) && ...
                vt_passFreqs(2) > vt_stopFreqs(2)
            ch_Type    = 'Bandstop';
        else
            error('[f_DesignIIRfilter] - ERROR: Frequencies mistmatch!')            
        end               
end

vt_wp    = vt_passFreqs ./ (nm_sampleRate/2);
vt_ws    = vt_stopFreqs ./ (nm_sampleRate/2);
                    
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
    st_filter       = dfilt.df2sos(vt_sos, nm_g);
        
catch
    if isempty(ch_filTyp)                     
        ch_filTyp	= 'pass'; 
    end
    
    [nm_Order,vt_wst]   = fb_cheb2ord(vt_wp,vt_ws,nm_aPass,nm_aStop);
    [vt_z, vt_p, nm_k]  = fb_cheby2(nm_Order, nm_aStop, vt_wst, ch_filTyp);
    vt_sos              = old_zp2sos(vt_z, vt_p, nm_k);
    
    st_filter           = struct('SOS',vt_sos,'G',nm_k);
    
end

