function mx_features	= fn_hypnogram_prepare(st_cfg)
% mx_features	= fn_hypnogram_prepare(st_cfg) prepares hypnogram features 
% to use in sleep stage classification
%
%   INPUT:
% 	st_cfg.chRead	= eeg labels to evaluate;
% 	st_cfg.chIdx	= index of eeg labels;
% 	st_cfg.patterns = patterns structure 
% 	st_cfg.spectrum = spectrum structure 
%
%   OUTPUT
%   mx_features     = features matrix for sleep stage classification
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

%% Code starts here
mx_eegLabel	= st_cfg.chRead;
mx_idCh     = st_cfg.chIdx;
st_patterns	= st_cfg.patterns;
st_spectrum	= st_cfg.spectrum;

clear st_cfg

%% Select file and stim condition
fprintf('    Summarizing data: ')
tic

% Set spectrum
vt_timeEpoch        = 30*(0:(length(st_patterns.EM)-1));
st_hypno.timeEpoch  = vt_timeEpoch(1:end-1);
mx_chSpectrum       = cell(numel(st_spectrum.labels),...
                    numel(st_hypno.timeEpoch));


for tt = 1:numel(vt_timeEpoch)
    nm_beg	= vt_timeEpoch(tt);
    nm_end	= vt_timeEpoch(tt)+30;
    
    vt_id	= st_spectrum.time >= nm_beg & ...
        st_spectrum.time <= nm_end;
    
    vt_section	= cellfun(@(x) x(:,vt_id),st_spectrum.data,...
        'UniformOutput',false);
    vt_section	= cellfun(@(x) mean(x,2),vt_section,...
        'UniformOutput',false);
    
    mx_chSpectrum(:,tt) = vt_section;
end

mx_var	= nan(size(mx_eegLabel));
mx_tf	= cell(size(mx_eegLabel));
mx_idCH = nan(size(mx_eegLabel));

for cc = 1:numel(mx_eegLabel)
    % Solve for spectrum
    if ~mx_idCh(cc)
        mx_var(cc)	= inf;
        continue
    end
    
    vt_idCH	= ismember(st_spectrum.labels,mx_eegLabel(cc));
    vt_tfCH = cell2mat(mx_chSpectrum(vt_idCH,:));
    vt_sdCH = std(vt_tfCH,[],2);
    
    mx_idCH(cc) = find(vt_idCH);
    mx_var(cc) = mean(vt_sdCH);
    mx_tf(cc)  = {vt_tfCH};
    
end

% Select features
[~,vt_id]	= min(mx_var,[],2);
vt_id       = sub2ind(size(mx_var),1:3,vt_id');
vt_idCh     = mx_idCH(vt_id);

vt_tf	= mx_tf(vt_id);
vt_tf   = vt_tf(:);

    
vt_tf_nrm	= cellfun(@(x) mean(x,2),vt_tf,'UniformOutput',false);
vt_tf_nrm	= cellfun(@(x) repmat(x,1,numel(vt_timeEpoch)),vt_tf_nrm,...
            'UniformOutput',false);
vt_tf_nrm	= cellfun(@(x,y) x./y,vt_tf,vt_tf_nrm,'UniformOutput',false);

% Solve for patterns
vt_delta    = st_patterns.delta(vt_idCh);
vt_theta    = st_patterns.theta(vt_idCh);
vt_alpha	= st_patterns.alpha(vt_idCh);
vt_mu       = st_patterns.mu(vt_idCh);
vt_beta     = st_patterns.beta(vt_idCh);


vt_delta_nrm	= cellfun(@(x) x./mean(x,'omitnan'),vt_delta,...
                'UniformOutput',false);
vt_theta_nrm    = cellfun(@(x) x./mean(x,'omitnan'),vt_theta,...
                'UniformOutput',false);
vt_alpha_nrm	= cellfun(@(x) x./mean(x,'omitnan'),vt_alpha,...
                'UniformOutput',false);
vt_mu_nrm       = cellfun(@(x) x./mean(x,'omitnan'),vt_mu,...
                'UniformOutput',false);
vt_beta_nrm     = cellfun(@(x) x./mean(x,'omitnan'),vt_beta,...
                'UniformOutput',false);
                
vt_EM       = {single(st_patterns.EM) + rand(2,numel(vt_timeEpoch))/100};
vt_EMG      = {st_patterns.rmsEMG(1,:) + rand(1,numel(vt_timeEpoch))/100};

vt_soRate	= st_patterns.soRate(vt_idCh); 
vt_soRate   = cellfun(@(x) x + rand(1,numel(st_hypno.timeEpoch))/100,...
            vt_soRate,'UniformOutput',false);

vt_spRate	= st_patterns.spRate(vt_idCh); 
vt_spRate   = cellfun(@(x) x + rand(1,numel(st_hypno.timeEpoch))/100,...
            vt_spRate,'UniformOutput',false);

mx_featCurr	= horzcat(vt_tf_nrm,...
            vt_delta_nrm,vt_theta_nrm,vt_alpha_nrm,vt_mu_nrm,vt_beta_nrm,...
            vt_soRate,vt_spRate);
            
mx_featCurr	= mx_featCurr';
mx_featCurr = [mx_featCurr(:);vt_EM;vt_EMG];

nm_epochNum	= min(cellfun(@(x) size(x,2),mx_featCurr));
mx_featCurr = cellfun(@(x) single(x(:,1:nm_epochNum)),mx_featCurr,...
            'UniformOutput',false);
mx_featCurr	= cell2mat(mx_featCurr);
mx_featNext = [mx_featCurr(:,2:end),mx_featCurr(:,end)];

mx_features = vertcat(mx_featCurr,mx_featNext)';
