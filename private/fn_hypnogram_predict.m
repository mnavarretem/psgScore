% fn_hypnogram_predict

%  psgScore is a graphical user interface (GUI) developed in MATLAB for
% scoring of human sleep.
% 
% psgScore is an extensive, flexible and open source sleep diagnostic 
% solution that simplifies the setup, review, analysis and reporting of 
% experimental sleep studies.
% 
% psgScore is Fieldtrip compatible and requires Fieldtrip toolbox for 
% reading files
% 
% psgScore implements different documented algorithms for sleep features 
% detection, it provides several tools for signal visualization and 
% manipulation, among which are found:
% 
% Channel(s) selection.
% Display of multiple signal at the same time.
% Several zoom and grid options (time, amplitude, etc.)
% Possibility to make time and amplitude measurements directly on the signals.
% Slow wave, spindle, eye movements, arousal detection.
% 
% 
%   Written by:
%   Miguel G. Navarrete Mejia, PhD
%   UNIVERSIDAD DE LOS ANDES
%   Colombia, 2021
%   mnavarretem@gmail.com
%   $Version: 0.5$ || $Date: 2021/11/13 10:30$
%   This file is part of the psgScore project.
%
%%     Copyright (C) 2020, Miguel Navarrete
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

%% Code starts here
function st_hyp = fn_hypnogram_predict(mx_features,st_hyp)
% st_hyp = fn_hypnogram_predict(mx_features,st_hyp) predicts two hypnograms 
% using two different classifiers 
%
%   INPUT:
%   mx_features	= features matrix for sleep stage classification
% 
%   OUTPUT:
%   st_hyp  = predicted hypnogram structure
% 
%% GNU licence,
% Copyright (C) <2020>  <Miguel Navarrete>
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

%% Load classifiers
fprintf('Loading predictors: ')
tic
st_mdl.tree	= load('ob_hypno_RF.mat');
st_mdl.svm	= load('ob_hypno_SVM.mat');
st_mdl.tree	= st_mdl.tree.ob_mdTree;
st_mdl.svm	= st_mdl.svm.ob_mdSVM;
toc

%% Estimate hypnograms
fprintf(' - Estimate by RF: ')
tic     
vt_hTree	= predict(st_mdl.tree,mx_features);
toc

fprintf(' - Estimate by SVM: ')
tic
vt_hSVM     = predict(st_mdl.svm,mx_features);
toc

%% Save predictions
mx_hypPred	= int8([vt_hTree(:),vt_hSVM(:)]');
vt_arousal  = cell(size(mx_hypPred,1),1);

st_hyp.dat          = vertcat(st_hyp.dat,mx_hypPred);
st_hyp.arousals     = vertcat(st_hyp.arousals(:),vt_arousal);
        