function ob_filter	= fn_designLowPassEEGfirfilter(nm_fSampling)
% ob_filter	= fn_designfirSOfilter(nm_fSampling) designs a optimal
% equiripple fir filter in the EEG frequency band [0.5,30] hz 
% with minimum order and phase distorsion

% Miguel Navarrete
% CUBRIC
% 2017

%% Define filter parameters 

nm_fNyquist	= nm_fSampling/2;
nm_fPassHi  = 30.0 / nm_fNyquist;
nm_fStopHi  = 30.5 / nm_fNyquist;
nm_dbPass   = 0.1;
nm_dbStopHi	= 40;

ob_filter	= fdesign.lowpass('Fp,Fst,Ap,Ast', ...
            nm_fPassHi,nm_fStopHi,...
            nm_dbPass,nm_dbStopHi);
        
ob_filter   = design(ob_filter,'equiripple');
