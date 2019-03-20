function ob_filter	= fn_designSpindlefirfilter(nm_fSampling,ch_spindleType,vt_freq)
% ob_filter	= fn_designSOfirfilter(nm_fSampling,ch_spindleType) designs a optimal
% equiripple fir filter in the sleep spindle frequency band [0.5,3] hz 
% determined by ch_spindleType ('all','slow','fast') with minimum order 
% and phase distorsion

% Miguel Navarrete
% CUBRIC
% 2017

%% Define filter parameters 

if nargin < 2
    ch_spindleType	= 'all'; 
end

nm_fNyquist	= nm_fSampling/2;
nm_dbPass   = 0.1;
nm_dbStopLo	= 40;
nm_dbStopHi	= 40;

switch lower(ch_spindleType)
    case 'all'        
        nm_fStopLo  = 8 / nm_fNyquist;
        nm_fPassLo  = 9 / nm_fNyquist;
        nm_fPassHi  = 16 / nm_fNyquist;
        nm_fStopHi  = 17 / nm_fNyquist;
    case 'slow'        
        nm_fStopLo  = 8 / nm_fNyquist;
        nm_fPassLo  = 9 / nm_fNyquist;
        nm_fPassHi  = 12 / nm_fNyquist;
        nm_fStopHi  = 13 / nm_fNyquist;
    case 'fast'
        nm_fStopLo  = 11 / nm_fNyquist;
        nm_fPassLo  = 12 / nm_fNyquist;
        nm_fPassHi  = 16 / nm_fNyquist;
        nm_fStopHi  = 17 / nm_fNyquist;
    case 'custom'        
        nm_fPassLo  = vt_freq(1) / nm_fNyquist;
        nm_fPassHi  = vt_freq(2) / nm_fNyquist;
        nm_fStopLo  = (vt_freq(1)-1) / nm_fNyquist;
        nm_fStopHi  = (vt_freq(2)+1) / nm_fNyquist;
    otherwise
        error('[fn_designSpindlefirfilter] - Wrong spindle type')
end

ob_filter	= fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2', ...
            nm_fStopLo,nm_fPassLo,nm_fPassHi,nm_fStopHi,...
            nm_dbStopLo,nm_dbPass,nm_dbStopHi);
        
ob_filter   = design(ob_filter,'equiripple');
