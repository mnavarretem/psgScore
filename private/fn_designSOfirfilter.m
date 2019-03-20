function ob_filter	= fn_designSOfirfilter(nm_fSampling)
% ob_filter	= fn_designSOfirfilter(nm_fSampling) designs a optimal
% equiripple fir filter in the sleep slow oscillation frequency band [0.5,3] hz 
% with minimum order and phase distorsion
%% Define filter parameters 

nm_fNyquist	= nm_fSampling/2;
nm_fStopLo  = 0.1 / nm_fNyquist;
nm_fPassLo  = 0.3 / nm_fNyquist;
nm_fPassHi  = 3.0 / nm_fNyquist;
nm_fStopHi  = 3.5 / nm_fNyquist;
nm_dbPass   = 0.1;
nm_dbStopLo	= 40;
nm_dbStopHi	= 40;

ob_filter	= fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2', ...
            nm_fStopLo,nm_fPassLo,nm_fPassHi,nm_fStopHi,...
            nm_dbStopLo,nm_dbPass,nm_dbStopHi);
        
ob_filter   = design(ob_filter,'equiripple');
