% Function: fn_gaborwavelet.m
%
% Description:
% This function calculates the Wavelet Transform using a Gaussian modulated
% window (Gabor Wavelet).
% The Sample Rate of the input signal is considered in order to compute
% the transform.
%
% Parameters:
% vt_signal(*): Signal to process
% nm_sampleRate(*): Sample rate
% nm_minFreqHz: Min frequency (in Hz) to process from
% nm_maxFreqHz: Max frequency (in Hz) to process to
% nm_freqSeg: Number of segments used to calculate the size of the
% resulting matrix in the frequency direction
%
% nm_stDevCycles: In the wavelet transform, the scale corresponding to each
% frequency (in vt_freqAxis) defines the value (in seconds) of the
% gaussian's standard deviation used for the calculation of the transform
% at every one of these frequencies. This standard deviation value must be
% big enough to cover at least one or more complete cycles (or periods) of
% the oscillation at each considered frequency. Thus, this parameter
% defines the number of cycles you want to include for the transform at
% every frequency.
%
% nm_magnitudes: Set to 1 (default) if the magnitudes of the coefficients
% must be returned; 0 for analytic values (complex values).
%
% nm_squaredMag: Set to 1 if the magnitudes of the coefficients divided by
% the squared of the corresponding scale must by power to 2
%
% nm_makeBandAve: Set to 1 if instead of returning a matrix with all values
% in the time-frequency map, the function returns just a vector with the
% average along all the frequency scales for each time moment.
%
% nm_phases: Set to 1 if the phases of the coefficients
% must be returned; 0 for analytic values (complex values).
%
% nm_timeStep: Time step between values that are going to be kept in the
% output matrix. Each time moment is the average of the previous values
% according to the size of the window defined by this parameter.
%
% (*) Required parameters
%
% Outputs:
% mx_gaborWT: Matrix containing the scalogram. Time in rows, frequency in
% colums. Frequencies in descending order
% vt_timeAxis: Array containing the time axis values (second units)
% vt_freqAxis: Array containing the frequency axis values in descending
% order (Hz units)
%
% Author: Mario Valderrama
%
function [mx_gaborWT, vt_timeAxis, vt_freqAxis] = ...
    fn_gaborwavelet(...
    vt_signal, ...
    nm_sampleRate, ...
    vt_freqAxis, ...
    nm_stDevCycles, ...
    nm_magnitudes, ...
    nm_squaredMag, ...
    nm_makeBandAve, ...
    nm_phases, ...
    nm_timeStep)

if nargin < 2
    return;
end

if ~exist('vt_freqAxis', 'var') || isempty(vt_freqAxis)
    vt_freqAxis	= 0.1:nm_sampleRate / 2;
else
    if vt_freqAxis(1) <= 0
        vt_freqAxis	= vt_freqAxis(vt_freqAxis>0);
    end
    if vt_freqAxis(1) > nm_sampleRate / 2
        vt_freqAxis = vt_freqAxis(vt_freqAxis<=nm_sampleRate / 2);
    end
    if isempty(vt_freqAxis)
        vt_freqAxis = 0.1:nm_sampleRate / 2;
    end
end

if ~exist('nm_stDevCycles', 'var') || isempty(nm_stDevCycles)
    nm_stDevCycles	= 3;
end

if ~exist('nm_magnitudes', 'var') || isempty(nm_magnitudes)
    nm_magnitudes	= 1;
end

if ~exist('nm_squaredMag', 'var') || isempty(nm_squaredMag)
    nm_squaredMag   = 0;
end

if ~exist('nm_makeBandAve', 'var') || isempty(nm_makeBandAve)
    nm_makeBandAve  = 0;
end

if ~exist('nm_phases', 'var') || isempty(nm_phases)
    nm_phases       = 0;
end

if ~exist('nm_timeStep', 'var')
    nm_timeStep     = [];
end


