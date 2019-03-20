function ob_filter	= fn_designDCfirfilter(nm_fSampling)
% ob_filter	= fn_designfirSOfilter(nm_fSampling) designs a optimal
% equiripple fir filter in the EEG frequency band [0.5,30] hz 
% with minimum order and phase distorsion

% Miguel Navarrete
% CUBRIC
% 2017

%% Define filter parameters 

nm_fNyquist	= nm_fSampling/2;
nm_fStopLo  = 0.1 / nm_fNyquist;
nm_fPassLo  = 0.5 / nm_fNyquist;
nm_dbPass   = 0.1;
nm_dbStopLo	= 40;

ob_filter	= fdesign.highpass('Fst,Fp,Ast,Ap', ...
            nm_fStopLo,nm_fPassLo,...
            nm_dbStopLo,nm_dbPass);
        
ob_filter   = design(ob_filter,'equiripple');
