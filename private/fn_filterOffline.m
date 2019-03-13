function vt_filtSignal  = fn_filterOffline(vt_signal,ob_filter,nm_backForw)
% vt_filtSignal  = fn_filterOffline(vt_signal,ob_filter,nm_backForw) applies a
% digital IIR/FIR filter ob_filter to a vector signal vt_signal. The
% logical flag nm_backForw indicates whether the filter is applied with 
% backwards-forward filtering (default: true)

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
    vt_filtSignal   = f_SOSfilt(ob_filter,vt_signal);
else
    vt_filtSignal   = filter(ob_filter,vt_signal);
end

if nm_backForw
    
    if isstruct(ob_filter)
        vt_filtSignal   = f_SOSfilt(ob_filter,flipud(vt_filtSignal));
    else
        vt_filtSignal = filter(ob_filter, flipud(vt_filtSignal));
    end

    vt_filtSignal = flipud(vt_filtSignal);
end
