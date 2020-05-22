% fn_hypnogram_predict

function st_hyp = fn_hypnogram_predict(mx_dat,st_hyp)

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
vt_hTree	= predict(st_mdl.tree,mx_dat);
toc

fprintf(' - Estimate by SVM: ')
tic
vt_hSVM     = predict(st_mdl.svm,mx_dat);
toc

%% Save predictions

mx_hypPred	= int8([vt_hTree(:),vt_hSVM(:)]');
vt_arousal  = cell(size(mx_hypPred,1),1);

st_hyp.dat          = vertcat(st_hyp.dat,mx_hypPred);
st_hyp.arousals     = vertcat(st_hyp.arousals,vt_arousal);
    
    