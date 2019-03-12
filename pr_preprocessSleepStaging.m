% pr_preprocessSleepStaging

%% Settings

ch_rootPath	= '/home/sapmn3/database/REM_stimulation/REM_pilot/rawFiles/Room1';
% vt_chName   = {'mgnmPilot_Room1_0001.eeg','mgnmPilot_Room1_0002.eeg',...
%             'mgnmPilot_Room1_0003.eeg','mgnmPilot_Room1_0004.eeg',...
%             'mgnmPilot_Room1_102_1.eeg'};
vt_chName   = {'mgnmPilot_Room1_0004.eeg',...
            'mgnmPilot_Room1_102_1.eeg'};



%% Process

for ff = 1:numel(vt_chName)
    ch_filename = fullfile(ch_rootPath,vt_chName{ff});
    fprintf('Selected file: %s\n',ch_filename)
    fn_preprocess_sleep_staging(ch_filename);
end
