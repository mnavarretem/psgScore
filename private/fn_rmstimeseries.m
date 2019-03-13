function vt_rms = fn_rmstimeseries(vt_signal,nm_window)
% vt_rms = fn_rmstimeseries(vt_signal,nm_window) computes the rms (vt_rms)
% timeseries of signal vt_signal using an sliding window of nm_window
% samples

% Miguel Navarrete
% CUBRIC
% 2017
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