vt_signal   = vt_signal(:);
vt_freqAxis	= vt_freqAxis(:)';
vt_freqAxis = sort(vt_freqAxis,'descend'); %#ok<UDIM>

if mod(numel(vt_signal), 2) == 0
    vt_signal = vt_signal(1:end - 1);
end

vt_timeAxis	= (0:numel(vt_signal) - 1)./ nm_sampleRate;
nm_len      = numel(vt_timeAxis);
nm_halfLen  = floor(nm_len / 2) + 1;

vt_wAxis    = (2.* pi./ nm_len).* (0:(nm_len - 1));
vt_wAxis    = vt_wAxis.* nm_sampleRate;
vt_wAxisHalf= vt_wAxis(1:nm_halfLen);

if isempty(nm_timeStep)
    nm_sampAve	= 1;
else
    nm_sampAve  = round(nm_timeStep * nm_sampleRate);
    if nm_sampAve < 1
        nm_sampAve	= 1;
    end
end

vt_sampAveFilt	= [];
if nm_sampAve > 1
    vt_indSamp  = 1:nm_sampAve:numel(vt_timeAxis);
    vt_timeAxis = vt_timeAxis(vt_indSamp);
    vt_sampAveFilt = ones(nm_sampAve, 1);
end

vt_inputSignalFFT	= fft(vt_signal, numel(vt_signal));

clear mx_gaborWT
mx_gaborWT	= zeros(numel(vt_freqAxis), numel(vt_timeAxis));
nm_freqInd  = 0;

for nm_freqCounter = vt_freqAxis
    
    nm_stDevSec	= (1 / nm_freqCounter) * nm_stDevCycles;
    
    clear vt_winFFT
    vt_winFFT	= zeros(nm_len, 1);
    vt_winFFT(1:nm_halfLen)	= exp(-0.5.* realpow(vt_wAxisHalf - ...
                            (2.* pi.* nm_freqCounter), 2).* ...
                            (nm_stDevSec.^ 2));
    vt_winFFT	= 2 * vt_winFFT;
    
    
    nm_freqInd	= nm_freqInd + 1;
    
    if nm_sampAve > 1
        clear vt_gFreq
        vt_gFreq	= zeros(numel(vt_inputSignalFFT) + (nm_sampAve - 1), 1);
        vt_gFreq(nm_sampAve:end)	=  ifft(vt_inputSignalFFT.* vt_winFFT);
        
        if nm_magnitudes
            vt_gFreq	= abs(vt_gFreq);
        end
        
        if nm_squaredMag
            vt_gFreq	= vt_gFreq.^2;
        end
        
        vt_gFreq(1:(nm_sampAve - 1))= flipud(vt_gFreq(...
                                    nm_sampAve + 1:2 * nm_sampAve - 1));
                                
        vt_gFreq	= filter(vt_sampAveFilt, 1, vt_gFreq)./ nm_sampAve;
        vt_gFreq	= vt_gFreq(nm_sampAve:end);
        
        mx_gaborWT(nm_freqInd, :)	= vt_gFreq(vt_indSamp);
    else
        
        mx_gaborWT(nm_freqInd, :)	= ifft(vt_inputSignalFFT.* vt_winFFT);
        
    end
end
clear vt_winFFT vt_gFreq vt_sampAveFilt

if nm_sampAve > 1
    return;
end

if nm_phases
    mx_gaborWT	= angle(mx_gaborWT);
    return;
end

if nm_magnitudes ~= 1
    return;
end

mx_gaborWT	= abs(mx_gaborWT);

if nm_squaredMag
    mx_gaborWT	= mx_gaborWT.^2;
end

if nm_makeBandAve
    mx_gaborWT	= mean(mx_gaborWT, 2);
    mx_gaborWT	= flipud(mx_gaborWT);
    vt_timeAxis	= [];
    vt_freqAxis	= fliplr(vt_freqAxis);
end

end

