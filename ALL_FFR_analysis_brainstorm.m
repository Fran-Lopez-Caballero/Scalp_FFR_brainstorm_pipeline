%% (OPTIONAL) Run in server mode: Set Brainstorm nogui on completely headless mode (FFR_Sz) 
% Set a window in 99 first, then run this section and run scripts normally 
% (it won't break despite bad remote connection this way -16/03/2020-)

% Set up the Brainstorm files
clear
addpath('~/matlab/brainstorm3_v20220706'); 
BrainstormDbDir = '~/brainstorm_db';
% Start Brainstorm
if ~brainstorm('status')
    brainstorm server
end
bst_set('BrainstormDbDir',BrainstormDbDir)
% Select the correct protocol
ProtocolName = 'FFR_Sz'; % Enter the name of your protocol
sProtocol.Comment = ProtocolName;
sProtocol.SUBJECTS = '~/brainstorm_db/FFR_Sz/anat';
sProtocol.STUDIES = '~/brainstorm_db/FFR_Sz/data';
db_edit_protocol('load',sProtocol);
% Get the protocol index
iProtocol = bst_get('Protocol', ProtocolName);
if isempty(iProtocol)
    error(['Unknown protocol: ' ProtocolName]);
end
% Select the current procotol
gui_brainstorm('SetCurrentProtocol', iProtocol);

%% Define variables FFR_Sz

% Directories for server in local computer
running_in = 'local'; % 'server' 'local'

% Define paths
path_list_cell = regexp(path,pathsep,'Split'); % To avoid adding paths if they are there already
if strcmp(running_in,'server')
    root_dir = '/private/path/User_FFR'; 
    root_dir_bs = '/private/path/User_FFR/brainstorm_db/FFR_Sz'; 
    anat_path = '/private/path/User_FFR/brainstorm_db/FFR_Sz';
    if ~any(ismember('\private\path\User_FFR',path_list_cell))
        addpath(genpath('/private/path/User_FFR'));
    end
elseif strcmp(running_in,'local')
    root_dir = 'C:/private_path';
    root_dir_bs = 'C:/private_path/brainstorm_db/FFR_Sz'; 
    anat_path = 'C:/private_path/brainstorm_db/FFR_Sz';
    if ~any(ismember('C:\private_path',path_list_cell))
        addpath(genpath('C:/private_path'));
    end
end

% Get protocol name, in case we don't run it with server mode
pos_last = find(root_dir_bs == '/', 1, 'last');
ProtocolName = root_dir_bs(pos_last+1:end); clear pos_last
load([root_dir '/subject_array.mat'])

% Define participants
participant = {subject_array{:,1}};
% So that it has a different name if we loop through sections
participant_general_list = participant; 
% We have to indicate all, even if some may not change
biosemi_channels_to_rename = {'F1','Fz','F2','FC1','FCz','FC2','C1_02','Cz','C2','CP1_02','CPz_02','CP2','FH','VEOG','EarL','EarR'}; % Should be the same number than next variable
biosemi_channels_renamed = {'F1','Fz','F2','FC1','FCz','FC2','C1','Cz','C2','CP1','CPz','CP2','FH','VEOG','EarL','EarR'}; % Should be the same number than previous variable

ref_EEG = 'EarL, EarR'; % Despite having the same label, during LLR these will actually be mastoids
delay_triggers = 0.03003; % 30ms
DC_detrend_correction = 1; % 0 = NO; 1 = YES;

% participant_group = {'FE','SZ','C'};
participant_group = {'FE','C'}; % For now leave at this
fre_string = {'low','medium','high'};
fre_num = [113,266,317];
condition_FFR = {'1','2'};
condition_FFR_exception = {'32513','32514'}; % Some subjects with wrong trigger codes
condition_LLR = {'1'};
condition_LLR_exception = {'32513'};
condition_names_FFR = {'Pol_1','Pol_2'};
condition_names_FFR_low = {'Pol_1_low','Pol_2_low'};
condition_names_FFR_medium = {'Pol_1_medium','Pol_2_medium'};
condition_names_FFR_high = {'Pol_1_high','Pol_2_high'};
event_name_FFR = 'Pol_1, Pol_2'; 
event_name_FFR_low = 'Pol_1_low, Pol_2_low';
event_name_FFR_medium = 'Pol_1_medium, Pol_2_medium';
event_name_FFR_high = 'Pol_1_high, Pol_2_high';
condition_names_LLR_400ms = {'Tone_400ms'};
condition_names_LLR_1s = {'Tone_1s'};
event_name_LLR = 'Tone'; % Replace by LLR?
event_name_LLR_400ms = 'Tone_400ms';
event_name_LLR_1s = 'Tone_1s';
measures = {'Pol_1_low','Pol_2_low','Pol_1_medium','Pol_2_medium','Pol_1_high','Pol_2_high','Tone_400ms','Tone_1s'}; % Normally it will be 'FFR','Tone'
epoch_wave_FFR = [-0.04, 0.23];
epoch_wave_LLR = [-0.1, 0.4];
epoch_baseline_FFR = [-0.04, 0]; % FFR baseline correction
epoch_baseline_LLR = [-0.100, 0]; % LLR baseline correction
reject_EEG_absolute_FFR = [0, 30]; % absolute threshold
reject_EEG_absolute_LLR = [0, 50]; % absolute threshold
FFR_highpass = 70; %
FFR_lowpass = 1500; %
LLR_highpass = 0.5; %
LLR_lowpass = 20; %
tranband_FFR = 0; % 
tranband_LLR = 0; % 
% Next filter settings should be for low-pass only
low_pass_FFR_low = 250; % Only for visualization purposes, probably useless after DC correction added
low_pass_FFR_low_string = '250Hz';
low_pass_FFR_medium = 600; % Only for visualization purposes, probably useless after DC correction added
low_pass_FFR_medium_string = '600Hz'; 
low_pass_FFR_high = 700; % Only for visualization purposes, probably useless after DC correction added
low_pass_FFR_high_string = '700Hz'; 
time_windows_FFR = {[-0.040, 0],[0.010, 0.055],[0.055, 0.170],[0.010, 0.170]}; % In seconds. Asuming 10ms of neural lag
time_windows_FFR_labels = {'Baseline','Transient','Constant','Total'};
time_windows_LLR = {[0.040, 0.060],[0.090, 0.110],[0.175, 0.195]};
time_windows_LLR_labels = {'P50','N1','P2'};
% IF MODIFYING PREVIOUS ONES, MODIFY shaded_areas VARIABLES ACCORDINGLY (below)
shaded_areas_FFR_TD = {[-40 0 0 -40],[10 55 55 10],[55 170 170 55]}; % Bas, Trans, Const
shaded_areas_FFR_FFT = {[108 118 118 108],[261 271 271 261],[312 322 322 312]}; % low, medium, high
shaded_areas_LLR = {[40 60 60 40],[90 110 110 90],[175 195 195 175]};
crit_sweeps_LLR = 30; % minimum number of surviving sweeps for LLR
crit_sweeps_FFR = 800; % minimum number of surviving sweeps for FFR
crit_percent = 50; % minimum percentage of surviving sweeps to discard EEG, MEG or BIMODAL
reref_option = 1; % 0 = NO 1 = YES Yes or no rereference
remove_blinks = 1; % = NO 1 = YES detect and remove blinks with SSP
delete_previous_file = 1; % 1 = delete previous head models and source kernels if reran these steps

% If selected more than one, they will be averaged as a cluster
choice_channel_EEG = {'Cz'}; % Watch out because others may be missing for some subjects
cluster_channel_EEG = {'F1','Fz','F2','FC1','FCz','FC2','C1','Cz','C2','CP1','CPz','CP2'};
% Spectral time windows for spectral peak extraction and spectral SNR
valley_length = 5; % Decide based on GAVR. Normally 10 to 20Hz windows in peak and + - 10/20 at the valleys
separation = 5; % Separation in Hz between time window of peak and time window of valleys (leave at 0 if adjacent): 5
init_peak_low = 108; % 108 for peak 221 for harmonic
end_peak_low = 118; % 118 for peak 231 for harmonic
init_peak_medium = 261;
end_peak_medium = 271;
init_peak_high = 312;
end_peak_high = 322;
% IF MODIFYING PREVIOUS ONES, MODIFY shaded_areas VARIABLES ACCORDINGLY (above)
xcorr_maxlag = 0.015; % In seconds (In TMS paper longest was 12ms and shortest was 3)
remove_outlier_SIN = 'YES'; % remove FF_2554 from SIN plots (outlier)
% Frequency windows for IPTC (ordered for low, medium and high)
% Originally set to 103-123, 256-276, 307-327, but changed to a wider freq window for better visibility
Freq_window_ITPC = {[70:170]...
    [215:315],...
    [275:375]}; %#ok<*NBRAK>

initialVars = who; % variables up until here, which won't be deleted afterwards
initialVars = who; % twice so that InitialVars itself is not deleted

%% (98 or 99) Import raw data
 
tic
disp(' ');      
disp('-------------------------');  
disp('IMPORTING EEG DATA FOR FFR_Sz');
disp(datetime)
disp('-------------------------');     
disp(' '); 

for p = 1:length(participant)
    % Check log info about the subject
    pos_subj = find(strcmp({subject_array{:,1}},participant{p})); %#ok<*CCAT1>
    if strcmp(subject_array{pos_subj,3},'needs_import')


    folders = dir(['/private/path/User_FFR/raw_files/' participant{p} '/']);
    infolder = find(endsWith({folders.name},'.bdf') & (...
                contains({folders.name},participant{p})));
        if isempty(infolder)
            error(['No bdf files for ' participant{p}]);
        end

        for i = 1:length(infolder)
            line = infolder(i);
            file_name = ['/private/path/User_FFR/raw_files/' participant{p} '/' folders(line).name];  %#ok<*SAGROW>             
            
            disp(' ');      
            disp('-------------------------');  
            disp(['Importing data bdf data for ' participant{p}]);
            disp(datetime)
            disp(' '); 

            sFiles = [];
            % Process: Create link to raw file
            sFiles = bst_process('CallProcess', 'process_import_data_raw', sFiles, [], ...
                'subjectname',    participant{p}, ...
                'datafile',       {file_name, 'EEG-BDF'}, ...
                'channelreplace', 1, ...
                'channelalign',   1, ...
                'evtmode',        'value');    
            
            % If successful, update subject_array for this subject
            subject_array{pos_subj,3} = 'needs_events';
            save([root_dir '/subject_array.mat'],'subject_array')  
        end
    end
end

clearvars('-except', initialVars{:});

disp 'DONE WITH IMPORTING EEG DATA FOR FFR_Sz!!!'
disp(datetime)
toc

%% (manual) Visually inspect the data to check for bad chans (add PSD notch filter?)

%% (98 or 99) Remove previous projectors, configurating channels, refs and blinks 

tic
disp(' ');      
disp('-------------------------');  
disp('PROJECTORS, CHANNEL LABEL, REF AND BLINKS (FFR_Sz)');  
disp(datetime)
disp('-------------------------');     
disp(' '); 

for p = 1:length(participant)
    
    % Check log info about the subject
    pos_subj = find(strcmp({subject_array{:,1}},participant{p}));
    if strcmp(subject_array{pos_subj,3},'needs_events')
   
    folders = dir([root_dir_bs '/data/' participant{p} '/']);
    infolder = find(endsWith({folders.name},'FFR_low') | endsWith({folders.name},'FFR_medium') | endsWith({folders.name},'FFR_high') | endsWith({folders.name},'LLR_400ms') | endsWith({folders.name},'LLR_1s'));
    if isempty(infolder)
        error(['No bst folders for ' participant{p}]);
    end

    % Remove active projectors and change channel labels
    for i = 1:length(infolder)
        line = infolder(i);
        sFiles = [root_dir_bs '/data/' participant{p} '/' folders(line).name '/channel.mat'];  %#ok<*SAGROW>             
        eval(['load ' sFiles])
        variableInfo = who('-file',sFiles);

        disp(' ');      
        disp('-------------------------');  
        disp(['Removing active projectors before importing events: ' participant{p}]);
        disp(datetime)
        disp(' '); 
        
        if ~isempty(Projector)
                num_proj = size(Projector,2);
            for npj = 1:num_proj
                Projector(npj).Status = 0;
            end
        end
        
        disp(' ');      
        disp('-------------------------');  
        disp(['Changing channel labels: ' participant{p}]);
        disp(datetime)
        disp(' '); 
        
        % Find channel names that will be changed
        pos_target = []; pos = 1;
        for pe = 1:length(biosemi_channels_to_rename)
            pos_target(pos) = find(strcmp({Channel.Name},biosemi_channels_to_rename{pe}));
            pos = pos + 1;
        end
        % Rename all other channels
        delete_pos = 1:length(Channel);
        delete_pos(pos_target) = [];
        for idp = 1:length(delete_pos)
            Channel(delete_pos(idp)).Name = 'empty';
            Channel(delete_pos(idp)).Type = 'none';
        end
        % Rename the others
        for pt = 1:length(pos_target)
            pos_ch = pos_target(pt);
            Channel(pos_ch).Name = biosemi_channels_renamed{pt};
        end
        % Define Reference and EOG channels
        pos = find(strcmp({Channel.Name},'VEOG'));
        if isempty(pos); error('no channel with this name was found');end
        Channel(pos).Type = 'EOG';

        % Then save channel file
        save(sFiles,variableInfo{:});
        
        % After this, reload the subject
        disp(' ');      
        disp('-------------------------');
        disp(['Reloading participant ' participant{p}]);
        disp(datetime)
        disp(' '); 

        prot_subs = bst_get('ProtocolSubjects');
        current_sub = find(strcmp({prot_subs.Subject.Name}, participant{p}));
        db_reload_conditions(current_sub);
        
        % Redefine sFiles
        sFiles = [participant{p} '/' folders(line).name '/data_0raw_' folders(line).name(5:end) '.mat'];        
        
        if reref_option == 1
            
            % Process: Re-reference EEG
            sFiles = bst_process('CallProcess', 'process_eegref', sFiles, [], ...
                'eegref',      ref_EEG, ...
                'sensortypes', 'EEG');  
        end

        % Process: Set channels type: addition on December 2020
        sFiles = bst_process('CallProcess', 'process_channel_settype', sFiles, [], ...
            'sensortypes', ref_EEG, ...
            'newtype',     'EEG REF');
                
        if remove_blinks == 1
            
            % Process: Detect eye blinks
            sFiles = bst_process('CallProcess', 'process_evt_detect_eog', sFiles, [], ...
                'channelname', 'VEOG', ...
                'timewindow',  [], ...
                'eventname',   'blink');

            % Process: SSP EOG: blink
            sFiles = bst_process('CallProcess', 'process_ssp_eog', sFiles, [], ...
                'eventname',   'blink', ...
                'sensortypes', 'EEG', ...
                'usessp',      0, ...
                'select',      1);
        end
    end
    
    % If successful, update subject_array for this subject
    subject_array{pos_subj,3} = 'needs_filter';
    save([root_dir '/subject_array.mat'],'subject_array')
    
    end
end

clearvars('-except', initialVars{:});
disp 'DONE WITH PROJECTORS, CHANNEL LABEL, REF AND BLINKS (FFR_Sz)!!!'
disp(datetime)
toc

%% Filter (Here trigger offset happens, repeating this step increases that offset)

tic
disp(' ');      
disp('-------------------------');  
disp('FILTERING (FFR_Sz)');  
disp(datetime)
disp('-------------------------');     
disp(' '); 

for p = 1:length(participant)
    % Check log info about the subject
    pos_subj = find(strcmp({subject_array{:,1}},participant{p}));
    if strcmp(subject_array{pos_subj,3},'needs_filter')
    
    % Reload subject first
    disp(' ');      
    disp('-------------------------');
    disp(['loading participant ' participant{p}]);
    disp(datetime)
    disp(' '); 

    prot_subs = bst_get('ProtocolSubjects');
    current_sub = find(strcmp({prot_subs.Subject.Name}, participant{p}));
    db_reload_conditions(current_sub);
        
    % Find files    
    folders = dir([root_dir_bs '/data/' participant{p} '/']);
    infolder_FFR_low = find(endsWith({folders.name},'FFR_low'));
    infolder_FFR_medium = find(endsWith({folders.name},'FFR_medium'));
    infolder_FFR_high = find(endsWith({folders.name},'FFR_high'));
    infolder_LLR_400ms = find(endsWith({folders.name},'LLR_400ms'));
    infolder_LLR_1s = find(endsWith({folders.name},'LLR_1s'));
    if isempty(infolder_FFR_low)
        error(['No FFR LOW bst folders for ' participant{p}]);
    end
    if isempty(infolder_FFR_medium)
        error(['No FFR MEDIUM bst folders for ' participant{p}]);
    end
    if isempty(infolder_FFR_high)
        error(['No FFR HIGH bst folders for ' participant{p}]);
    end
    if isempty(infolder_LLR_400ms)
        error(['No LLR 400ms bst folders for ' participant{p}]);
    end
    if isempty(infolder_LLR_1s)
        error(['No LLR 1s bst folders for ' participant{p}]);
    end
    
    for fl = 1:length(infolder_FFR_low)
        line = infolder_FFR_low(fl);
        sFiles_FFR_low = [participant{p} '/' folders(line).name '/data_0raw_' folders(line).name(5:end) '.mat'];
    end
    for fm = 1:length(infolder_FFR_medium)
        line = infolder_FFR_medium(fm);
        sFiles_FFR_medium = [participant{p} '/' folders(line).name '/data_0raw_' folders(line).name(5:end) '.mat'];
    end
    for fh = 1:length(infolder_FFR_high)
        line = infolder_FFR_high(fh);
        sFiles_FFR_high = [participant{p} '/' folders(line).name '/data_0raw_' folders(line).name(5:end) '.mat'];
    end

    for l4 = 1:length(infolder_LLR_400ms)
        line = infolder_LLR_400ms(l4);
        sFiles_LLR_400ms = [participant{p} '/' folders(line).name '/data_0raw_' folders(line).name(5:end) '.mat'];
    end
    for l1 = 1:length(infolder_LLR_1s)
        line = infolder_LLR_1s(l1);
        sFiles_LLR_1s = [participant{p} '/' folders(line).name '/data_0raw_' folders(line).name(5:end) '.mat'];
    end
    
    % Only if needed for this subject, correct stimulus delay relative to trigger
    if strcmp(subject_array{pos_subj,18},'correct_delay')
        
    if strcmp(participant{p},'FFR_X581')
        warning('2581 needs delay only in FFR medium, not in low or high, watch out with that!!!');
        pause;
    end
    
    disp(' ');      
    disp('-------------------------');  
    disp(['Adding trigger time offset ' participant{p}]);
    disp(datetime)
    disp(' '); 
    
    % Add delay based on oscilloscope testing (triggers come 30 ms early)
    for c = 1:length(condition_FFR)
        if strcmp(subject_array{pos_subj,23},'exception_triggers')
            sFiles_FFR_low = bst_process('CallProcess', 'process_evt_timeoffset', sFiles_FFR_low, [], ...
                'info',      [], ...
                'eventname', condition_FFR_exception{c}, ...
                'offset',    delay_triggers); 
            sFiles_FFR_medium = bst_process('CallProcess', 'process_evt_timeoffset', sFiles_FFR_medium, [], ...
                'info',      [], ...
                'eventname', condition_FFR_exception{c}, ...
                'offset',    delay_triggers);
            sFiles_FFR_high = bst_process('CallProcess', 'process_evt_timeoffset', sFiles_FFR_high, [], ...
                'info',      [], ...
                'eventname', condition_FFR_exception{c}, ...
                'offset',    delay_triggers);
        else
            sFiles_FFR_low = bst_process('CallProcess', 'process_evt_timeoffset', sFiles_FFR_low, [], ...
                'info',      [], ...
                'eventname', condition_FFR{c}, ...
                'offset',    delay_triggers); 
            sFiles_FFR_medium = bst_process('CallProcess', 'process_evt_timeoffset', sFiles_FFR_medium, [], ...
                'info',      [], ...
                'eventname', condition_FFR{c}, ...
                'offset',    delay_triggers);
            sFiles_FFR_high = bst_process('CallProcess', 'process_evt_timeoffset', sFiles_FFR_high, [], ...
                'info',      [], ...
                'eventname', condition_FFR{c}, ...
                'offset',    delay_triggers);
        end
    end
    
    for c = 1:length(condition_LLR)
        if strcmp(subject_array{pos_subj,23},'exception_triggers')
            sFiles_LLR_400ms = bst_process('CallProcess', 'process_evt_timeoffset', sFiles_LLR_400ms, [], ...
                'info',      [], ...
                'eventname', condition_LLR_exception{c}, ...
                'offset',    delay_triggers);
            sFiles_LLR_1s = bst_process('CallProcess', 'process_evt_timeoffset', sFiles_LLR_1s, [], ...
                'info',      [], ...
                'eventname', condition_LLR_exception{c}, ...
                'offset',    delay_triggers);
        else
            sFiles_LLR_400ms = bst_process('CallProcess', 'process_evt_timeoffset', sFiles_LLR_400ms, [], ...
                'info',      [], ...
                'eventname', condition_LLR{c}, ...
                'offset',    delay_triggers);
            sFiles_LLR_1s = bst_process('CallProcess', 'process_evt_timeoffset', sFiles_LLR_1s, [], ...
                'info',      [], ...
                'eventname', condition_LLR{c}, ...
                'offset',    delay_triggers);
        end
    
    end
    
    end
    
    if DC_detrend_correction == 1
        
        % Process: DC offset correction: [All file]
        sFiles_FFR_low = bst_process('CallProcess', 'process_baseline', sFiles_FFR_low, [], ...
            'baseline',    [], ...
            'sensortypes', 'EEG', ...
            'method',      'bl', ...  % DC offset correction:    x_std = x - &mu;
            'read_all',    1);   
        
        % Process: DC offset correction: [All file]
        sFiles_FFR_medium = bst_process('CallProcess', 'process_baseline', sFiles_FFR_medium, [], ...
            'baseline',    [], ...
            'sensortypes', 'EEG', ...
            'method',      'bl', ...  % DC offset correction:    x_std = x - &mu;
            'read_all',    1);   
        
        % Process: DC offset correction: [All file]
        sFiles_FFR_high = bst_process('CallProcess', 'process_baseline', sFiles_FFR_high, [], ...
            'baseline',    [], ...
            'sensortypes', 'EEG', ...
            'method',      'bl', ...  % DC offset correction:    x_std = x - &mu;
            'read_all',    1);   
        
        % Process: DC offset correction: [All file]
        sFiles_LLR_400ms = bst_process('CallProcess', 'process_baseline', sFiles_LLR_400ms, [], ...
            'baseline',    [], ...
            'sensortypes', 'EEG', ...
            'method',      'bl', ...  % DC offset correction:    x_std = x - &mu;
            'read_all',    1);   
        
        % Process: DC offset correction: [All file]
        sFiles_LLR_1s = bst_process('CallProcess', 'process_baseline', sFiles_LLR_1s, [], ...
            'baseline',    [], ...
            'sensortypes', 'EEG', ...
            'method',      'bl', ...  % DC offset correction:    x_std = x - &mu;
            'read_all',    1);   
        
    end
    
    if strcmp(subject_array{pos_subj,19},'notch_low')
        
        notch_low = str2double(subject_array{pos_subj,20});
        % Process: Notch filter: 300Hz
        sFiles_FFR_low = bst_process('CallProcess', 'process_notch', sFiles_FFR_low, [], ...
            'sensortypes', 'EEG', ...
            'freqlist',    notch_low, ...
            'cutoffW',     1, ...
            'useold',      0, ...
            'read_all',    1);
    end
    
    if strcmp(subject_array{pos_subj,21},'notch_medium')
        
        notch_medium = str2double(subject_array{pos_subj,22});
        % Process: Notch filter: 300Hz
        sFiles_FFR_medium = bst_process('CallProcess', 'process_notch', sFiles_FFR_medium, [], ...
            'sensortypes', 'EEG', ...
            'freqlist',    notch_medium, ...
            'cutoffW',     1, ...
            'useold',      0, ...
            'read_all',    1);
    end

    if strcmp(subject_array{pos_subj,23},'notch_high')
        
        notch_high = str2double(subject_array{pos_subj,24});
        % Process: Notch filter: 300Hz
        sFiles_FFR_high = bst_process('CallProcess', 'process_notch', sFiles_FFR_high, [], ...
            'sensortypes', 'EEG', ...
            'freqlist',    notch_high, ...
            'cutoffW',     1, ...
            'useold',      0, ...
            'read_all',    1);
    end
    

    disp(' ');      
    disp('-------------------------');  
    disp(['Filtering ' participant{p}]);
    disp(datetime)
    disp(' '); 
    
    try
        
    % Filter FFR
    sFiles_FFR_low = bst_process('CallProcess', 'process_bandpass', sFiles_FFR_low, [], ...
        'sensortypes', '', ...
        'highpass',    FFR_highpass, ... 
        'lowpass',     FFR_lowpass, ... 
        'tranband',    tranband_FFR, ...
        'attenuation', 'strict', ...  % 60dB
        'ver',         '2019', ...  % 2019
        'mirror',      0, ...
        'read_all',    0);
    
    sFiles_FFR_medium = bst_process('CallProcess', 'process_bandpass', sFiles_FFR_medium, [], ...
        'sensortypes', '', ...
        'highpass',    FFR_highpass, ... 
        'lowpass',     FFR_lowpass, ... 
        'tranband',    tranband_FFR, ...
        'attenuation', 'strict', ...  % 60dB
        'ver',         '2019', ...  % 2019
        'mirror',      0, ...
        'read_all',    0);
    
    sFiles_FFR_high = bst_process('CallProcess', 'process_bandpass', sFiles_FFR_high, [], ...
        'sensortypes', '', ...
        'highpass',    FFR_highpass, ... 
        'lowpass',     FFR_lowpass, ... 
        'tranband',    tranband_FFR, ...
        'attenuation', 'strict', ...  % 60dB
        'ver',         '2019', ...  % 2019
        'mirror',      0, ...
        'read_all',    0);
    
    % Filter LLR
    sFiles_LLR_400ms = bst_process('CallProcess', 'process_bandpass', sFiles_LLR_400ms, [], ...
        'sensortypes', '', ...
        'highpass',    LLR_highpass, ... 
        'lowpass',     LLR_lowpass, ... 
        'tranband',    tranband_LLR, ...
        'attenuation', 'strict', ...  % 60dB
        'ver',         '2019', ...  % 2019
        'mirror',      0, ...
        'read_all',    0);
    
    sFiles_LLR_1s = bst_process('CallProcess', 'process_bandpass', sFiles_LLR_1s, [], ...
        'sensortypes', '', ...
        'highpass',    LLR_highpass, ... 
        'lowpass',     LLR_lowpass, ... 
        'tranband',    tranband_LLR, ...
        'attenuation', 'strict', ...  % 60dB
        'ver',         '2019', ...  % 2019
        'mirror',      0, ...
        'read_all',    0);

    % If successful, update subject_array for this subject
    subject_array{pos_subj,3} = 'needs_epoch';
    save([root_dir '/subject_array.mat'],'subject_array')    
    catch
        error(['No filtering performed for ' participant{p}]);
    end
    end  
end

clearvars('-except', initialVars{:});
disp 'DONE WITH FILTERING (FFR_Sz)!!!'
disp(datetime)
toc

%% Check trigger times in log file and EEG file (now that trigger offset was corrected)

tic
disp(' ');      
disp('-------------------------');  
disp('CHECKING TRIGGER TIMES IN LOG FILE AND EEG FILE');
disp(datetime)
disp('-------------------------');     
disp(' '); 

trigger_info_header = {'event_types_FFR','event_types_LLR',...
    'FFR_low_pr','FFR_low_pr','FFR_low_pr','FFR_low_bs','FFR_low_bs','FFR_low_bs',...
    'FFR_med_pr','FFR_med_pr','FFR_med_pr','FFR_med_bs','FFR_med_bs','FFR_med_bs',...
    'FFR_high_pr','FFR_high_pr','FFR_high_pr','FFR_high_bs','FFR_high_bs','FFR_high_bs','-----'...
    'LLR_400ms_pr','LLR_400ms_pr','LLR_400ms_pr','LLR_400ms_bs','LLR_400ms_bs','LLR_400ms_bs',...
    'LLR_1s_pr','LLR_1s_pr','LLR_1s_pr','LLR_1s_bs','LLR_1s_bs','LLR_1s_bs'};

for p = 1:length(participant)
    % Check log info about the subject
    pos_subj = find(strcmp({subject_array{:,1}},participant{p})); %#ok<*CCAT1>
    
    % We check it but won't change it
    if strcmp(subject_array{pos_subj,3},'needs_epoch')
        
        % Create template where trigger info would be saved
        trigger_info = {};
        
        % Retrieve events from log files
        FFR_presentation_low = readtable([root_dir '/raw_files/' participant{p} '/' participant{p} '-FFR_113_presentation_code_2000.log'],'Filetype','text');
        FFR_presentation_medium = readtable([root_dir '/raw_files/' participant{p} '/' participant{p} '-FFR_266_presentation_code_2000.log'],'Filetype','text');
        FFR_presentation_high = readtable([root_dir '/raw_files/' participant{p} '/' participant{p} '-FFR_317_presentation_code_2000.log'],'Filetype','text');
        LLR_presentation_400ms = readtable([root_dir '/raw_files/' participant{p} '/' participant{p} '-Pure_tone_400ms_presentation_code_200.log'],'Filetype','text');
        LLR_presentation_1s = readtable([root_dir '/raw_files/' participant{p} '/' participant{p} '-Pure_tone_1s_presentation_code_200.log'],'Filetype','text');
        
        % Retrieve events from brainstorm files
        FFR_low_brainstorm = load([root_dir_bs '/data/' participant{p} '/@raw' participant{p} '_FFR_low/data_0raw_' participant{p} '_FFR_low.mat']); 
        FFR_low_brainstorm = FFR_low_brainstorm.F.events;
        FFR_medium_brainstorm = load([root_dir_bs '/data/' participant{p} '/@raw' participant{p} '_FFR_medium/data_0raw_' participant{p} '_FFR_medium.mat']); 
        FFR_medium_brainstorm = FFR_medium_brainstorm.F.events;
        FFR_high_brainstorm = load([root_dir_bs '/data/' participant{p} '/@raw' participant{p} '_FFR_high/data_0raw_' participant{p} '_FFR_high.mat']); 
        FFR_high_brainstorm = FFR_high_brainstorm.F.events;
        LLR_400ms_brainstorm = load([root_dir_bs '/data/' participant{p} '/@raw' participant{p} '_LLR_400ms/data_0raw_' participant{p} '_LLR_400ms.mat']); 
        LLR_400ms_brainstorm = LLR_400ms_brainstorm.F.events;
        LLR_1s_brainstorm = load([root_dir_bs '/data/' participant{p} '/@raw' participant{p} '_LLR_1s/data_0raw_' participant{p} '_LLR_1s.mat']); 
        LLR_1s_brainstorm = LLR_1s_brainstorm.F.events;
        
        % Check what kind of events are present in bs, except blinks
        event_types_FFR_low = {FFR_low_brainstorm.label};
        event_types_FFR_low = event_types_FFR_low(~contains(event_types_FFR_low,'blink'));
        event_types_FFR_medium = {FFR_medium_brainstorm.label};
        event_types_FFR_medium = event_types_FFR_medium(~contains(event_types_FFR_medium,'blink'));
        event_types_FFR_high = {FFR_high_brainstorm.label};
        event_types_FFR_high = event_types_FFR_high(~contains(event_types_FFR_high,'blink'));
        event_types_LLR_400ms = {LLR_400ms_brainstorm.label};
        event_types_LLR_400ms = event_types_LLR_400ms(~contains(event_types_LLR_400ms,'blink'));
        event_types_LLR_1s = {LLR_1s_brainstorm.label};
        event_types_LLR_1s = event_types_LLR_1s(~contains(event_types_LLR_1s,'blink'));
        event_types_FFR = [event_types_FFR_low, event_types_FFR_medium, event_types_FFR_high];
        event_types_LLR = [event_types_LLR_400ms, event_types_LLR_1s];
        trigger_info{1,1} = sprintf('%s ',event_types_FFR{:}); %%%%%%%%%%%%%%%%%%%%
        trigger_info{1,2} = sprintf('%s ',event_types_LLR{:});%%%%%%%%%%%%%%%%%%%%%

        % In brainstorm file, only information available is trigger times & label
        % Retrieve FFR LOW event times and labels Pol 1 FFR bs
        pos = find(strcmp({FFR_low_brainstorm.label},'1'));
        pol_1_event_times = FFR_low_brainstorm(pos).times; %#ok<*FNDSB>
        pol_1_event_labels = {}; % store labels as well 
        for p1 = 1:length(pol_1_event_times)
            pol_1_event_labels{p1} = 'Pol_1';
        end
        
        % Retrieve event times and labels Pol 2 FFR bs
        pos = find(strcmp({FFR_low_brainstorm.label},'2'));
        pol_2_event_times = FFR_low_brainstorm(pos).times;
        pol_2_event_labels = {}; % store labels as well 
        for p2 = 1:length(pol_2_event_times)
            pol_2_event_labels{p2} = 'Pol_2';
        end
        
        % Mix event times Pol 1 and 2
        ba_event_times = [pol_1_event_times,pol_2_event_times];
        ba_event_labels = [pol_1_event_labels,pol_2_event_labels];
        % Sort them
        [ba_event_times_low, sorted_order] = sort(ba_event_times,'ascend'); %%%%%%%%%%%%%%%%%%%%%%%      
        ba_event_labels_low = ba_event_labels(sorted_order);%%%%%%%%%%%%%%%%%
        
        % In brainstorm file, only information available is trigger times & label
        % Retrieve FFR MEDIUM event times and labels Pol 1 FFR bs
        pos = find(strcmp({FFR_medium_brainstorm.label},'1'));
        pol_1_event_times = FFR_medium_brainstorm(pos).times; %#ok<*FNDSB>
        pol_1_event_labels = {}; % store labels as well 
        for p1 = 1:length(pol_1_event_times)
            pol_1_event_labels{p1} = 'Pol_1';
        end
        
        % Retrieve event times and labels Pol 2 FFR bs
        pos = find(strcmp({FFR_medium_brainstorm.label},'2'));
        pol_2_event_times = FFR_medium_brainstorm(pos).times;
        pol_2_event_labels = {}; % store labels as well 
        for p2 = 1:length(pol_2_event_times)
            pol_2_event_labels{p2} = 'Pol_2';
        end
        
        % Mix event times Pol 1 and 2
        ba_event_times = [pol_1_event_times,pol_2_event_times];
        ba_event_labels = [pol_1_event_labels,pol_2_event_labels];
        % Sort them
        [ba_event_times_medium, sorted_order] = sort(ba_event_times,'ascend'); %%%%%%%%%%%%%%%%%%%%%%%      
        ba_event_labels_medium = ba_event_labels(sorted_order);%%%%%%%%%%%%%%%%%
        
        % In brainstorm file, only information available is trigger times & label
        % Retrieve FFR HIGH event times and labels Pol 1 FFR bs
        pos = find(strcmp({FFR_high_brainstorm.label},'1'));
        pol_1_event_times = FFR_high_brainstorm(pos).times; %#ok<*FNDSB>
        pol_1_event_labels = {}; % store labels as well 
        for p1 = 1:length(pol_1_event_times)
            pol_1_event_labels{p1} = 'Pol_1';
        end
        
        % Retrieve event times and labels Pol 2 FFR bs
        pos = find(strcmp({FFR_high_brainstorm.label},'2'));
        pol_2_event_times = FFR_high_brainstorm(pos).times;
        pol_2_event_labels = {}; % store labels as well 
        for p2 = 1:length(pol_2_event_times)
            pol_2_event_labels{p2} = 'Pol_2';
        end
        
        % Mix event times Pol 1 and 2
        ba_event_times = [pol_1_event_times,pol_2_event_times];
        ba_event_labels = [pol_1_event_labels,pol_2_event_labels];
        % Sort them
        [ba_event_times_high, sorted_order] = sort(ba_event_times,'ascend');%%%%%%%%%%%%%%%    
        ba_event_labels_high = ba_event_labels(sorted_order);%%%%%%%%%%%%%%%
        
        % Stack toghether FFR LOW, MEDIUM AND HIGH brainstorm times and labels
        ba_event_times = [ba_event_times_low, ba_event_times_medium, ba_event_times_high];%%%%%%%%%%%%%%%%%%%%%%
        ba_event_labels = [ba_event_labels_low, ba_event_labels_medium, ba_event_labels_high];%%%%%%%%%%%%%%%%%%%
        
        % Retrieve event times and labels pure tone bs
        pos = find(strcmp({LLR_400ms_brainstorm.label},'1'));
        tone_400ms_event_times = LLR_400ms_brainstorm(pos).times; %%%%%%%%%%%%%%%%%%%%%%%%%
        tone_400ms_event_labels = {};
        for pt = 1:length(tone_400ms_event_times)
            tone_400ms_event_labels{pt} = '1'; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        
        % Retrieve event times and labels pure tone bs
        pos = find(strcmp({LLR_1s_brainstorm.label},'1'));
        tone_1s_event_times = LLR_1s_brainstorm(pos).times; %%%%%%%%%%%%%%%%%%%%%%%%%
        tone_1s_event_labels = {};
        for pt = 1:length(tone_1s_event_times)
            tone_1s_event_labels{pt} = '1'; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        
        % Presentation event list FFR LOW
        try
            FFR_pres_labels = FFR_presentation_low.Var4;
            subj_list = FFR_presentation_low.Scenario_;
            if strcmp(participant{p},'FFR_S01') 
                error('FFR_S01 subject should not be analyzed using this script');
            end
            first_subj = find(contains(subj_list,participant{p}), 1 );
        catch
            FFR_pres_labels = FFR_presentation_low.Code;
            subj_list = FFR_presentation_low.Subject;
            if strcmp(participant{p},'FFR_S01') 
                error('FFR_S01 subject should not be analyzed using this script');
            end
            first_subj = find(contains(subj_list,participant{p}), 1 );
        end
        FFR_pres_labels_low = FFR_pres_labels(first_subj:end,1); %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        try 
            FFR_pres_times = FFR_presentation_low.Var5;
        catch
            FFR_pres_times = FFR_presentation_low.Time;
        end
        
        FFR_pres_times_low = FFR_pres_times(first_subj:end,1); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Presentation event list FFR MEDIUM
        try
            FFR_pres_labels = FFR_presentation_medium.Var4;
            subj_list = FFR_presentation_medium.Scenario_;
            if strcmp(participant{p},'FFR_S01') 
                error('FFR_S01 subject should not be analyzed using this script');
            end
            first_subj = find(contains(subj_list,participant{p}), 1 );
        catch
            FFR_pres_labels = FFR_presentation_medium.Code;
            subj_list = FFR_presentation_medium.Subject;
            if strcmp(participant{p},'FFR_S01') 
                error('FFR_S01 subject should not be analyzed using this script');
            end
            first_subj = find(contains(subj_list,participant{p}), 1 );
        end
        FFR_pres_labels_medium = FFR_pres_labels(first_subj:end,1); %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        try 
            FFR_pres_times = FFR_presentation_medium.Var5;
        catch
            FFR_pres_times = FFR_presentation_medium.Time;
        end
        
        FFR_pres_times_medium = FFR_pres_times(first_subj:end,1); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Presentation event list FFR HIGH
        try
            FFR_pres_labels = FFR_presentation_high.Var4;
            subj_list = FFR_presentation_high.Scenario_;
            if strcmp(participant{p},'FFR_S01') 
                error('FFR_S01 subject should not be analyzed using this script');
            end
            first_subj = find(contains(subj_list,participant{p}), 1 );
        catch
            FFR_pres_labels = FFR_presentation_high.Code;
            subj_list = FFR_presentation_high.Subject;
            if strcmp(participant{p},'FFR_S01') 
                error('FFR_S01 subject should not be analyzed using this script');
            end
            first_subj = find(contains(subj_list,participant{p}), 1 );
        end
        FFR_pres_labels_high = FFR_pres_labels(first_subj:end,1); %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        try 
            FFR_pres_times = FFR_presentation_high.Var5;
        catch
            FFR_pres_times = FFR_presentation_high.Time;
        end
        
        FFR_pres_times_high = FFR_pres_times(first_subj:end,1); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Presentation event list LLR 400ms
        try 
            LLR_pres_labels = LLR_presentation_400ms.Var4;
            subj_list = LLR_presentation_400ms.Scenario_;
            first_subj = find(contains(subj_list,participant{p}), 1 );
        catch
            LLR_pres_labels = LLR_presentation_400ms.Code;
            subj_list = LLR_presentation_400ms.Subject;
            first_subj = find(contains(subj_list,participant{p}), 1 );
        end
        LLR_pres_labels_400ms = LLR_pres_labels(first_subj:end,1); %%%%%%%%%%%%%%%%%%%%%%%%%%%
        try
            LLR_pres_times = LLR_presentation_400ms.Var5;
        catch
            LLR_pres_times = LLR_presentation_400ms.Time;
        end
        LLR_pres_times_400ms = LLR_pres_times(first_subj:end,1); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Presentation event list LLR 1s
        try 
            LLR_pres_labels = LLR_presentation_1s.Var4;
            subj_list = LLR_presentation_1s.Scenario_;
            first_subj = find(contains(subj_list,participant{p}), 1 );
        catch
            LLR_pres_labels = LLR_presentation_1s.Code;
            subj_list = LLR_presentation_1s.Subject;
            first_subj = find(contains(subj_list,participant{p}), 1 );
        end
        LLR_pres_labels_1s = LLR_pres_labels(first_subj:end,1); %%%%%%%%%%%%%%%%%%%%%%%%%%%
        try
            LLR_pres_times = LLR_presentation_1s.Var5;
        catch
            LLR_pres_times = LLR_presentation_1s.Time;
        end
        LLR_pres_times_1s = LLR_pres_times(first_subj:end,1); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Store information in main cell for this subject     
        % FFR LOW
        for i = 1:length(FFR_pres_labels_low)
            trigger_info{i,3} = FFR_pres_labels_low{i};
            try
                trigger_info{i,4} = FFR_pres_times_low{i};
            catch
                trigger_info{i,4} = FFR_pres_times_low(i);
            end
        end
        
        if iscell(FFR_pres_times_low)
        % Ensure there are no empty values in FFR times
        if find(cellfun(@isempty,FFR_pres_times_low)); error('empty values in FFR_pres_times');end
        % Convert FFR event times to matrix
        FFR_pres_times_low_matrix = cellfun(@str2num,FFR_pres_times_low);
        else
            FFR_pres_times_low_matrix = FFR_pres_times_low;
        end
        
        for i = 1:length(ba_event_labels_low)
            trigger_info{i,6} = ba_event_labels_low{i};
            trigger_info{i,7} = ba_event_times_low(i);
        end
        
        % FFR MEDIUM
        for i = 1:length(FFR_pres_labels_medium)
            trigger_info{i,3+6} = FFR_pres_labels_medium{i};
            try
                trigger_info{i,4+6} = FFR_pres_times_medium{i};
            catch
                trigger_info{i,4+6} = FFR_pres_times_medium(i);
            end
        end
        
        if iscell(FFR_pres_times_medium)
        % Ensure there are no empty values in FFR times
        if find(cellfun(@isempty,FFR_pres_times_medium)); error('empty values in FFR_pres_times');end
        % Convert FFR event times to matrix
        FFR_pres_times_medium_matrix = cellfun(@str2num,FFR_pres_times_medium);
        else
            FFR_pres_times_medium_matrix = FFR_pres_times_medium;
        end
        
        for i = 1:length(ba_event_labels_medium)
            trigger_info{i,6+6} = ba_event_labels_medium{i};
            trigger_info{i,7+6} = ba_event_times_medium(i);
        end
        
        % FFR HIGH
        for i = 1:length(FFR_pres_labels_high)
            trigger_info{i,9+6} = FFR_pres_labels_high{i};
            try
                trigger_info{i,10+6} = FFR_pres_times_high{i};
            catch
                trigger_info{i,10+6} = FFR_pres_times_high(i);
            end
        end
        
        if iscell(FFR_pres_times_high)
        % Ensure there are no empty values in FFR times
        if find(cellfun(@isempty,FFR_pres_times_high)); error('empty values in FFR_pres_times');end
        % Convert FFR event times to matrix
        FFR_pres_times_high_matrix = cellfun(@str2num,FFR_pres_times_high);
        else
            FFR_pres_times_high_matrix = FFR_pres_times_high;
        end
        
        for i = 1:length(ba_event_labels_high)
            trigger_info{i,12+6} = ba_event_labels_high{i};
            trigger_info{i,13+6} = ba_event_times_high(i);
        end
        
        % LLR 400ms
        for i = 1:length(LLR_pres_labels_400ms)
            trigger_info{i,16+6} = LLR_pres_labels_400ms{i};
            try
                trigger_info{i,17+6} = LLR_pres_times_400ms{i};
            catch
                trigger_info{i,17+6} = LLR_pres_times_400ms(i);
            end
        end
        
        if iscell(LLR_pres_times_400ms)
        % Ensure there are no empty values in LLR times
        if find(cellfun(@isempty,LLR_pres_times_400ms)); error('empty values in LLR_pres_times');end
        % Convert FFR event times to matrix
        LLR_pres_times_400ms_matrix = cellfun(@str2num,LLR_pres_times_400ms);
        else
            LLR_pres_times_400ms_matrix = LLR_pres_times_400ms;
        end
        
        for i = 1:length(tone_400ms_event_labels)
            trigger_info{i,19+6} = tone_400ms_event_labels{i};
            trigger_info{i,20+6} = tone_400ms_event_times(i);
        end
        
        % LLR 1s
        for i = 1:length(LLR_pres_labels_1s)
            trigger_info{i,22+6} = LLR_pres_labels_1s{i};
            try
                trigger_info{i,23+6} = LLR_pres_times_1s{i};
            catch
                trigger_info{i,23+6} = LLR_pres_times_1s(i);
            end
        end
        
        if iscell(LLR_pres_times_1s)
        % Ensure there are no empty values in LLR times
        if find(cellfun(@isempty,LLR_pres_times_1s)); error('empty values in LLR_pres_times');end
        % Convert FFR event times to matrix
        LLR_pres_times_1s_matrix = cellfun(@str2num,LLR_pres_times_1s);
        else
            LLR_pres_times_1s_matrix = LLR_pres_times_1s;
        end
        
        for i = 1:length(tone_1s_event_labels)
            trigger_info{i,25+6} = tone_1s_event_labels{i};
            trigger_info{i,26+6} = tone_1s_event_times(i);
        end
        
        % Calculate delays in FFR LOW
        % Presentation
        FFR_pres_delays_low = [];
        for i = 1:length(FFR_pres_times_low_matrix)
            if i == 1; continue; end % Avoid first iteration
            FFR_pres_delays_low(i) = (FFR_pres_times_low_matrix(i) - FFR_pres_times_low_matrix(i-1))/1e4;
        end
        FFR_pres_delays_low = FFR_pres_delays_low';
        % Store in main cell
        for i = 1:length(FFR_pres_delays_low)
            trigger_info{i,5} = FFR_pres_delays_low(i);
        end
        
        % Brainstorm
        FFR_bs_delays_low = [];
        for i = 1:length(ba_event_times_low)
            if i == 1; continue; end % Avoid first iteration
            FFR_bs_delays_low(i) = ba_event_times_low(i) - ba_event_times_low(i-1);
        end
        FFR_bs_delays_low = FFR_bs_delays_low';
        % Store in main cell
        for i = 1:length(FFR_bs_delays_low)
            trigger_info{i,8} = FFR_bs_delays_low(i);
        end
        
        % Calculate delays in FFR MEDIUM
        % Presentation
        FFR_pres_delays_medium = [];
        for i = 1:length(FFR_pres_times_medium_matrix)
            if i == 1; continue; end % Avoid first iteration
            FFR_pres_delays_medium(i) = (FFR_pres_times_medium_matrix(i) - FFR_pres_times_medium_matrix(i-1))/1e4;
        end
        FFR_pres_delays_medium = FFR_pres_delays_medium';
        % Store in main cell
        for i = 1:length(FFR_pres_delays_medium)
            trigger_info{i,11} = FFR_pres_delays_medium(i);
        end
        
        % Brainstorm
        FFR_bs_delays_medium = [];
        for i = 1:length(ba_event_times_medium)
            if i == 1; continue; end % Avoid first iteration
            FFR_bs_delays_medium(i) = ba_event_times_medium(i) - ba_event_times_medium(i-1);
        end
        FFR_bs_delays_medium = FFR_bs_delays_medium';
        % Store in main cell
        for i = 1:length(FFR_bs_delays_medium)
            trigger_info{i,14} = FFR_bs_delays_medium(i);
        end
        
        % Calculate delays in FFR high
        % Presentation
        FFR_pres_delays_high = [];
        for i = 1:length(FFR_pres_times_high_matrix)
            if i == 1; continue; end % Avoid first iteration
            FFR_pres_delays_high(i) = (FFR_pres_times_high_matrix(i) - FFR_pres_times_high_matrix(i-1))/1e4;
        end
        FFR_pres_delays_high = FFR_pres_delays_high';
        % Store in main cell
        for i = 1:length(FFR_pres_delays_high)
            trigger_info{i,11+6} = FFR_pres_delays_high(i);
        end
        
        % Brainstorm
        FFR_bs_delays_high = [];
        for i = 1:length(ba_event_times_high)
            if i == 1; continue; end % Avoid first iteration
            FFR_bs_delays_high(i) = ba_event_times_high(i) - ba_event_times_high(i-1);
        end
        FFR_bs_delays_high = FFR_bs_delays_high';
        % Store in main cell
        for i = 1:length(FFR_bs_delays_high)
            trigger_info{i,14+6} = FFR_bs_delays_high(i);
        end
        
        % Calculate delays in LLR 400ms
        % Presentation
        LLR_pres_delays_400ms = [];
        for i = 1:length(LLR_pres_times_400ms_matrix)
            if i == 1; continue; end % Avoid first iteration
            LLR_pres_delays_400ms(i) = (LLR_pres_times_400ms_matrix(i) - LLR_pres_times_400ms_matrix(i-1))/1e4;
        end
        LLR_pres_delays_400ms = LLR_pres_delays_400ms';
        % Store in main cell
        for i = 1:length(LLR_pres_delays_400ms)
            trigger_info{i,18+6} = LLR_pres_delays_400ms(i);
        end
        
        % Brainstorm
        LLR_bs_delays_400ms = [];
        for i = 1:length(tone_400ms_event_times)
            if i == 1; continue; end % Avoid first iteration
            LLR_bs_delays_400ms(i) = tone_400ms_event_times(i) - tone_400ms_event_times(i-1);
        end
        LLR_bs_delays_400ms = LLR_bs_delays_400ms';      
        % Store in main cell
        for i = 1:length(LLR_bs_delays_400ms)
            trigger_info{i,21+6} = LLR_bs_delays_400ms(i);
        end
        
        % Calculate delays in LLR 1s
        % Presentation
        LLR_pres_delays_1s = [];
        for i = 1:length(LLR_pres_times_1s_matrix)
            if i == 1; continue; end % Avoid first iteration
            LLR_pres_delays_1s(i) = (LLR_pres_times_1s_matrix(i) - LLR_pres_times_1s_matrix(i-1))/1e4;
        end
        LLR_pres_delays_1s = LLR_pres_delays_1s';
        % Store in main cell
        for i = 1:length(LLR_pres_delays_1s)
            trigger_info{i,24+6} = LLR_pres_delays_1s(i);
        end
        
        % Brainstorm
        LLR_bs_delays_1s = [];
        for i = 1:length(tone_1s_event_times)
            if i == 1; continue; end % Avoid first iteration
            LLR_bs_delays_1s(i) = tone_1s_event_times(i) - tone_1s_event_times(i-1);
        end
        LLR_bs_delays_1s = LLR_bs_delays_1s';      
        % Store in main cell
        for i = 1:length(LLR_bs_delays_1s)
            trigger_info{i,27+6} = LLR_bs_delays_1s(i);
        end
        
        % Now calculate a percentage of matches between pres and bs
        % Low FFR
        match_FFR_delays_low = FFR_bs_delays_low - FFR_pres_delays_low;
        % How many matches (difference smaller than 0.0001 s)
        how_many = find(match_FFR_delays_low < 0.001);
        perc_match_FFR_delays_low = [num2str((length(how_many)/length(FFR_bs_delays_low))*100) '%'];
        % Medium FFR
        match_FFR_delays_medium = FFR_bs_delays_medium - FFR_pres_delays_medium;
        % How many matches (difference smaller than 0.0001 s)
        how_many = find(match_FFR_delays_medium < 0.001);
        perc_match_FFR_delays_medium = [num2str((length(how_many)/length(FFR_bs_delays_medium))*100) '%'];
        % High FFR
        match_FFR_delays_high = FFR_bs_delays_high - FFR_pres_delays_high;
        % How many matches (difference smaller than 0.0001 s)
        how_many = find(match_FFR_delays_high < 0.001);
        perc_match_FFR_delays_high = [num2str((length(how_many)/length(FFR_bs_delays_high))*100) '%'];
        
        % LLR 400ms
        match_LLR_delays_400ms = LLR_bs_delays_400ms - LLR_pres_delays_400ms;
        % How many matches (difference smaller than 0.0001 s)
        how_many = find(match_LLR_delays_400ms < 0.001);
        perc_match_LLR_delays_400ms = [num2str((length(how_many)/length(LLR_bs_delays_400ms))*100) '%'];
        
        % LLR 1s
        match_LLR_delays_1s = LLR_bs_delays_1s - LLR_pres_delays_1s;
        % How many matches (difference smaller than 0.0001 s)
        how_many = find(match_LLR_delays_1s < 0.001);
        perc_match_LLR_delays_1s = [num2str((length(how_many)/length(LLR_bs_delays_1s))*100) '%'];
        
        
        trigger_info{2,1} = 'FFR_low_pres_bs';
        trigger_info{3,1} = 'FFR_high_pres_bs';
        trigger_info{2,2} = perc_match_FFR_delays_low;
        trigger_info{3,2} = perc_match_FFR_delays_high;
        
        trigger_info{4,1} = 'LLR_400ms_pres_bs';
        trigger_info{5,1} = 'LLR_1s_pres_bs';
        
        trigger_info{4,2} = perc_match_LLR_delays_400ms;
        trigger_info{5,2} = perc_match_LLR_delays_1s;
        
        % Also, calculate a percentage of expected timings based on code
        % Only in presentation since we have this info only there
        trigger_info{6,1} = 'FFR_low_jitter';
        trigger_info{7,1} = 'FFR_medium_jitter';
        trigger_info{8,1} = 'FFR_high_jitter';
        trigger_info{9,1} = 'LLR_400ms_jitter';
        trigger_info{10,1} = 'LLR_1s_jitter';
        
        % Find matches FFR low jitter
        count = 1;
        for i = 2:length(FFR_pres_delays_low) % Except first one
            if contains(FFR_pres_labels_low{i},'95')
                if (FFR_pres_delays_low(i) - 0.265) < 0.001 % expected delay
                    count = count + 1;
                else
                    disp('mismatch found');
                end
            elseif contains(FFR_pres_labels_low{i},'100')
                if (FFR_pres_delays_low(i) - 0.270) < 0.001 % expected delay
                    count = count + 1;
                else
                    disp('mismatch found');
                end
            elseif contains(FFR_pres_labels_low{i},'105')
                if (FFR_pres_delays_low(i) - 0.275) < 0.001 % expected delay
                    count = count + 1;
                else
                    disp('mismatch found');
                end
            else
                error([participant{p} ' presentation file not containing proper FFR labels']);
            end
        end
        % Store FFR jitter match information
        jitter_string_FFR_low = [num2str((count/length(FFR_pres_delays_low))*100) '%'];
        trigger_info{6,2} = jitter_string_FFR_low;
        
        % Find matches FFR medium jitter
        count = 1;
        for i = 2:length(FFR_pres_delays_medium) % Except first one
            if contains(FFR_pres_labels_medium{i},'95')
                if (FFR_pres_delays_medium(i) - 0.265) < 0.001 % expected delay
                    count = count + 1;
                else
                    disp('mismatch found');
                end
            elseif contains(FFR_pres_labels_medium{i},'100')
                if (FFR_pres_delays_medium(i) - 0.270) < 0.001 % expected delay
                    count = count + 1;
                else
                    disp('mismatch found');
                end
            elseif contains(FFR_pres_labels_medium{i},'105')
                if (FFR_pres_delays_medium(i) - 0.275) < 0.001 % expected delay
                    count = count + 1;
                else
                    disp('mismatch found');
                end
            else
                error([participant{p} ' presentation file not containing proper FFR labels']);
            end
        end
        % Store FFR jitter match information
        jitter_string_FFR_medium = [num2str((count/length(FFR_pres_delays_medium))*100) '%'];
        trigger_info{7,2} = jitter_string_FFR_medium;
        
        % Find matches FFR high jitter
        count = 1;
        for i = 2:length(FFR_pres_delays_high) % Except first one
            if contains(FFR_pres_labels_high{i},'95')
                if (FFR_pres_delays_high(i) - 0.265) < 0.001 % expected delay
                    count = count + 1;
                else
                    disp('mismatch found');
                end
            elseif contains(FFR_pres_labels_high{i},'100')
                if (FFR_pres_delays_high(i) - 0.270) < 0.001 % expected delay
                    count = count + 1;
                else
                    disp('mismatch found');
                end
            elseif contains(FFR_pres_labels_high{i},'105')
                if (FFR_pres_delays_high(i) - 0.275) < 0.001 % expected delay
                    count = count + 1;
                else
                    disp('mismatch found');
                end
            else
                error([participant{p} ' presentation file not containing proper FFR labels']);
            end
        end
        % Store FFR jitter match information
        jitter_string_FFR_high = [num2str((count/length(FFR_pres_delays_high))*100) '%'];
        trigger_info{8,2} = jitter_string_FFR_high;
        
        % Find matches LLR 400ms jitter
        count = 1;
        for i = 2:length(LLR_pres_delays_400ms) % Except first one
            if contains(LLR_pres_labels_400ms{i},'395')
                if (LLR_pres_delays_400ms(i) - 0.495) < 0.001 % expected delay
                    count = count + 1;
                else
                    disp('mismatch found');
                end
            elseif contains(LLR_pres_labels_400ms{i},'400')
                if (LLR_pres_delays_400ms(i) - 0.500) < 0.001 % expected delay
                    count = count + 1;
                else
                    disp('mismatch found');
                end
            elseif contains(LLR_pres_labels_400ms{i},'405')
                if (LLR_pres_delays_400ms(i) - 0.505) < 0.001 % expected delay
                    count = count + 1;
                else
                    disp('mismatch found');
                end
            else
                error([participant{p} ' presentation file not containing proper FFR labels']);
            end
        end
        % Store LLR jitter match information
        jitter_string_LLR_400ms = [num2str((count/length(LLR_pres_delays_400ms))*100) '%'];
        trigger_info{9,2} = jitter_string_LLR_400ms;
        
        % Find matches LLR 1s jitter
        count = 1;
        for i = 2:length(LLR_pres_delays_1s) % Except first one
            if contains(LLR_pres_labels_1s{i},'995')
                if (LLR_pres_delays_1s(i) - 1.095) < 0.001 % expected delay
                    count = count + 1;
                else
                    disp('mismatch found');
                end
            elseif contains(LLR_pres_labels_1s{i},'1000')
                if (LLR_pres_delays_1s(i) - 1.100) < 0.001 % expected delay
                    count = count + 1;
                else
                    disp('mismatch found');
                end
            elseif contains(LLR_pres_labels_1s{i},'1005')
                if (LLR_pres_delays_1s(i) - 1.105) < 0.001 % expected delay
                    count = count + 1;
                else
                    disp('mismatch found');
                end
            else
                error([participant{p} ' presentation file not containing proper FFR labels']);
            end
        end
        % Store LLR jitter match information
        jitter_string_LLR_1s = [num2str((count/length(LLR_pres_delays_1s))*100) '%'];
        trigger_info{10,2} = jitter_string_LLR_1s;
        
        % Add header
        events_info = [trigger_info_header; trigger_info];
        % Save trigger checking file
        save([root_dir '/QC/Event_times/' participant{p} '_triger_check.mat'],'events_info');
        
        % Save percentages alone in subject_array
        subject_array{pos_subj,8} = [perc_match_FFR_delays_low ' FFR low delay'];
        subject_array{pos_subj,9} = [jitter_string_FFR_low 'FFR low jitter'];
        subject_array{pos_subj,10} = [perc_match_FFR_delays_medium ' FFR med delay'];
        subject_array{pos_subj,11} = [jitter_string_FFR_medium 'FFR med jitter'];
        subject_array{pos_subj,12} = [perc_match_FFR_delays_high ' FFR high delay'];
        subject_array{pos_subj,13} = [jitter_string_FFR_high 'FFR high jitter'];
        subject_array{pos_subj,14} = [perc_match_LLR_delays_400ms 'LLR 400ms delay'];
        subject_array{pos_subj,15} = [jitter_string_LLR_400ms 'LLR 400ms jitter'];
        subject_array{pos_subj,16} = [perc_match_LLR_delays_1s 'LLR 1s delay'];
        subject_array{pos_subj,17} = [jitter_string_LLR_1s 'LLR 1s jitter'];
        save([root_dir '/subject_array.mat'],'subject_array')
    end
end

clearvars('-except', initialVars{:});

disp 'DONE CHECKING TRIGGER TIMES IN LOG FILE AND EEG FILE!!!'
disp(datetime)
toc

%% Epoch, cleaning and average + average two FFR polarities

tic
disp(' ');      
disp('-------------------------');  
disp('EPOCHING, CLEANING AND AVERAGE (FFR_Sz)');  
disp(datetime)
disp('-------------------------');     
disp(' '); 

for p = 1:length(participant)
    % Check log info about the subject
    pos_subj = find(strcmp({subject_array{:,1}},participant{p}));
    if strcmp(subject_array{pos_subj,3},'needs_epoch')
    
    % Reload subject first
    disp(' ');      
    disp('-------------------------');
    disp(['loading participant ' participant{p}]);
    disp(datetime)
    disp(' '); 

    prot_subs = bst_get('ProtocolSubjects');
    current_sub = find(strcmp({prot_subs.Subject.Name}, participant{p}));
    db_reload_conditions(current_sub);
        
    % Find files    
    folders = dir([root_dir_bs '/data/' participant{p} '/']);
    % This includes notch if it has it 
    infolder_FFR_low = find(contains({folders.name},'FFR_low_') & endsWith({folders.name},'_band'));
    infolder_FFR_medium = find(contains({folders.name},'FFR_medium_') & endsWith({folders.name},'_band'));
    infolder_FFR_high = find(contains({folders.name},'FFR_high_') & endsWith({folders.name},'_band'));
    infolder_LLR_400ms = find(contains({folders.name},'LLR_400ms_') & endsWith({folders.name},'_band'));
    infolder_LLR_1s = find(contains({folders.name},'LLR_1s_') & endsWith({folders.name},'_band'));
    if isempty(infolder_FFR_low)
        error(['No FFR low filtered bst folders for ' participant{p}]);
    end
    if isempty(infolder_FFR_medium)
        error(['No FFR medium filtered bst folders for ' participant{p}]);
    end
    if isempty(infolder_FFR_high)
        error(['No FFR high filtered bst folders for ' participant{p}]);
    end
    if isempty(infolder_LLR_400ms)
        error(['No LLR 400ms filtered bst folders for ' participant{p}]);
    end
    if isempty(infolder_LLR_1s)
        error(['No LLR 1s filtered bst folders for ' participant{p}]);
    end
    
    sFiles_FFR_low = [participant{p} '/' folders(infolder_FFR_low).name '/data_0raw_' folders(infolder_FFR_low).name(5:end) '.mat'];
    sFiles_FFR_medium = [participant{p} '/' folders(infolder_FFR_medium).name '/data_0raw_' folders(infolder_FFR_medium).name(5:end) '.mat'];
    sFiles_FFR_high = [participant{p} '/' folders(infolder_FFR_high).name '/data_0raw_' folders(infolder_FFR_high).name(5:end) '.mat'];
    sFiles_LLR_400ms = [participant{p} '/' folders(infolder_LLR_400ms).name '/data_0raw_' folders(infolder_LLR_400ms).name(5:end) '.mat'];
    sFiles_LLR_1s = [participant{p} '/' folders(infolder_LLR_1s).name '/data_0raw_' folders(infolder_LLR_1s).name(5:end) '.mat'];
    
    disp(' ');      
    disp('-------------------------');
    disp(['Renaming events to epoch data: participant ' participant{p}]);
    disp(datetime)
    disp(' ');  

    % Rename events (if they are already renamed, nothing will happen)
    for c =1:length(condition_FFR)
        if strcmp(subject_array{pos_subj,23},'exception_triggers')
            sFiles_FFR_low = bst_process('CallProcess', 'process_evt_rename', sFiles_FFR_low, [], ...
                'src',  condition_FFR_exception{c}, ...
                'dest', condition_names_FFR_low{c});
            sFiles_FFR_medium = bst_process('CallProcess', 'process_evt_rename', sFiles_FFR_medium, [], ...
                'src',  condition_FFR_exception{c}, ...
                'dest', condition_names_FFR_medium{c});
            sFiles_FFR_high = bst_process('CallProcess', 'process_evt_rename', sFiles_FFR_high, [], ...
                'src',  condition_FFR_exception{c}, ...
                'dest', condition_names_FFR_high{c});
        else
            sFiles_FFR_low = bst_process('CallProcess', 'process_evt_rename', sFiles_FFR_low, [], ...
                'src',  condition_FFR{c}, ...
                'dest', condition_names_FFR_low{c});
            sFiles_FFR_medium = bst_process('CallProcess', 'process_evt_rename', sFiles_FFR_medium, [], ...
                'src',  condition_FFR{c}, ...
                'dest', condition_names_FFR_medium{c});
            sFiles_FFR_high = bst_process('CallProcess', 'process_evt_rename', sFiles_FFR_high, [], ...
                'src',  condition_FFR{c}, ...
                'dest', condition_names_FFR_high{c});
        end
    end    
    for c =1:length(condition_LLR)
        if strcmp(subject_array{pos_subj,23},'exception_triggers')
            sFiles_LLR_400ms = bst_process('CallProcess', 'process_evt_rename', sFiles_LLR_400ms, [], ...
                'src',  condition_LLR_exception{c}, ...
                'dest', condition_names_LLR_400ms{c});
            sFiles_LLR_1s = bst_process('CallProcess', 'process_evt_rename', sFiles_LLR_1s, [], ...
                'src',  condition_LLR_exception{c}, ...
                'dest', condition_names_LLR_1s{c});
        else
            sFiles_LLR_400ms = bst_process('CallProcess', 'process_evt_rename', sFiles_LLR_400ms, [], ...
                'src',  condition_LLR{c}, ...
                'dest', condition_names_LLR_400ms{c});
            sFiles_LLR_1s = bst_process('CallProcess', 'process_evt_rename', sFiles_LLR_1s, [], ...
                'src',  condition_LLR{c}, ...
                'dest', condition_names_LLR_1s{c});
        end
    end    

    disp(' ');      
    disp('-------------------------');  
    disp(['Making epochs for ' participant{p}]);
    disp(datetime)
    disp(' ');  

    % Process: epoch data for normal epochs
    sFiles_FFR_low = bst_process('CallProcess', 'process_import_data_event', sFiles_FFR_low, [], ...
        'subjectname',  participant{p}, ...
        'condition',    '', ...
    ...%    'datafile',     RawFiles, ...
        'eventname',    event_name_FFR_low, ...
        'timewindow',   [], ...
        'epochtime',    epoch_wave_FFR, ...
        'createcond',   1, ...
        'ignoreshort',  1, ...
        'channelalign', 0, ...
        'usectfcomp',   0, ...
        'usessp',       1, ...
        'freq',         [], ...
        'baseline',     []); % Process: epoch data for normal epochs
    
    sFiles_FFR_medium = bst_process('CallProcess', 'process_import_data_event', sFiles_FFR_medium, [], ...
        'subjectname',  participant{p}, ...
        'condition',    '', ...
    ...%    'datafile',     RawFiles, ...
        'eventname',    event_name_FFR_medium, ...
        'timewindow',   [], ...
        'epochtime',    epoch_wave_FFR, ...
        'createcond',   1, ...
        'ignoreshort',  1, ...
        'channelalign', 0, ...
        'usectfcomp',   0, ...
        'usessp',       1, ...
        'freq',         [], ...
        'baseline',     []); 
    
    % Process: epoch data for normal epochs
    sFiles_FFR_high = bst_process('CallProcess', 'process_import_data_event', sFiles_FFR_high, [], ...
        'subjectname',  participant{p}, ...
        'condition',    '', ...
    ...%    'datafile',     RawFiles, ...
        'eventname',    event_name_FFR_high, ...
        'timewindow',   [], ...
        'epochtime',    epoch_wave_FFR, ...
        'createcond',   1, ...
        'ignoreshort',  1, ...
        'channelalign', 0, ...
        'usectfcomp',   0, ...
        'usessp',       1, ...
        'freq',         [], ...
        'baseline',     []); 
    
    % Process: epoch data for normal epochs
    sFiles_LLR_400ms = bst_process('CallProcess', 'process_import_data_event', sFiles_LLR_400ms, [], ...
        'subjectname',  participant{p}, ...
        'condition',    '', ...
    ...%    'datafile',     RawFiles, ...
        'eventname',    event_name_LLR_400ms, ...
        'timewindow',   [], ...
        'epochtime',    epoch_wave_LLR, ...
        'createcond',   1, ...
        'ignoreshort',  1, ...
        'channelalign', 0, ...
        'usectfcomp',   0, ...
        'usessp',       1, ...
        'freq',         [], ...
        'baseline',     []); 
    
    % Process: epoch data for normal epochs
    sFiles_LLR_1s = bst_process('CallProcess', 'process_import_data_event', sFiles_LLR_1s, [], ...
        'subjectname',  participant{p}, ...
        'condition',    '', ...
    ...%    'datafile',     RawFiles, ...
        'eventname',    event_name_LLR_1s, ...
        'timewindow',   [], ...
        'epochtime',    epoch_wave_LLR, ...
        'createcond',   1, ...
        'ignoreshort',  1, ...
        'channelalign', 0, ...
        'usectfcomp',   0, ...
        'usessp',       1, ...
        'freq',         [], ...
        'baseline',     []); 
    
    disp(' ');      
    disp('-------------------------');  
    disp(['Baseline correcting epochs for ' participant{p}]);
    disp(datetime)
    disp(' ');  

    % Process: DC offset correction: [-50ms,1ms]
    sFiles_FFR_low = bst_process('CallProcess', 'process_baseline_norm', sFiles_FFR_low, [], ...
        'baseline',    epoch_baseline_FFR, ...
        'sensortypes', '', ...
        'method',      'bl', ...  % DC offset correction:    x_std = x - &mu;
        'overwrite',   1);
    
    % Process: DC offset correction: [-50ms,1ms]
    sFiles_FFR_medium = bst_process('CallProcess', 'process_baseline_norm', sFiles_FFR_medium, [], ...
        'baseline',    epoch_baseline_FFR, ...
        'sensortypes', '', ...
        'method',      'bl', ...  % DC offset correction:    x_std = x - &mu;
        'overwrite',   1);
    
    % Process: DC offset correction: [-50ms,1ms]
    sFiles_FFR_high = bst_process('CallProcess', 'process_baseline_norm', sFiles_FFR_high, [], ...
        'baseline',    epoch_baseline_FFR, ...
        'sensortypes', '', ...
        'method',      'bl', ...  % DC offset correction:    x_std = x - &mu;
        'overwrite',   1);
    
    % Process: DC offset correction: [-50ms,1ms]
    sFiles_LLR_400ms = bst_process('CallProcess', 'process_baseline_norm', sFiles_LLR_400ms, [], ...
        'baseline',    epoch_baseline_LLR, ...
        'sensortypes', '', ...
        'method',      'bl', ...  % DC offset correction:    x_std = x - &mu;
        'overwrite',   1);
    
    % Process: DC offset correction: [-50ms,1ms]
    sFiles_LLR_1s = bst_process('CallProcess', 'process_baseline_norm', sFiles_LLR_1s, [], ...
        'baseline',    epoch_baseline_LLR, ...
        'sensortypes', '', ...
        'method',      'bl', ...  % DC offset correction:    x_std = x - &mu;
        'overwrite',   1);
    
    disp(' ');      
    disp('-------------------------');  
    disp(['Cleaning epochs for ' participant{p} '(EEG)']);
    disp(datetime)
    disp(' '); 

    % Process: Detect bad trials: Absolute threshold EEG
    sFiles_FFR_low = bst_process('CallProcess', 'process_CNRL_detectbad', sFiles_FFR_low, [], ...
        'timewindow', [], ...
        'meggrad',    [0, 0], ...
        'megmag',     [0, 0], ...
        'eeg',        reject_EEG_absolute_FFR, ...
        'ieeg',       [0, 0], ...
        'eog',        [0, 0], ...
        'ecg',        [0, 0], ...
        'rejectmode', 2);  % Reject the entire trial
    
    % Process: Detect bad trials: Absolute threshold EEG
    sFiles_FFR_medium = bst_process('CallProcess', 'process_CNRL_detectbad', sFiles_FFR_medium, [], ...
        'timewindow', [], ...
        'meggrad',    [0, 0], ...
        'megmag',     [0, 0], ...
        'eeg',        reject_EEG_absolute_FFR, ...
        'ieeg',       [0, 0], ...
        'eog',        [0, 0], ...
        'ecg',        [0, 0], ...
        'rejectmode', 2);  % Reject the entire trial
    
    % Process: Detect bad trials: Absolute threshold EEG
    sFiles_FFR_high = bst_process('CallProcess', 'process_CNRL_detectbad', sFiles_FFR_high, [], ...
        'timewindow', [], ...
        'meggrad',    [0, 0], ...
        'megmag',     [0, 0], ...
        'eeg',        reject_EEG_absolute_FFR, ...
        'ieeg',       [0, 0], ...
        'eog',        [0, 0], ...
        'ecg',        [0, 0], ...
        'rejectmode', 2);  % Reject the entire trial
    
    % Process: Detect bad trials: Absolute threshold EEG
    sFiles_LLR_400ms = bst_process('CallProcess', 'process_CNRL_detectbad', sFiles_LLR_400ms, [], ...
        'timewindow', [], ...
        'meggrad',    [0, 0], ...
        'megmag',     [0, 0], ...
        'eeg',        reject_EEG_absolute_LLR, ...
        'ieeg',       [0, 0], ...
        'eog',        [0, 0], ...
        'ecg',        [0, 0], ...
        'rejectmode', 2);  % Reject the entire trial
    
    % Process: Detect bad trials: Absolute threshold EEG
    sFiles_LLR_1s = bst_process('CallProcess', 'process_CNRL_detectbad', sFiles_LLR_1s, [], ...
        'timewindow', [], ...
        'meggrad',    [0, 0], ...
        'megmag',     [0, 0], ...
        'eeg',        reject_EEG_absolute_LLR, ...
        'ieeg',       [0, 0], ...
        'eog',        [0, 0], ...
        'ecg',        [0, 0], ...
        'rejectmode', 2);  % Reject the entire trial
    
    % SENSOR AVERAGE EEG  
    disp(' ');      
    disp('-------------------------');  
    disp(['Averaging epochs for ' participant{p} '(EEG)']);
    disp(datetime)
    disp(' '); 

    sFiles_FFR_low = bst_process('CallProcess', 'process_average', sFiles_FFR_low, [], ...
        'avgtype',         5, ...  % By trial group (folder average)
        'avg_func',        1, ...  % Arithmetic average:  mean(x)
        'weighted',        0, ...
        'keepevents', 0);
    
    sFiles_FFR_medium = bst_process('CallProcess', 'process_average', sFiles_FFR_medium, [], ...
        'avgtype',         5, ...  % By trial group (folder average)
        'avg_func',        1, ...  % Arithmetic average:  mean(x)
        'weighted',        0, ...
        'keepevents', 0);
    
    sFiles_FFR_high = bst_process('CallProcess', 'process_average', sFiles_FFR_high, [], ...
        'avgtype',         5, ...  % By trial group (folder average)
        'avg_func',        1, ...  % Arithmetic average:  mean(x)
        'weighted',        0, ...
        'keepevents', 0);
    
    sFiles_LLR_400ms = bst_process('CallProcess', 'process_average', sFiles_LLR_400ms, [], ...
        'avgtype',         5, ...  % By trial group (folder average)
        'avg_func',        1, ...  % Arithmetic average:  mean(x)
        'weighted',        0, ...
        'keepevents', 0);
    
    sFiles_LLR_1s = bst_process('CallProcess', 'process_average', sFiles_LLR_1s, [], ...
        'avgtype',         5, ...  % By trial group (folder average)
        'avg_func',        1, ...  % Arithmetic average:  mean(x)
        'weighted',        0, ...
        'keepevents', 0);
    
    % Process: Add tag
    sFiles_FFR_low = bst_process('CallProcess', 'process_add_tag', sFiles_FFR_low, [], ...
        'tag',           'FFR_average', ...
        'output',        2);  % Add to file name (1 to add a tag)
    
    % Process: Add tag
    sFiles_FFR_medium = bst_process('CallProcess', 'process_add_tag', sFiles_FFR_medium, [], ...
        'tag',           'FFR_average', ...
        'output',        2);  % Add to file name (1 to add a tag)
    
    % Process: Add tag
    sFiles_FFR_high = bst_process('CallProcess', 'process_add_tag', sFiles_FFR_high, [], ...
        'tag',           'FFR_average', ...
        'output',        2);  % Add to file name (1 to add a tag)
    
    % Process: Add tag
    sFiles_LLR_400ms = bst_process('CallProcess', 'process_add_tag', sFiles_LLR_400ms, [], ...
        'tag',           'LLR_average', ...
        'output',        2);  % Add to file name (1 to add a tag)
    
    % Process: Add tag
    sFiles_LLR_1s = bst_process('CallProcess', 'process_add_tag', sFiles_LLR_1s, [], ...
        'tag',           'LLR_average', ...
        'output',        2);  % Add to file name (1 to add a tag)

    % Process: Set name
    sFiles_FFR_low = bst_process('CallProcess', 'process_set_comment', sFiles_FFR_low, [], ...
        'tag',           'FFR_average', ...
        'isindex',       1);
    
    % Process: Set name
    sFiles_FFR_medium = bst_process('CallProcess', 'process_set_comment', sFiles_FFR_medium, [], ...
        'tag',           'FFR_average', ...
        'isindex',       1);
    
    % Process: Set name
    sFiles_FFR_high = bst_process('CallProcess', 'process_set_comment', sFiles_FFR_high, [], ...
        'tag',           'FFR_average', ...
        'isindex',       1);
    
     % Process: Set name
    sFiles_LLR_400ms = bst_process('CallProcess', 'process_set_comment', sFiles_LLR_400ms, [], ...
        'tag',           'LLR_average', ...
        'isindex',       1);
    
    % Process: Set name
    sFiles_LLR_1s = bst_process('CallProcess', 'process_set_comment', sFiles_LLR_1s, [], ...
        'tag',           'LLR_average', ...
        'isindex',       1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%% Now, average two FFR polarities %%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Reload so that epoch folders appear first
    prot_subs = bst_get('ProtocolSubjects');
    current_sub = find(strcmp({prot_subs.Subject.Name}, participant{p}));
    db_reload_conditions(current_sub);
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% FFR LOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find Pol_1 and Pol_2 files    
    folders_Pol_1 = dir([root_dir_bs '/data/' participant{p} '/Pol_1_low/']);
    infolder_Pol_1 = find(contains({folders_Pol_1.name},'_average_'));
    % Choose most recent one if there are two
    if length(infolder_Pol_1) > 1; infolder_Pol_1 = infolder_Pol_1(end);end
    folders_Pol_2 = dir([root_dir_bs '/data/' participant{p} '/Pol_2_low/']);
    infolder_Pol_2 = find(contains({folders_Pol_2.name},'_average_'));
    % Choose most recent one if there are two
    if length(infolder_Pol_2) > 1; infolder_Pol_2 = infolder_Pol_2(end);end
    if isempty(infolder_Pol_1)
        error(['No FFR Pol_1_low average for ' participant{p}]);
    end
    if isempty(infolder_Pol_2)
        error(['No FFR Pol_2_low average for ' participant{p}]);
    end
    
    sFiles_Pol_1 = [participant{p} '/Pol_1_low/' folders_Pol_1(infolder_Pol_1).name];
    sFiles_Pol_2 = [participant{p} '/Pol_2_low/' folders_Pol_2(infolder_Pol_2).name];
    
    sFiles_average = {sFiles_Pol_1, sFiles_Pol_2};
    
    % Process: Weighted Average: Everything
    sFiles_average = bst_process('CallProcess', 'process_average', sFiles_average, [], ...
    'avgtype',       1, ...  % Everything
    'avg_func',      1, ...  % Arithmetic average:  mean(x)
    'weighted',      1, ...
    'keepevents',    0);
    
    % Process: Add tag
    sFiles_average = bst_process('CallProcess', 'process_add_tag', sFiles_average, [], ...
        'tag',           'FFR_average_low', ...
        'output',        2);  % Add to file name (1 to add a tag)

    % Process: Set name
    sFiles_average = bst_process('CallProcess', 'process_set_comment', sFiles_average, [], ...
        'tag',           'FFR_average_low', ...
        'isindex',       1);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% FFR MEDIUM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find Pol_1 and Pol_2 files    
    folders_Pol_1 = dir([root_dir_bs '/data/' participant{p} '/Pol_1_medium/']);
    infolder_Pol_1 = find(contains({folders_Pol_1.name},'_average_'));
    % Choose most recent one if there are two
    if length(infolder_Pol_1) > 1; infolder_Pol_1 = infolder_Pol_1(end);end
    folders_Pol_2 = dir([root_dir_bs '/data/' participant{p} '/Pol_2_medium/']);
    infolder_Pol_2 = find(contains({folders_Pol_2.name},'_average_'));
    % Choose most recent one if there are two
    if length(infolder_Pol_2) > 1; infolder_Pol_2 = infolder_Pol_2(end);end
    if isempty(infolder_Pol_1)
        error(['No FFR Pol_1_medium average for ' participant{p}]);
    end
    if isempty(infolder_Pol_2)
        error(['No FFR Pol_2_medium average for ' participant{p}]);
    end
    
    sFiles_Pol_1 = [participant{p} '/Pol_1_medium/' folders_Pol_1(infolder_Pol_1).name];
    sFiles_Pol_2 = [participant{p} '/Pol_2_medium/' folders_Pol_2(infolder_Pol_2).name];
    
    sFiles_average = {sFiles_Pol_1, sFiles_Pol_2};
    
    % Process: Weighted Average: Everything
    sFiles_average = bst_process('CallProcess', 'process_average', sFiles_average, [], ...
    'avgtype',       1, ...  % Everything
    'avg_func',      1, ...  % Arithmetic average:  mean(x)
    'weighted',      1, ...
    'keepevents',    0);
    
    % Process: Add tag
    sFiles_average = bst_process('CallProcess', 'process_add_tag', sFiles_average, [], ...
        'tag',           'FFR_average_medium', ...
        'output',        2);  % Add to file name (1 to add a tag)

    % Process: Set name
    sFiles_average = bst_process('CallProcess', 'process_set_comment', sFiles_average, [], ...
        'tag',           'FFR_average_medium', ...
        'isindex',       1);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% FFR HIGH %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find Pol_1 and Pol_2 files    
    folders_Pol_1 = dir([root_dir_bs '/data/' participant{p} '/Pol_1_high/']);
    infolder_Pol_1 = find(contains({folders_Pol_1.name},'_average_'));
    % Choose most recent one if there are two
    if length(infolder_Pol_1) > 1; infolder_Pol_1 = infolder_Pol_1(end);end
    folders_Pol_2 = dir([root_dir_bs '/data/' participant{p} '/Pol_2_high/']);
    infolder_Pol_2 = find(contains({folders_Pol_2.name},'_average_'));
    % Choose most recent one if there are two
    if length(infolder_Pol_2) > 1; infolder_Pol_2 = infolder_Pol_2(end);end
    if isempty(infolder_Pol_1)
        error(['No FFR Pol_1_high average for ' participant{p}]);
    end
    if isempty(infolder_Pol_2)
        error(['No FFR Pol_2_high average for ' participant{p}]);
    end
    
    sFiles_Pol_1 = [participant{p} '/Pol_1_high/' folders_Pol_1(infolder_Pol_1).name];
    sFiles_Pol_2 = [participant{p} '/Pol_2_high/' folders_Pol_2(infolder_Pol_2).name];
    
    sFiles_average = {sFiles_Pol_1, sFiles_Pol_2};
    
    % Process: Weighted Average: Everything
    sFiles_average = bst_process('CallProcess', 'process_average', sFiles_average, [], ...
    'avgtype',       1, ...  % Everything
    'avg_func',      1, ...  % Arithmetic average:  mean(x)
    'weighted',      1, ...
    'keepevents',    0);
    
    % Process: Add tag
    sFiles_average = bst_process('CallProcess', 'process_add_tag', sFiles_average, [], ...
        'tag',           'FFR_average_high', ...
        'output',        2);  % Add to file name (1 to add a tag)

    % Process: Set name
    sFiles_average = bst_process('CallProcess', 'process_set_comment', sFiles_average, [], ...
        'tag',           'FFR_average_high', ...
        'isindex',       1);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % If successful, update subject_array for this subject
    subject_array{pos_subj,3} = 'ready_to_extract';
    save([root_dir '/subject_array.mat'],'subject_array') 
    
    end  
end

clearvars('-except', initialVars{:});
disp 'DONE WITH EPOCHING, CLEANING AND AVERAGE (FFR_Sz)!!!'
disp(datetime)
toc

%% Extract LLR/FFR time/frequency domain out of brainstorm

% In here not only do we extract LLR/FFR, but also we compute FFR frequency decomposition

tic
disp(' ');      
disp('-------------------------');  
disp('EXTRACTING LLR AND FFR TIME DOMAIN AND FREQ DOMAIN COMPUTED (FFR_Sz)');  
disp(datetime)
disp('-------------------------');     
disp(' '); 

% Store to preserve later
original_single_channel = choice_channel_EEG;

% Do with single channel
for p = 1:length(participant)
    % Check log info about the subject
    pos_subj = find(strcmp({subject_array{:,1}},participant{p}));
    if strcmp(subject_array{pos_subj,3},'ready_to_extract')
    
    % Reload subject first
    disp(' ');      
    disp('-------------------------');
    disp(['loading participant ' participant{p}]);
    disp(datetime)
    disp(' '); 

    prot_subs = bst_get('ProtocolSubjects');
    current_sub = find(strcmp({prot_subs.Subject.Name}, participant{p}));
    db_reload_conditions(current_sub);
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FFR LOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find files    
    folders = dir([root_dir_bs '/data/' participant{p} '/@intra/']);
    infolder_FFR_average = find(endsWith({folders.name},'FFR_average_low.mat'));
    % Choose most recent one if there are more than one
    if length(infolder_FFR_average) > 1; infolder_FFR_average = infolder_FFR_average(end);end

    if isempty(infolder_FFR_average)
        error(['No FFR @intra average for ' participant{p}]);
    end
    
    sFiles_FFR_average = [participant{p} '/@intra/' folders(infolder_FFR_average).name];

    % Load channel file
    load([root_dir_bs '/data/' participant{p} '/@intra/channel.mat']);
    % Get the position of channel
    pos_data = [];
    for ch = 1:length(choice_channel_EEG)
        pos_data(ch) = find(strcmp({Channel.Name},choice_channel_EEG{ch}));
    end

    % Load averaged FFR data
    load([root_dir_bs '/data/' sFiles_FFR_average])

    % Retrieve amplitudes at each channel
    Average = [];
    for ps = 1:length(pos_data)
        Average(ps,:) = F(pos_data(ps),:);
    end

    % If it was more than one channel, average across channels
    if size(Average,1) > 1
        Average = mean(Average,1);
    end
    
    % Create participant folder if not already there
    if ~exist([root_dir '/Results/' participant{p}], 'dir')
        mkdir([root_dir '/Results/'], [participant{p}]);
    end

    disp(' ');      
    disp('-------------------------');
    disp(['Extracting FFR LOW average for ' participant{p}]);
    disp(datetime)
    disp(' ');
    
    % For cluster vs single channel
    if length(choice_channel_EEG) > 1
        channel_string = 'cluster';
    else
        channel_string = choice_channel_EEG{1};
    end
    
    % Finnally, extract values outside Brainstorm
    save([root_dir '/Results/' participant{p} '/FFR_low_' channel_string '.mat'],'Average');
    
    % Compute and extract a low-pass filtered version of the time domain
    
    % Delete any previous low pass filtered FFR
    if delete_previous_file == 1
        folders_delete = dir([root_dir_bs '/data/' participant{p} '/@intra']);
        infolder_delete = find(endsWith({folders_delete.name},['FFR_low_' low_pass_FFR_low_string '.mat']));
        if ~isempty(infolder_delete) % file exists, therefore delete it
           delete([root_dir_bs '/data/' participant{p} '/@intra/' folders_delete(infolder_delete).name]);
        end
    end
    
    disp(' ');      
    disp('-------------------------');
    disp(['Extracting a low-pass version of FFR LOW average for ' participant{p}]);
    disp(datetime)
    disp(' ');
    
    % Process: Low-pass:
    sFiles_FFR_filtered = bst_process('CallProcess', 'process_bandpass', sFiles_FFR_average, [], ...
        'sensortypes', 'EEG', ...
        'highpass',    0, ...
        'lowpass',     low_pass_FFR_low, ...
        'tranband',    10, ...
        'attenuation', 'strict', ...  % 60dB
        'ver',         '2019', ...  % 2019
        'mirror',      0, ...
        'overwrite',   0);
    
     % Process: Add tag
    sFiles_FFR_filtered = bst_process('CallProcess', 'process_add_tag', sFiles_FFR_filtered, [], ...
        'tag',           ['FFR_low_' low_pass_FFR_low_string], ...
        'output',        2);  % Add to file name (1 to add a tag)

    % Process: Set name
    sFiles_FFR_filtered = bst_process('CallProcess', 'process_set_comment', sFiles_FFR_filtered, [], ...
        'tag',           ['FFR_low_' low_pass_FFR_low_string], ...
        'isindex',       1);
    
    % Load channel file
    load([root_dir_bs '/data/' participant{p} '/@intra/channel.mat']);
    % Get the position of channel
    pos_data = [];
    for ch = 1:length(choice_channel_EEG)
        pos_data(ch) = find(strcmp({Channel.Name},choice_channel_EEG{ch}));
    end
    
    % Load Low_pass FFR file
    load([root_dir_bs '/data/' sFiles_FFR_filtered.FileName]);
    
    % Retrieve amplitudes at each channel
    Average = [];
    for ps = 1:length(pos_data)
        Average(ps,:) = F(pos_data(ps),:);
    end

    % If it was more than one channel, average across channels
    if size(Average,1) > 1
        Average = mean(Average,1);
    end
    
    % Finnally, extract values outside Brainstorm
    save([root_dir '/Results/' participant{p} '/FFR_low_' low_pass_FFR_low_string '_' channel_string '.mat'],'Average');
    
    % Compute FFT and extract it out of brainstorm
    % Do so in every time window: Pre (-40 0), Tra (10-55), Con (55-170), Tot (10-170). Asuming 10ms of neural lag    
    for tw = 1:length(time_windows_FFR)
        
        disp(' ');      
        disp('-------------------------');
        disp(['Computing FFT for FFR LOW ' participant{p} ' ' time_windows_FFR_labels{tw}]);
        disp(datetime)
        disp(' ');  
                
        % Load original average to compute FFTs
        load([root_dir '/Results/' participant{p} '/FFR_low_' channel_string '.mat']);
        
        % Compute and save FFT 
        % (Here you can replace this with Brainstorm steps commented below        
        SR =  round(length(Average)/0.270); % Sampling rate
        % Define section to compute FFT on
        time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
        [~,closestIndex] = min(abs(time_samples-(time_windows_FFR{tw}(1)*1000)));
        init_time = closestIndex;
        [~,closestIndex] = min(abs(time_samples-(time_windows_FFR{tw}(2)*1000)));
        end_time = closestIndex;        
        Average_section = Average(1,init_time:end_time);
        
        % Now compute FFT
        complex_spect = fft(Average_section,SR)/length(Average_section);
        freqs = SR/2*linspace(0,1,SR/2+1);
        amplitude = 2*abs(complex_spect(1:SR/2+1));
        
        % Save resulting FFT
        save([root_dir '/Results/' participant{p} '/FFT_low_' time_windows_FFR_labels{tw} '_' channel_string '.mat'],'amplitude');
        
        % Compute FFT with Brainstorm too (alternative to compare)
        % Delete any previous TF in brainstorm
        if delete_previous_file == 1
            folders_delete = dir([root_dir_bs '/data/' participant{p} '/@intra']);
            infolder_delete = find(endsWith({folders_delete.name},['FFT_low_' time_windows_FFR_labels{tw} '.mat']));
            if ~isempty(infolder_delete) % file exists, therefore delete it
               delete([root_dir_bs '/data/' participant{p} '/@intra/' folders_delete(infolder_delete).name]);
            end
        end

        sFiles_FFT = bst_process('CallProcess', 'process_fft', sFiles_FFR_average, [], ...
        'timewindow',  time_windows_FFR{tw}, ...
        'units',       'physical', ...  % Physical: U2/Hz
        'sensortypes', 'EEG', ...
        'avgoutput',   1);
        
        % Process: Add tag
        sFiles_FFT = bst_process('CallProcess', 'process_add_tag', sFiles_FFT, [], ...
            'tag',           ['FFT_low_' time_windows_FFR_labels{tw}], ...
            'output',        2);  % Add to file name (1 to add a tag)

        % Process: Set name
        sFiles_FFT = bst_process('CallProcess', 'process_set_comment', sFiles_FFT, [], ...
            'tag',           ['FFT_low_' time_windows_FFR_labels{tw}], ...
            'isindex',       1);
              
        % Just to have them for comparison in Brainstorm, don't extract them
        
    end

    % Compute Time-Frequency analysis
    
    disp(' ');      
    disp('-------------------------');
    disp(['Computing Time Frequency for ' participant{p} 'FFR LOW']);
    disp(datetime)
    disp(' ');  
    
    % Delete any previous TF in brainstorm    
    if delete_previous_file == 1
        folders_delete = dir([root_dir_bs '/data/' participant{p} '/@intra']);
        infolder_delete = find(endsWith({folders_delete.name},'Time_Frequency_low.mat'));
        if ~isempty(infolder_delete) % file exists, therefore delete it
           delete([root_dir_bs '/data/' participant{p} '/@intra/' folders_delete(infolder_delete).name]);
        end
    end
 
    % Process: Time-frequency (Morlet wavelets)
    sFiles_TF = bst_process('CallProcess', 'process_timefreq', sFiles_FFR_average, [], ...
        'sensortypes', 'EEG', ...
        'edit',        struct(...
             'Comment',         'Power,1-500Hz', ...
             'TimeBands',       [], ...
             'Freqs',           [1:500], ...
             'MorletFc',        1, ...
             'MorletFwhmTc',    3, ...
             'ClusterFuncTime', 'none', ...
             'Measure',         'power', ...
             'Output',          'all', ...
             'SaveKernel',      0), ...
        'normalize',   'none');  % None: Save non-standardized time-frequency maps
    
    % Process: Add tag
    sFiles_TF = bst_process('CallProcess', 'process_add_tag', sFiles_TF, [], ...
        'tag',           'Time_Frequency_low', ...
        'output',        2);  % Add to file name (1 to add a tag)

    % Process: Set name
    sFiles_TF = bst_process('CallProcess', 'process_set_comment', sFiles_TF, [], ...
        'tag',           'Time_Frequency_low', ...
        'isindex',       1);

    % Load TF file
    load([root_dir_bs '/data/' sFiles_TF.FileName])
    
    % Get the position of channel
    pos_data = [];
    for ch = 1:length(choice_channel_EEG)
        pos_data(ch) = find(strcmp(RowNames,choice_channel_EEG{ch}));
    end
    
    % Retrieve amplitudes at each channel
    tf_map = [];
    for ps = 1:length(pos_data)
        tf_map(ps,:,:) = TF(pos_data(ps),:,:);
    end

    % If it was more than one channel, average across channels
    if size(tf_map,1) > 1
        tf_map = mean(tf_map,1);
    end
    
    % Now save the tf_map outside brainstorm
    save([root_dir '/Results/' participant{p} '/Time_Frequency_low_' channel_string '.mat'],'tf_map');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FFR MEDIUM %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find files    
    folders = dir([root_dir_bs '/data/' participant{p} '/@intra/']);
    infolder_FFR_average = find(endsWith({folders.name},'FFR_average_medium.mat'));
    % Choose most recent one if there are more than one
    if length(infolder_FFR_average) > 1; infolder_FFR_average = infolder_FFR_average(end);end

    if isempty(infolder_FFR_average)
        error(['No FFR @intra average for ' participant{p}]);
    end
    
    sFiles_FFR_average = [participant{p} '/@intra/' folders(infolder_FFR_average).name];

    % Load channel file
    load([root_dir_bs '/data/' participant{p} '/@intra/channel.mat']);
    % Get the position of channel
    pos_data = [];
    for ch = 1:length(choice_channel_EEG)
        pos_data(ch) = find(strcmp({Channel.Name},choice_channel_EEG{ch}));
    end

    % Load averaged FFR data
    load([root_dir_bs '/data/' sFiles_FFR_average])

    % Retrieve amplitudes at each channel
    Average = [];
    for ps = 1:length(pos_data)
        Average(ps,:) = F(pos_data(ps),:);
    end

    % If it was more than one channel, average across channels
    if size(Average,1) > 1
        Average = mean(Average,1);
    end
    
    % Create participant folder if not already there
    if ~exist([root_dir '/Results/' participant{p}], 'dir')
        mkdir([root_dir '/Results/'], [participant{p}]);
    end

    disp(' ');      
    disp('-------------------------');
    disp(['Extracting FFR MEDIUM average for ' participant{p}]);
    disp(datetime)
    disp(' ');
    
    % For cluster vs single channel
    if length(choice_channel_EEG) > 1
        channel_string = 'cluster';
    else
        channel_string = choice_channel_EEG{1};
    end
    
    % Finnally, extract values outside Brainstorm
    save([root_dir '/Results/' participant{p} '/FFR_medium_' channel_string '.mat'],'Average');
    
    % Compute and extract a low-pass filtered version of the time domain
    
    % Delete any previous low pass filtered FFR
    if delete_previous_file == 1
        folders_delete = dir([root_dir_bs '/data/' participant{p} '/@intra']);
        infolder_delete = find(endsWith({folders_delete.name},['FFR_medium_' low_pass_FFR_medium_string '.mat']));
        if ~isempty(infolder_delete) % file exists, therefore delete it
           delete([root_dir_bs '/data/' participant{p} '/@intra/' folders_delete(infolder_delete).name]);
        end
    end
    
    disp(' ');      
    disp('-------------------------');
    disp(['Extracting a low-pass version of FFR MEDIUM average for ' participant{p}]);
    disp(datetime)
    disp(' ');
    
    % Process: Low-pass:
    sFiles_FFR_filtered = bst_process('CallProcess', 'process_bandpass', sFiles_FFR_average, [], ...
        'sensortypes', 'EEG', ...
        'highpass',    0, ...
        'lowpass',     low_pass_FFR_medium, ...
        'tranband',    10, ...
        'attenuation', 'strict', ...  % 60dB
        'ver',         '2019', ...  % 2019
        'mirror',      0, ...
        'overwrite',   0);
    
     % Process: Add tag
    sFiles_FFR_filtered = bst_process('CallProcess', 'process_add_tag', sFiles_FFR_filtered, [], ...
        'tag',           ['FFR_medium_' low_pass_FFR_medium_string], ...
        'output',        2);  % Add to file name (1 to add a tag)

    % Process: Set name
    sFiles_FFR_filtered = bst_process('CallProcess', 'process_set_comment', sFiles_FFR_filtered, [], ...
        'tag',           ['FFR_medium_' low_pass_FFR_medium_string], ...
        'isindex',       1);
    
    % Load channel file
    load([root_dir_bs '/data/' participant{p} '/@intra/channel.mat']);
    % Get the position of channel
    pos_data = [];
    for ch = 1:length(choice_channel_EEG)
        pos_data(ch) = find(strcmp({Channel.Name},choice_channel_EEG{ch}));
    end
    
    % Load Low_pass FFR file
    load([root_dir_bs '/data/' sFiles_FFR_filtered.FileName]);
    
    % Retrieve amplitudes at each channel
    Average = [];
    for ps = 1:length(pos_data)
        Average(ps,:) = F(pos_data(ps),:);
    end

    % If it was more than one channel, average across channels
    if size(Average,1) > 1
        Average = mean(Average,1);
    end
    
    % Finnally, extract values outside Brainstorm
    save([root_dir '/Results/' participant{p} '/FFR_medium_' low_pass_FFR_medium_string '_' channel_string '.mat'],'Average');
    
    % Compute FFT and extract it out of brainstorm
    % Do so in every time window: Pre (-40 0), Tra (10-55), Con (55-170), Tot (10-170). Asuming 10ms of neural lag    
    for tw = 1:length(time_windows_FFR)
        
        disp(' ');      
        disp('-------------------------');
        disp(['Computing FFT for FFR MEDIUM ' participant{p} ' ' time_windows_FFR_labels{tw}]);
        disp(datetime)
        disp(' ');  
                
        % Load original average to compute FFTs
        load([root_dir '/Results/' participant{p} '/FFR_medium_' channel_string '.mat']);
        
        % Compute and save FFT 
        % (Here you can replace this with Brainstorm steps commented below        
        SR =  round(length(Average)/0.270); % Sampling rate
        % Define section to compute FFT on
        time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
        [~,closestIndex] = min(abs(time_samples-(time_windows_FFR{tw}(1)*1000)));
        init_time = closestIndex;
        [~,closestIndex] = min(abs(time_samples-(time_windows_FFR{tw}(2)*1000)));
        end_time = closestIndex;        
        Average_section = Average(1,init_time:end_time);
        
        % Now compute FFT
        complex_spect = fft(Average_section,SR)/length(Average_section);
        freqs = SR/2*linspace(0,1,SR/2+1);
        amplitude = 2*abs(complex_spect(1:SR/2+1));
        
        % Save resulting FFT
        save([root_dir '/Results/' participant{p} '/FFT_medium_' time_windows_FFR_labels{tw} '_' channel_string '.mat'],'amplitude');
        
        % Compute FFT with Brainstorm too (alternative to compare)
        % Delete any previous TF in brainstorm
        if delete_previous_file == 1
            folders_delete = dir([root_dir_bs '/data/' participant{p} '/@intra']);
            infolder_delete = find(endsWith({folders_delete.name},['FFT_medium_' time_windows_FFR_labels{tw} '.mat']));
            if ~isempty(infolder_delete) % file exists, therefore delete it
               delete([root_dir_bs '/data/' participant{p} '/@intra/' folders_delete(infolder_delete).name]);
            end
        end

        sFiles_FFT = bst_process('CallProcess', 'process_fft', sFiles_FFR_average, [], ...
        'timewindow',  time_windows_FFR{tw}, ...
        'units',       'physical', ...  % Physical: U2/Hz
        'sensortypes', 'EEG', ...
        'avgoutput',   1);
        
        % Process: Add tag
        sFiles_FFT = bst_process('CallProcess', 'process_add_tag', sFiles_FFT, [], ...
            'tag',           ['FFT_medium_' time_windows_FFR_labels{tw}], ...
            'output',        2);  % Add to file name (1 to add a tag)

        % Process: Set name
        sFiles_FFT = bst_process('CallProcess', 'process_set_comment', sFiles_FFT, [], ...
            'tag',           ['FFT_medium_' time_windows_FFR_labels{tw}], ...
            'isindex',       1);
              
        % Just to have them for comparison in Brainstorm, don't extract them
        
    end

    % Compute Time-Frequency analysis
    
    disp(' ');      
    disp('-------------------------');
    disp(['Computing Time Frequency for ' participant{p} 'FFR MEDIUM']);
    disp(datetime)
    disp(' ');  
    
    % Delete any previous TF in brainstorm    
    if delete_previous_file == 1
        folders_delete = dir([root_dir_bs '/data/' participant{p} '/@intra']);
        infolder_delete = find(endsWith({folders_delete.name},'Time_Frequency_medium.mat'));
        if ~isempty(infolder_delete) % file exists, therefore delete it
           delete([root_dir_bs '/data/' participant{p} '/@intra/' folders_delete(infolder_delete).name]);
        end
    end
 
    % Process: Time-frequency (Morlet wavelets)
    sFiles_TF = bst_process('CallProcess', 'process_timefreq', sFiles_FFR_average, [], ...
        'sensortypes', 'EEG', ...
        'edit',        struct(...
             'Comment',         'Power,1-500Hz', ...
             'TimeBands',       [], ...
             'Freqs',           [1:500], ...
             'MorletFc',        1, ...
             'MorletFwhmTc',    3, ...
             'ClusterFuncTime', 'none', ...
             'Measure',         'power', ...
             'Output',          'all', ...
             'SaveKernel',      0), ...
        'normalize',   'none');  % None: Save non-standardized time-frequency maps
    
    % Process: Add tag
    sFiles_TF = bst_process('CallProcess', 'process_add_tag', sFiles_TF, [], ...
        'tag',           'Time_Frequency_medium', ...
        'output',        2);  % Add to file name (1 to add a tag)

    % Process: Set name
    sFiles_TF = bst_process('CallProcess', 'process_set_comment', sFiles_TF, [], ...
        'tag',           'Time_Frequency_medium', ...
        'isindex',       1);

    % Load TF file
    load([root_dir_bs '/data/' sFiles_TF.FileName])
    
    % Get the position of channel
    pos_data = [];
    for ch = 1:length(choice_channel_EEG)
        pos_data(ch) = find(strcmp(RowNames,choice_channel_EEG{ch}));
    end
    
    % Retrieve amplitudes at each channel
    tf_map = [];
    for ps = 1:length(pos_data)
        tf_map(ps,:,:) = TF(pos_data(ps),:,:);
    end

    % If it was more than one channel, average across channels
    if size(tf_map,1) > 1
        tf_map = mean(tf_map,1);
    end
    
    % Now save the tf_map outside brainstorm
    save([root_dir '/Results/' participant{p} '/Time_Frequency_medium_' channel_string '.mat'],'tf_map');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FFR HIGH %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find files    
    folders = dir([root_dir_bs '/data/' participant{p} '/@intra/']);
    infolder_FFR_average = find(endsWith({folders.name},'FFR_average_high.mat'));
    % Choose most recent one if there are more than one
    if length(infolder_FFR_average) > 1; infolder_FFR_average = infolder_FFR_average(end);end

    if isempty(infolder_FFR_average)
        error(['No FFR @intra average for ' participant{p}]);
    end
    
    sFiles_FFR_average = [participant{p} '/@intra/' folders(infolder_FFR_average).name];

    % Load channel file
    load([root_dir_bs '/data/' participant{p} '/@intra/channel.mat']);
    % Get the position of channel
    pos_data = [];
    for ch = 1:length(choice_channel_EEG)
        pos_data(ch) = find(strcmp({Channel.Name},choice_channel_EEG{ch}));
    end

    % Load averaged FFR data
    load([root_dir_bs '/data/' sFiles_FFR_average])

    % Retrieve amplitudes at each channel
    Average = [];
    for ps = 1:length(pos_data)
        Average(ps,:) = F(pos_data(ps),:);
    end

    % If it was more than one channel, average across channels
    if size(Average,1) > 1
        Average = mean(Average,1);
    end
    
    % Create participant folder if not already there
    if ~exist([root_dir '/Results/' participant{p}], 'dir')
        mkdir([root_dir '/Results/'], [participant{p}]);
    end

    disp(' ');      
    disp('-------------------------');
    disp(['Extracting FFR HIGH average for ' participant{p}]);
    disp(datetime)
    disp(' ');
    
    % For cluster vs single channel
    if length(choice_channel_EEG) > 1
        channel_string = 'cluster';
    else
        channel_string = choice_channel_EEG{1};
    end
    
    % Finnally, extract values outside Brainstorm
    save([root_dir '/Results/' participant{p} '/FFR_high_' channel_string '.mat'],'Average');
    
    % Compute and extract a low-pass filtered version of the time domain
    
    % Delete any previous low pass filtered FFR
    if delete_previous_file == 1
        folders_delete = dir([root_dir_bs '/data/' participant{p} '/@intra']);
        infolder_delete = find(endsWith({folders_delete.name},['FFR_high_' low_pass_FFR_high_string '.mat']));
        if ~isempty(infolder_delete) % file exists, therefore delete it
           delete([root_dir_bs '/data/' participant{p} '/@intra/' folders_delete(infolder_delete).name]);
        end
    end
    
    disp(' ');      
    disp('-------------------------');
    disp(['Extracting a low-pass version of FFR HIGH average for ' participant{p}]);
    disp(datetime)
    disp(' ');
    
    % Process: Low-pass:
    sFiles_FFR_filtered = bst_process('CallProcess', 'process_bandpass', sFiles_FFR_average, [], ...
        'sensortypes', 'EEG', ...
        'highpass',    0, ...
        'lowpass',     low_pass_FFR_high, ...
        'tranband',    10, ...
        'attenuation', 'strict', ...  % 60dB
        'ver',         '2019', ...  % 2019
        'mirror',      0, ...
        'overwrite',   0);
    
     % Process: Add tag
    sFiles_FFR_filtered = bst_process('CallProcess', 'process_add_tag', sFiles_FFR_filtered, [], ...
        'tag',           ['FFR_high_' low_pass_FFR_high_string], ...
        'output',        2);  % Add to file name (1 to add a tag)

    % Process: Set name
    sFiles_FFR_filtered = bst_process('CallProcess', 'process_set_comment', sFiles_FFR_filtered, [], ...
        'tag',           ['FFR_high_' low_pass_FFR_high_string], ...
        'isindex',       1);
    
    % Load channel file
    load([root_dir_bs '/data/' participant{p} '/@intra/channel.mat']);
    % Get the position of channel
    pos_data = [];
    for ch = 1:length(choice_channel_EEG)
        pos_data(ch) = find(strcmp({Channel.Name},choice_channel_EEG{ch}));
    end
    
    % Load Low_pass FFR file
    load([root_dir_bs '/data/' sFiles_FFR_filtered.FileName]);
    
    % Retrieve amplitudes at each channel
    Average = [];
    for ps = 1:length(pos_data)
        Average(ps,:) = F(pos_data(ps),:);
    end

    % If it was more than one channel, average across channels
    if size(Average,1) > 1
        Average = mean(Average,1);
    end
    
    % Finnally, extract values outside Brainstorm
    save([root_dir '/Results/' participant{p} '/FFR_high_' low_pass_FFR_high_string '_' channel_string '.mat'],'Average');
    
    % Compute FFT and extract it out of brainstorm
    % Do so in every time window: Pre (-40 0), Tra (10-55), Con (55-170), Tot (10-170). Asuming 10ms of neural lag    
    for tw = 1:length(time_windows_FFR)
        
        disp(' ');      
        disp('-------------------------');
        disp(['Computing FFT for FFR HIGH ' participant{p} ' ' time_windows_FFR_labels{tw}]);
        disp(datetime)
        disp(' ');  
                
        % Load original average to compute FFTs
        load([root_dir '/Results/' participant{p} '/FFR_high_' channel_string '.mat']);
        
        % Compute and save FFT 
        % (Here you can replace this with Brainstorm steps commented below        
        SR =  round(length(Average)/0.270); % Sampling rate
        % Define section to compute FFT on
        time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
        [~,closestIndex] = min(abs(time_samples-(time_windows_FFR{tw}(1)*1000)));
        init_time = closestIndex;
        [~,closestIndex] = min(abs(time_samples-(time_windows_FFR{tw}(2)*1000)));
        end_time = closestIndex;        
        Average_section = Average(1,init_time:end_time);
        
        % Now compute FFT
        complex_spect = fft(Average_section,SR)/length(Average_section);
        freqs = SR/2*linspace(0,1,SR/2+1);
        amplitude = 2*abs(complex_spect(1:SR/2+1));
        
        % Save resulting FFT
        save([root_dir '/Results/' participant{p} '/FFT_high_' time_windows_FFR_labels{tw} '_' channel_string '.mat'],'amplitude');
        
        % Compute FFT with Brainstorm too (alternative to compare)
        % Delete any previous TF in brainstorm
        if delete_previous_file == 1
            folders_delete = dir([root_dir_bs '/data/' participant{p} '/@intra']);
            infolder_delete = find(endsWith({folders_delete.name},['FFT_high_' time_windows_FFR_labels{tw} '.mat']));
            if ~isempty(infolder_delete) % file exists, therefore delete it
               delete([root_dir_bs '/data/' participant{p} '/@intra/' folders_delete(infolder_delete).name]);
            end
        end

        sFiles_FFT = bst_process('CallProcess', 'process_fft', sFiles_FFR_average, [], ...
        'timewindow',  time_windows_FFR{tw}, ...
        'units',       'physical', ...  % Physical: U2/Hz
        'sensortypes', 'EEG', ...
        'avgoutput',   1);
        
        % Process: Add tag
        sFiles_FFT = bst_process('CallProcess', 'process_add_tag', sFiles_FFT, [], ...
            'tag',           ['FFT_high_' time_windows_FFR_labels{tw}], ...
            'output',        2);  % Add to file name (1 to add a tag)

        % Process: Set name
        sFiles_FFT = bst_process('CallProcess', 'process_set_comment', sFiles_FFT, [], ...
            'tag',           ['FFT_high_' time_windows_FFR_labels{tw}], ...
            'isindex',       1);
              
        % Just to have them for comparison in Brainstorm, don't extract them
        
    end

    % Compute Time-Frequency analysis
    
    disp(' ');      
    disp('-------------------------');
    disp(['Computing Time Frequency for ' participant{p} 'FFR HIGH']);
    disp(datetime)
    disp(' ');  
    
    % Delete any previous TF in brainstorm    
    if delete_previous_file == 1
        folders_delete = dir([root_dir_bs '/data/' participant{p} '/@intra']);
        infolder_delete = find(endsWith({folders_delete.name},'Time_Frequency_high.mat'));
        if ~isempty(infolder_delete) % file exists, therefore delete it
           delete([root_dir_bs '/data/' participant{p} '/@intra/' folders_delete(infolder_delete).name]);
        end
    end
 
    % Process: Time-frequency (Morlet wavelets)
    sFiles_TF = bst_process('CallProcess', 'process_timefreq', sFiles_FFR_average, [], ...
        'sensortypes', 'EEG', ...
        'edit',        struct(...
             'Comment',         'Power,1-500Hz', ...
             'TimeBands',       [], ...
             'Freqs',           [1:500], ...
             'MorletFc',        1, ...
             'MorletFwhmTc',    3, ...
             'ClusterFuncTime', 'none', ...
             'Measure',         'power', ...
             'Output',          'all', ...
             'SaveKernel',      0), ...
        'normalize',   'none');  % None: Save non-standardized time-frequency maps
    
    % Process: Add tag
    sFiles_TF = bst_process('CallProcess', 'process_add_tag', sFiles_TF, [], ...
        'tag',           'Time_Frequency_high', ...
        'output',        2);  % Add to file name (1 to add a tag)

    % Process: Set name
    sFiles_TF = bst_process('CallProcess', 'process_set_comment', sFiles_TF, [], ...
        'tag',           'Time_Frequency_high', ...
        'isindex',       1);

    % Load TF file
    load([root_dir_bs '/data/' sFiles_TF.FileName])
    
    % Get the position of channel
    pos_data = [];
    for ch = 1:length(choice_channel_EEG)
        pos_data(ch) = find(strcmp(RowNames,choice_channel_EEG{ch}));
    end
    
    % Retrieve amplitudes at each channel
    tf_map = [];
    for ps = 1:length(pos_data)
        tf_map(ps,:,:) = TF(pos_data(ps),:,:);
    end

    % If it was more than one channel, average across channels
    if size(tf_map,1) > 1
        tf_map = mean(tf_map,1);
    end
    
    % Now save the tf_map outside brainstorm
    save([root_dir '/Results/' participant{p} '/Time_Frequency_high_' channel_string '.mat'],'tf_map');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LLR 400ms %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find files    
    folders = dir([root_dir_bs '/data/' participant{p} '/Tone_400ms/']);
    infolder_LLR_average = find(endsWith({folders.name},'LLR_average.mat'));
    % Choose most recent one if there are more than one
    if length(infolder_LLR_average) > 1; infolder_LLR_average = infolder_LLR_average(end);end

    if isempty(infolder_LLR_average)
        error(['No LLR tone average for ' participant{p}]);
    end
    
    sFiles_LLR_average = [participant{p} '/Tone_400ms/' folders(infolder_LLR_average).name];

    % Load channel file
    load([root_dir_bs '/data/' participant{p} '/Tone_400ms/channel.mat']);
    % Get the position of channel
    pos_data = [];
    for ch = 1:length(choice_channel_EEG)
        pos_data(ch) = find(strcmp({Channel.Name},choice_channel_EEG{ch}));
    end

    % Load averaged LLR data
    load([root_dir_bs '/data/' sFiles_LLR_average])

    % Retrieve amplitudes at each channel
    Average = [];
    for ps = 1:length(pos_data)
        Average(ps,:) = F(pos_data(ps),:);
    end

    % If it was more than one channel, average across channels
    if size(Average,1) > 1
        Average = mean(Average,1);
    end
    
    % Take the change and load and extract out of brainstorm every FFT
    % Create participant folder if not already there
    if ~exist([root_dir '/Results/' participant{p}], 'dir')
        mkdir([root_dir '/Results/'], [participant{p}]);
    end

    disp(' ');      
    disp('-------------------------');
    disp(['Extracting LLR 400ms average for ' participant{p}]);
    disp(datetime)
    disp(' ');
    
    % Finnally, extract values outside Brainstorm
    if length(choice_channel_EEG) > 1
        save([root_dir '/Results/' participant{p} '/LLR_400ms_cluster.mat'],'Average');
    else
        save([root_dir '/Results/' participant{p} '/LLR_400ms_' choice_channel_EEG{1} '.mat'],'Average');
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LLR 1s %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find files    
    folders = dir([root_dir_bs '/data/' participant{p} '/Tone_1s/']);
    infolder_LLR_average = find(endsWith({folders.name},'LLR_average.mat'));
    % Choose most recent one if there are more than one
    if length(infolder_LLR_average) > 1; infolder_LLR_average = infolder_LLR_average(end);end

    if isempty(infolder_LLR_average)
        error(['No LLR tone average for ' participant{p}]);
    end
    
    sFiles_LLR_average = [participant{p} '/Tone_1s/' folders(infolder_LLR_average).name];

    % Load channel file
    load([root_dir_bs '/data/' participant{p} '/Tone_1s/channel.mat']);
    % Get the position of channel
    pos_data = [];
    for ch = 1:length(choice_channel_EEG)
        pos_data(ch) = find(strcmp({Channel.Name},choice_channel_EEG{ch}));
    end

    % Load averaged LLR data
    load([root_dir_bs '/data/' sFiles_LLR_average])

    % Retrieve amplitudes at each channel
    Average = [];
    for ps = 1:length(pos_data)
        Average(ps,:) = F(pos_data(ps),:);
    end

    % If it was more than one channel, average across channels
    if size(Average,1) > 1
        Average = mean(Average,1);
    end
    
    % Take the change and load and extract out of brainstorm every FFT
    % Create participant folder if not already there
    if ~exist([root_dir '/Results/' participant{p}], 'dir')
        mkdir([root_dir '/Results/'], [participant{p}]);
    end

    disp(' ');      
    disp('-------------------------');
    disp(['Extracting LLR 1s average for ' participant{p}]);
    disp(datetime)
    disp(' ');
    
    % Finnally, extract values outside Brainstorm
    if length(choice_channel_EEG) > 1
        save([root_dir '/Results/' participant{p} '/LLR_1s_cluster.mat'],'Average');
    else
        save([root_dir '/Results/' participant{p} '/LLR_1s_' choice_channel_EEG{1} '.mat'],'Average');
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    end  
end

% Do with cluster (it only takes extra 5 minutes to repeat with the cluster instead)
choice_channel_EEG = cluster_channel_EEG;
for p = 1:length(participant)
    % Check log info about the subject
    pos_subj = find(strcmp({subject_array{:,1}},participant{p}));
    if strcmp(subject_array{pos_subj,3},'ready_to_extract')
    
    % Reload subject first
    disp(' ');      
    disp('-------------------------');
    disp(['loading participant ' participant{p}]);
    disp(datetime)
    disp(' '); 

    prot_subs = bst_get('ProtocolSubjects');
    current_sub = find(strcmp({prot_subs.Subject.Name}, participant{p}));
    db_reload_conditions(current_sub);
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FFR LOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find files    
    folders = dir([root_dir_bs '/data/' participant{p} '/@intra/']);
    infolder_FFR_average = find(endsWith({folders.name},'FFR_average_low.mat'));
    % Choose most recent one if there are more than one
    if length(infolder_FFR_average) > 1; infolder_FFR_average = infolder_FFR_average(end);end

    if isempty(infolder_FFR_average)
        error(['No FFR @intra average for ' participant{p}]);
    end
    
    sFiles_FFR_average = [participant{p} '/@intra/' folders(infolder_FFR_average).name];

    % Load channel file
    load([root_dir_bs '/data/' participant{p} '/@intra/channel.mat']);
    % Get the position of channel
    pos_data = [];
    for ch = 1:length(choice_channel_EEG)
        pos_data(ch) = find(strcmp({Channel.Name},choice_channel_EEG{ch}));
    end

    % Load averaged FFR data
    load([root_dir_bs '/data/' sFiles_FFR_average])

    % Retrieve amplitudes at each channel
    Average = [];
    for ps = 1:length(pos_data)
        Average(ps,:) = F(pos_data(ps),:);
    end

    % If it was more than one channel, average across channels
    if size(Average,1) > 1
        Average = mean(Average,1);
    end
    
    % Create participant folder if not already there
    if ~exist([root_dir '/Results/' participant{p}], 'dir')
        mkdir([root_dir '/Results/'], [participant{p}]);
    end

    disp(' ');      
    disp('-------------------------');
    disp(['Extracting FFR LOW average for ' participant{p}]);
    disp(datetime)
    disp(' ');
    
    % For cluster vs single channel
    if length(choice_channel_EEG) > 1
        channel_string = 'cluster';
    else
        channel_string = choice_channel_EEG{1};
    end
    
    % Finnally, extract values outside Brainstorm
    save([root_dir '/Results/' participant{p} '/FFR_low_' channel_string '.mat'],'Average');
    
    % Compute and extract a low-pass filtered version of the time domain
    
    % Delete any previous low pass filtered FFR
    if delete_previous_file == 1
        folders_delete = dir([root_dir_bs '/data/' participant{p} '/@intra']);
        infolder_delete = find(endsWith({folders_delete.name},['FFR_low_' low_pass_FFR_low_string '.mat']));
        if ~isempty(infolder_delete) % file exists, therefore delete it
           delete([root_dir_bs '/data/' participant{p} '/@intra/' folders_delete(infolder_delete).name]);
        end
    end
    
    disp(' ');      
    disp('-------------------------');
    disp(['Extracting a low-pass version of FFR LOW average for ' participant{p}]);
    disp(datetime)
    disp(' ');
    
    % Process: Low-pass:
    sFiles_FFR_filtered = bst_process('CallProcess', 'process_bandpass', sFiles_FFR_average, [], ...
        'sensortypes', 'EEG', ...
        'highpass',    0, ...
        'lowpass',     low_pass_FFR_low, ...
        'tranband',    10, ...
        'attenuation', 'strict', ...  % 60dB
        'ver',         '2019', ...  % 2019
        'mirror',      0, ...
        'overwrite',   0);
    
     % Process: Add tag
    sFiles_FFR_filtered = bst_process('CallProcess', 'process_add_tag', sFiles_FFR_filtered, [], ...
        'tag',           ['FFR_low_' low_pass_FFR_low_string], ...
        'output',        2);  % Add to file name (1 to add a tag)

    % Process: Set name
    sFiles_FFR_filtered = bst_process('CallProcess', 'process_set_comment', sFiles_FFR_filtered, [], ...
        'tag',           ['FFR_low_' low_pass_FFR_low_string], ...
        'isindex',       1);
    
    % Load channel file
    load([root_dir_bs '/data/' participant{p} '/@intra/channel.mat']);
    % Get the position of channel
    pos_data = [];
    for ch = 1:length(choice_channel_EEG)
        pos_data(ch) = find(strcmp({Channel.Name},choice_channel_EEG{ch}));
    end
    
    % Load Low_pass FFR file
    load([root_dir_bs '/data/' sFiles_FFR_filtered.FileName]);
    
    % Retrieve amplitudes at each channel
    Average = [];
    for ps = 1:length(pos_data)
        Average(ps,:) = F(pos_data(ps),:);
    end

    % If it was more than one channel, average across channels
    if size(Average,1) > 1
        Average = mean(Average,1);
    end
    
    % Finnally, extract values outside Brainstorm
    save([root_dir '/Results/' participant{p} '/FFR_low_' low_pass_FFR_low_string '_' channel_string '.mat'],'Average');
    
    % Compute FFT and extract it out of brainstorm
    % Do so in every time window: Pre (-40 0), Tra (10-55), Con (55-170), Tot (10-170). Asuming 10ms of neural lag    
    for tw = 1:length(time_windows_FFR)
        
        disp(' ');      
        disp('-------------------------');
        disp(['Computing FFT for FFR LOW ' participant{p} ' ' time_windows_FFR_labels{tw}]);
        disp(datetime)
        disp(' ');  
                
        % Load original average to compute FFTs
        load([root_dir '/Results/' participant{p} '/FFR_low_' channel_string '.mat']);
        
        % Compute and save FFT 
        % (Here you can replace this with Brainstorm steps commented below        
        SR =  round(length(Average)/0.270); % Sampling rate
        % Define section to compute FFT on
        time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
        [~,closestIndex] = min(abs(time_samples-(time_windows_FFR{tw}(1)*1000)));
        init_time = closestIndex;
        [~,closestIndex] = min(abs(time_samples-(time_windows_FFR{tw}(2)*1000)));
        end_time = closestIndex;        
        Average_section = Average(1,init_time:end_time);
        
        % Now compute FFT
        complex_spect = fft(Average_section,SR)/length(Average_section);
        freqs = SR/2*linspace(0,1,SR/2+1);
        amplitude = 2*abs(complex_spect(1:SR/2+1));
        
        % Save resulting FFT
        save([root_dir '/Results/' participant{p} '/FFT_low_' time_windows_FFR_labels{tw} '_' channel_string '.mat'],'amplitude');
        
        % Compute FFT with Brainstorm too (alternative to compare)
        % Delete any previous TF in brainstorm
        if delete_previous_file == 1
            folders_delete = dir([root_dir_bs '/data/' participant{p} '/@intra']);
            infolder_delete = find(endsWith({folders_delete.name},['FFT_low_' time_windows_FFR_labels{tw} '.mat']));
            if ~isempty(infolder_delete) % file exists, therefore delete it
               delete([root_dir_bs '/data/' participant{p} '/@intra/' folders_delete(infolder_delete).name]);
            end
        end

        sFiles_FFT = bst_process('CallProcess', 'process_fft', sFiles_FFR_average, [], ...
        'timewindow',  time_windows_FFR{tw}, ...
        'units',       'physical', ...  % Physical: U2/Hz
        'sensortypes', 'EEG', ...
        'avgoutput',   1);
        
        % Process: Add tag
        sFiles_FFT = bst_process('CallProcess', 'process_add_tag', sFiles_FFT, [], ...
            'tag',           ['FFT_low_' time_windows_FFR_labels{tw}], ...
            'output',        2);  % Add to file name (1 to add a tag)

        % Process: Set name
        sFiles_FFT = bst_process('CallProcess', 'process_set_comment', sFiles_FFT, [], ...
            'tag',           ['FFT_low_' time_windows_FFR_labels{tw}], ...
            'isindex',       1);
              
        % Just to have them for comparison in Brainstorm, don't extract them
        
    end

    % Compute Time-Frequency analysis
    
    disp(' ');      
    disp('-------------------------');
    disp(['Computing Time Frequency for ' participant{p} 'FFR LOW']);
    disp(datetime)
    disp(' ');  
    
    % Delete any previous TF in brainstorm    
    if delete_previous_file == 1
        folders_delete = dir([root_dir_bs '/data/' participant{p} '/@intra']);
        infolder_delete = find(endsWith({folders_delete.name},'Time_Frequency_low.mat'));
        if ~isempty(infolder_delete) % file exists, therefore delete it
           delete([root_dir_bs '/data/' participant{p} '/@intra/' folders_delete(infolder_delete).name]);
        end
    end
 
    % Process: Time-frequency (Morlet wavelets)
    sFiles_TF = bst_process('CallProcess', 'process_timefreq', sFiles_FFR_average, [], ...
        'sensortypes', 'EEG', ...
        'edit',        struct(...
             'Comment',         'Power,1-500Hz', ...
             'TimeBands',       [], ...
             'Freqs',           [1:500], ...
             'MorletFc',        1, ...
             'MorletFwhmTc',    3, ...
             'ClusterFuncTime', 'none', ...
             'Measure',         'power', ...
             'Output',          'all', ...
             'SaveKernel',      0), ...
        'normalize',   'none');  % None: Save non-standardized time-frequency maps
    
    % Process: Add tag
    sFiles_TF = bst_process('CallProcess', 'process_add_tag', sFiles_TF, [], ...
        'tag',           'Time_Frequency_low', ...
        'output',        2);  % Add to file name (1 to add a tag)

    % Process: Set name
    sFiles_TF = bst_process('CallProcess', 'process_set_comment', sFiles_TF, [], ...
        'tag',           'Time_Frequency_low', ...
        'isindex',       1);

    % Load TF file
    load([root_dir_bs '/data/' sFiles_TF.FileName])
    
    % Get the position of channel
    pos_data = [];
    for ch = 1:length(choice_channel_EEG)
        pos_data(ch) = find(strcmp(RowNames,choice_channel_EEG{ch}));
    end
    
    % Retrieve amplitudes at each channel
    tf_map = [];
    for ps = 1:length(pos_data)
        tf_map(ps,:,:) = TF(pos_data(ps),:,:);
    end

    % If it was more than one channel, average across channels
    if size(tf_map,1) > 1
        tf_map = mean(tf_map,1);
    end
    
    % Now save the tf_map outside brainstorm
    save([root_dir '/Results/' participant{p} '/Time_Frequency_low_' channel_string '.mat'],'tf_map');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FFR MEDIUM %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find files    
    folders = dir([root_dir_bs '/data/' participant{p} '/@intra/']);
    infolder_FFR_average = find(endsWith({folders.name},'FFR_average_medium.mat'));
    % Choose most recent one if there are more than one
    if length(infolder_FFR_average) > 1; infolder_FFR_average = infolder_FFR_average(end);end

    if isempty(infolder_FFR_average)
        error(['No FFR @intra average for ' participant{p}]);
    end
    
    sFiles_FFR_average = [participant{p} '/@intra/' folders(infolder_FFR_average).name];

    % Load channel file
    load([root_dir_bs '/data/' participant{p} '/@intra/channel.mat']);
    % Get the position of channel
    pos_data = [];
    for ch = 1:length(choice_channel_EEG)
        pos_data(ch) = find(strcmp({Channel.Name},choice_channel_EEG{ch}));
    end

    % Load averaged FFR data
    load([root_dir_bs '/data/' sFiles_FFR_average])

    % Retrieve amplitudes at each channel
    Average = [];
    for ps = 1:length(pos_data)
        Average(ps,:) = F(pos_data(ps),:);
    end

    % If it was more than one channel, average across channels
    if size(Average,1) > 1
        Average = mean(Average,1);
    end
    
    % Create participant folder if not already there
    if ~exist([root_dir '/Results/' participant{p}], 'dir')
        mkdir([root_dir '/Results/'], [participant{p}]);
    end

    disp(' ');      
    disp('-------------------------');
    disp(['Extracting FFR MEDIUM average for ' participant{p}]);
    disp(datetime)
    disp(' ');
    
    % For cluster vs single channel
    if length(choice_channel_EEG) > 1
        channel_string = 'cluster';
    else
        channel_string = choice_channel_EEG{1};
    end
    
    % Finnally, extract values outside Brainstorm
    save([root_dir '/Results/' participant{p} '/FFR_medium_' channel_string '.mat'],'Average');
    
    % Compute and extract a low-pass filtered version of the time domain
    
    % Delete any previous low pass filtered FFR
    if delete_previous_file == 1
        folders_delete = dir([root_dir_bs '/data/' participant{p} '/@intra']);
        infolder_delete = find(endsWith({folders_delete.name},['FFR_medium_' low_pass_FFR_medium_string '.mat']));
        if ~isempty(infolder_delete) % file exists, therefore delete it
           delete([root_dir_bs '/data/' participant{p} '/@intra/' folders_delete(infolder_delete).name]);
        end
    end
    
    disp(' ');      
    disp('-------------------------');
    disp(['Extracting a low-pass version of FFR MEDIUM average for ' participant{p}]);
    disp(datetime)
    disp(' ');
    
    % Process: Low-pass:
    sFiles_FFR_filtered = bst_process('CallProcess', 'process_bandpass', sFiles_FFR_average, [], ...
        'sensortypes', 'EEG', ...
        'highpass',    0, ...
        'lowpass',     low_pass_FFR_medium, ...
        'tranband',    10, ...
        'attenuation', 'strict', ...  % 60dB
        'ver',         '2019', ...  % 2019
        'mirror',      0, ...
        'overwrite',   0);
    
     % Process: Add tag
    sFiles_FFR_filtered = bst_process('CallProcess', 'process_add_tag', sFiles_FFR_filtered, [], ...
        'tag',           ['FFR_medium_' low_pass_FFR_medium_string], ...
        'output',        2);  % Add to file name (1 to add a tag)

    % Process: Set name
    sFiles_FFR_filtered = bst_process('CallProcess', 'process_set_comment', sFiles_FFR_filtered, [], ...
        'tag',           ['FFR_medium_' low_pass_FFR_medium_string], ...
        'isindex',       1);
    
    % Load channel file
    load([root_dir_bs '/data/' participant{p} '/@intra/channel.mat']);
    % Get the position of channel
    pos_data = [];
    for ch = 1:length(choice_channel_EEG)
        pos_data(ch) = find(strcmp({Channel.Name},choice_channel_EEG{ch}));
    end
    
    % Load Low_pass FFR file
    load([root_dir_bs '/data/' sFiles_FFR_filtered.FileName]);
    
    % Retrieve amplitudes at each channel
    Average = [];
    for ps = 1:length(pos_data)
        Average(ps,:) = F(pos_data(ps),:);
    end

    % If it was more than one channel, average across channels
    if size(Average,1) > 1
        Average = mean(Average,1);
    end
    
    % Finnally, extract values outside Brainstorm
    save([root_dir '/Results/' participant{p} '/FFR_medium_' low_pass_FFR_medium_string '_' channel_string '.mat'],'Average');
    
    % Compute FFT and extract it out of brainstorm
    % Do so in every time window: Pre (-40 0), Tra (10-55), Con (55-170), Tot (10-170). Asuming 10ms of neural lag    
    for tw = 1:length(time_windows_FFR)
        
        disp(' ');      
        disp('-------------------------');
        disp(['Computing FFT for FFR MEDIUM ' participant{p} ' ' time_windows_FFR_labels{tw}]);
        disp(datetime)
        disp(' ');  
                
        % Load original average to compute FFTs
        load([root_dir '/Results/' participant{p} '/FFR_medium_' channel_string '.mat']);
        
        % Compute and save FFT 
        % (Here you can replace this with Brainstorm steps commented below        
        SR =  round(length(Average)/0.270); % Sampling rate
        % Define section to compute FFT on
        time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
        [~,closestIndex] = min(abs(time_samples-(time_windows_FFR{tw}(1)*1000)));
        init_time = closestIndex;
        [~,closestIndex] = min(abs(time_samples-(time_windows_FFR{tw}(2)*1000)));
        end_time = closestIndex;        
        Average_section = Average(1,init_time:end_time);
        
        % Now compute FFT
        complex_spect = fft(Average_section,SR)/length(Average_section);
        freqs = SR/2*linspace(0,1,SR/2+1);
        amplitude = 2*abs(complex_spect(1:SR/2+1));
        
        % Save resulting FFT
        save([root_dir '/Results/' participant{p} '/FFT_medium_' time_windows_FFR_labels{tw} '_' channel_string '.mat'],'amplitude');
        
        % Compute FFT with Brainstorm too (alternative to compare)
        % Delete any previous TF in brainstorm
        if delete_previous_file == 1
            folders_delete = dir([root_dir_bs '/data/' participant{p} '/@intra']);
            infolder_delete = find(endsWith({folders_delete.name},['FFT_medium_' time_windows_FFR_labels{tw} '.mat']));
            if ~isempty(infolder_delete) % file exists, therefore delete it
               delete([root_dir_bs '/data/' participant{p} '/@intra/' folders_delete(infolder_delete).name]);
            end
        end

        sFiles_FFT = bst_process('CallProcess', 'process_fft', sFiles_FFR_average, [], ...
        'timewindow',  time_windows_FFR{tw}, ...
        'units',       'physical', ...  % Physical: U2/Hz
        'sensortypes', 'EEG', ...
        'avgoutput',   1);
        
        % Process: Add tag
        sFiles_FFT = bst_process('CallProcess', 'process_add_tag', sFiles_FFT, [], ...
            'tag',           ['FFT_medium_' time_windows_FFR_labels{tw}], ...
            'output',        2);  % Add to file name (1 to add a tag)

        % Process: Set name
        sFiles_FFT = bst_process('CallProcess', 'process_set_comment', sFiles_FFT, [], ...
            'tag',           ['FFT_medium_' time_windows_FFR_labels{tw}], ...
            'isindex',       1);
              
        % Just to have them for comparison in Brainstorm, don't extract them
        
    end

    % Compute Time-Frequency analysis
    
    disp(' ');      
    disp('-------------------------');
    disp(['Computing Time Frequency for ' participant{p} 'FFR MEDIUM']);
    disp(datetime)
    disp(' ');  
    
    % Delete any previous TF in brainstorm    
    if delete_previous_file == 1
        folders_delete = dir([root_dir_bs '/data/' participant{p} '/@intra']);
        infolder_delete = find(endsWith({folders_delete.name},'Time_Frequency_medium.mat'));
        if ~isempty(infolder_delete) % file exists, therefore delete it
           delete([root_dir_bs '/data/' participant{p} '/@intra/' folders_delete(infolder_delete).name]);
        end
    end
 
    % Process: Time-frequency (Morlet wavelets)
    sFiles_TF = bst_process('CallProcess', 'process_timefreq', sFiles_FFR_average, [], ...
        'sensortypes', 'EEG', ...
        'edit',        struct(...
             'Comment',         'Power,1-500Hz', ...
             'TimeBands',       [], ...
             'Freqs',           [1:500], ...
             'MorletFc',        1, ...
             'MorletFwhmTc',    3, ...
             'ClusterFuncTime', 'none', ...
             'Measure',         'power', ...
             'Output',          'all', ...
             'SaveKernel',      0), ...
        'normalize',   'none');  % None: Save non-standardized time-frequency maps
    
    % Process: Add tag
    sFiles_TF = bst_process('CallProcess', 'process_add_tag', sFiles_TF, [], ...
        'tag',           'Time_Frequency_medium', ...
        'output',        2);  % Add to file name (1 to add a tag)

    % Process: Set name
    sFiles_TF = bst_process('CallProcess', 'process_set_comment', sFiles_TF, [], ...
        'tag',           'Time_Frequency_medium', ...
        'isindex',       1);

    % Load TF file
    load([root_dir_bs '/data/' sFiles_TF.FileName])
    
    % Get the position of channel
    pos_data = [];
    for ch = 1:length(choice_channel_EEG)
        pos_data(ch) = find(strcmp(RowNames,choice_channel_EEG{ch}));
    end
    
    % Retrieve amplitudes at each channel
    tf_map = [];
    for ps = 1:length(pos_data)
        tf_map(ps,:,:) = TF(pos_data(ps),:,:);
    end

    % If it was more than one channel, average across channels
    if size(tf_map,1) > 1
        tf_map = mean(tf_map,1);
    end
    
    % Now save the tf_map outside brainstorm
    save([root_dir '/Results/' participant{p} '/Time_Frequency_medium_' channel_string '.mat'],'tf_map');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FFR HIGH %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find files    
    folders = dir([root_dir_bs '/data/' participant{p} '/@intra/']);
    infolder_FFR_average = find(endsWith({folders.name},'FFR_average_high.mat'));
    % Choose most recent one if there are more than one
    if length(infolder_FFR_average) > 1; infolder_FFR_average = infolder_FFR_average(end);end

    if isempty(infolder_FFR_average)
        error(['No FFR @intra average for ' participant{p}]);
    end
    
    sFiles_FFR_average = [participant{p} '/@intra/' folders(infolder_FFR_average).name];

    % Load channel file
    load([root_dir_bs '/data/' participant{p} '/@intra/channel.mat']);
    % Get the position of channel
    pos_data = [];
    for ch = 1:length(choice_channel_EEG)
        pos_data(ch) = find(strcmp({Channel.Name},choice_channel_EEG{ch}));
    end

    % Load averaged FFR data
    load([root_dir_bs '/data/' sFiles_FFR_average])

    % Retrieve amplitudes at each channel
    Average = [];
    for ps = 1:length(pos_data)
        Average(ps,:) = F(pos_data(ps),:);
    end

    % If it was more than one channel, average across channels
    if size(Average,1) > 1
        Average = mean(Average,1);
    end
    
    % Create participant folder if not already there
    if ~exist([root_dir '/Results/' participant{p}], 'dir')
        mkdir([root_dir '/Results/'], [participant{p}]);
    end

    disp(' ');      
    disp('-------------------------');
    disp(['Extracting FFR HIGH average for ' participant{p}]);
    disp(datetime)
    disp(' ');
    
    % For cluster vs single channel
    if length(choice_channel_EEG) > 1
        channel_string = 'cluster';
    else
        channel_string = choice_channel_EEG{1};
    end
    
    % Finnally, extract values outside Brainstorm
    save([root_dir '/Results/' participant{p} '/FFR_high_' channel_string '.mat'],'Average');
    
    % Compute and extract a low-pass filtered version of the time domain
    
    % Delete any previous low pass filtered FFR
    if delete_previous_file == 1
        folders_delete = dir([root_dir_bs '/data/' participant{p} '/@intra']);
        infolder_delete = find(endsWith({folders_delete.name},['FFR_high_' low_pass_FFR_high_string '.mat']));
        if ~isempty(infolder_delete) % file exists, therefore delete it
           delete([root_dir_bs '/data/' participant{p} '/@intra/' folders_delete(infolder_delete).name]);
        end
    end
    
    disp(' ');      
    disp('-------------------------');
    disp(['Extracting a low-pass version of FFR HIGH average for ' participant{p}]);
    disp(datetime)
    disp(' ');
    
    % Process: Low-pass:
    sFiles_FFR_filtered = bst_process('CallProcess', 'process_bandpass', sFiles_FFR_average, [], ...
        'sensortypes', 'EEG', ...
        'highpass',    0, ...
        'lowpass',     low_pass_FFR_high, ...
        'tranband',    10, ...
        'attenuation', 'strict', ...  % 60dB
        'ver',         '2019', ...  % 2019
        'mirror',      0, ...
        'overwrite',   0);
    
     % Process: Add tag
    sFiles_FFR_filtered = bst_process('CallProcess', 'process_add_tag', sFiles_FFR_filtered, [], ...
        'tag',           ['FFR_high_' low_pass_FFR_high_string], ...
        'output',        2);  % Add to file name (1 to add a tag)

    % Process: Set name
    sFiles_FFR_filtered = bst_process('CallProcess', 'process_set_comment', sFiles_FFR_filtered, [], ...
        'tag',           ['FFR_high_' low_pass_FFR_high_string], ...
        'isindex',       1);
    
    % Load channel file
    load([root_dir_bs '/data/' participant{p} '/@intra/channel.mat']);
    % Get the position of channel
    pos_data = [];
    for ch = 1:length(choice_channel_EEG)
        pos_data(ch) = find(strcmp({Channel.Name},choice_channel_EEG{ch}));
    end
    
    % Load Low_pass FFR file
    load([root_dir_bs '/data/' sFiles_FFR_filtered.FileName]);
    
    % Retrieve amplitudes at each channel
    Average = [];
    for ps = 1:length(pos_data)
        Average(ps,:) = F(pos_data(ps),:);
    end

    % If it was more than one channel, average across channels
    if size(Average,1) > 1
        Average = mean(Average,1);
    end
    
    % Finnally, extract values outside Brainstorm
    save([root_dir '/Results/' participant{p} '/FFR_high_' low_pass_FFR_high_string '_' channel_string '.mat'],'Average');
    
    % Compute FFT and extract it out of brainstorm
    % Do so in every time window: Pre (-40 0), Tra (10-55), Con (55-170), Tot (10-170). Asuming 10ms of neural lag    
    for tw = 1:length(time_windows_FFR)
        
        disp(' ');      
        disp('-------------------------');
        disp(['Computing FFT for FFR HIGH ' participant{p} ' ' time_windows_FFR_labels{tw}]);
        disp(datetime)
        disp(' ');  
                
        % Load original average to compute FFTs
        load([root_dir '/Results/' participant{p} '/FFR_high_' channel_string '.mat']);
        
        % Compute and save FFT 
        % (Here you can replace this with Brainstorm steps commented below        
        SR =  round(length(Average)/0.270); % Sampling rate
        % Define section to compute FFT on
        time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
        [~,closestIndex] = min(abs(time_samples-(time_windows_FFR{tw}(1)*1000)));
        init_time = closestIndex;
        [~,closestIndex] = min(abs(time_samples-(time_windows_FFR{tw}(2)*1000)));
        end_time = closestIndex;        
        Average_section = Average(1,init_time:end_time);
        
        % Now compute FFT
        complex_spect = fft(Average_section,SR)/length(Average_section);
        freqs = SR/2*linspace(0,1,SR/2+1);
        amplitude = 2*abs(complex_spect(1:SR/2+1));
        
        % Save resulting FFT
        save([root_dir '/Results/' participant{p} '/FFT_high_' time_windows_FFR_labels{tw} '_' channel_string '.mat'],'amplitude');
        
        % Compute FFT with Brainstorm too (alternative to compare)
        % Delete any previous TF in brainstorm
        if delete_previous_file == 1
            folders_delete = dir([root_dir_bs '/data/' participant{p} '/@intra']);
            infolder_delete = find(endsWith({folders_delete.name},['FFT_high_' time_windows_FFR_labels{tw} '.mat']));
            if ~isempty(infolder_delete) % file exists, therefore delete it
               delete([root_dir_bs '/data/' participant{p} '/@intra/' folders_delete(infolder_delete).name]);
            end
        end

        sFiles_FFT = bst_process('CallProcess', 'process_fft', sFiles_FFR_average, [], ...
        'timewindow',  time_windows_FFR{tw}, ...
        'units',       'physical', ...  % Physical: U2/Hz
        'sensortypes', 'EEG', ...
        'avgoutput',   1);
        
        % Process: Add tag
        sFiles_FFT = bst_process('CallProcess', 'process_add_tag', sFiles_FFT, [], ...
            'tag',           ['FFT_high_' time_windows_FFR_labels{tw}], ...
            'output',        2);  % Add to file name (1 to add a tag)

        % Process: Set name
        sFiles_FFT = bst_process('CallProcess', 'process_set_comment', sFiles_FFT, [], ...
            'tag',           ['FFT_high_' time_windows_FFR_labels{tw}], ...
            'isindex',       1);
              
        % Just to have them for comparison in Brainstorm, don't extract them
        
    end

    % Compute Time-Frequency analysis
    
    disp(' ');      
    disp('-------------------------');
    disp(['Computing Time Frequency for ' participant{p} 'FFR HIGH']);
    disp(datetime)
    disp(' ');  
    
    % Delete any previous TF in brainstorm    
    if delete_previous_file == 1
        folders_delete = dir([root_dir_bs '/data/' participant{p} '/@intra']);
        infolder_delete = find(endsWith({folders_delete.name},'Time_Frequency_high.mat'));
        if ~isempty(infolder_delete) % file exists, therefore delete it
           delete([root_dir_bs '/data/' participant{p} '/@intra/' folders_delete(infolder_delete).name]);
        end
    end
 
    % Process: Time-frequency (Morlet wavelets)
    sFiles_TF = bst_process('CallProcess', 'process_timefreq', sFiles_FFR_average, [], ...
        'sensortypes', 'EEG', ...
        'edit',        struct(...
             'Comment',         'Power,1-500Hz', ...
             'TimeBands',       [], ...
             'Freqs',           [1:500], ...
             'MorletFc',        1, ...
             'MorletFwhmTc',    3, ...
             'ClusterFuncTime', 'none', ...
             'Measure',         'power', ...
             'Output',          'all', ...
             'SaveKernel',      0), ...
        'normalize',   'none');  % None: Save non-standardized time-frequency maps
    
    % Process: Add tag
    sFiles_TF = bst_process('CallProcess', 'process_add_tag', sFiles_TF, [], ...
        'tag',           'Time_Frequency_high', ...
        'output',        2);  % Add to file name (1 to add a tag)

    % Process: Set name
    sFiles_TF = bst_process('CallProcess', 'process_set_comment', sFiles_TF, [], ...
        'tag',           'Time_Frequency_high', ...
        'isindex',       1);

    % Load TF file
    load([root_dir_bs '/data/' sFiles_TF.FileName])
    
    % Get the position of channel
    pos_data = [];
    for ch = 1:length(choice_channel_EEG)
        pos_data(ch) = find(strcmp(RowNames,choice_channel_EEG{ch}));
    end
    
    % Retrieve amplitudes at each channel
    tf_map = [];
    for ps = 1:length(pos_data)
        tf_map(ps,:,:) = TF(pos_data(ps),:,:);
    end

    % If it was more than one channel, average across channels
    if size(tf_map,1) > 1
        tf_map = mean(tf_map,1);
    end
    
    % Now save the tf_map outside brainstorm
    save([root_dir '/Results/' participant{p} '/Time_Frequency_high_' channel_string '.mat'],'tf_map');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LLR 400ms %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find files    
    folders = dir([root_dir_bs '/data/' participant{p} '/Tone_400ms/']);
    infolder_LLR_average = find(endsWith({folders.name},'LLR_average.mat'));
    % Choose most recent one if there are more than one
    if length(infolder_LLR_average) > 1; infolder_LLR_average = infolder_LLR_average(end);end

    if isempty(infolder_LLR_average)
        error(['No LLR tone average for ' participant{p}]);
    end
    
    sFiles_LLR_average = [participant{p} '/Tone_400ms/' folders(infolder_LLR_average).name];

    % Load channel file
    load([root_dir_bs '/data/' participant{p} '/Tone_400ms/channel.mat']);
    % Get the position of channel
    pos_data = [];
    for ch = 1:length(choice_channel_EEG)
        pos_data(ch) = find(strcmp({Channel.Name},choice_channel_EEG{ch}));
    end

    % Load averaged LLR data
    load([root_dir_bs '/data/' sFiles_LLR_average])

    % Retrieve amplitudes at each channel
    Average = [];
    for ps = 1:length(pos_data)
        Average(ps,:) = F(pos_data(ps),:);
    end

    % If it was more than one channel, average across channels
    if size(Average,1) > 1
        Average = mean(Average,1);
    end
    
    % Take the change and load and extract out of brainstorm every FFT
    % Create participant folder if not already there
    if ~exist([root_dir '/Results/' participant{p}], 'dir')
        mkdir([root_dir '/Results/'], [participant{p}]);
    end

    disp(' ');      
    disp('-------------------------');
    disp(['Extracting LLR 400ms average for ' participant{p}]);
    disp(datetime)
    disp(' ');
    
    % Finnally, extract values outside Brainstorm
    if length(choice_channel_EEG) > 1
        save([root_dir '/Results/' participant{p} '/LLR_400ms_cluster.mat'],'Average');
    else
        save([root_dir '/Results/' participant{p} '/LLR_400ms_' choice_channel_EEG{1} '.mat'],'Average');
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LLR 1s %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find files    
    folders = dir([root_dir_bs '/data/' participant{p} '/Tone_1s/']);
    infolder_LLR_average = find(endsWith({folders.name},'LLR_average.mat'));
    % Choose most recent one if there are more than one
    if length(infolder_LLR_average) > 1; infolder_LLR_average = infolder_LLR_average(end);end

    if isempty(infolder_LLR_average)
        error(['No LLR tone average for ' participant{p}]);
    end
    
    sFiles_LLR_average = [participant{p} '/Tone_1s/' folders(infolder_LLR_average).name];

    % Load channel file
    load([root_dir_bs '/data/' participant{p} '/Tone_1s/channel.mat']);
    % Get the position of channel
    pos_data = [];
    for ch = 1:length(choice_channel_EEG)
        pos_data(ch) = find(strcmp({Channel.Name},choice_channel_EEG{ch}));
    end

    % Load averaged LLR data
    load([root_dir_bs '/data/' sFiles_LLR_average])

    % Retrieve amplitudes at each channel
    Average = [];
    for ps = 1:length(pos_data)
        Average(ps,:) = F(pos_data(ps),:);
    end

    % If it was more than one channel, average across channels
    if size(Average,1) > 1
        Average = mean(Average,1);
    end
    
    % Take the change and load and extract out of brainstorm every FFT
    % Create participant folder if not already there
    if ~exist([root_dir '/Results/' participant{p}], 'dir')
        mkdir([root_dir '/Results/'], [participant{p}]);
    end

    disp(' ');      
    disp('-------------------------');
    disp(['Extracting LLR 1s average for ' participant{p}]);
    disp(datetime)
    disp(' ');
    
    % Finnally, extract values outside Brainstorm
    if length(choice_channel_EEG) > 1
        save([root_dir '/Results/' participant{p} '/LLR_1s_cluster.mat'],'Average');
    else
        save([root_dir '/Results/' participant{p} '/LLR_1s_' choice_channel_EEG{1} '.mat'],'Average');
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % If successful, update subject_array for this subject
    subject_array{pos_subj,3} = 'DONE';
    save([root_dir '/subject_array.mat'],'subject_array') 
    
    end  
end

% Reset to how it was for next steps
choice_channel_EEG = original_single_channel;

clearvars('-except', initialVars{:});
disp 'DONE EXTRACTING LLR AND FFR TIME DOMAIN AND FREQ DOMAIN COMPUTED (FFR_Sz)!!!'
disp(datetime)
toc
 
%% GAVR outside brainstorm
% * If not willing to include certain subjects (e.g. 2581), just mark
% them as not 'DONE' in subject array

tic
disp(' ');      
disp('-------------------------');  
disp('GAVR outside brainstorm (FFR_Sz)');  
disp(datetime)
disp('-------------------------');     
disp(' ');

% Indicate which channels or clusters you are going to average
gavr_name = 'GAVR_13C_vs_15FE'; % Whatever you want the GAVR folder to be named
channel_to_average = {'Cz','cluster'}; % Cell array {'Cz','cluster'}

% FFR TD (Original and Low-pass filtered)
for cha = 1:length(channel_to_average)
for pg = 1:length(participant_group)
    
    % Create matrices where individual subject's data will be stored
    matrix_FFR_low_TD = [];
    matrix_FFR_low_TD_filtered = [];
    matrix_FFR_medium_TD = [];
    matrix_FFR_medium_TD_filtered = [];
    matrix_FFR_high_TD = [];
    matrix_FFR_high_TD_filtered = [];
    
    for p = 1:length(participant) 
        % Do only for participants that are done anlyzing
        pos_subj = find(strcmp({subject_array{:,1}},participant{p}));
        if strcmp(subject_array{pos_subj,3},'DONE')
        
            % Only include participants that belong to the group
            if ~strcmp(subject_array{pos_subj,2},participant_group{pg}); continue; end

            % FFR TD LOW original filter
            if strcmp(participant{p},'FFR_S01') || strcmp(participant{p},'FFR_S02') || strcmp(participant{p},'FFR_X74') || strcmp(participant{p},'FFR_X10')
                if exist([root_dir '/Results/' participant{p} '/FFR_' channel_to_average{cha} '.mat'],'file')
                    load([root_dir '/Results/' participant{p} '/FFR_' channel_to_average{cha} '.mat']);
                    current_average = Average;
                else
                    current_average = []; % So that it's stored as a missing one in the matrix
                    warning(['No FFR TD low original filter (' channel_to_average{cha} ') for ' participant{p}]);
                end
            else
                if exist([root_dir '/Results/' participant{p} '/FFR_low_' channel_to_average{cha} '.mat'],'file')
                    load([root_dir '/Results/' participant{p} '/FFR_low_' channel_to_average{cha} '.mat']);
                    current_average = Average;
                else
                    current_average = []; % So that it's stored as a missing one in the matrix
                    warning(['No FFR TD low original filter (' channel_to_average{cha} ') for ' participant{p}]);
                end
            end
            if ~isempty(current_average)
                pos = size(matrix_FFR_low_TD,1);
                matrix_FFR_low_TD(pos+1,:) = current_average;
            end
                        
            % FFR TD LOW low-pass filter
            if strcmp(participant{p},'FFR_S01') || strcmp(participant{p},'FFR_S02') || strcmp(participant{p},'FFR_X74') || strcmp(participant{p},'FFR_X10')
                if exist([root_dir '/Results/' participant{p} '/FFR_low_pass_' channel_to_average{cha} '.mat'],'file')
                    load([root_dir '/Results/' participant{p} '/FFR_low_pass_' channel_to_average{cha} '.mat']);
                    current_average = Average;
                else
                    current_average = []; % So that it's stored as a missing one in the matrix
                    warning(['No FFR TD low low passed (' channel_to_average{cha} ') for ' participant{p}]);
                end
            else
                if exist([root_dir '/Results/' participant{p} '/FFR_low_' low_pass_FFR_low_string '_' channel_to_average{cha} '.mat'],'file')
                    load([root_dir '/Results/' participant{p} '/FFR_low_' low_pass_FFR_low_string '_' channel_to_average{cha} '.mat']);
                    current_average = Average;
                else
                    current_average = []; % So that it's stored as a missing one in the matrix
                    warning(['No FFR TD low low passed (' channel_to_average{cha} ') for ' participant{p}]);
                end
            end
            if ~isempty(current_average)
                pos = size(matrix_FFR_low_TD_filtered,1);
                matrix_FFR_low_TD_filtered(pos+1,:) = current_average;
            end
            
            % FFR TD MEDIUM original filter
            if exist([root_dir '/Results/' participant{p} '/FFR_medium_' channel_to_average{cha} '.mat'],'file')
                load([root_dir '/Results/' participant{p} '/FFR_medium_' channel_to_average{cha} '.mat']);
                current_average = Average;
            else
                current_average = []; % So that it's stored as a missing one in the matrix
                warning(['No FFR TD medium original filter (' channel_to_average{cha} ') for ' participant{p}]);
            end
            if ~isempty(current_average)
                pos = size(matrix_FFR_medium_TD,1);
                matrix_FFR_medium_TD(pos+1,:) = current_average;
            end
                        
            % FFR TD MEDIUM low-pass filter
            if exist([root_dir '/Results/' participant{p} '/FFR_medium_' low_pass_FFR_medium_string '_' channel_to_average{cha} '.mat'],'file')
                load([root_dir '/Results/' participant{p} '/FFR_medium_' low_pass_FFR_medium_string '_' channel_to_average{cha} '.mat']);
                current_average = Average;
            else
                current_average = []; % So that it's stored as a missing one in the matrix
                warning(['No FFR TD medium low passed (' channel_to_average{cha} ') for ' participant{p}]);
            end
            if ~isempty(current_average)
                pos = size(matrix_FFR_medium_TD_filtered,1);
                matrix_FFR_medium_TD_filtered(pos+1,:) = current_average;
            end
            
            % FFR TD HIGH original filter
            if exist([root_dir '/Results/' participant{p} '/FFR_high_' channel_to_average{cha} '.mat'],'file')
                load([root_dir '/Results/' participant{p} '/FFR_high_' channel_to_average{cha} '.mat']);
                current_average = Average;
            else
                current_average = []; % So that it's stored as a missing one in the matrix
                warning(['No FFR TD high original filter (' channel_to_average{cha} ') for ' participant{p}]);
            end
            if ~isempty(current_average)
                pos = size(matrix_FFR_high_TD,1);
                matrix_FFR_high_TD(pos+1,:) = current_average;
            end
                        
            % FFR TD HIGH low-pass filter
            if exist([root_dir '/Results/' participant{p} '/FFR_high_' low_pass_FFR_high_string '_' channel_to_average{cha} '.mat'],'file')
                load([root_dir '/Results/' participant{p} '/FFR_high_' low_pass_FFR_high_string '_' channel_to_average{cha} '.mat']);
                current_average = Average;
            else
                current_average = []; % So that it's stored as a missing one in the matrix
                warning(['No FFR TD high low passed (' channel_to_average{cha} ') for ' participant{p}]);
            end
            if ~isempty(current_average)
                pos = size(matrix_FFR_high_TD_filtered,1);
                matrix_FFR_high_TD_filtered(pos+1,:) = current_average;
            end  
        end
    end
    
    % Before saving, be sure that destiny folders exist
    if ~exist([root_dir '/Results/' gavr_name], 'dir')
        mkdir([root_dir '/Results/' gavr_name], 'gavr');
        mkdir([root_dir '/Results/' gavr_name], 'std_dev');
        mkdir([root_dir '/Results/' gavr_name], 'std_err');
    end
    
    % Averages to save
    Averages_to_save = {'FFR_low_TD','FFR_low_TD_filtered',...
        'FFR_medium_TD','FFR_medium_TD_filtered',...
        'FFR_high_TD','FFR_high_TD_filtered'};
    
    for i = 1:length(Averages_to_save)
        eval(['Matrix = matrix_' Averages_to_save{i} ';'])
        
        % Ensure no empty rows (fatal for average)
        Matrix = Matrix(~all(Matrix == 0, 2),:);

        % Generate files
        gavr = mean(Matrix,1);
        STD = squeeze(std(Matrix,0,1));
        num_valid_subjects = size(Matrix,1);
        STD_ERR = STD/sqrt(num_valid_subjects);
        
        % Save files
        
        
        F = gavr;
        eval(['save(''' root_dir '/Results/' gavr_name '/gavr/' Averages_to_save{i} '_' participant_group{pg} '_' channel_to_average{cha} ''', ''F'');'])
        F = STD;
        eval(['save(''' root_dir '/Results/' gavr_name '/std_dev/' Averages_to_save{i} '_' participant_group{pg} '_' channel_to_average{cha} ''', ''F'');'])
        F = STD_ERR;
        eval(['save(''' root_dir '/Results/' gavr_name  '/std_err/' Averages_to_save{i} '_' participant_group{pg} '_' channel_to_average{cha} ''', ''F'');'])
        % Save the matrix in case we need it in the future too
        eval(['save(''' root_dir '/Results/' gavr_name '/Matrix_' Averages_to_save{i} '_' participant_group{pg} '_' channel_to_average{cha} ''', ''Matrix'');'])
  
    end  
end
end

% FFR FFT
for cha = 1:length(channel_to_average)
for pg = 1:length(participant_group)
    
    for tw = 1:length(time_windows_FFR_labels)
    % Create matrices where individual subject's data will be stored
    eval(['matrix_FFT_low_' time_windows_FFR_labels{tw} ' = [];'])
    eval(['matrix_FFT_medium_' time_windows_FFR_labels{tw} ' = [];'])
    eval(['matrix_FFT_high_' time_windows_FFR_labels{tw} ' = [];'])
    
    for p = 1:length(participant) 
        % Do only for participants that are done anlyzing
        pos_subj = find(strcmp({subject_array{:,1}},participant{p}));
        if strcmp(subject_array{pos_subj,3},'DONE')
        
            % Only include participants that belong to the group
            if ~strcmp(subject_array{pos_subj,2},participant_group{pg}); continue; end

            % FFT LOW
            if strcmp(participant{p},'FFR_S01') || strcmp(participant{p},'FFR_S02') || strcmp(participant{p},'FFR_X74') || strcmp(participant{p},'FFR_X10')
                if exist([root_dir '/Results/' participant{p} '/FFT_' time_windows_FFR_labels{tw} '_' channel_to_average{cha} '.mat'],'file')
                    load([root_dir '/Results/' participant{p} '/FFT_' time_windows_FFR_labels{tw} '_' channel_to_average{cha} '.mat']);
                    current_average = amplitude;
                else
                    current_average = []; % So that it's stored as a missing one in the matrix
                    warning(['No FFT ' time_windows_FFR_labels{tw} ' LOW (' channel_to_average{cha} ') for ' participant{p}]);
                end
            else
                if exist([root_dir '/Results/' participant{p} '/FFT_low_' time_windows_FFR_labels{tw} '_' channel_to_average{cha} '.mat'],'file')
                    load([root_dir '/Results/' participant{p} '/FFT_low_' time_windows_FFR_labels{tw} '_' channel_to_average{cha} '.mat']);
                    current_average = amplitude;
                else
                    current_average = []; % So that it's stored as a missing one in the matrix
                    warning(['No FFT ' time_windows_FFR_labels{tw} ' LOW (' channel_to_average{cha} ') for ' participant{p}]);
                end
            end
            if ~isempty(current_average)
                eval(['pos = size(matrix_FFT_low_' time_windows_FFR_labels{tw} ',1);'])
                eval(['matrix_FFT_low_' time_windows_FFR_labels{tw} '(pos+1,:) = current_average;'])
            end             

            % FFT MEDIUM
            if exist([root_dir '/Results/' participant{p} '/FFT_medium_' time_windows_FFR_labels{tw} '_' channel_to_average{cha} '.mat'],'file')
                load([root_dir '/Results/' participant{p} '/FFT_medium_' time_windows_FFR_labels{tw} '_' channel_to_average{cha} '.mat']);
                current_average = amplitude;
            else
                current_average = []; % So that it's stored as a missing one in the matrix
                warning(['No FFT medium ' time_windows_FFR_labels{tw} ' (' channel_to_average{cha} ') for ' participant{p}]);
            end
            if ~isempty(current_average)
                eval(['pos = size(matrix_FFT_medium_' time_windows_FFR_labels{tw} ',1);'])
                eval(['matrix_FFT_medium_' time_windows_FFR_labels{tw} '(pos+1,:) = current_average;'])
            end 

            % FFT HIGH
            if exist([root_dir '/Results/' participant{p} '/FFT_high_' time_windows_FFR_labels{tw} '_' channel_to_average{cha} '.mat'],'file')
                load([root_dir '/Results/' participant{p} '/FFT_high_' time_windows_FFR_labels{tw} '_' channel_to_average{cha} '.mat']);
                current_average = amplitude;
            else
                current_average = []; % So that it's stored as a missing one in the matrix
                warning(['No FFT high ' time_windows_FFR_labels{tw} ' (' channel_to_average{cha} ') for ' participant{p}]);
            end
            if ~isempty(current_average)
                eval(['pos = size(matrix_FFT_high_' time_windows_FFR_labels{tw} ',1);'])
                eval(['matrix_FFT_high_' time_windows_FFR_labels{tw} '(pos+1,:) = current_average;'])
            end              
        end
    end
    
    end
    
    % Before saving, be sure that destiny folders exist
    if ~exist([root_dir '/Results/' gavr_name], 'dir')
        mkdir([root_dir '/Results/' gavr_name], 'gavr');
        mkdir([root_dir '/Results/' gavr_name], 'std_dev');
        mkdir([root_dir '/Results/' gavr_name], 'std_err');
    end
    
    % Averages to save
    Averages_to_save = {'FFT_low_Baseline','FFT_low_Transient','FFT_low_Constant','FFT_low_Total',...
        'FFT_medium_Baseline','FFT_medium_Transient','FFT_medium_Constant','FFT_medium_Total',...
        'FFT_high_Baseline','FFT_high_Transient','FFT_high_Constant','FFT_high_Total'};
    
    for i = 1:length(Averages_to_save)
        eval(['Matrix = matrix_' Averages_to_save{i} ';'])
        
        % Ensure no empty rows (fatal for average)
        Matrix = Matrix(~all(Matrix == 0, 2),:);

        % Generate files
        gavr = mean(Matrix,1);
        STD = squeeze(std(Matrix,0,1));
        num_valid_subjects = size(Matrix,1);
        STD_ERR = STD/sqrt(num_valid_subjects);
        
        % Save files
        F = gavr;
        eval(['save(''' root_dir '/Results/' gavr_name '/gavr/' Averages_to_save{i} '_' participant_group{pg} '_' channel_to_average{cha} ''', ''F'');'])
        F = STD;
        eval(['save(''' root_dir '/Results/' gavr_name '/std_dev/' Averages_to_save{i} '_' participant_group{pg} '_' channel_to_average{cha} ''', ''F'');'])
        F = STD_ERR;
        eval(['save(''' root_dir '/Results/' gavr_name  '/std_err/' Averages_to_save{i} '_' participant_group{pg} '_' channel_to_average{cha} ''', ''F'');'])
        % Save the matrix in case we need it in the future too
        eval(['save(''' root_dir '/Results/' gavr_name '/Matrix_' Averages_to_save{i} '_' participant_group{pg} '_' channel_to_average{cha} ''', ''Matrix'');'])
  
    end  
    
end
end

% FFR Autocorrelogram can be done with the TD averaged FFR

% FFR Time-frequency can only be made in BS (next step)

% LLR
for cha = 1:length(channel_to_average)
for pg = 1:length(participant_group)
    
    % Create matrices where individual subject's data will be stored
    matrix_LLR_400ms = [];
    matrix_LLR_1s = [];
    
    for p = 1:length(participant) 
        % Do only for participants that are done anlyzing
        pos_subj = find(strcmp({subject_array{:,1}},participant{p}));
        if strcmp(subject_array{pos_subj,3},'DONE')
        
            % Only include participants that belong to the group
            if ~strcmp(subject_array{pos_subj,2},participant_group{pg}); continue; end

            % LLR 400ms
            if strcmp(participant{p},'FFR_S01') || strcmp(participant{p},'FFR_S02') || strcmp(participant{p},'FFR_X74') || strcmp(participant{p},'FFR_X10')
                if exist([root_dir '/Results/' participant{p} '/LLR_' channel_to_average{cha} '.mat'],'file')
                    load([root_dir '/Results/' participant{p} '/LLR_' channel_to_average{cha} '.mat']);
                    current_average = Average;
                else
                    current_average = []; % So that it's stored as a missing one in the matrix
                    warning(['No LLR 400ms (' channel_to_average{cha} ') for ' participant{p}]);
                end
            else
                if exist([root_dir '/Results/' participant{p} '/LLR_400ms_' channel_to_average{cha} '.mat'],'file')
                    load([root_dir '/Results/' participant{p} '/LLR_400ms_' channel_to_average{cha} '.mat']);
                    current_average = Average;
                else
                    current_average = []; % So that it's stored as a missing one in the matrix
                    warning(['No LLR 400ms (' channel_to_average{cha} ') for ' participant{p}]);
                end
            end
            if ~isempty(current_average)
                pos = size(matrix_LLR_400ms,1);
                matrix_LLR_400ms(pos+1,:) = current_average;
            end
               
            % LLR 1s
            if strcmp(participant{p},'FFR_S01') || strcmp(participant{p},'FFR_S02') || strcmp(participant{p},'FFR_X74') || strcmp(participant{p},'FFR_X10')
               % We know that these did not have 1s ISI
                current_average = []; % So that it's stored as a missing one in the matrix
                warning(['No LLR 1s (' channel_to_average{cha} ') for ' participant{p}]); 
            else
                if exist([root_dir '/Results/' participant{p} '/LLR_1s_' channel_to_average{cha} '.mat'],'file')
                    load([root_dir '/Results/' participant{p} '/LLR_1s_' channel_to_average{cha} '.mat']);
                    current_average = Average;
                else
                    current_average = []; % So that it's stored as a missing one in the matrix
                    warning(['No LLR 1s (' channel_to_average{cha} ') for ' participant{p}]);
                end
            end
            if ~isempty(current_average)
                pos = size(matrix_LLR_1s,1);
                matrix_LLR_1s(pos+1,:) = current_average;
            end
            
        end
    end
    
    % Before saving, be sure that destiny folders exist
    if ~exist([root_dir '/Results/' gavr_name], 'dir')
        mkdir([root_dir '/Results/' gavr_name], 'gavr');
        mkdir([root_dir '/Results/' gavr_name], 'std_dev');
        mkdir([root_dir '/Results/' gavr_name], 'std_err');
    end
    
    % Averages to save
    Averages_to_save = {'LLR_400ms','LLR_1s'};
    
    for i = 1:length(Averages_to_save)
        eval(['Matrix = matrix_' Averages_to_save{i} ';'])
        
        % Ensure no empty rows (fatal for average)
        Matrix = Matrix(~all(Matrix == 0, 2),:);

        % Generate files
        gavr = mean(Matrix,1);
        STD = squeeze(std(Matrix,0,1));
        num_valid_subjects = size(Matrix,1);
        STD_ERR = STD/sqrt(num_valid_subjects);
        
        % Save files
        F = gavr;
        eval(['save(''' root_dir '/Results/' gavr_name '/gavr/' Averages_to_save{i} '_' participant_group{pg} '_' channel_to_average{cha} ''', ''F'');'])
        F = STD;
        eval(['save(''' root_dir '/Results/' gavr_name '/std_dev/' Averages_to_save{i} '_' participant_group{pg} '_' channel_to_average{cha} ''', ''F'');'])
        F = STD_ERR;
        eval(['save(''' root_dir '/Results/' gavr_name  '/std_err/' Averages_to_save{i} '_' participant_group{pg} '_' channel_to_average{cha} ''', ''F'');'])
        % Save the matrix in case we need it in the future too
        eval(['save(''' root_dir '/Results/' gavr_name '/Matrix_' Averages_to_save{i} '_' participant_group{pg} '_' channel_to_average{cha} ''', ''Matrix'');'])
  
    end  
end
end

clearvars('-except', initialVars{:});
disp 'DONE WITH GAVR outside brainstorm (FFR_Sz)!!!'
disp(datetime)
toc

%% GAVR in brainstorm

tic
disp(' ');      
disp('-------------------------');  
disp('OBTAINING SWEEP COUNT (FFR_Sz)');  
disp(datetime)
disp('-------------------------');     
disp(' '); 

% FFR_Post will be Pol_1 name now but should be 'FFR' once we have the
% triggers for the two polarities
colNames = {'Group',...
    'FFR_low_Pre','FFR_low_Post',...
    'FFR_med_Pre','FFR_med_Post',...
    'FFR_high_Pre','FFR_high_Post',...
    'LLR_400ms_Pre','LLR_400ms_Post',...
    'LLR_1s_Pre','LLR_1s_Post'...
    'FFR_low_Per','FFR_med_Per','FFR_high_Per',...
    'LLR_400ms_Per','LLR_1s_Per'};

Trial_count = {};
Percentage_count = [];
for p = 1:length(participant)
    % Check log info about the subject
    pos_subj = find(strcmp({subject_array{:,1}},participant{p}));
    Subj_type = subject_array{pos_subj,2};
    
    % If subject does not have scalp analyses completed, continue
    if ~strcmp(subject_array{pos_subj,3},'DONE')
        continue;
    end
    
    % Do once for FFR low, medium and high and LLR 400ms and 1s
    for c = 1:length(measures)
        
        % If subject does not have the medium ones
        if contains(measures{c},'medium') && (strcmp(subject_array{pos_subj,1},'FFR_X62') || ...
                strcmp(subject_array{pos_subj,1},'FFR_X18'))
            continue;
        end
        
        files = dir([root_dir_bs '/data/' participant{p} '/' measures{c}]);
        if isempty(files)
            error(['No ' measures{c} ' files for ' participant{p}]);
        end
        number = find(contains({files.name},'_trial')); 
        % Original number of trials found in folder
        eval(['ot_' measures{c} ' = length(number);'])
        infolder = find(endsWith({files.name},'_average.mat'));
        if length(infolder) > 1
            error(['More than one ' measures{c} ' average for ' participant{p}]);
        end
        if isempty(infolder)
            warning(['No ' measures{c} ' average for ' participant{p}]);
            % Surviving trials
            eval(['st_' measures{c} ' = 0;'])
            % Percentage of trials
            eval(['pt_' measures{c} ' = 0%;'])
        else
            filename = [root_dir_bs '/data/' participant{p} '/' measures{c} '/' files(infolder).name];
            load(filename);
            % Surviving trials
            eval(['st_' measures{c} ' = nAvg;'])
            % Percentage of trials
            eval(['pt_' measures{c} ' = round((nAvg/ot_' measures{c} ')*100,0);'])
        end 
    end 
    
    % Sum trials from Pol 1 and Pol 2 for each FFR (low, medium and high), and average percentages
    ot_FFR_low = ot_Pol_1_low + ot_Pol_2_low;
    st_FFR_low = st_Pol_1_low + st_Pol_2_low;
    pt_FFR_low = (pt_Pol_1_low + pt_Pol_2_low)/2; % percentage average
    
    ot_FFR_medium = ot_Pol_1_medium + ot_Pol_2_medium;
    st_FFR_medium = st_Pol_1_medium + st_Pol_2_medium;
    pt_FFR_medium = (pt_Pol_1_medium + pt_Pol_2_medium)/2; % percentage average
    
    ot_FFR_high = ot_Pol_1_high + ot_Pol_2_high;
    st_FFR_high = st_Pol_1_high + st_Pol_2_high;
    pt_FFR_high = (pt_Pol_1_high + pt_Pol_2_high)/2; % percentage average
    
    % Now store values in matrices (ot original trials, st survivor trials)
    Trial_count{p,1} = Subj_type;
    Trial_count{p,2} = ot_FFR_low;
    Trial_count{p,3} = st_FFR_low;
    Trial_count{p,4} = ot_FFR_medium;
    Trial_count{p,5} = st_FFR_medium;
    Trial_count{p,6} = ot_FFR_high;
    Trial_count{p,7} = st_FFR_high;
    Trial_count{p,8} = ot_Tone_400ms;
    Trial_count{p,9} = st_Tone_400ms;
    Trial_count{p,10} = ot_Tone_1s;
    Trial_count{p,11} = st_Tone_1s;
    
    Trial_count{p,12} = [num2str(pt_FFR_low) ' %'];
    Trial_count{p,13} = [num2str(pt_FFR_medium) ' %'];
    Trial_count{p,14} = [num2str(pt_FFR_high) ' %'];
    Trial_count{p,15} = [num2str(pt_Tone_400ms) ' %'];
    Trial_count{p,16} = [num2str(pt_Tone_400ms) ' %'];
    
    % Determine now if EEG/MEG is bad based on criteria and numbers at hand
    % Set all as not bad before testing
    low_bad = 0;
    medium_bad = 0;
    high_bad = 0;
    % FFR LOW
    if ((pt_FFR_low < crit_percent) || (st_FFR_low < crit_sweeps_FFR))
        low_bad = 1;
    end
    % FFR MEDIUM
    if ((pt_FFR_medium < crit_percent) || (st_FFR_medium < crit_sweeps_FFR))
        medium_bad = 1;
    end
    % FFR HIGH
    if ((pt_FFR_high < crit_percent) || (st_FFR_high < crit_sweeps_FFR))
        high_bad = 1;
    end

    if (low_bad == 0) && (medium_bad == 0) && (high_bad == 0)
        disp('All FFRs have enough sweeps');
    elseif (low_bad == 1) && (medium_bad == 0) && (high_bad == 0)
        if ~strcmp(subject_array{pos_subj,5},'exception_FFR')
            subject_array{pos_subj,5} = 'LOW_bad';
        end
    elseif (low_bad == 0) && (medium_bad == 1) && (high_bad == 0)
        if ~strcmp(subject_array{pos_subj,5},'exception_FFR')
            subject_array{pos_subj,5} = 'MED_bad';
        end
    elseif (low_bad == 0) && (medium_bad == 0) && (high_bad == 1)
        if ~strcmp(subject_array{pos_subj,5},'exception_FFR')
            subject_array{pos_subj,5} = 'HIGH_bad';
        end
    elseif (low_bad == 1) && (medium_bad == 1) && (high_bad == 0)
        if ~strcmp(subject_array{pos_subj,5},'exception_FFR')
            subject_array{pos_subj,5} = 'LOW&MED_bad';
        end
    elseif (low_bad == 0) && (medium_bad == 1) && (high_bad == 1)
        if ~strcmp(subject_array{pos_subj,5},'exception_FFR')
            subject_array{pos_subj,5} = 'MED&HIGH_bad';
        end
    elseif (low_bad == 1) && (medium_bad == 0) && (high_bad == 1)
        if ~strcmp(subject_array{pos_subj,5},'exception_FFR')
            subject_array{pos_subj,5} = 'LOW&HIGH_bad';
        end
    elseif (low_bad == 1) && (medium_bad == 1) && (high_bad == 1)
        if ~strcmp(subject_array{pos_subj,5},'exception_FFR')
            subject_array{pos_subj,5} = 'ALL_bad';
        end
    end

    if (((pt_Tone_400ms < crit_percent) || (st_Tone_400ms < crit_sweeps_LLR)) && ((pt_Tone_1s > crit_percent) || (st_Tone_1s > crit_sweeps_LLR))) % Tone 400ms but not 1s is bad
        if ~strcmp(subject_array{pos_subj,6},'exception_LLR')
            subject_array{pos_subj,6} = '400ms_bad';
        end
    elseif (((pt_Tone_1s < crit_percent) || (st_Tone_1s < crit_sweeps_LLR)) && ((pt_Tone_400ms > crit_percent) || (st_Tone_400ms > crit_sweeps_LLR))) % Tone 1s but not 400ms is bad
        if ~strcmp(subject_array{pos_subj,6},'exception_LLR')
            subject_array{pos_subj,6} = '1s_bad';
        end
    elseif (((pt_Tone_400ms < crit_percent) || (st_Tone_400ms < crit_sweeps_LLR)) && ((pt_Tone_1s < crit_percent) || (st_Tone_1s < crit_sweeps_LLR))) % Both 400ms and 1s ISI tones are bad
        if ~strcmp(subject_array{pos_subj,6},'exception_LLR')
            subject_array{pos_subj,6} = '400ms&1s_bad';
        end
    end
    
    save([root_dir '/subject_array.mat'],'subject_array') 
end
% Convert to tables
Trial_table = array2table(Trial_count,'RowNames',participant(1:size(Trial_count,1)),'VariableNames',colNames);
% Save
save([root_dir '/QC/Surviving_sweeps_v3.mat'],'Trial_table');
% Write table in Excel
writetable(Trial_table, [root_dir '/QC/Surviving_sweeps_v3.xlsx'])

clearvars('-except', initialVars{:});
disp 'DONE WITH OBTAINING SWEEP COUNT (FFR_Sz)!!!'
disp(datetime)
toc

%% Plot individual subjects LLR/FFR (Time Domain and Freq domain)

channel_to_plot = 'Cz'; % 'cluster', 'Cz'
% RECOMEND ONE AT A TIME
participant = {
'FFR_X15'
    }; % In case you don't want to plot them all

set(0,'defaultfigurecolor',[1 1 1]); % I want white backgrounds
% FFR time domain
for p = 1:length(participant)
    
pos_subj = find(strcmp({subject_array{:,1}},participant{p}));
% if ~strcmp(subject_array{pos_subj,3},'DONE'); continue; end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LLR PLOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;
h(1) = subplot(1,2,1); h(2) = subplot(1,2,2); 
% LLR 400ms ISI
load([root_dir '/Results/' participant{p} '/LLR_400ms_' channel_to_plot '.mat']);
s_r = round((length(Average)/500)*1000);
time_samples=linspace(-100,400,((((-100*(-1)) + 400)/1000)*s_r));
Average = Average*1e6;
hold (h(1),'on')
plot(h(1),time_samples,Average,'k');
current_max = max(Average);
current_min = min(Average);
xlim(h(1),[-100,400]);
ylabel(h(1),'Amplitude (µV)')
xlabel(h(1),'Time (ms)');
current_title = '400ms ISI';
current_title = strrep(current_title,'_',' ');
title(h(1),current_title)

% LLR 1s ISI
load([root_dir '/Results/' participant{p} '/LLR_1s_' channel_to_plot '.mat']);
s_r = round((length(Average)/500)*1000);
time_samples=linspace(-100,400,((((-100*(-1)) + 400)/1000)*s_r));
Average = Average*1e6;
if max(Average) > current_max; current_max = max(Average); end
if min(Average) < current_min; current_min = min(Average); end
hold (h(2),'on')
plot(h(2),time_samples,Average,'k');
xlim(h(2),[-100,400]);
line(h(2),[0 0], [ylim],'Color','black')
line(h(2),xlim(), [0,0], 'Color', 'k');
current_title = '1s ISI';
current_title = strrep(current_title,'_',' ');
title(h(2),current_title)

for i = 1:2
    hold(h(i),'on');
    ylim(h(i),[floor(current_min),ceil(current_max)]);
    line(h(i),[0 0], [floor(current_min),ceil(current_max)],'Color','black')
    line(h(i),xlim(), [0,0], 'Color', 'k');
end
current_title = ['Pure_Tone (' channel_to_plot ') ' participant{p}];
current_title = strrep(current_title,'_',' ');
suptitle(current_title)
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FFR TIME DOMAIN PLOT %%%%%%%%%%%%%%%%%%%%%
figure;
h(1) = subplot(2,3,1); h(2) = subplot(2,3,2); h(3) = subplot(2,3,3); 
h(4) = subplot(2,3,4); h(5) = subplot(2,3,5); h(6) = subplot(2,3,6); 

% FFR LOW time domain original filter
load([root_dir '/Results/' participant{p} '/FFR_low_' channel_to_plot '.mat']);
Average = Average*1e6; % Adjust scale
SR =  round(length(Average)/0.270); % Sampling rate
if SR ~= 16385; warning(['FFR sampling rate is odd for ' participant{p}]);end
time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
plot(h(1),time_samples,Average,'k');
current_max = max(Average);
current_min = min(Average);
xlim(h(1),[-40,230]);
current_title = '113 Hz F0 (Original filter)';
current_title = strrep(current_title,'_',' ');
title(h(1),current_title)

% FFR MEDIUM time domain original filter
load([root_dir '/Results/' participant{p} '/FFR_medium_' channel_to_plot '.mat']);
Average = Average*1e6; % Adjust scale
SR =  round(length(Average)/0.270); % Sampling rate
if SR ~= 16385; warning(['FFR sampling rate is odd for ' participant{p}]);end
time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
plot(h(2),time_samples,Average,'k');
if max(Average) > current_max; current_max = max(Average); end
if min(Average) < current_min; current_min = min(Average); end
xlim(h(2),[-40,230]);
current_title = '266 Hz F0 (Original filter)';
current_title = strrep(current_title,'_',' ');
title(h(2),current_title)

% FFR HIGH time domain original filter
load([root_dir '/Results/' participant{p} '/FFR_high_' channel_to_plot '.mat']);
Average = Average*1e6; % Adjust scale
SR =  round(length(Average)/0.270); % Sampling rate
if SR ~= 16385; warning(['FFR sampling rate is odd for ' participant{p}]);end
time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
plot(h(3),time_samples,Average,'k');
if max(Average) > current_max; current_max = max(Average); end
if min(Average) < current_min; current_min = min(Average); end
xlim(h(3),[-40,230]);
current_title = '317 Hz F0 (Original filter)';
current_title = strrep(current_title,'_',' ');
title(h(3),current_title)

% FFR low time domain low pass filtered
load([root_dir '/Results/' participant{p} '/FFR_low_' low_pass_FFR_low_string '_' channel_to_plot '.mat']);
Average = Average*1e6; % Adjust scale
SR =  round(length(Average)/0.270); % Sampling rate
if SR ~= 16385; warning(['FFR sampling rate is odd for ' participant{p}]);end
time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
plot(h(4),time_samples,Average,'k');
if max(Average) > current_max; current_max = max(Average); end
if min(Average) < current_min; current_min = min(Average); end
xlabel(h(4),'Time (ms)')
xlim(h(4),[-40,230]);
ylabel(h(4),'Amplitude (uV)')
current_title = ['113 Hz F0  (low_pass ' low_pass_FFR_low_string ')'];
current_title = strrep(current_title,'_',' ');
title(h(4),current_title)

% FFR medium time domain low pass filtered
load([root_dir '/Results/' participant{p} '/FFR_medium_' low_pass_FFR_medium_string '_' channel_to_plot '.mat']);
Average = Average*1e6; % Adjust scale
SR =  round(length(Average)/0.270); % Sampling rate
if SR ~= 16385; warning(['FFR sampling rate is odd for ' participant{p}]);end
time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
plot(h(5),time_samples,Average,'k');
if max(Average) > current_max; current_max = max(Average); end
if min(Average) < current_min; current_min = min(Average); end
xlim(h(5),[-40,230]);
current_title = ['266 Hz F0  (low_pass ' low_pass_FFR_medium_string ')'];
current_title = strrep(current_title,'_',' ');
title(h(5),current_title)

% FFR high time domain low pass filtered
load([root_dir '/Results/' participant{p} '/FFR_high_' low_pass_FFR_high_string '_' channel_to_plot '.mat']);
Average = Average*1e6; % Adjust scale
SR =  round(length(Average)/0.270); % Sampling rate
if SR ~= 16385; warning(['FFR sampling rate is odd for ' participant{p}]);end
time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
plot(h(6),time_samples,Average,'k');
if max(Average) > current_max; current_max = max(Average); end
if min(Average) < current_min; current_min = min(Average); end
xlim(h(6),[-40,230]);
current_title = ['317 Hz F0  (low_pass ' low_pass_FFR_high_string ')'];
current_title = strrep(current_title,'_',' ');
title(h(6),current_title)

for i = 1:6
    hold(h(i),'on');
    ylim(h(i),[round(current_min,1),round(current_max,1)]);
    line(h(i),[0 0], [round(current_min,1),round(current_max,1)],'Color','black')
    line(h(i),[-40,230], [0,0], 'Color', 'k');
end
current_title = ['FFR (' channel_to_plot ') ' participant{p}];
current_title = strrep(current_title,'_',' ');
suptitle(current_title)

%%%%%%%%%%%%%%%%%%%%%%%%% AUTOCORRELOGRAM PLOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;
h(1) = subplot(2,3,1); h(2) = subplot(2,3,2); h(3) = subplot(2,3,3); 
h(4) = subplot(2,3,4); h(5) = subplot(2,3,5); h(6) = subplot(2,3,6); 

% Autocorrelogram default frequency FFR LOW
load([root_dir '/Results/' participant{p} '/FFR_low_' channel_to_plot '.mat']);
Average = Average*1e6; % Adjust scale
SR =  round(length(Average)/0.270); % Sampling rate
if SR ~= 16385; warning(['FFR sampling rate is odd for ' participant{p}]);end
time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
samples_per_ms = round(SR/1000);
[acf] = autocorr(Average,length(Average)-1);
autocorr_axis = linspace(0,round(length(time_samples)/samples_per_ms)-1,length(time_samples));
lineHandles = stem(h(1),autocorr_axis,acf,'filled','r-o');
set(lineHandles(1),'MarkerSize',4)
grid(h(1),'on')
hold(h(1),'on')
plot(h(1),[8.84 8.84],[0 1],'k')
xlim(h(1),[0,20]);
current_title = '113 Hz Original filter';
current_title = strrep(current_title,'_',' ');
title(h(1),current_title)

% Autocorrelogram default frequency FFR MEDIUM
load([root_dir '/Results/' participant{p} '/FFR_medium_' channel_to_plot '.mat']);
Average = Average*1e6; % Adjust scale
SR =  round(length(Average)/0.270); % Sampling rate
if SR ~= 16385; warning(['FFR sampling rate is odd for ' participant{p}]);end
time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
samples_per_ms = round(SR/1000);
[acf] = autocorr(Average,length(Average)-1);
autocorr_axis = linspace(0,round(length(time_samples)/samples_per_ms)-1,length(time_samples));
lineHandles = stem(h(2),autocorr_axis,acf,'filled','r-o');
set(lineHandles(1),'MarkerSize',4)
grid(h(2),'on')
hold(h(2),'on')
plot(h(2),[3.75 3.75],[0 1],'k')
xlim(h(2),[0,20]);
current_title = '266 Hz Original filter';
current_title = strrep(current_title,'_',' ');
title(h(2),current_title)

% Autocorrelogram FFR HIGH default frequency
load([root_dir '/Results/' participant{p} '/FFR_high_' channel_to_plot '.mat']);
Average = Average*1e6; % Adjust scale
SR =  round(length(Average)/0.270); % Sampling rate
if SR ~= 16385; warning(['FFR sampling rate is odd for ' participant{p}]);end
time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
samples_per_ms = round(SR/1000);
[acf] = autocorr(Average,length(Average)-1);
autocorr_axis = linspace(0,round(length(time_samples)/samples_per_ms)-1,length(time_samples));
lineHandles = stem(h(3),autocorr_axis,acf,'filled','r-o');
set(lineHandles(1),'MarkerSize',4)
grid(h(3),'on')
hold(h(3),'on')
plot(h(3),[3.15 3.15],[0 1],'k')
xlim(h(3),[0,20]);
current_title = '317 Hz Original filter';
current_title = strrep(current_title,'_',' ');
title(h(3),current_title)

% Autocorrelogram low pass frequency FFR LOW
load([root_dir '/Results/' participant{p} '/FFR_low_' low_pass_FFR_low_string '_' channel_to_plot '.mat']);
Average = Average*1e6; % Adjust scale
SR =  round(length(Average)/0.270); % Sampling rate
if SR ~= 16385; warning(['FFR sampling rate is odd for ' participant{p}]);end
time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
samples_per_ms = round(SR/1000);
[acf] = autocorr(Average,length(Average)-1);
autocorr_axis = linspace(0,round(length(time_samples)/samples_per_ms)-1,length(time_samples));
lineHandles = stem(h(4),autocorr_axis,acf,'filled','r-o');
set(lineHandles(1),'MarkerSize',4)
grid(h(4),'on')
xlabel(h(4),'Lag')
xlim(h(4),[0,20]);
hold(h(4),'on')
plot(h(4),[8.84 8.84],[0 1],'k')
ylabel(h(4),'Sample Autocorrelation')
current_title = ['113 Hz (' low_pass_FFR_low_string ' low pass)'];
current_title = strrep(current_title,'_',' ');
title(h(4),current_title)

% Autocorrelogram low pass frequency FFR MEDIUM
load([root_dir '/Results/' participant{p} '/FFR_medium_' low_pass_FFR_medium_string '_' channel_to_plot '.mat']);
Average = Average*1e6; % Adjust scale
SR =  round(length(Average)/0.270); % Sampling rate
if SR ~= 16385; warning(['FFR sampling rate is odd for ' participant{p}]);end
time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
samples_per_ms = round(SR/1000);
[acf] = autocorr(Average,length(Average)-1);
autocorr_axis = linspace(0,round(length(time_samples)/samples_per_ms)-1,length(time_samples));
lineHandles = stem(h(5),autocorr_axis,acf,'filled','r-o');
set(lineHandles(1),'MarkerSize',4)
grid(h(5),'on')
xlim(h(5),[0,20]);
hold(h(5),'on')
plot(h(5),[3.75 3.75],[0 1],'k')
current_title = ['266 Hz (' low_pass_FFR_medium_string ' low pass)'];
current_title = strrep(current_title,'_',' ');
title(h(5),current_title)

% Autocorrelogram low pass frequency FFR HIGH
load([root_dir '/Results/' participant{p} '/FFR_high_' low_pass_FFR_high_string '_' channel_to_plot '.mat']);
Average = Average*1e6; % Adjust scale
SR =  round(length(Average)/0.270); % Sampling rate
if SR ~= 16385; warning(['FFR sampling rate is odd for ' participant{p}]);end
time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
samples_per_ms = round(SR/1000);
[acf] = autocorr(Average,length(Average)-1);
autocorr_axis = linspace(0,round(length(time_samples)/samples_per_ms)-1,length(time_samples));
lineHandles = stem(h(6),autocorr_axis,acf,'filled','r-o');
set(lineHandles(1),'MarkerSize',4)
grid(h(6),'on')
xlim([0,20]);
hold(h(6),'on')
plot(h(6),[3.15 3.15],[0 1],'k')
current_title = ['317 Hz (' low_pass_FFR_high_string ' low pass)'];
current_title = strrep(current_title,'_',' ');
title(h(6),current_title)

current_title = ['Autocorrelogram (' channel_to_plot ') ' participant{p}];
current_title = strrep(current_title,'_',' ');
suptitle(current_title)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FFT PLOTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;
h(1) = subplot(3,4,1); h(2) = subplot(3,4,2); h(3) = subplot(3,4,3); h(4) = subplot(3,4,4); 
h(5) = subplot(3,4,5); h(6) = subplot(3,4,6); h(7) = subplot(3,4,7); h(8) = subplot(3,4,8); 
h(9) = subplot(3,4,9); h(10) = subplot(3,4,10); h(11) = subplot(3,4,11); h(12) = subplot(3,4,12); 

% FFR LOW FFT in each time section
for tw = 1:length(time_windows_FFR)
load([root_dir '/Results/' participant{p} '/FFT_low_' time_windows_FFR_labels{tw} '_' channel_to_plot '.mat']);
amplitude = amplitude*1e6; % Adjust scale
amplitude = amplitude.^2; % Convert to power
if tw == 1 % first iteration
    current_max = max(amplitude(1,[1:500]));
else
    if max(amplitude(1,[1:500])) > current_max; current_max = max(amplitude(1,[1:500])); end
end
plot(h(tw),amplitude,'k');
xlim(h(tw),[0,500]);
% y = ylim;
% plot(h(i),[113 113],[y(1) y(2)],'k')
current_title = ['113 (' time_windows_FFR_labels{tw} ')'];
current_title = strrep(current_title,'_',' ');
title(h(tw),current_title)
end

% FFR MEDIUM FFT in each time section
for tw = 1:length(time_windows_FFR)
load([root_dir '/Results/' participant{p} '/FFT_medium_' time_windows_FFR_labels{tw} '_' channel_to_plot '.mat']);
amplitude = amplitude*1e6; % Adjust scale
amplitude = amplitude.^2; % Convert to power
plot(h(tw+4),amplitude,'k');
if max(amplitude(1,[1:500])) > current_max; current_max = max(amplitude(1,[1:500])); end
xlim(h(tw+4),[0,500]);
% y = ylim; hold on;
% plot([317 317],[y(1) y(2)],'k')
current_title = ['266 (' time_windows_FFR_labels{tw} ')'];
current_title = strrep(current_title,'_',' ');
title(h(tw+4),current_title)
end

% FFR HIGH FFT in each time section
for tw = 1:length(time_windows_FFR)
load([root_dir '/Results/' participant{p} '/FFT_high_' time_windows_FFR_labels{tw} '_' channel_to_plot '.mat']);
amplitude = amplitude*1e6; % Adjust scale
amplitude = amplitude.^2; % Convert to power
plot(h(tw+8),amplitude,'k');
if max(amplitude(1,[1:500])) > current_max; current_max = max(amplitude(1,[1:500])); end
xlim(h(tw+8),[0,500]);
% y = ylim; hold on;
% plot([317 317],[y(1) y(2)],'k')
if tw == 1
    ylabel(h(tw+8),'Power')
    xlabel(h(tw+8),'Frequencies (Hz)')
end
current_title = ['317 (' time_windows_FFR_labels{tw} ')'];
current_title = strrep(current_title,'_',' ');
title(h(tw+8),current_title)
end

for i = 1:4
    hold(h(i),'on')
    ylim(h(i),[0,current_max]);
    plot(h(i),[113 113],[0 current_max],'r')
end

for i = 5:8
    hold(h(i),'on')
    ylim(h(i),[0,current_max]);
    plot(h(i),[266 266],[0 current_max],'r')
end

for i = 9:12
    hold(h(i),'on')
    ylim(h(i),[0,current_max]);
    plot(h(i),[317 317],[0 current_max],'r')
end

current_title = ['FFR FFT (' channel_to_plot ') ' participant{p}];
current_title = strrep(current_title,'_',' ');
suptitle(current_title)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TIME FREQUENCY PLOT %%%%%%%%%%%%%%%%%%%%%%%%
% Plot time-frequency FFR LOW
load([root_dir '/Results/' participant{p} '/Time_Frequency_low_' channel_to_plot '.mat']);
tf_map = squeeze(tf_map);
% Average = Average*1e6; % Adjust scale
SR =  round(size(tf_map,1)/0.270); % Sampling rate
if SR ~= 16385; warning(['FFR sampling cdrate is odd for ' participant{p}]);end
time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
% Plot Time-frequency map
figure; surf([1:500],time_samples,abs(tf_map),'EdgeColor','none');   
axis xy; axis tight; colormap(jet); view(0,90);
camroll(90)
set(gca,'YDir','reverse');
ax = gca;
ax.XAxisLocation = 'top';
line([0 500], [0 0],'Color','black')
ax.SortMethod = 'childorder';
line([113,113], [-40 230], 'Color', 'r');
ylabel('Time (ms)')
xlabel('Frequencies (Hz)')
cb = colorbar;
ylabel(cb, 'Power')
set(cb,'position',[0.9 0.11 0.02 0.811])
% [xposition yposition width height].
% line([0 0], [xlim],'Color','black')
% line(xlim(), [0,0], 'Color', 'k');
current_title = ['FFR 113Hz Time-frequency ' participant{p} ' (' channel_to_plot ')'];
current_title = strrep(current_title,'_',' ');
title(current_title)

% Plot time-frequency FFR MEDIUM
load([root_dir '/Results/' participant{p} '/Time_Frequency_medium_' channel_to_plot '.mat']);
tf_map = squeeze(tf_map);
% Average = Average*1e6; % Adjust scale
SR =  round(size(tf_map,1)/0.270); % Sampling rate
if SR ~= 16385; warning(['FFR sampling rate is odd for ' participant{p}]);end
time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
% Plot Time-frequency map
figure; surf([1:500],time_samples,abs(tf_map),'EdgeColor','none');   
axis xy; axis tight; colormap(jet); view(0,90);
camroll(90)
set(gca,'YDir','reverse');
ax = gca;
ax.XAxisLocation = 'top';
line([0 500], [0 0],'Color','black')
ax.SortMethod = 'childorder';
line([266,266], [-40 230], 'Color', 'r');
ylabel('Time (ms)')
xlabel('Frequencies (Hz)')
cb = colorbar;
ylabel(cb, 'Power')
set(cb,'position',[0.9 0.11 0.02 0.811])
% [xposition yposition width height].
% line([0 0], [xlim],'Color','black')
% line(xlim(), [0,0], 'Color', 'k');
current_title = ['FFR 266Hz Time-frequency ' participant{p} ' (' channel_to_plot ')'];
current_title = strrep(current_title,'_',' ');
title(current_title)

% Plot time-frequency FFR HIGH
load([root_dir '/Results/' participant{p} '/Time_Frequency_high_' channel_to_plot '.mat']);
tf_map = squeeze(tf_map);
% Average = Average*1e6; % Adjust scale
SR =  round(size(tf_map,1)/0.270); % Sampling rate
if SR ~= 16385; warning(['FFR sampling cdrate is odd for ' participant{p}]);end
time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
% Plot Time-frequency map
figure; surf([1:500],time_samples,abs(tf_map),'EdgeColor','none');   
axis xy; axis tight; colormap(jet); view(0,90);
camroll(90)
set(gca,'YDir','reverse');
ax = gca;
ax.XAxisLocation = 'top';
line([0 500], [0 0],'Color','black')
ax.SortMethod = 'childorder';
line([317,317], [-40 230], 'Color', 'r');
ylabel('Time (ms)')
xlabel('Frequencies (Hz)')
cb = colorbar;
ylabel(cb, 'Power')
set(cb,'position',[0.9 0.11 0.02 0.811])
% [xposition yposition width height].
% line([0 0], [xlim],'Color','black')
% line(xlim(), [0,0], 'Color', 'k');
current_title = ['FFR 317Hz Time-frequency ' participant{p} ' (' channel_to_plot ')'];
current_title = strrep(current_title,'_',' ');
title(current_title)
end

% TF with brainstorm

% Program stim_response cross correlation
% Will have to load stimulus into brainstorm, sample it at 16385 
% and filter it from 100 to 3000 Hz before comparing with FFR


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% FFR freq domain (55 to 170ms, corresponding to vowel)
% [~,closestIndex_init] = min(abs(time_samples-55));
% [~,closestIndex_end] = min(abs(time_samples-170));               
% T = 1/s_r;             % Sampling period       
% t = (0:length(F)-1)*T;        % Time vector
% F_freq = fft(F(closestIndex_init:closestIndex_end));
% P2 = abs(F_freq/length(F));
% P1 = P2(1:length(F)/2+1);
% P1(2:end-1) = 2*P1(2:end-1);
% figure;
% f = s_r*(0:(length(F_freq)/2))/length(F_freq);
% plot(f,P1) 
% title('FFR FFT (55 - 170 ms)')
% xlabel('f (Hz)')
% ylabel('|P1(f)|')

% F_freq = squeeze(TF(3,1,:))';
% load([root_dir '/Scalp/' participant{p} '/FFR_FFT.mat']);
% load([root_dir '/Scalp/' participant{p} '/Freqs.mat']);
% figure;
% plot(Freqs,F_freq);
% hold on;
% xlim([0,500]);
% hold on;
% ylabel('Power')
% xlabel('Frequencies (Hz)');
% title('FFR freqs (55 to 170ms)');

% Time_windows: Pre (-40 0), Tra (10-55), Con (55-170), Tot (10-170)
% asuming 10ms of neural lag
% 
% Measures TIME DOMAIN:
% * rms (for each time window): root(Sum amp/time points).
% * amp snr (normalized rms, for each time window): same than before but divided by rms at baseline
% * Stimulus-to-respomse cross-correlation (only once): computed with xcorr, MATLAB, once for each response delay from 3 to 10ms. Stimulus has to be bandpass filtered and sampled in the same range than signal. One value of maximum cross-correlation.
% * Neural lag (only once): delay with maximum stimulus to response cross-correlation from before (in ms).
% 
% Measures SPECTRAL DOMAIN:
% * freq amp or power FFT or Welch (for each time window): if Welch, 82%overlap and 40ms (like baseline). FFT gives more accurate peak (consider overlapping FFTs manually instead of using brainstorm Welch: pwelch matlab).
% * freq amp or power SNR (for each time window) = 10 to 20Hz windows in peak and + - 10/20 at the valleys
% * Pitch error (only once): calculate spectrogram in stim and response/compare where in Hz the maximum amplitude is in stim and response for each sample (should be in F0 = 113Hz)/Measure for each time point the difference in Hz between the point of maximum amplitude in the stim and the response and average.
% * Pitch strength (autocorrelogram): correlate response (starting at 10ms) and response moved 1ms and get values, do again moving 2ms, etc and obtain a "ms moved(Lag) x samples (ms)" matrix of correlation values. Then check at which delay the correlation values are stronger. If highest correlation coefficient coincides with the duration of a cicle (1/F0 = 8.84ms) then response is robust. Then, average lags across samples to get a single autocorrelation value (pitch strength). 
% 
% PLOTC:
% Time domain FFR
% Frequency (amp or power) FFR
% Spectrograms: basic time frequency plot
% Autocorrelogram (related to pitch strength)


% For autocorr (prob useless)
% samples_per_ms = round(s_r/1000);
% num_iter = round(s_r/samples_per_ms); % How many ms fit
% delay = samples_per_ms; % 1 ms
% Correlogram = [];
% for ni = 1:length(num_iter)
%     new_F = [zeros(1,delay) F(1:end-delay)];
%     delay = delay + samples_per_ms; % each time we include +1ms
%     corr_matrix = interleave(F,new_F);
%     Correlogram(ni) = corr(corr_matrix);
%     % Correlogram(ni) = xcorr(F,new_F);
% end

%% Butterfly plots waves (Time Domain and Freq domain)
% As opposed to 'Butterfly plots single values', which are butterfly 
% plots with rms, neural lag, spectral snr, etc)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MODIFY THIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define which channel to use (or cluster)
channel_to_plot = 'Cz'; % 'cluster', 'Cz'
gavr_to_overlay = 'GAVR_13C_vs_15FE'; % Folder from GAVR that will be on top of plot
% GAVR_12C_vs_10FE
% GAVR_6C_vs_4FE for NARSAD

% Decide what to plot
plot_llr = 0; % 0: NO 1: YES
plot_ffr_td = 0; % 0: NO 1: YES
plot_ffr_fft = 1; % 0: NO 1: YES
ffr_version = 'original'; % 'original' or 'filtered' choose only one
shaded_areas = 1; % Overlay of FFR sections, spec and TD peaks, etc
transparency_shaded = 0.1; % For shaded areas

% Define groups for each FFR frequency separately 
% (as some subjects have low FFR only, high FFR only, etc)
% HC
FFR_low_HC = {'FFR_S01','FFR_X74','FFR_X10','FFR_X62','FFR_X40','FFR_2456','FFR_2494','FFR_2496','FFR_X54','FFR_X72','FFR_2442','FFR_X70',...
    'FFR_X99','FFR_X09','FFR_X15','FFR_X86','FFR_X21','FFR_X15'};
FFR_medium_HC = {'FFR_X40','FFR_2456','FFR_2494','FFR_2496','FFR_X54','FFR_X72','FFR_2442','FFR_X70','FFR_X99','FFR_X09','FFR_X15','FFR_X86','FFR_X21','FFR_X15'};
FFR_high_HC = {'FFR_X62','FFR_X40','FFR_2456','FFR_2494','FFR_2496','FFR_X54','FFR_X72','FFR_2442','FFR_X70','FFR_X99','FFR_X09','FFR_X15','FFR_X86','FFR_X21','FFR_X15'};
% FE 
FFR_low_FE = {'FFR_X18','FFR_X81','FFR_X01','FFR_X79','FFR_X61','FFR_2477','FFR_X16','FFR_X97','FFR_2480','FFR_X05','FFR_X78','FFR_X11','FFR_X01','FFR_X13','FFR_X17'};
FFR_medium_FE = {'FFR_X01','FFR_X79','FFR_X61','FFR_2477','FFR_X16','FFR_X97','FFR_2480','FFR_X05','FFR_X78','FFR_X11','FFR_X01','FFR_X13','FFR_X17'};
FFR_high_FE = {'FFR_X18','FFR_X81','FFR_X01','FFR_X79','FFR_X61','FFR_2477','FFR_X16','FFR_X97','FFR_2480','FFR_X05','FFR_X78','FFR_X11','FFR_X01','FFR_X13','FFR_X17'};


FFR_low_CHSZ = {}; % Won't use for now, but think about it for the future
FFR_medium_CHSZ = {};
FFR_high_CHSZ = {};

% Define groups for LLR (only ones with 400ms and 1s ISI since it's only
% for quality control and we already saw each LLR individually anyway)
LLR_HC = {'FFR_X62','FFR_X40','FFR_2456','FFR_2494','FFR_2496','FFR_X54','FFR_X72','FFR_2442','FFR_X70','FFR_X99','FFR_X09','FFR_X15','FFR_X86'};
LLR_FE = {'FFR_X18','FFR_X81','FFR_X01','FFR_X79','FFR_X61','FFR_2477','FFR_X16','FFR_X97','FFR_2480','FFR_X05','FFR_X78','FFR_X11','FFR_X01'};
LLR_CHSZ = {}; % Won't use for now, but think about it for the future
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%% START PLOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(0,'defaultfigurecolor',[1 1 1]); % I want white backgrounds
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LLR PLOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if plot_llr == 1
figure;
h(1) = subplot(2,2,1); h(2) = subplot(2,2,2);
h(3) = subplot(2,2,3); h(4) = subplot(2,2,4);

% LLR HC 400ms ISI
for llrhc = 1:length(LLR_HC)
if strcmp(LLR_HC{llrhc},'FFR_S01') || strcmp(LLR_HC{llrhc},'FFR_S02') || strcmp(LLR_HC{llrhc},'FFR_X74') || strcmp(LLR_HC{llrhc},'FFR_X10')
    load([root_dir '/Results/' LLR_HC{llrhc} '/LLR_' channel_to_plot '.mat']);
else
    load([root_dir '/Results/' LLR_HC{llrhc} '/LLR_400ms_' channel_to_plot '.mat']);
end
s_r = round((length(Average)/500)*1000);
time_samples=linspace(-100,400,((((-100*(-1)) + 400)/1000)*s_r));
Average = Average*1e6;
hold (h(1),'on')
plot(h(1),time_samples,Average);
if llrhc == 1
    current_max = max(Average);
    current_min = min(Average);
else
    if max(Average) > current_max; current_max = max(Average); end
    if min(Average) < current_min; current_min = min(Average); end
end
end
hold (h(1),'on')
% Plot average here
load([root_dir '/Results/' gavr_to_overlay '/gavr/LLR_400ms_C_' channel_to_plot '.mat']);
F = F*1e6; % scale
plot(h(1),time_samples,F,'Color','k','LineWidth',4,'LineStyle',':');
legend_string = strrep(LLR_HC,'_',' ');
hLeg = legend(h(1),legend_string);
set(hLeg,'visible','off')
xlim(h(1),[-100,400]);
current_title = 'HC 400ms ISI';
current_title = strrep(current_title,'_',' ');
title(h(1),current_title)

% LLR HC 1s ISI
for llrhc = 1:length(LLR_HC)
if strcmp(LLR_HC{llrhc},'FFR_S01') || strcmp(LLR_HC{llrhc},'FFR_S02') || strcmp(LLR_HC{llrhc},'FFR_X74') || strcmp(LLR_HC{llrhc},'FFR_X10')
    continue;
else
    load([root_dir '/Results/' LLR_HC{llrhc} '/LLR_1s_' channel_to_plot '.mat']);
end
s_r = round((length(Average)/500)*1000);
time_samples=linspace(-100,400,((((-100*(-1)) + 400)/1000)*s_r));
Average = Average*1e6;
if max(Average) > current_max; current_max = max(Average); end
if min(Average) < current_min; current_min = min(Average); end
hold (h(3),'on')
plot(h(3),time_samples,Average);
end
hold (h(3),'on')
% Plot average here
load([root_dir '/Results/' gavr_to_overlay '/gavr/LLR_1s_C_' channel_to_plot '.mat']);
F = F*1e6; % scale
plot(h(3),time_samples,F,'Color','k','LineWidth',4,'LineStyle',':');
legend_string = strrep(LLR_HC,'_',' ');
hLeg = legend(h(3),legend_string);
set(hLeg,'visible','off')
xlim(h(3),[-100,400]);
line(h(3),[0 0], [ylim],'Color','black')
line(h(3),xlim(), [0,0], 'Color', 'k');
ylabel(h(3),'Amplitude (µV)')
xlabel(h(3),'Time (ms)');
current_title = 'HC 1s ISI';
current_title = strrep(current_title,'_',' ');
title(h(3),current_title)

% LLR FE 400ms ISI
for llrfe = 1:length(LLR_FE)
load([root_dir '/Results/' LLR_FE{llrfe} '/LLR_400ms_' channel_to_plot '.mat']);
s_r = round((length(Average)/500)*1000);
time_samples=linspace(-100,400,((((-100*(-1)) + 400)/1000)*s_r));
Average = Average*1e6;
hold (h(2),'on')
plot(h(2),time_samples,Average);
if max(Average) > current_max; current_max = max(Average); end
if min(Average) < current_min; current_min = min(Average); end
end
hold (h(2),'on')
% Plot average here
load([root_dir '/Results/' gavr_to_overlay '/gavr/LLR_400ms_FE_' channel_to_plot '.mat']);
F = F*1e6; % scale
plot(h(2),time_samples,F,'Color','k','LineWidth',4,'LineStyle',':');
legend_string = strrep(LLR_FE,'_',' ');
hLeg = legend(h(2),legend_string);
set(hLeg,'visible','off')
xlim(h(2),[-100,400]);
current_title = 'FE 400ms ISI';
current_title = strrep(current_title,'_',' ');
title(h(2),current_title)

% LLR FE 1s ISI
for llrfe = 1:length(LLR_FE)
load([root_dir '/Results/' LLR_FE{llrfe} '/LLR_1s_' channel_to_plot '.mat']);
s_r = round((length(Average)/500)*1000);
time_samples=linspace(-100,400,((((-100*(-1)) + 400)/1000)*s_r));
Average = Average*1e6;
if max(Average) > current_max; current_max = max(Average); end
if min(Average) < current_min; current_min = min(Average); end
hold (h(4),'on')
plot(h(4),time_samples,Average);
end
hold (h(4),'on')
% Plot average here
load([root_dir '/Results/' gavr_to_overlay '/gavr/LLR_1s_FE_' channel_to_plot '.mat']);
F = F*1e6; % scale
plot(h(4),time_samples,F,'Color','k','LineWidth',4,'LineStyle',':');
legend_string = strrep(LLR_FE,'_',' ');
hLeg = legend(h(4),legend_string);
set(hLeg,'visible','off')
xlim(h(4),[-100,400]);
line(h(4),[0 0], [ylim],'Color','black')
line(h(4),xlim(), [0,0], 'Color', 'k');
current_title = 'FE 1s ISI';
current_title = strrep(current_title,'_',' ');
title(h(4),current_title)

for i = 1:4
    hold(h(i),'on');
    ylim(h(i),[floor(current_min),ceil(current_max)]);
    line(h(i),[0 0], [floor(current_min),ceil(current_max)],'Color','black')
    line(h(i),xlim(), [0,0], 'Color', 'k');
end
current_title = ['Pure_Tone (' channel_to_plot ')'];
current_title = strrep(current_title,'_',' ');
suptitle(current_title)
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FFR TIME DOMAIN PLOT %%%%%%%%%%%%%%%%%%%%%
if plot_ffr_td == 1
figure;
h(1) = subplot(3,2,1); h(2) = subplot(3,2,2); 
h(3) = subplot(3,2,3); h(4) = subplot(3,2,4);
h(5) = subplot(3,2,5); h(6) = subplot(3,2,6); 

% FFR LOW time domain HC
for ffrlhc = 1:length(FFR_low_HC)
if strcmp(ffr_version,'original')
    if strcmp(FFR_low_HC{ffrlhc},'FFR_S01') || strcmp(FFR_low_HC{ffrlhc},'FFR_S02') || strcmp(FFR_low_HC{ffrlhc},'FFR_X74') || strcmp(FFR_low_HC{ffrlhc},'FFR_X10')
        load([root_dir '/Results/' FFR_low_HC{ffrlhc} '/FFR_' channel_to_plot '.mat']);
    else
        load([root_dir '/Results/' FFR_low_HC{ffrlhc} '/FFR_low_' channel_to_plot '.mat']);
    end
elseif strcmp(ffr_version,'filtered')
    if strcmp(FFR_low_HC{ffrlhc},'FFR_S01') || strcmp(FFR_low_HC{ffrlhc},'FFR_S02') || strcmp(FFR_low_HC{ffrlhc},'FFR_X74') || strcmp(FFR_low_HC{ffrlhc},'FFR_X10')
        load([root_dir '/Results/' FFR_low_HC{ffrlhc} '/FFR_low_pass_' channel_to_plot '.mat']);
    else
        load([root_dir '/Results/' FFR_low_HC{ffrlhc} '/FFR_low_' low_pass_FFR_low_string '_' channel_to_plot '.mat']);
    end
end
Average = Average*1e6; % Adjust scale
SR =  round(length(Average)/0.270); % Sampling rate
if SR ~= 16385; warning(['FFR sampling rate is odd for ' participant{p}]);end
time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
hold(h(1),'on');
plot(h(1),time_samples,Average);
if ffrlhc == 1
    current_max = max(Average);
    current_min = min(Average);
else
    if max(Average) > current_max; current_max = max(Average); end
    if min(Average) < current_min; current_min = min(Average); end
end
end
hold(h(1),'on');
% Plot average here
if strcmp(ffr_version,'original')
    load([root_dir '/Results/' gavr_to_overlay '/gavr/FFR_low_TD_C_' channel_to_plot '.mat']);
elseif strcmp(ffr_version,'filtered')
    load([root_dir '/Results/' gavr_to_overlay '/gavr/FFR_low_TD_filtered_C_' channel_to_plot '.mat']);
end
F = F*1e6; % scale
plot(h(1),time_samples,F,'Color','k','LineWidth',2);
legend_string = strrep(FFR_low_HC,'_',' ');
hLeg = legend(h(1),legend_string);
set(hLeg,'visible','off')
xlim(h(1),[-40,230]);
if strcmp(ffr_version,'original') 
    current_title = 'HC 113Hz F0 (Original filter)';
elseif strcmp(ffr_version,'filtered') 
    current_title = ['HC 113Hz F0  (low_pass ' low_pass_FFR_low_string ')'];
end
current_title = strrep(current_title,'_',' ');
title(h(1),current_title)

for ffrlfe = 1:length(FFR_low_FE)
if strcmp(ffr_version,'original') 
    if strcmp(FFR_low_FE{ffrlfe},'FFR_S01') || strcmp(FFR_low_FE{ffrlfe},'FFR_S02') || strcmp(FFR_low_FE{ffrlfe},'FFR_X74') || strcmp(FFR_low_FE{ffrlfe},'FFR_X10')
        load([root_dir '/Results/' FFR_low_FE{ffrlfe} '/FFR_' channel_to_plot '.mat']);
    else
        load([root_dir '/Results/' FFR_low_FE{ffrlfe} '/FFR_low_' channel_to_plot '.mat']);
    end
elseif strcmp(ffr_version,'filtered') 
    if strcmp(FFR_low_FE{ffrlfe},'FFR_S01') || strcmp(FFR_low_FE{ffrlfe},'FFR_S02') || strcmp(FFR_low_FE{ffrlfe},'FFR_X74') || strcmp(FFR_low_FE{ffrlfe},'FFR_X10')
        load([root_dir '/Results/' FFR_low_FE{ffrlfe} '/FFR_low_pass_' channel_to_plot '.mat']);
    else
        load([root_dir '/Results/' FFR_low_FE{ffrlfe} '/FFR_low_' low_pass_FFR_low_string '_' channel_to_plot '.mat']);
    end
end
Average = Average*1e6; % Adjust scale
SR =  round(length(Average)/0.270); % Sampling rate
if SR ~= 16385; warning(['FFR sampling rate is odd for ' participant{p}]);end
time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
hold(h(2),'on');
plot(h(2),time_samples,Average);
if max(Average) > current_max; current_max = max(Average); end
if min(Average) < current_min; current_min = min(Average); end
end
hold(h(2),'on');
% Plot average here
if strcmp(ffr_version,'original') 
    load([root_dir '/Results/' gavr_to_overlay '/gavr/FFR_low_TD_FE_' channel_to_plot '.mat']);
elseif strcmp(ffr_version,'filtered') 
    load([root_dir '/Results/' gavr_to_overlay '/gavr/FFR_low_TD_filtered_FE_' channel_to_plot '.mat']);
end
F = F*1e6; % scale
plot(h(2),time_samples,F,'Color','k','LineWidth',2);
legend_string = strrep(FFR_low_FE,'_',' ');
hLeg = legend(h(2),legend_string);
set(hLeg,'visible','off')
xlim(h(2),[-40,230]);
if strcmp(ffr_version,'original') 
    current_title = 'FE 113Hz F0 (Original filter)';
elseif strcmp(ffr_version,'filtered') 
    current_title = ['FE 113Hz F0  (low_pass ' low_pass_FFR_low_string ')'];
end
current_title = strrep(current_title,'_',' ');
title(h(2),current_title)

% FFR MEDIUM time domain HC
for ffrmhc = 1:length(FFR_medium_HC)
if strcmp(ffr_version,'original')
    load([root_dir '/Results/' FFR_medium_HC{ffrmhc} '/FFR_medium_' channel_to_plot '.mat']);
elseif strcmp(ffr_version,'filtered')
    load([root_dir '/Results/' FFR_medium_HC{ffrmhc} '/FFR_medium_' low_pass_FFR_medium_string '_' channel_to_plot '.mat']);
end
Average = Average*1e6; % Adjust scale
SR =  round(length(Average)/0.270); % Sampling rate
if SR ~= 16385; warning(['FFR sampling rate is odd for ' participant{p}]);end
time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
hold(h(3),'on');
plot(h(3),time_samples,Average);
if max(Average) > current_max; current_max = max(Average); end
if min(Average) < current_min; current_min = min(Average); end
end
hold(h(3),'on');
% Plot average here
if strcmp(ffr_version,'original')
    load([root_dir '/Results/' gavr_to_overlay '/gavr/FFR_medium_TD_C_' channel_to_plot '.mat']);
elseif strcmp(ffr_version,'filtered')
    load([root_dir '/Results/' gavr_to_overlay '/gavr/FFR_medium_TD_filtered_C_' channel_to_plot '.mat']);
end
F = F*1e6; % scale
plot(h(3),time_samples,F,'Color','k','LineWidth',2);
legend_string = strrep(FFR_medium_HC,'_',' ');
hLeg = legend(h(3),legend_string);
set(hLeg,'visible','off')
xlim(h(3),[-40,230]);
if strcmp(ffr_version,'original')
    current_title = 'HC 266Hz F0 (Original filter)';
elseif strcmp(ffr_version,'filtered')
    current_title = ['HC 266Hz F0  (low_pass ' low_pass_FFR_medium_string ')'];
end
current_title = strrep(current_title,'_',' ');
title(h(3),current_title)

% FFR MEDIUM time domain FE
for ffrmfe = 1:length(FFR_medium_FE)
if strcmp(ffr_version,'original')
    load([root_dir '/Results/' FFR_medium_FE{ffrmfe} '/FFR_medium_' channel_to_plot '.mat']);
elseif strcmp(ffr_version,'filtered')
    load([root_dir '/Results/' FFR_medium_FE{ffrmfe} '/FFR_medium_' low_pass_FFR_medium_string '_' channel_to_plot '.mat']);
end
Average = Average*1e6; % Adjust scale
SR =  round(length(Average)/0.270); % Sampling rate
if SR ~= 16385; warning(['FFR sampling rate is odd for ' participant{p}]);end
time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
hold(h(4),'on');
plot(h(4),time_samples,Average);
if max(Average) > current_max; current_max = max(Average); end
if min(Average) < current_min; current_min = min(Average); end
end
hold(h(4),'on');
% Plot average here
if strcmp(ffr_version,'original')
    load([root_dir '/Results/' gavr_to_overlay '/gavr/FFR_medium_TD_FE_' channel_to_plot '.mat']);
elseif strcmp(ffr_version,'filtered')
    load([root_dir '/Results/' gavr_to_overlay '/gavr/FFR_medium_TD_filtered_FE_' channel_to_plot '.mat']);
end
F = F*1e6; % scale
plot(h(4),time_samples,F,'Color','k','LineWidth',2);
legend_string = strrep(FFR_medium_FE,'_',' ');
hLeg = legend(h(4),legend_string);
set(hLeg,'visible','off')
xlim(h(4),[-40,230]);
if strcmp(ffr_version,'original')
    current_title = 'FE 266Hz F0 (Original filter)';
elseif strcmp(ffr_version,'filtered')
    current_title = ['FE 266Hz F0  (low_pass ' low_pass_FFR_high_string ')'];
end
current_title = strrep(current_title,'_',' ');
title(h(4),current_title)

% FFR HIGH time domain HC
for ffrhhc = 1:length(FFR_high_HC)
if strcmp(ffr_version,'original')
    load([root_dir '/Results/' FFR_high_HC{ffrhhc} '/FFR_high_' channel_to_plot '.mat']);
elseif strcmp(ffr_version,'filtered')
    load([root_dir '/Results/' FFR_high_HC{ffrhhc} '/FFR_high_' low_pass_FFR_high_string '_' channel_to_plot '.mat']);
end
Average = Average*1e6; % Adjust scale
SR =  round(length(Average)/0.270); % Sampling rate
if SR ~= 16385; warning(['FFR sampling rate is odd for ' participant{p}]);end
time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
hold(h(5),'on');
plot(h(5),time_samples,Average);
if max(Average) > current_max; current_max = max(Average); end
if min(Average) < current_min; current_min = min(Average); end
end
hold(h(5),'on');
% Plot average here
if strcmp(ffr_version,'original')
    load([root_dir '/Results/' gavr_to_overlay '/gavr/FFR_high_TD_C_' channel_to_plot '.mat']);
elseif strcmp(ffr_version,'filtered')
    load([root_dir '/Results/' gavr_to_overlay '/gavr/FFR_high_TD_filtered_C_' channel_to_plot '.mat']);
end
F = F*1e6; % scale
plot(h(5),time_samples,F,'Color','k','LineWidth',2);
legend_string = strrep(FFR_high_HC,'_',' ');
hLeg = legend(h(5),legend_string);
set(hLeg,'visible','off')
xlim(h(5),[-40,230]);
if strcmp(ffr_version,'original')
    current_title = 'HC 317Hz F0 (Original filter)';
elseif strcmp(ffr_version,'filtered')
    current_title = ['HC 317Hz F0  (low_pass ' low_pass_FFR_high_string ')'];
end
current_title = strrep(current_title,'_',' ');
title(h(5),current_title)

% FFR HIGH time domain FE
for ffrhfe = 1:length(FFR_high_FE)
if strcmp(ffr_version,'original')
    load([root_dir '/Results/' FFR_high_FE{ffrhfe} '/FFR_high_' channel_to_plot '.mat']);
elseif strcmp(ffr_version,'filtered')
    load([root_dir '/Results/' FFR_high_FE{ffrhfe} '/FFR_high_' low_pass_FFR_high_string '_' channel_to_plot '.mat']);
end
Average = Average*1e6; % Adjust scale
SR =  round(length(Average)/0.270); % Sampling rate
if SR ~= 16385; warning(['FFR sampling rate is odd for ' participant{p}]);end
time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
hold(h(6),'on');
plot(h(6),time_samples,Average);
if max(Average) > current_max; current_max = max(Average); end
if min(Average) < current_min; current_min = min(Average); end
end
hold(h(6),'on');
% Plot average here
if strcmp(ffr_version,'original')
    load([root_dir '/Results/' gavr_to_overlay '/gavr/FFR_high_TD_FE_' channel_to_plot '.mat']);
elseif strcmp(ffr_version,'filtered')
    load([root_dir '/Results/' gavr_to_overlay '/gavr/FFR_high_TD_filtered_FE_' channel_to_plot '.mat']);
end
F = F*1e6; % scale
plot(h(6),time_samples,F,'Color','k','LineWidth',2);
legend_string = strrep(FFR_high_FE,'_',' ');
hLeg = legend(h(6),legend_string);
set(hLeg,'visible','off')
xlim(h(6),[-40,230]);
if strcmp(ffr_version,'original')
    current_title = 'FE 317Hz F0 (Original filter)';
elseif strcmp(ffr_version,'filtered')
    current_title = ['FE 317Hz F0  (low_pass ' low_pass_FFR_high_string ')'];
end
current_title = strrep(current_title,'_',' ');
title(h(6),current_title)

for i = 1:6
    hold(h(i),'on');
    ylim(h(i),[round(current_min,1),round(current_max,1)]);
    line(h(i),[0 0], [round(current_min,1),round(current_max,1)],'Color','black')
    line(h(i),[-40,230], [0,0], 'Color', 'k');
end
current_title = ['FFR (' channel_to_plot ') '];
current_title = strrep(current_title,'_',' ');
suptitle(current_title)

end

%%%%%%%%%%%%%%%%%%%%%%%%% AUTOCORRELOGRAM PLOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%
warning('Autocorrelogram butterfly not ready (probably not worth it)');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FFT PLOTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if plot_ffr_fft == 1
figure;
h(1) = subplot(2,4,1); h(2) = subplot(2,4,2); h(3) = subplot(2,4,3); h(4) = subplot(2,4,4); 
h(5) = subplot(2,4,5); h(6) = subplot(2,4,6); h(7) = subplot(2,4,7); h(8) = subplot(2,4,8);  

% FFR LOW FFT in each time section HC
for tw = 1:length(time_windows_FFR)
for par = 1:length(FFR_low_HC)
if strcmp(FFR_low_HC{par},'FFR_S01') || strcmp(FFR_low_HC{par},'FFR_S02') || strcmp(FFR_low_HC{par},'FFR_X74') || strcmp(FFR_low_HC{par},'FFR_X10')
    load([root_dir '/Results/' FFR_low_HC{par} '/FFT_' time_windows_FFR_labels{tw} '_' channel_to_plot '.mat']);
else
    load([root_dir '/Results/' FFR_low_HC{par} '/FFT_low_' time_windows_FFR_labels{tw} '_' channel_to_plot '.mat']);
end
amplitude = amplitude*1e6; % Adjust scale
amplitude = amplitude.^2; % Convert to power
if tw == 1 && par == 1 % first iteration
    current_max = max(amplitude(1,[1:500]));
else
    if max(amplitude(1,[1:500])) > current_max; current_max = max(amplitude(1,[1:500])); end
end
hold(h(tw),'on')
plot(h(tw),amplitude);
end
hold(h(tw),'on')
% Plot average here
load([root_dir '/Results/' gavr_to_overlay '/gavr/FFT_low_' time_windows_FFR_labels{tw} '_C_' channel_to_plot '.mat']);
F = F*1e6; % scale
F = F.^2; % Convert to power
plot(h(tw),F,'Color','k','LineWidth',2);
legend_string = strrep(FFR_low_HC,'_',' ');
hLeg = legend(h(tw),legend_string);
set(hLeg,'visible','off')
xlim(h(tw),[0,500]);
current_title = ['HC (' time_windows_FFR_labels{tw} ')'];
current_title = strrep(current_title,'_',' ');
title(h(tw),current_title)
end

% FFR LOW FFT in each time section FE
for tw = 1:length(time_windows_FFR)
for par = 1:length(FFR_low_FE)
if strcmp(FFR_low_FE{par},'FFR_S01') || strcmp(FFR_low_FE{par},'FFR_S02') || strcmp(FFR_low_FE{par},'FFR_X74') || strcmp(FFR_low_FE{par},'FFR_X10')
    load([root_dir '/Results/' FFR_low_FE{par} '/FFT_' time_windows_FFR_labels{tw} '_' channel_to_plot '.mat']);
else
    load([root_dir '/Results/' FFR_low_FE{par} '/FFT_low_' time_windows_FFR_labels{tw} '_' channel_to_plot '.mat']);
end
amplitude = amplitude*1e6; % Adjust scale
amplitude = amplitude.^2; % Convert to power
if max(amplitude(1,[1:500])) > current_max; current_max = max(amplitude(1,[1:500])); end
hold(h(tw+4),'on')
plot(h(tw+4),amplitude);
end
hold(h(tw+4),'on')
% Plot average here
load([root_dir '/Results/' gavr_to_overlay '/gavr/FFT_low_' time_windows_FFR_labels{tw} '_FE_' channel_to_plot '.mat']);
F = F*1e6; % scale
F = F.^2; % Convert to power
plot(h(tw+4),F,'Color','k','LineWidth',2);
legend_string = strrep(FFR_low_FE,'_',' ');
hLeg = legend(h(tw+4),legend_string);
set(hLeg,'visible','off')
xlim(h(tw+4),[0,500]);
current_title = ['FE (' time_windows_FFR_labels{tw} ')'];
current_title = strrep(current_title,'_',' ');
title(h(tw+4),current_title)
end
hold(h(5),'on')
xlabel(h(5),'Frequency (Hz)')
ylabel(h(5),'Power (uV2/Hz)')

for i = 1:8
    hold(h(i),'on')
    ylim(h(i),[0,current_max]);
    % plot(h(i),[113 113],[0 current_max],'r')
    if shaded_areas == 1
        hold (h(i),'on')
        gray = [0 0 0];
        patch(h(i),shaded_areas_FFR_FFT{1},[0*[1 1] current_max*[1 1]],gray,'FaceAlpha', transparency_shaded,'EdgeAlpha',0.1,'HandleVisibility','off')
    end
end

current_title = ['FFR 113Hz FFT (' channel_to_plot ') '];
current_title = strrep(current_title,'_',' ');
suptitle(current_title)

figure;
h(1) = subplot(2,4,1); h(2) = subplot(2,4,2); h(3) = subplot(2,4,3); h(4) = subplot(2,4,4); 
h(5) = subplot(2,4,5); h(6) = subplot(2,4,6); h(7) = subplot(2,4,7); h(8) = subplot(2,4,8); 

% FFR MEDIUM FFT in each time section HC
for tw = 1:length(time_windows_FFR)
for par = 1:length(FFR_medium_HC)
load([root_dir '/Results/' FFR_medium_HC{par} '/FFT_medium_' time_windows_FFR_labels{tw} '_' channel_to_plot '.mat']);
amplitude = amplitude*1e6; % Adjust scale
amplitude = amplitude.^2; % Convert to power
if tw == 1 && par == 1 % first iteration
    current_max = max(amplitude(1,[1:500]));
else
    if max(amplitude(1,[1:500])) > current_max; current_max = max(amplitude(1,[1:500])); end
end
hold(h(tw),'on')
plot(h(tw),amplitude);
end
hold(h(tw),'on')
% Plot average here
load([root_dir '/Results/' gavr_to_overlay '/gavr/FFT_medium_' time_windows_FFR_labels{tw} '_C_' channel_to_plot '.mat']);
F = F*1e6; % scale
F = F.^2; % Convert to power
plot(h(tw),F,'Color','k','LineWidth',2);
legend_string = strrep(FFR_medium_HC,'_',' ');
hLeg = legend(h(tw),legend_string);
set(hLeg,'visible','off')
xlim(h(tw),[0,500]);
current_title = ['HC (' time_windows_FFR_labels{tw} ')'];
current_title = strrep(current_title,'_',' ');
title(h(tw),current_title)
end

% FFR MEDIUM FFT in each time section FE
for tw = 1:length(time_windows_FFR)
for par = 1:length(FFR_medium_FE)
load([root_dir '/Results/' FFR_medium_FE{par} '/FFT_medium_' time_windows_FFR_labels{tw} '_' channel_to_plot '.mat']);
amplitude = amplitude*1e6; % Adjust scale
amplitude = amplitude.^2; % Convert to power
if max(amplitude(1,[1:500])) > current_max; current_max = max(amplitude(1,[1:500])); end
hold(h(tw+4),'on')
plot(h(tw+4),amplitude);
end
hold(h(tw+4),'on')
% Plot average here
load([root_dir '/Results/' gavr_to_overlay '/gavr/FFT_medium_' time_windows_FFR_labels{tw} '_FE_' channel_to_plot '.mat']);
F = F*1e6; % scale
F = F.^2; % Convert to power
plot(h(tw+4),F,'Color','k','LineWidth',2);
legend_string = strrep(FFR_medium_FE,'_',' ');
hLeg = legend(h(tw+4),legend_string);
set(hLeg,'visible','off')
xlim(h(tw+4),[0,500]);
current_title = ['FE (' time_windows_FFR_labels{tw} ')'];
current_title = strrep(current_title,'_',' ');
title(h(tw+4),current_title)
end
hold(h(5),'on')
xlabel(h(5),'Frequency (Hz)')
ylabel(h(5),'Power (uV2/Hz)')

for i = 1:8
    hold(h(i),'on')
    ylim(h(i),[0,current_max]);
    % plot(h(i),[266 266],[0 current_max],'r')
    if shaded_areas == 1
        hold (h(i),'on')
        gray = [0 0 0];
        patch(h(i),shaded_areas_FFR_FFT{2},[0*[1 1] current_max*[1 1]],gray,'FaceAlpha', transparency_shaded,'EdgeAlpha',0.1,'HandleVisibility','off')
    end
end

current_title = ['FFR 266Hz FFT (' channel_to_plot ') '];
current_title = strrep(current_title,'_',' ');
suptitle(current_title)

figure;
h(1) = subplot(2,4,1); h(2) = subplot(2,4,2); h(3) = subplot(2,4,3); h(4) = subplot(2,4,4); 
h(5) = subplot(2,4,5); h(6) = subplot(2,4,6); h(7) = subplot(2,4,7); h(8) = subplot(2,4,8); 

% FFR HIGH FFT in each time section HC
for tw = 1:length(time_windows_FFR)
for par = 1:length(FFR_high_HC)
load([root_dir '/Results/' FFR_high_HC{par} '/FFT_high_' time_windows_FFR_labels{tw} '_' channel_to_plot '.mat']);
amplitude = amplitude*1e6; % Adjust scale
amplitude = amplitude.^2; % Convert to power
if tw == 1 && par == 1 % first iteration
    current_max = max(amplitude(1,[1:500]));
else
    if max(amplitude(1,[1:500])) > current_max; current_max = max(amplitude(1,[1:500])); end
end
hold(h(tw),'on')
plot(h(tw),amplitude);
end
hold(h(tw),'on')
% Plot average here
load([root_dir '/Results/' gavr_to_overlay '/gavr/FFT_high_' time_windows_FFR_labels{tw} '_C_' channel_to_plot '.mat']);
F = F*1e6; % scale
F = F.^2; % Convert to power
plot(h(tw),F,'Color','k','LineWidth',2);
legend_string = strrep(FFR_high_HC,'_',' ');
hLeg = legend(h(tw),legend_string);
set(hLeg,'visible','off')
xlim(h(tw),[0,500]);
current_title = ['HC (' time_windows_FFR_labels{tw} ')'];
current_title = strrep(current_title,'_',' ');
title(h(tw),current_title)
end

% FFR HIGH FFT in each time section FE
for tw = 1:length(time_windows_FFR)
for par = 1:length(FFR_high_FE)
load([root_dir '/Results/' FFR_high_FE{par} '/FFT_high_' time_windows_FFR_labels{tw} '_' channel_to_plot '.mat']);
amplitude = amplitude*1e6; % Adjust scale
amplitude = amplitude.^2; % Convert to power
if max(amplitude(1,[1:500])) > current_max; current_max = max(amplitude(1,[1:500])); end
hold(h(tw+4),'on')
plot(h(tw+4),amplitude);
end
hold(h(tw+4),'on')
% Plot average here
load([root_dir '/Results/' gavr_to_overlay '/gavr/FFT_high_' time_windows_FFR_labels{tw} '_FE_' channel_to_plot '.mat']);
F = F*1e6; % scale
F = F.^2; % Convert to power
plot(h(tw+4),F,'Color','k','LineWidth',2);
legend_string = strrep(FFR_high_FE,'_',' ');
hLeg = legend(h(tw+4),legend_string);
set(hLeg,'visible','off')
xlim(h(tw+4),[0,500]);
current_title = ['FE (' time_windows_FFR_labels{tw} ')'];
current_title = strrep(current_title,'_',' ');
title(h(tw+4),current_title)
end
hold(h(5),'on')
xlabel(h(5),'Frequency (Hz)')
ylabel(h(5),'Power (uV2/Hz)')

for i = 1:8
    hold(h(i),'on')
    ylim(h(i),[0,current_max]);
    % plot(h(i),[317 317],[0 current_max],'r')
    if shaded_areas == 1
        hold (h(i),'on')
        gray = [0 0 0];
        patch(h(i),shaded_areas_FFR_FFT{3},[0*[1 1] current_max*[1 1]],gray,'FaceAlpha', transparency_shaded,'EdgeAlpha',0.1,'HandleVisibility','off')
    end
end

current_title = ['FFR 317Hz FFT (' channel_to_plot ') '];
current_title = strrep(current_title,'_',' ');
suptitle(current_title)

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TIME FREQUENCY PLOT %%%%%%%%%%%%%%%%%%%%%%%%
warning('Time-frequency butterfly not ready (probably not worth it)');

%% GAVR plots (Time Domain and Freq domain)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MODIFY THIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define which channel to use (or cluster)
channel_to_plot = 'Cz'; % 'cluster', 'Cz'
gavr_to_overlay = 'GAVR_12C_vs_14FE'; % Folder from GAVR that will be on top of plot
% GAVR_12C_vs_10FE
dev_GAVR = 2; % 1 = standard deviation; 2 = standard error
color_group = {[255 0 0],[0 0 0]}; % FE C FOR NOW
transparency = 0.2; % For STDEV/STDERR
shaded_areas = 0; % Overlay of FFR sections, spec and TD peaks, etc
transparency_shaded = 0.1; % For shaded areas
ffr_version = 'original'; % 'original' or 'filtered' choose only one

% Decide what to plot
plot_llr = 1; % 0: NO 1: YES
plot_ffr_td = 1; % 0: NO 1: YES
plot_ac = 1; % 0: NO 1: YES
plot_ffr_fft = 1; % 0: NO 1: YES

%%%%%%%%%%%%%%%%%%%%%%%%% START PLOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(0,'defaultfigurecolor',[1 1 1]); % I want white backgrounds
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LLR PLOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if plot_llr == 1
figure;
h(1) = subplot(1,2,1); h(2) = subplot(1,2,2);

for pg = 1:length(participant_group)
% LLR HC 400ms ISI
load([root_dir '/Results/' gavr_to_overlay '/gavr/LLR_400ms_' participant_group{pg} '_' channel_to_plot '.mat']);
Average = F*1e6; % scale
if pg == 1
    current_max = max(Average);
    current_min = min(Average);
else
    if max(Average) > current_max; current_max = max(Average); end
    if min(Average) < current_min; current_min = min(Average); end
end
s_r = round((length(Average)/500)*1000);
time_samples=linspace(-100,400,((((-100*(-1)) + 400)/1000)*s_r));
% Load stdev or stderr
if dev_GAVR == 1 % standard deviation
    load([root_dir '/Results/' gavr_to_overlay '/std_dev/LLR_400ms_' participant_group{pg} '_' channel_to_plot '.mat']);
    F = F*1e6; % scale
    dev = F;
elseif dev_GAVR == 2 % standard error
    load([root_dir '/Results/' gavr_to_overlay '/std_err/LLR_400ms_' participant_group{pg} '_' channel_to_plot '.mat']);
    F = F*1e6; % scale
    dev = F;
end  
% Set data ready for plot
curve1 = Average + dev;
curve2 = Average - dev;
time_samples_2 = [time_samples, fliplr(time_samples)];
inBetween = [curve1, fliplr(curve2)];   
% Now plot
hold (h(1),'on')
fill(h(1),time_samples_2, inBetween, (color_group{pg}/256), 'FaceAlpha', transparency, 'LineStyle', 'none','HandleVisibility','off');
plot(h(1),time_samples, Average, 'color', (color_group{pg}/256), 'LineWidth', 1.5);
if pg == 2
    hLeg = legend(h(1),participant_group);
else
end
xlim(h(1),[-100,400]);
ylabel(h(1),'Amplitude (µV)')
xlabel(h(1),'Time (ms)');
current_title = '400ms ISI';
current_title = strrep(current_title,'_',' ');
title(h(1),current_title)

% LLR HC 1s ISI
load([root_dir '/Results/' gavr_to_overlay '/gavr/LLR_1s_' participant_group{pg} '_' channel_to_plot '.mat']);
Average = F*1e6; % scale
if max(Average) > current_max; current_max = max(Average); end
if min(Average) < current_min; current_min = min(Average); end
s_r = round((length(Average)/500)*1000);
time_samples=linspace(-100,400,((((-100*(-1)) + 400)/1000)*s_r));
% Load stdev or stderr
if dev_GAVR == 1 % standard deviation
    load([root_dir '/Results/' gavr_to_overlay '/std_dev/LLR_1s_' participant_group{pg} '_' channel_to_plot '.mat']);
    F = F*1e6; % scale
    dev = F;
elseif dev_GAVR == 2 % standard error
    load([root_dir '/Results/' gavr_to_overlay '/std_err/LLR_1s_' participant_group{pg} '_' channel_to_plot '.mat']);
    F = F*1e6; % scale
    dev = F;
end  
% Set data ready for plot
curve1 = Average + dev;
curve2 = Average - dev;
time_samples_2 = [time_samples, fliplr(time_samples)];
inBetween = [curve1, fliplr(curve2)];   
% Now plot
hold (h(2),'on')
fill(h(2),time_samples_2, inBetween, (color_group{pg}/256), 'FaceAlpha', transparency, 'LineStyle', 'none','HandleVisibility','off');
plot(h(2),time_samples, Average, 'color', (color_group{pg}/256), 'LineWidth', 1.5);
xlim(h(2),[-100,400]);
current_title = '1s ISI';
current_title = strrep(current_title,'_',' ');
title(h(2),current_title)

end

for i = 1:2
    hold(h(i),'on');
    ylim(h(i),[floor(current_min)*1.2,ceil(current_max)*1.2]);
    line(h(i),[0 0], [floor(current_min)*1.2,ceil(current_max)*1.2],'Color','black','HandleVisibility','off')
    line(h(i),xlim(), [0,0], 'Color', 'k','HandleVisibility','off');
    if shaded_areas == 1
        hold (h(i),'on')
        for shad = 1:length(shaded_areas_LLR)
            gray = [0 0 0];
            patch(h(i),shaded_areas_LLR{shad},[min(ylim)*[1 1] max(ylim)*[1 1]],gray,'FaceAlpha', transparency_shaded,'EdgeAlpha',0.1,'HandleVisibility','off')
        end
    end
end
current_title = ['Pure_Tone (' channel_to_plot ') ' gavr_to_overlay];
current_title = strrep(current_title,'_',' ');
suptitle(current_title)
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FFR TIME DOMAIN PLOT %%%%%%%%%%%%%%%%%%%%%
if plot_ffr_td == 1

figure;
h(1) = subplot(3,1,1); h(2) = subplot(3,1,2); h(3) = subplot(3,1,3);

for pg = 1:length(participant_group)
% FFR LOW (original or low pass filtered)
if strcmp(ffr_version,'original')
    load([root_dir '/Results/' gavr_to_overlay '/gavr/FFR_low_TD_' participant_group{pg} '_' channel_to_plot '.mat']);
elseif strcmp(ffr_version,'filtered')
    load([root_dir '/Results/' gavr_to_overlay '/gavr/FFR_low_TD_filtered_' participant_group{pg} '_' channel_to_plot '.mat']);
end
Average = F*1e6; % scale
if pg == 1
    current_max = max(Average);
    current_min = min(Average);
else
    if max(Average) > current_max; current_max = max(Average); end
    if min(Average) < current_min; current_min = min(Average); end
end
SR =  round(length(Average)/0.270); % Sampling rate
if SR ~= 16385; warning(['FFR sampling rate is odd for ' participant{p}]);end
time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
% Load stdev or stderr
if dev_GAVR == 1 % standard deviation
    if strcmp(ffr_version,'original')
        load([root_dir '/Results/' gavr_to_overlay '/std_dev/FFR_low_TD_' participant_group{pg} '_' channel_to_plot '.mat']);
    elseif strcmp(ffr_version,'filtered')
        load([root_dir '/Results/' gavr_to_overlay '/std_dev/FFR_low_TD_filtered_' participant_group{pg} '_' channel_to_plot '.mat']);
    end
    F = F*1e6; % scale
    dev = F;
elseif dev_GAVR == 2 % standard error
    if strcmp(ffr_version,'original')
        load([root_dir '/Results/' gavr_to_overlay '/std_err/FFR_low_TD_' participant_group{pg} '_' channel_to_plot '.mat']);
    elseif strcmp(ffr_version,'filtered')
        load([root_dir '/Results/' gavr_to_overlay '/std_err/FFR_low_TD_filtered_' participant_group{pg} '_' channel_to_plot '.mat']);
    end
    F = F*1e6; % scale
    dev = F;
end  
% Set data ready for plot
curve1 = Average + dev;
curve2 = Average - dev;
time_samples_2 = [time_samples, fliplr(time_samples)];
inBetween = [curve1, fliplr(curve2)];   
% Now plot
hold (h(1),'on')
fill(h(1),time_samples_2, inBetween, (color_group{pg}/256), 'FaceAlpha', transparency, 'LineStyle', 'none','HandleVisibility','off');
plot(h(1),time_samples, Average, 'color', (color_group{pg}/256), 'LineWidth', 1.5);
if pg == 2
    hLeg = legend(h(1),participant_group);
else
end
xlim(h(1),[-40,230]);
% ylabel(h(1),'Amplitude (µV)')
% xlabel(h(1),'Time (ms)');
if strcmp(ffr_version,'original')
    current_title = '113Hz F0 Original filter';
elseif strcmp(ffr_version,'filtered')
    current_title = ['113Hz F0 ' low_pass_FFR_low_string ' low-pass'];
end
current_title = strrep(current_title,'_',' ');
title(h(1),current_title)

% FFR MEDIUM (original filter or low-pass filtered)
if strcmp(ffr_version,'original')
    load([root_dir '/Results/' gavr_to_overlay '/gavr/FFR_medium_TD_' participant_group{pg} '_' channel_to_plot '.mat']);
elseif strcmp(ffr_version,'filtered')
    load([root_dir '/Results/' gavr_to_overlay '/gavr/FFR_medium_TD_filtered_' participant_group{pg} '_' channel_to_plot '.mat']);
end
Average = F*1e6; % scale
if max(Average) > current_max; current_max = max(Average); end
if min(Average) < current_min; current_min = min(Average); end
SR =  round(length(Average)/0.270); % Sampling rate
if SR ~= 16385; warning(['FFR sampling rate is odd for ' participant{p}]);end
time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
% Load stdev or stderr
if dev_GAVR == 1 % standard deviation
    if strcmp(ffr_version,'original')
        load([root_dir '/Results/' gavr_to_overlay '/std_dev/FFR_medium_TD_' participant_group{pg} '_' channel_to_plot '.mat']);
    elseif strcmp(ffr_version,'filtered')
        load([root_dir '/Results/' gavr_to_overlay '/std_dev/FFR_medium_TD_filtered_' participant_group{pg} '_' channel_to_plot '.mat']);
    end
    F = F*1e6; % scale
    dev = F;
elseif dev_GAVR == 2 % standard error
    if strcmp(ffr_version,'original')
        load([root_dir '/Results/' gavr_to_overlay '/std_err/FFR_medium_TD_' participant_group{pg} '_' channel_to_plot '.mat']);
    elseif strcmp(ffr_version,'filtered')
        load([root_dir '/Results/' gavr_to_overlay '/std_err/FFR_medium_TD_filtered_' participant_group{pg} '_' channel_to_plot '.mat']);
    end
    F = F*1e6; % scale
    dev = F;
end  
% Set data ready for plot
curve1 = Average + dev;
curve2 = Average - dev;
time_samples_2 = [time_samples, fliplr(time_samples)];
inBetween = [curve1, fliplr(curve2)];   
% Now plot
hold (h(2),'on')
fill(h(2),time_samples_2, inBetween, (color_group{pg}/256), 'FaceAlpha', transparency, 'LineStyle', 'none','HandleVisibility','off');
plot(h(2),time_samples, Average, 'color', (color_group{pg}/256), 'LineWidth', 1.5);
xlim(h(2),[-40,230]);
if strcmp(ffr_version,'original')
   current_title = '266Hz F0 Original filter';    
elseif strcmp(ffr_version,'filtered')
   current_title = ['266Hz F0 ' low_pass_FFR_medium_string ' low-pass'];
end
current_title = strrep(current_title,'_',' ');
title(h(2),current_title)

% FFR HIGH (original filter or low-pass filtered)
if strcmp(ffr_version,'original')
    load([root_dir '/Results/' gavr_to_overlay '/gavr/FFR_high_TD_' participant_group{pg} '_' channel_to_plot '.mat']);
elseif strcmp(ffr_version,'filtered')
    load([root_dir '/Results/' gavr_to_overlay '/gavr/FFR_high_TD_filtered_' participant_group{pg} '_' channel_to_plot '.mat']);
end
Average = F*1e6; % scale
if max(Average) > current_max; current_max = max(Average); end
if min(Average) < current_min; current_min = min(Average); end
SR =  round(length(Average)/0.270); % Sampling rate
if SR ~= 16385; warning(['FFR sampling rate is odd for ' participant{p}]);end
time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
% Load stdev or stderr
if dev_GAVR == 1 % standard deviation
    if strcmp(ffr_version,'original')
        load([root_dir '/Results/' gavr_to_overlay '/std_dev/FFR_high_TD_' participant_group{pg} '_' channel_to_plot '.mat']);
    elseif strcmp(ffr_version,'filtered')
        load([root_dir '/Results/' gavr_to_overlay '/std_dev/FFR_high_TD_filtered_' participant_group{pg} '_' channel_to_plot '.mat']);
    end
    F = F*1e6; % scale
    dev = F;
elseif dev_GAVR == 2 % standard error
    if strcmp(ffr_version,'original')
        load([root_dir '/Results/' gavr_to_overlay '/std_err/FFR_high_TD_' participant_group{pg} '_' channel_to_plot '.mat']);
    elseif strcmp(ffr_version,'filtered')
        load([root_dir '/Results/' gavr_to_overlay '/std_err/FFR_high_TD_filtered_' participant_group{pg} '_' channel_to_plot '.mat']);
    end
    F = F*1e6; % scale
    dev = F;
end  
% Set data ready for plot
curve1 = Average + dev;
curve2 = Average - dev;
time_samples_2 = [time_samples, fliplr(time_samples)];
inBetween = [curve1, fliplr(curve2)];   
% Now plot
hold (h(3),'on')
fill(h(3),time_samples_2, inBetween, (color_group{pg}/256), 'FaceAlpha', transparency, 'LineStyle', 'none','HandleVisibility','off');
plot(h(3),time_samples, Average, 'color', (color_group{pg}/256), 'LineWidth', 1.5);
xlim(h(3),[-40,230]);
ylabel(h(3),'Amplitude (µV)')
xlabel(h(3),'Time (ms)');
if strcmp(ffr_version,'original')
   current_title = '317Hz F0 Original filter';    
elseif strcmp(ffr_version,'filtered')
   current_title = ['317Hz F0 ' low_pass_FFR_high_string ' low-pass'];
end
current_title = strrep(current_title,'_',' ');
title(h(3),current_title)

end

for i = 1:3
    hold(h(i),'on');
    ylim(h(i),[round(current_min,1)*1.5,round(current_max,1)*1.5]);
    line(h(i),[0 0], [round(current_min,1),round(current_max,1)],'Color','black','HandleVisibility','off')
    line(h(i),[-40,230], [0,0], 'Color', 'k','HandleVisibility','off');
    if shaded_areas == 1
        hold (h(i),'on')
        for shad = 1:length(shaded_areas_FFR_TD)
            gray = [0 0 0];
            patch(h(i),shaded_areas_FFR_TD{shad},[min(ylim)*[1 1] max(ylim)*[1 1]],gray,'FaceAlpha', transparency_shaded,'EdgeAlpha',0.1,'HandleVisibility','off')
        end
    end
end
current_title = ['FFR (' channel_to_plot ') ' gavr_to_overlay];
current_title = strrep(current_title,'_',' ');
suptitle(current_title)
    
end

%%%%%%%%%%%%%%%%%%%%%%%%% AUTOCORRELOGRAM PLOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%
if plot_ac == 1

figure;
h(1) = subplot(3,2,1); h(2) = subplot(3,2,2);
h(3) = subplot(3,2,3); h(4) = subplot(3,2,4);
h(5) = subplot(3,2,5); h(6) = subplot(3,2,6);
    
% Autocorrelogram FFR LOW HC
if strcmp(ffr_version,'original')
    load([root_dir '/Results/' gavr_to_overlay '/gavr/FFR_low_TD_C_' channel_to_plot '.mat']);
elseif strcmp(ffr_version,'filtered')
    load([root_dir '/Results/' gavr_to_overlay '/gavr/FFR_low_TD_filtered_C_' channel_to_plot '.mat']);
end
Average = F*1e6; % Adjust scale
SR =  round(length(Average)/0.270); % Sampling rate
time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
samples_per_ms = round(SR/1000);
[acf] = autocorr(Average,length(Average)-1);
autocorr_axis = linspace(0,round(length(time_samples)/samples_per_ms)-1,length(time_samples));
lineHandles = stem(h(1),autocorr_axis,acf,'filled','r-o');
set(lineHandles(1),'MarkerSize',4)
grid(h(1),'on')
hold(h(1),'on')
plot(h(1),[8.84 8.84],[0 1],'k')
xlim(h(1),[0,20]);
if strcmp(ffr_version,'original')
    current_title = 'C 113 Hz Original filter';
elseif strcmp(ffr_version,'filtered')
    current_title = ['C 113 Hz (' low_pass_FFR_low_string ' low pass)'];
end
current_title = strrep(current_title,'_',' ');
title(h(1),current_title)

% Autocorrelogram FFR MEDIUM HC
if strcmp(ffr_version,'original')
    load([root_dir '/Results/' gavr_to_overlay '/gavr/FFR_medium_TD_C_' channel_to_plot '.mat']);
elseif strcmp(ffr_version,'filtered')
    load([root_dir '/Results/' gavr_to_overlay '/gavr/FFR_medium_TD_filtered_C_' channel_to_plot '.mat']);
end
Average = F*1e6; % Adjust scale
SR =  round(length(Average)/0.270); % Sampling rate
time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
samples_per_ms = round(SR/1000);
[acf] = autocorr(Average,length(Average)-1);
autocorr_axis = linspace(0,round(length(time_samples)/samples_per_ms)-1,length(time_samples));
lineHandles = stem(h(3),autocorr_axis,acf,'filled','r-o');
set(lineHandles(1),'MarkerSize',4)
grid(h(3),'on')
hold(h(3),'on')
plot(h(3),[3.75 3.75],[0 1],'k')
xlim(h(3),[0,20]);
if strcmp(ffr_version,'original')
    current_title = 'C 266 Hz Original filter';
elseif strcmp(ffr_version,'filtered')
    current_title = ['C 266 Hz (' low_pass_FFR_medium_string ' low pass)'];
end
current_title = strrep(current_title,'_',' ');
title(h(3),current_title)

% Autocorrelogram FFR HIGH HC
if strcmp(ffr_version,'original')
    load([root_dir '/Results/' gavr_to_overlay '/gavr/FFR_high_TD_C_' channel_to_plot '.mat']);
elseif strcmp(ffr_version,'filtered')
    load([root_dir '/Results/' gavr_to_overlay '/gavr/FFR_high_TD_filtered_C_' channel_to_plot '.mat']);
end
Average = F*1e6; % Adjust scale
SR =  round(length(Average)/0.270); % Sampling rate
time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
samples_per_ms = round(SR/1000);
[acf] = autocorr(Average,length(Average)-1);
autocorr_axis = linspace(0,round(length(time_samples)/samples_per_ms)-1,length(time_samples));
lineHandles = stem(h(5),autocorr_axis,acf,'filled','r-o');
set(lineHandles(1),'MarkerSize',4)
grid(h(5),'on')
hold(h(5),'on')
plot(h(5),[3.15 3.15],[0 1],'k')
xlim(h(5),[0,20]);
if strcmp(ffr_version,'original')
    current_title = 'C 317 Hz Original filter';
elseif strcmp(ffr_version,'filtered')
    current_title = ['C 317 Hz (' low_pass_FFR_high_string ' low pass)'];
end
current_title = strrep(current_title,'_',' ');
title(h(5),current_title)

% Autocorrelogram FFR LOW FE
if strcmp(ffr_version,'original')
    load([root_dir '/Results/' gavr_to_overlay '/gavr/FFR_low_TD_FE_' channel_to_plot '.mat']);
elseif strcmp(ffr_version,'filtered')
    load([root_dir '/Results/' gavr_to_overlay '/gavr/FFR_low_TD_filtered_FE_' channel_to_plot '.mat']);
end
Average = F*1e6; % Adjust scale
SR =  round(length(Average)/0.270); % Sampling rate
time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
samples_per_ms = round(SR/1000);
[acf] = autocorr(Average,length(Average)-1);
autocorr_axis = linspace(0,round(length(time_samples)/samples_per_ms)-1,length(time_samples));
lineHandles = stem(h(1+1),autocorr_axis,acf,'filled','r-o');
set(lineHandles(1),'MarkerSize',4)
grid(h(1+1),'on')
hold(h(1+1),'on')
plot(h(1+1),[8.84 8.84],[0 1],'k')
xlim(h(1+1),[0,20]);
if strcmp(ffr_version,'original')
    current_title = 'FE 113 Hz Original filter';
elseif strcmp(ffr_version,'filtered')
    current_title = ['FE 113 Hz (' low_pass_FFR_low_string ' low pass)'];
end
current_title = strrep(current_title,'_',' ');
title(h(1+1),current_title)

% Autocorrelogram FFR MEDIUM FE
if strcmp(ffr_version,'original')
    load([root_dir '/Results/' gavr_to_overlay '/gavr/FFR_medium_TD_FE_' channel_to_plot '.mat']);
elseif strcmp(ffr_version,'filtered')
    load([root_dir '/Results/' gavr_to_overlay '/gavr/FFR_medium_TD_filtered_FE_' channel_to_plot '.mat']);
end
Average = F*1e6; % Adjust scale
SR =  round(length(Average)/0.270); % Sampling rate
time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
samples_per_ms = round(SR/1000);
[acf] = autocorr(Average,length(Average)-1);
autocorr_axis = linspace(0,round(length(time_samples)/samples_per_ms)-1,length(time_samples));
lineHandles = stem(h(3+1),autocorr_axis,acf,'filled','r-o');
set(lineHandles(1),'MarkerSize',4)
grid(h(3+1),'on')
hold(h(3+1),'on')
plot(h(3+1),[3.75 3.75],[0 1],'k')
xlim(h(3+1),[0,20]);
if strcmp(ffr_version,'original')
    current_title = 'FE 266 Hz Original filter';
elseif strcmp(ffr_version,'filtered')
    current_title = ['FE 266 Hz (' low_pass_FFR_medium_string ' low pass)'];
end
current_title = strrep(current_title,'_',' ');
title(h(3+1),current_title)

% Autocorrelogram FFR HIGH default frequency FE
if strcmp(ffr_version,'original')
    load([root_dir '/Results/' gavr_to_overlay '/gavr/FFR_high_TD_FE_' channel_to_plot '.mat']);
elseif strcmp(ffr_version,'filtered')
    load([root_dir '/Results/' gavr_to_overlay '/gavr/FFR_high_TD_filtered_FE_' channel_to_plot '.mat']);
end
Average = F*1e6; % Adjust scale
SR =  round(length(Average)/0.270); % Sampling rate
time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
samples_per_ms = round(SR/1000);
[acf] = autocorr(Average,length(Average)-1);
autocorr_axis = linspace(0,round(length(time_samples)/samples_per_ms)-1,length(time_samples));
lineHandles = stem(h(5+1),autocorr_axis,acf,'filled','r-o');
set(lineHandles(1),'MarkerSize',4)
grid(h(5+1),'on')
hold(h(5+1),'on')
plot(h(5+1),[3.15 3.15],[0 1],'k')
xlim(h(5+1),[0,20]);
if strcmp(ffr_version,'original')
    current_title = 'FE 317 Hz Original filter';
elseif strcmp(ffr_version,'filtered')
    current_title = ['FE 317 Hz (' low_pass_FFR_high_string ' low pass)'];
end
current_title = strrep(current_title,'_',' ');
title(h(5+1),current_title)

hold(h(5),'on')
ylabel(h(5),'Sample Autocorrelation') 
xlabel(h(5),'Lag')

current_title = ['Autocorrelogram (' channel_to_plot ') ' gavr_to_overlay];
current_title = strrep(current_title,'_',' ');
suptitle(current_title)

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FFT PLOTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if plot_ffr_fft == 1
figure;
h(1) = subplot(3,4,1); h(2) = subplot(3,4,2); h(3) = subplot(3,4,3); h(4) = subplot(3,4,4); 
h(5) = subplot(3,4,5); h(6) = subplot(3,4,6); h(7) = subplot(3,4,7); h(8) = subplot(3,4,8); 
h(9) = subplot(3,4,9); h(10) = subplot(3,4,10); h(11) = subplot(3,4,11); h(12) = subplot(3,4,12); 

% FFR LOW FFT in each time section
for tw = 1:length(time_windows_FFR)
for pg = 1:length(participant_group)
hold(h(tw),'on')
% Plot average here
load([root_dir '/Results/' gavr_to_overlay '/gavr/FFT_low_' time_windows_FFR_labels{tw} '_' participant_group{pg} '_' channel_to_plot '.mat']);
Average = F*1e6; % scale
Average = Average.^2; % Convert to power
time_samples = [1:8193]; % Technically I have this many frequencies?
if dev_GAVR == 1 % standard deviation
    load([root_dir '/Results/' gavr_to_overlay '/std_dev/FFT_low_' time_windows_FFR_labels{tw} '_' participant_group{pg} '_' channel_to_plot '.mat']);
    F = F*1e6; % scale
    F = F.^2; % Convert to power
    dev = F;
elseif dev_GAVR == 2 % standard error
    load([root_dir '/Results/' gavr_to_overlay '/std_err/FFT_low_' time_windows_FFR_labels{tw} '_' participant_group{pg} '_' channel_to_plot '.mat']);
    F = F*1e6; % scale
    F = F.^2; % Convert to power
    dev = F;
end  
% Set data ready for plot
curve1 = Average + dev;
curve2 = Average - dev;
if pg == 1 && tw == 1
    current_max_low = max(curve1(1,[1:500]));
else
    if max(curve1(1,[1:500])) > current_max_low; current_max_low = max(curve1(1,[1:500])); end
end
time_samples_2 = [time_samples, fliplr(time_samples)];
inBetween = [curve1, fliplr(curve2)];   
% Now plot
hold (h(tw),'on')
fill(h(tw),time_samples_2, inBetween, (color_group{pg}/256), 'FaceAlpha', transparency, 'LineStyle', 'none','HandleVisibility','off');
plot(h(tw),time_samples, Average, 'color', (color_group{pg}/256), 'LineWidth', 1.5);
if pg == 2 && tw == 1
    legend(h(tw),participant_group);
end
xlim(h(tw),[0,500]);
current_title = ['113Hz F0 ' time_windows_FFR_labels{tw}];
current_title = strrep(current_title,'_',' ');
title(h(tw),current_title)
end
end

% FFR MEDIUM FFT in each time section
for tw = 1:length(time_windows_FFR)
for pg = 1:length(participant_group)
hold(h(tw+4),'on')
% Plot average here
load([root_dir '/Results/' gavr_to_overlay '/gavr/FFT_medium_' time_windows_FFR_labels{tw} '_' participant_group{pg} '_' channel_to_plot '.mat']);
Average = F*1e6; % scale
Average = Average.^2; % Convert to power
time_samples = [1:8193]; % Technically I have this many frequencies?
if dev_GAVR == 1 % standard deviation
    load([root_dir '/Results/' gavr_to_overlay '/std_dev/FFT_medium_' time_windows_FFR_labels{tw} '_' participant_group{pg} '_' channel_to_plot '.mat']);
    F = F*1e6; % scale
    F = F.^2; % Convert to power
    dev = F;
elseif dev_GAVR == 2 % standard error
    load([root_dir '/Results/' gavr_to_overlay '/std_err/FFT_medium_' time_windows_FFR_labels{tw} '_' participant_group{pg} '_' channel_to_plot '.mat']);
    F = F*1e6; % scale
    F = F.^2; % Convert to power
    dev = F;
end
% Set data ready for plot
curve1 = Average + dev;
curve2 = Average - dev;
if pg == 1 && tw == 1
    current_max_medium = max(curve1(1,[1:500]));
else
    if max(curve1(1,[1:500])) > current_max_medium; current_max_medium = max(curve1(1,[1:500])); end
end
time_samples_2 = [time_samples, fliplr(time_samples)];
inBetween = [curve1, fliplr(curve2)];
% Now plot
hold (h(tw+4),'on')
fill(h(tw+4),time_samples_2, inBetween, (color_group{pg}/256), 'FaceAlpha', transparency, 'LineStyle', 'none','HandleVisibility','off');
plot(h(tw+4),time_samples, Average, 'color', (color_group{pg}/256), 'LineWidth', 1.5);
xlim(h(tw+4),[0,500]);
current_title = ['266Hz F0 ' time_windows_FFR_labels{tw}];
current_title = strrep(current_title,'_',' ');
title(h(tw+4),current_title)
end
end

% FFR HIGH FFT in each time section
for tw = 1:length(time_windows_FFR)
for pg = 1:length(participant_group)
hold(h(tw+8),'on')
% Plot average here
load([root_dir '/Results/' gavr_to_overlay '/gavr/FFT_high_' time_windows_FFR_labels{tw} '_' participant_group{pg} '_' channel_to_plot '.mat']);
Average = F*1e6; % scale
Average = Average.^2; % Convert to power
time_samples = [1:8193]; % Technically I have this many frequencies?
if dev_GAVR == 1 % standard deviation
    load([root_dir '/Results/' gavr_to_overlay '/std_dev/FFT_high_' time_windows_FFR_labels{tw} '_' participant_group{pg} '_' channel_to_plot '.mat']);
    F = F*1e6; % scale
    F = F.^2; % Convert to power
    dev = F;
elseif dev_GAVR == 2 % standard error
    load([root_dir '/Results/' gavr_to_overlay '/std_err/FFT_high_' time_windows_FFR_labels{tw} '_' participant_group{pg} '_' channel_to_plot '.mat']);
    F = F*1e6; % scale
    F = F.^2; % Convert to power
    dev = F;
end
% Set data ready for plot
curve1 = Average + dev;
curve2 = Average - dev;
if pg == 1 && tw == 1
    current_max_high = max(curve1(1,[1:500]));
else
    if max(curve1(1,[1:500])) > current_max_high; current_max_high = max(curve1(1,[1:500])); end
end
time_samples_2 = [time_samples, fliplr(time_samples)];
inBetween = [curve1, fliplr(curve2)];
% Now plot
hold (h(tw+8),'on')
fill(h(tw+8),time_samples_2, inBetween, (color_group{pg}/256), 'FaceAlpha', transparency, 'LineStyle', 'none','HandleVisibility','off');
plot(h(tw+8),time_samples, Average, 'color', (color_group{pg}/256), 'LineWidth', 1.5);
xlim(h(tw+8),[0,500]);
current_title = ['317Hz F0 ' time_windows_FFR_labels{tw}];
current_title = strrep(current_title,'_',' ');
title(h(tw+8),current_title)
end
end

hold(h(9),'on')
xlabel(h(9),'Frequency (Hz)')
ylabel(h(9),'Power (uV2/Hz)')

for i = 1:4
    % plot(h(i),[113 113],[0 current_max],'r','HandleVisibility','off','linestyle','--')
    if shaded_areas == 1
        hold (h(i),'on')
        gray = [0 0 0];
        patch(h(i),shaded_areas_FFR_FFT{1},[0*[1 1] current_max_low*[1 1]],gray,'FaceAlpha', transparency_shaded,'EdgeAlpha',0.1,'HandleVisibility','off')
    end
    hold(h(i),'on')
    ylim(h(i),[0,current_max_low]);
end

for i = 5:8
    % plot(h(i),[317 317],[0 current_max],'r','HandleVisibility','off','linestyle','--')
    if shaded_areas == 1
        hold (h(i),'on')
        gray = [0 0 0];
        patch(h(i),shaded_areas_FFR_FFT{2},[0*[1 1] current_max_medium*[1 1]],gray,'FaceAlpha', transparency_shaded,'EdgeAlpha',0.1,'HandleVisibility','off')
    end
    hold(h(i),'on')
    ylim(h(i),[0,current_max_medium]);
end

for i = 9:12
    % plot(h(i),[317 317],[0 current_max],'r','HandleVisibility','off','linestyle','--')
    if shaded_areas == 1
        hold (h(i),'on')
        gray = [0 0 0];
        patch(h(i),shaded_areas_FFR_FFT{3},[0*[1 1] current_max_high*[1 1]],gray,'FaceAlpha', transparency_shaded,'EdgeAlpha',0.1,'HandleVisibility','off')
    end
    hold(h(i),'on')
    ylim(h(i),[0,current_max_high]);
end

current_title = ['FFR FFT (' channel_to_plot ') '];
current_title = strrep(current_title,'_',' ');
suptitle(current_title)

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TIME FREQUENCY PLOT %%%%%%%%%%%%%%%%%%%%%%%%
disp('Time-frequency GAVR is in BS');

%% Extract values for statistics (Mega variable)

tic
disp(' ');      
disp('-------------------------');  
disp('Extracting values for statistics (FFR_Sz)');  
disp(datetime)
disp('-------------------------');     
disp(' ');

% Indicate which channels or clusters you are going to average
gavr_name = 'GAVR_12C_vs_14FE'; % Since stats will be saved in a folder based on this name
% GAVR_11C_vs_12FE (largest "FFR but not necessarily psychoacoustics" sample without outliers)
% GAVR_SIN (only those who have SIN)
% GAVR_AMP (only  those who have at least all but SIN)
% GAVR_adjacent_valley (with adjacent valley for spectral SNR)
ffr_version = 'original'; % 'original' or 'filtered' choose only one
% Cell array with all the freqs. Participants without one or some of them will just be empty for that one
FFR_freq = {'low','medium','high'};
spectra_unit = 'power'; % 'amplitude' OR 'power'
channel_to_average = {'Cz','cluster'}; % Cell array {'Cz','cluster'}
Quiet_treshold_type = 'Original'; % 'Original' OR 'ChrLab'
% Spectral time windows are determined in main 'Define variables' section
% Define header
if strcmp(Quiet_treshold_type,'ChrLab')
header_measures = {'Subj','Group',...
    'RMS_low_Baseline','RMS_low_Transient','RMS_low_Constant','RMS_low_Total',...
    'AMP_SNR_low_Transient','AMP_SNR_low_Constant','AMP_SNR_low_Total',...
    'STR_xcorr_low','neur_lag_low',...
    'pitch_err_low','pitch_str_low',...
    'F0_peak_low_Baseline','F0_peak_low_Transient','F0_peak_low_Constant','F0_peak_low_Total',...
    'F0_SNR_low_Baseline','F0_SNR_low_Transient','F0_SNR_low_Constant','F0_SNR_low_Total',...
    'RMS_medium_Baseline','RMS_medium_Transient','RMS_medium_Constant','RMS_medium_Total',...
    'AMP_SNR_medium_Transient','AMP_SNR_medium_Constant','AMP_SNR_medium_Total',...
    'STR_xcorr_medium','neur_lag_medium',...
    'pitch_err_medium','pitch_str_medium',...
    'F0_peak_medium_Baseline','F0_peak_medium_Transient','F0_peak_medium_Constant','F0_peak_medium_Total',...
    'F0_SNR_medium_Baseline','F0_SNR_medium_Transient','F0_SNR_medium_Constant','F0_SNR_medium_Total',...
    'RMS_high_Baseline','RMS_high_Transient','RMS_high_Constant','RMS_high_Total',...
    'AMP_SNR_high_Transient','AMP_SNR_high_Constant','AMP_SNR_high_Total',...
    'STR_xcorr_high','neur_lag_high',...
    'pitch_err_high','pitch_str_high',...
    'F0_peak_high_Baseline','F0_peak_high_Transient','F0_peak_high_Constant','F0_peak_high_Total',...
    'F0_SNR_high_Baseline','F0_SNR_high_Transient','F0_SNR_high_Constant','F0_SNR_high_Total',...
    'LLR_400ms_P50','LLR_400ms_N1','LLR_400ms_P2',...
    'LLR_1s_P50','LLR_1s_N1','LLR_1s_P2',...
    'AGE','SEX','VOCAB_TS','PSES',... % FOR MATCHING
    'YRSED','OVERALLTSCR','MATRIX_TS','FULL2IQ','SPEEDTSCR',... % NEUROPSYCHO TESTS
    'ATT_VIGTSCR', 'WMTSCR', 'VERBTSCR', 'VISTSCR', 'RPSTSCR', 'SOCCOGTSCR','SANITM', 'SAPITM', 'ROLECURR',...
    'ROLELOW', 'ROLEHIGH', 'SOCIALCURR', 'SOCIALLOW', 'SOCIALHIGH','SFS_WITHDRAW_RS', 'SFS_INTERACT_RS',...
    'SFS_RECREAT_RS', 'SFS_OCCUP_RS', 'SFS_IND_PERF_RS', 'SFS_IND_COMP_RS','SFS_PROSOC_RS',... 
    'PANSSP_RS','PANSSN_RS', 'PANSST_RS','PSYRATS_AUD_HALL', 'PSYRATS_DELUSIONS',... % CLINICAL TESTS
    'SANSSAPS_Level7_AudHall','SANSSAPS_Level7_UnusPercBeh','SANSSAPS_Level7_Delusions',... % COMPOSITE SCORES
    'SANSSAPS_Level7_ThDis','SANSSAPS_Level7_Inattention','SANSSAPS_Level7_Inexpress','SANSSAPS_Level7_Apathy',...
    'SANSSAPS_Level4_RealityDis','SANSSAPS_Level4_ThDis','SANSSAPS_Level4_Inexpress','SANSSAPS_Level4_Apathy',...
    'PANSS_Affect','PANSS_Disorg','PANSS_Negative','PANSS_Positive','PANSS_Resistance',...
    'BPRS_Total','BPRS_Positive','BPRS_Negative','BPRS_DeprAnx','BPRS_ActMania','BPRS_HostSusp',...
    'QT_L_125Hz', 'QT_L_250Hz', 'QT_L_500Hz', 'QT_L_1000Hz', 'QT_L_2000Hz', 'QT_L_4000Hz',... % PSYCHOACOUSTICS
    'QT_L_8000Hz','QT_R_125Hz', 'QT_R_250Hz', 'QT_R_500Hz', 'QT_R_1000Hz', 'QT_R_2000Hz', 'QT_R_4000Hz',...
    'QT_R_8000Hz','FD_250Hz', 'FD_1000Hz', 'FD_4000Hz', 'ITD_500Hz', 'ITD_1000Hz',...
    'ITD_2000Hz', 'ITD_4000Hz','MD_4Hz', 'MD_16Hz', 'MD_64Hz','SIND'...
    'QT_L_average','QT_R_average','FD_average','ITD_average','MD_average',...
    'DAYS_SINCE_PRDM','DAYS_SINCE_1STEP','DAYS_SINCE_DISOR',... % DURATION OF ILLNESS (IN DAYS)
    'DUP', 'PSYCH2SCAN', 'MED2SCAN',...
    'CPZ_equivalent'}; % MEDICATION LOAD
elseif strcmp(Quiet_treshold_type,'Original')
    header_measures = {'Subj','Group',...
    'RMS_low_Baseline','RMS_low_Transient','RMS_low_Constant','RMS_low_Total',...
    'AMP_SNR_low_Transient','AMP_SNR_low_Constant','AMP_SNR_low_Total',...
    'STR_xcorr_low','neur_lag_low',...
    'pitch_err_low','pitch_str_low',...
    'F0_peak_low_Baseline','F0_peak_low_Transient','F0_peak_low_Constant','F0_peak_low_Total',...
    'F0_SNR_low_Baseline','F0_SNR_low_Transient','F0_SNR_low_Constant','F0_SNR_low_Total',...
    'RMS_medium_Baseline','RMS_medium_Transient','RMS_medium_Constant','RMS_medium_Total',...
    'AMP_SNR_medium_Transient','AMP_SNR_medium_Constant','AMP_SNR_medium_Total',...
    'STR_xcorr_medium','neur_lag_medium',...
    'pitch_err_medium','pitch_str_medium',...
    'F0_peak_medium_Baseline','F0_peak_medium_Transient','F0_peak_medium_Constant','F0_peak_medium_Total',...
    'F0_SNR_medium_Baseline','F0_SNR_medium_Transient','F0_SNR_medium_Constant','F0_SNR_medium_Total',...
    'RMS_high_Baseline','RMS_high_Transient','RMS_high_Constant','RMS_high_Total',...
    'AMP_SNR_high_Transient','AMP_SNR_high_Constant','AMP_SNR_high_Total',...
    'STR_xcorr_high','neur_lag_high',...
    'pitch_err_high','pitch_str_high',...
    'F0_peak_high_Baseline','F0_peak_high_Transient','F0_peak_high_Constant','F0_peak_high_Total',...
    'F0_SNR_high_Baseline','F0_SNR_high_Transient','F0_SNR_high_Constant','F0_SNR_high_Total',...
    'LLR_400ms_P50','LLR_400ms_N1','LLR_400ms_P2',...
    'LLR_1s_P50','LLR_1s_N1','LLR_1s_P2',...
    'AGE','SEX','VOCAB_TS','PSES',... % FOR MATCHING
    'YRSED','OVERALLTSCR','MATRIX_TS','FULL2IQ','SPEEDTSCR',... % NEUROPSYCHO TESTS
    'ATT_VIGTSCR', 'WMTSCR', 'VERBTSCR', 'VISTSCR', 'RPSTSCR', 'SOCCOGTSCR','SANITM', 'SAPITM', 'ROLECURR',...
    'ROLELOW', 'ROLEHIGH', 'SOCIALCURR', 'SOCIALLOW', 'SOCIALHIGH','SFS_WITHDRAW_RS', 'SFS_INTERACT_RS',...
    'SFS_RECREAT_RS', 'SFS_OCCUP_RS', 'SFS_IND_PERF_RS', 'SFS_IND_COMP_RS','SFS_PROSOC_RS',... 
    'PANSSP_RS','PANSSN_RS', 'PANSST_RS','PSYRATS_AUD_HALL', 'PSYRATS_DELUSIONS',... % CLINICAL TESTS
    'SANSSAPS_Level7_AudHall','SANSSAPS_Level7_UnusPercBeh','SANSSAPS_Level7_Delusions',... % COMPOSITE SCORES
    'SANSSAPS_Level7_ThDis','SANSSAPS_Level7_Inattention','SANSSAPS_Level7_Inexpress','SANSSAPS_Level7_Apathy',...
    'SANSSAPS_Level4_RealityDis','SANSSAPS_Level4_ThDis','SANSSAPS_Level4_Inexpress','SANSSAPS_Level4_Apathy',...
    'PANSS_Affect','PANSS_Disorg','PANSS_Negative','PANSS_Positive','PANSS_Resistance',...
    'BPRS_Total','BPRS_Positive','BPRS_Negative','BPRS_DeprAnx','BPRS_ActMania','BPRS_HostSusp',...
    'QuiT_L_1000', 'QuiT_L_1500', 'QuiT_L_2000', 'QuiT_L_3000', 'QuiT_L_4000',... % PSYCHOACOUSTICS
    'QuiT_R_1000', 'QuiT_R_1500', 'QuiT_R_2000', 'QuiT_R_3000', 'QuiT_R_4000',...
    'FD_250Hz', 'FD_1000Hz', 'FD_4000Hz', 'ITD_500Hz', 'ITD_1000Hz',...
    'ITD_2000Hz', 'ITD_4000Hz','MD_4Hz', 'MD_16Hz', 'MD_64Hz','SIND'...
    'QT_L_average','QT_R_average','FD_average','ITD_average','MD_average',...
    'DAYS_SINCE_PRDM','DAYS_SINCE_1STEP','DAYS_SINCE_DISOR',... % DURATION OF ILLNESS (IN DAYS)
    'DUP', 'PSYCH2SCAN', 'MED2SCAN',...
    'CPZ_equivalent'}; % MEDICATION LOAD
end

% PROSDATE – date of the onset of the prodrome
% FPSSDATE – date of the first psychotic symptoms
% FPPDSDAT – date of the onset of the principal psychotic disorder

% For clinical/neuropsych variables (WILL HAVE TO FIND A MORE UPDATED ONE!!)
T1 = readtable('C:/Project/User/Project_MMN_global/Clinical/ATTNMOD_PEP_P_ALL_DATA_TOGETHER_20220419.xlsx');
warning('Ensure CONDATE, PROSDATE, FPSSDATE, FPPDSDAT, HOSPITALIZATION_ERVISITS_PSYCHIATRIC, INDIVIDUALTREATMENT, are in short date format in current Project-Clinical being read, are you sure this is the case? Same for STMED in med data')
pause;
% Variables to read from this table
T1_variables = {'SEX','SUBSES','MOMSES','DADSES','YRSED','VOCAB_TS','OVERALLTSCR','MATRIX_TS','FULL2IQ','SPEEDTSCR',...
    'ATT_VIGTSCR', 'WMTSCR', 'VERBTSCR', 'VISTSCR', 'RPSTSCR', 'SOCCOGTSCR','SANITM', 'SAPITM', 'ROLECURR',...
    'ROLELOW', 'ROLEHIGH', 'SOCIALCURR', 'SOCIALLOW', 'SOCIALHIGH','SFS_WITHDRAW_RS', 'SFS_INTERACT_RS',...
    'SFS_RECREAT_RS', 'SFS_OCCUP_RS', 'SFS_IND_PERF_RS', 'SFS_IND_COMP_RS','SFS_PROSOC_RS',...
    'PANSSP_RS','PANSSN_RS', 'PANSST_RS','PSYRATS_AUD_HALL', 'PSYRATS_DELUSIONS','PROSDATE','FPSSDATE','FPPDSDAT'};

% For clinical composite scores (WILL HAVE TO FIND A MORE UPDATED ONE!!)
T2 = readtable('C:/Project/User/Project_MMN_global/Clinical/Composite_scores_03_08_2022.xlsx');
% Variables to read from this table (ID: 2574)
T2_variables = {'SANSSAPS_Level7_AudHall','SANSSAPS_Level7_UnusPercBeh','SANSSAPS_Level7_Delusions',...
    'SANSSAPS_Level7_ThDis','SANSSAPS_Level7_Inattention','SANSSAPS_Level7_Inexpress','SANSSAPS_Level7_Apathy',...
    'SANSSAPS_Level4_RealityDis','SANSSAPS_Level4_ThDis','SANSSAPS_Level4_Inexpress','SANSSAPS_Level4_Apathy',...
    'PANSS_Affect','PANSS_Disorg','PANSS_Negative','PANSS_Positive','PANSS_Resistance',...
    'BPRS_Total','BPRS_Positive','BPRS_Negative','BPRS_DeprAnx','BPRS_ActMania','BPRS_HostSusp'};

% For updated age only (be sure that is updated manually)
T3 = readtable('C:/PrivatePath/FFR in Schizophrenia Pilot/Tracking_FFR_sheet.xlsx');
% Variables to read from this table (ID: 2574)
T3_variables = {'Age', 'EEGSession'}; % ONLY THESE TWO: EEG Session is a date to calculate time since FEP, etc.
% For psychoacoustics (manually edit for every new version)
T4 = readtable('C:/private_path/Psychoacoustics/Psychoacoustics_ready_to_correlate.xlsx');
% Variables to read from this table (ID: FFR_X74)
if strcmp(Quiet_treshold_type,'ChrLab')  
T4_variables = {'QT_L_125Hz', 'QT_L_250Hz', 'QT_L_500Hz', 'QT_L_1000Hz', 'QT_L_2000Hz', 'QT_L_4000Hz',...
    'QT_L_8000Hz','QT_R_125Hz', 'QT_R_250Hz', 'QT_R_500Hz', 'QT_R_1000Hz', 'QT_R_2000Hz', 'QT_R_4000Hz',...
    'QT_R_8000Hz','FD_250Hz', 'FD_1000Hz', 'FD_4000Hz', 'ITD_500Hz', 'ITD_1000Hz', 'ITD_2000Hz', 'ITD_4000Hz',...
    'MD_4Hz', 'MD_16Hz', 'MD_64Hz', 'SIND'}; % ADD SPEECH IN NOISE SOON
elseif strcmp(Quiet_treshold_type,'Original')  
T4_variables = {'QuiT_L_1000', 'QuiT_L_1500', 'QuiT_L_2000', 'QuiT_L_3000', 'QuiT_L_4000',...
    'QuiT_R_1000', 'QuiT_R_1500', 'QuiT_R_2000', 'QuiT_R_3000', 'QuiT_R_4000',...
    'QT_R_8000Hz','FD_250Hz', 'FD_1000Hz', 'FD_4000Hz', 'ITD_500Hz', 'ITD_1000Hz', 'ITD_2000Hz', 'ITD_4000Hz',...
    'MD_4Hz', 'MD_16Hz', 'MD_64Hz', 'SIND'}; % ADD SPEECH IN NOISE SOON
end
% Read medication data
T6 = readtable('C:/Project/User/Project_MMN_global/Clinical/A_SCHZMEDS_20220610.xlsx');
T7 = readtable('C:/Project/User/Project_MMN_global/Clinical/CPZ_equivalent_table.xlsx');

table1_columns = T1.Properties.VariableNames;
table2_columns = T2.Properties.VariableNames;
table3_columns = T3.Properties.VariableNames;
table4_columns = T4.Properties.VariableNames;
table6_columns = T6.Properties.VariableNames;
table7_columns = T7.Properties.VariableNames;

% FFR (Original OR Low-pass filtered)
for cha = 1:length(channel_to_average)
    Mega_matrix = {};
for pg = 1:length(participant_group) % Just to have groups organized in matrix    
    for p = 1:length(participant) 
        % Do only for participants that are done anlyzing
        pos_subj = find(strcmp({subject_array{:,1}},participant{p}));
        
        if strcmp(subject_array{pos_subj,3},'DONE')

            % Only include participants that belong to the group
            if ~strcmp(subject_array{pos_subj,2},participant_group{pg}); continue; end

            % First of all, retrieve participant code and group
            Subj = participant{p};
            Group = participant_group{pg};
            
            disp(' ');      
            disp('-------------------------');  
            disp(['Extracting FFR/LLR measures for ' participant{p}]);
            disp(datetime)
            disp(' '); 
            
            % Retrieve FFR measures
            for ff = 1:length(FFR_freq)
            
                % Retrieve TD data
                if strcmp(FFR_freq{ff},'low')
                    % FFR LOW 
                    if strcmp(ffr_version,'original')
                        % FFR TD LOW
                        if strcmp(participant{p},'FFR_S01') || strcmp(participant{p},'FFR_S02') || strcmp(participant{p},'FFR_X74') || strcmp(participant{p},'FFR_X10')
                            if exist([root_dir '/Results/' participant{p} '/FFR_' channel_to_average{cha} '.mat'],'file')
                                load([root_dir '/Results/' participant{p} '/FFR_' channel_to_average{cha} '.mat']);
                                current_average = Average;
                            else
                                current_average = []; % So that it's stored as a missing one in the matrix
                                warning(['No FFR TD low original filter (' channel_to_average{cha} ') for ' participant{p}]);
                            end
                        else
                            if exist([root_dir '/Results/' participant{p} '/FFR_low_' channel_to_average{cha} '.mat'],'file')
                                load([root_dir '/Results/' participant{p} '/FFR_low_' channel_to_average{cha} '.mat']);
                                current_average = Average;
                            else
                                current_average = []; % So that it's stored as a missing one in the matrix
                                warning(['No FFR TD low original filter (' channel_to_average{cha} ') for ' participant{p}]);
                            end
                        end
                    elseif strcmp(ffr_version,'filtered')
                        % FFR TD LOW low-pass filter
                        if strcmp(participant{p},'FFR_S01') || strcmp(participant{p},'FFR_S02') || strcmp(participant{p},'FFR_X74') || strcmp(participant{p},'FFR_X10')
                            if exist([root_dir '/Results/' participant{p} '/FFR_low_pass_' channel_to_average{cha} '.mat'],'file')
                                load([root_dir '/Results/' participant{p} '/FFR_low_pass_' channel_to_average{cha} '.mat']);
                                current_average = Average;
                            else
                                current_average = []; % So that it's stored as a missing one in the matrix
                                warning(['No FFR TD low low passed (' channel_to_average{cha} ') for ' participant{p}]);
                            end
                        else
                            if exist([root_dir '/Results/' participant{p} '/FFR_low_' low_pass_FFR_low_string '_' channel_to_average{cha} '.mat'],'file')
                                load([root_dir '/Results/' participant{p} '/FFR_low_' low_pass_FFR_low_string '_' channel_to_average{cha} '.mat']);
                                current_average = Average;
                            else
                                current_average = []; % So that it's stored as a missing one in the matrix
                                warning(['No FFR TD low low passed (' channel_to_average{cha} ') for ' participant{p}]);
                            end
                        end
                    end

                
                elseif strcmp(FFR_freq{ff},'medium')
                    % FFR MEDIUM
                    if strcmp(ffr_version,'original')
                        % FFR TD MEDIUM original filter
                        if exist([root_dir '/Results/' participant{p} '/FFR_medium_' channel_to_average{cha} '.mat'],'file')
                            load([root_dir '/Results/' participant{p} '/FFR_medium_' channel_to_average{cha} '.mat']);
                            current_average = Average;
                        else
                            current_average = []; % So that it's stored as a missing one in the matrix
                            % We know already that these don't have it
                            if ~strcmp(participant{p},'FFR_S01') && ~strcmp(participant{p},'FFR_S02')...
                                && ~strcmp(participant{p},'FFR_X74') && ~strcmp(participant{p},'FFR_X10')...
                                && ~strcmp(participant{p},'FFR_X62') && ~strcmp(participant{p},'FFR_X18')...
                                && ~strcmp(participant{p},'FFR_X81')
                                warning(['No FFR TD medium original filter (' channel_to_average{cha} ') for ' participant{p}]);
                            end
                        end
                    elseif strcmp(ffr_version,'filtered')
                        % FFR TD MEDIUM low-pass filter
                        if exist([root_dir '/Results/' participant{p} '/FFR_medium_' low_pass_FFR_medium_string '_' channel_to_average{cha} '.mat'],'file')
                            load([root_dir '/Results/' participant{p} '/FFR_medium_' low_pass_FFR_medium_string '_' channel_to_average{cha} '.mat']);
                            current_average = Average;
                        else
                            current_average = []; % So that it's stored as a missing one in the matrix
                            % We know already that these don't have it
                            if ~strcmp(participant{p},'FFR_S01') && ~strcmp(participant{p},'FFR_S02')...
                                && ~strcmp(participant{p},'FFR_X74') && ~strcmp(participant{p},'FFR_X10')...
                                && ~strcmp(participant{p},'FFR_X62') && ~strcmp(participant{p},'FFR_X18')...
                                && ~strcmp(participant{p},'FFR_X81')
                                warning(['No FFR TD medium low passed (' channel_to_average{cha} ') for ' participant{p}]);
                            end
                        end
                    end
                    

                elseif strcmp(FFR_freq{ff},'high')
                    % FFR HIGH 
                    if strcmp(ffr_version,'original')
                        % FFR TD HIGH original filter
                        if exist([root_dir '/Results/' participant{p} '/FFR_high_' channel_to_average{cha} '.mat'],'file')
                            load([root_dir '/Results/' participant{p} '/FFR_high_' channel_to_average{cha} '.mat']);
                            current_average = Average;
                        else
                            current_average = []; % So that it's stored as a missing one in the matrix
                            % We know already that these don't have it
                            if ~strcmp(participant{p},'FFR_S01') && ~strcmp(participant{p},'FFR_S02')...
                                && ~strcmp(participant{p},'FFR_X74') && ~strcmp(participant{p},'FFR_X10')
                                warning(['No FFR TD high original filter (' channel_to_average{cha} ') for ' participant{p}]);
                            end
                        end
                    elseif strcmp(ffr_version,'filtered')
                        % FFR TD HIGH low-pass filter
                        if exist([root_dir '/Results/' participant{p} '/FFR_high_' low_pass_FFR_high_string '_' channel_to_average{cha} '.mat'],'file')
                            load([root_dir '/Results/' participant{p} '/FFR_high_' low_pass_FFR_high_string '_' channel_to_average{cha} '.mat']);
                            current_average = Average;
                        else
                            current_average = []; % So that it's stored as a missing one in the matrix
                            % We know already that these don't have it
                            if ~strcmp(participant{p},'FFR_S01') && ~strcmp(participant{p},'FFR_S02')...
                                && ~strcmp(participant{p},'FFR_X74') && ~strcmp(participant{p},'FFR_X10')
                                warning(['No FFR TD high low passed (' channel_to_average{cha} ') for ' participant{p}]);
                            end
                        end
                    end
                    
                end

                % Extract FFR TD measures
                if ~isempty(current_average)
                    for tw = 1:length(time_windows_FFR)
                        
                        % Adjust scale
                        current_average = current_average*1e6;
                        
                        SR =  round(length(current_average)/0.270); % Sampling rate
                        % Define section to compute FFT on
                        time_samples=linspace(-40,230,((((-40*(-1)) + 230)/1000)*SR) +1);
                        [~,closestIndex] = min(abs(time_samples-(time_windows_FFR{tw}(1)*1000)));
                        init_time = closestIndex;
                        [~,closestIndex] = min(abs(time_samples-(time_windows_FFR{tw}(2)*1000)));
                        end_time = closestIndex;        
                        Average_section = current_average(1,init_time:end_time);
                        
                        % RMS
                        eval(['RMS_' FFR_freq{ff} '_' time_windows_FFR_labels{tw} ' = rms(mean(Average_section,2));'])
                
                        % AMP SNR
                        if strcmp(time_windows_FFR_labels{tw},'Baseline')
                            % This baseline will be used for next ones
                            Baseline = rms(mean(Average_section,2));
                        else
                            eval(['AMP_SNR_' FFR_freq{ff} '_' time_windows_FFR_labels{tw} ' = (rms(mean(Average_section,2)))/Baseline;'])
                        end
                    end
                    
                    %%%%%%%%%%%%%%%%%%%%%% Stim to response xcorr and neural lag %%%%%%%%%%%%%%%%%%%%%%
                    
                    % Load stimulus ready for xcorr
                    stim = load([root_dir '/Stimuli/FFR_' FFR_freq{ff} '_decimated_and_filtered.mat']);
                    
                    % Crop current_average to remove baseline
                    [~,closestIndex] = min(abs(time_samples-(0*1000)));
                    init_time = closestIndex;
                    [~,closestIndex] = min(abs(time_samples-(0.200*1000)));
                    end_time = closestIndex;        
                    Average_section = current_average(1,init_time:end_time);
                    
                    % Normalize amplitudes betwen zero and 1
                    norm_response = (Average_section - min(Average_section))/(max(Average_section) - min(Average_section));
                    norm_stim = (stim.F - min(stim.F))/(max(stim.F) - min(stim.F));
                    
                    % Add zeros at the end of shortest vector as xcorr would do (but can't if 'coeff' option needs to be used
                    if length(norm_stim) < length(norm_response)
                         num_zeros = length(norm_response) - length(norm_stim);
                         zero_vec = zeros(1,num_zeros);
                         norm_stim_length = [norm_stim(1,:),zero_vec];
                    end
                    
                    % Cross correlate
                    
                    [c,lag] = xcorr(norm_response,norm_stim_length,round(xcorr_maxlag*SR),'coeff');
                    % Ensure no negative lag
                    c = c(lag>=0);
                    lag = lag(lag>=0);
                    [max_corr,I] = max(abs(c));
                    sampleDiff = lag(I); 
                    neural_lag = (sampleDiff)/SR;
                    
                    % Stim to response xcorr (pending)
                    eval(['STR_xcorr_' FFR_freq{ff} ' = [max_corr];']);

                    % Neural lag (from previous xcorr)
                    eval(['neur_lag_' FFR_freq{ff} ' = [neural_lag];']);
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
                    % These next we will have to figure it out, for now they are empty
                    
                    % Pitch error (pending): probably need BS TF
                    eval(['pitch_err_' FFR_freq{ff} ' = [];']);
                    
                    % Pitch strength (pending): needs autocorrelogram
                    eval(['pitch_str_' FFR_freq{ff} ' = [];']);
                    
                else % If it's empty, we still need the variables (although empty) to store them
                    
                    for tw = 1:length(time_windows_FFR)
                        eval(['RMS_' FFR_freq{ff} '_' time_windows_FFR_labels{tw} ' = [];'])
                        eval(['AMP_SNR_' FFR_freq{ff} '_' time_windows_FFR_labels{tw} ' = [];'])
                    end
                    
                    % Stim to response xcorr (pending)
                    eval(['STR_xcorr_' FFR_freq{ff} ' = [];']);

                    % Neural lag (from previous xcorr)
                    eval(['neur_lag_' FFR_freq{ff} ' = [];']);
                    
                    % Pitch error (pending): probably need BS TF
                    eval(['pitch_err_' FFR_freq{ff} ' = [];']);
                    
                    % Pitch strength (pending): needs autocorrelogram
                    eval(['pitch_str_' FFR_freq{ff} ' = [];']);
                end
                
                % Now retrieve FFT data (have to loop through tw first)
                for tw = 1:length(time_windows_FFR)

                    % Now retrieve FFT data
                    if strcmp(FFR_freq{ff},'low')
                        % FFT LOW
                        if strcmp(participant{p},'FFR_S01') || strcmp(participant{p},'FFR_S02') || strcmp(participant{p},'FFR_X74') || strcmp(participant{p},'FFR_X10')
                            if exist([root_dir '/Results/' participant{p} '/FFT_' time_windows_FFR_labels{tw} '_' channel_to_average{cha} '.mat'],'file')
                                load([root_dir '/Results/' participant{p} '/FFT_' time_windows_FFR_labels{tw} '_' channel_to_average{cha} '.mat']);
                                current_average = amplitude(1,[1:500]);
                            else
                                current_average = []; % So that it's stored as a missing one in the matrix
                                warning(['No FFT ' time_windows_FFR_labels{tw} ' LOW (' channel_to_average{cha} ') for ' participant{p}]);
                            end
                        else
                            if exist([root_dir '/Results/' participant{p} '/FFT_low_' time_windows_FFR_labels{tw} '_' channel_to_average{cha} '.mat'],'file')
                                load([root_dir '/Results/' participant{p} '/FFT_low_' time_windows_FFR_labels{tw} '_' channel_to_average{cha} '.mat']);
                                current_average = amplitude(1,[1:500]);
                            else
                                current_average = []; % So that it's stored as a missing one in the matrix
                                warning(['No FFT ' time_windows_FFR_labels{tw} ' LOW (' channel_to_average{cha} ') for ' participant{p}]);
                            end
                        end

                    elseif strcmp(FFR_freq{ff},'medium')
                        % FFT MEDIUM
                        if exist([root_dir '/Results/' participant{p} '/FFT_medium_' time_windows_FFR_labels{tw} '_' channel_to_average{cha} '.mat'],'file')
                            load([root_dir '/Results/' participant{p} '/FFT_medium_' time_windows_FFR_labels{tw} '_' channel_to_average{cha} '.mat']);
                            current_average = amplitude(1,[1:500]);
                        else
                            current_average = []; % So that it's stored as a missing one in the matrix
                            % We know already that these don't have it
                            if ~strcmp(participant{p},'FFR_S01') && ~strcmp(participant{p},'FFR_S02')...
                                && ~strcmp(participant{p},'FFR_X74') && ~strcmp(participant{p},'FFR_X10')...
                                && ~strcmp(participant{p},'FFR_X62') && ~strcmp(participant{p},'FFR_X18')...
                                && ~strcmp(participant{p},'FFR_X81')
                                warning(['No FFT medium ' time_windows_FFR_labels{tw} ' (' channel_to_average{cha} ') for ' participant{p}]);
                            end
                        end

                    elseif strcmp(FFR_freq{ff},'high')
                        % FFT HIGH
                        if exist([root_dir '/Results/' participant{p} '/FFT_high_' time_windows_FFR_labels{tw} '_' channel_to_average{cha} '.mat'],'file')
                            load([root_dir '/Results/' participant{p} '/FFT_high_' time_windows_FFR_labels{tw} '_' channel_to_average{cha} '.mat']);
                            current_average = amplitude(1,[1:500]);
                        else
                            current_average = []; % So that it's stored as a missing one in the matrix
                            % We know already that these don't have it
                            if ~strcmp(participant{p},'FFR_S01') && ~strcmp(participant{p},'FFR_S02')...
                                && ~strcmp(participant{p},'FFR_X74') && ~strcmp(participant{p},'FFR_X10')
                                warning(['No FFT high ' time_windows_FFR_labels{tw} ' (' channel_to_average{cha} ') for ' participant{p}]);
                            end
                        end

                    end
                    
                    % Extract FFT variables if not empty
                    if ~isempty(current_average)

                        % Adjust scale
                        current_average = current_average*1e6; 

                        % Transform to adequate units
                        if strcmp(spectra_unit,'power')
                            current_average = current_average.^2; % Convert to power
                        end

                        % Peak amplitude/Power (current_average is already only first 500Hz)
                        eval(['F0_peak_' FFR_freq{ff} '_' time_windows_FFR_labels{tw} ' = mean(current_average(1,init_peak_' FFR_freq{ff} ':end_peak_' FFR_freq{ff} '));'])

                        % Spectral SNR (amplitude or power)
                        eval(['Spectral_valley_pre = current_average(1,init_peak_' FFR_freq{ff} '-valley_length-separation:init_peak_' FFR_freq{ff} '-separation-1);'])
                        eval(['Spectral_valley_post = current_average(1,end_peak_' FFR_freq{ff} '+1+separation:end_peak_' FFR_freq{ff} '+separation+valley_length);'])
                        Spectral_valley_pre = mean(Spectral_valley_pre);
                        Spectral_valley_post = mean(Spectral_valley_post);
                        Spectral_valleys = (Spectral_valley_pre + Spectral_valley_post)/2;
                        eval(['F0_SNR_' FFR_freq{ff} '_' time_windows_FFR_labels{tw} ' = mean(current_average(1,init_peak_' FFR_freq{ff} ':end_peak_' FFR_freq{ff} '))/Spectral_valleys;'])
                    
                    else % If it's empty we still need the variables
                        eval(['F0_peak_' FFR_freq{ff} '_' time_windows_FFR_labels{tw} ' = [];'])
                        eval(['F0_SNR_' FFR_freq{ff} '_' time_windows_FFR_labels{tw} ' = [];'])
                    end
                end                
            end

            % Now retrieve LLR measures
            % 400ms ISI
            if strcmp(participant{p},'FFR_S01') || strcmp(participant{p},'FFR_S02') || strcmp(participant{p},'FFR_X74') || strcmp(participant{p},'FFR_X10')
                if exist([root_dir '/Results/' participant{p} '/LLR_' channel_to_average{cha} '.mat'],'file')
                    load([root_dir '/Results/' participant{p} '/LLR_' channel_to_average{cha} '.mat']);
                    current_average = Average;
                else
                    current_average = []; % So that it's stored as a missing one in the matrix
                    warning(['No LLR 400ms (' channel_to_average{cha} ') for ' participant{p}]);
                end
            else
                if exist([root_dir '/Results/' participant{p} '/LLR_400ms_' channel_to_average{cha} '.mat'],'file')
                    load([root_dir '/Results/' participant{p} '/LLR_400ms_' channel_to_average{cha} '.mat']);
                    current_average = Average;
                else
                    current_average = []; % So that it's stored as a missing one in the matrix
                    warning(['No LLR 400ms (' channel_to_average{cha} ') for ' participant{p}]);
                end
            end
            
            if ~isempty(current_average)
                
                % Adjust scale
                current_average = current_average*1e6;
                
                % Extract LLR means 400ms ISI
                for tl = 1:length(time_windows_LLR_labels) 
                    SR =  round(length(current_average)/0.500); % Sampling rate
                    % Define section to compute FFT on
                    time_samples=linspace(-100,400,((((-100*(-1)) + 400)/1000)*SR) +1);
                    [~,closestIndex] = min(abs(time_samples-(time_windows_LLR{tl}(1)*1000)));
                    init_time = closestIndex;
                    [~,closestIndex] = min(abs(time_samples-(time_windows_LLR{tl}(2)*1000)));
                    end_time = closestIndex;        
                    Average_section = current_average(1,init_time:end_time);
                    A = mean(Average_section);
                    eval(['LLR_400ms_' time_windows_LLR_labels{tl} ' = mean(Average_section);'])
                end
                
            else % If it's empty, we still need the variables
                for tl = 1:length(time_windows_LLR_labels) 
                    eval(['LLR_400ms_' time_windows_LLR_labels{tl} ' = [];'])
                end
            end
            
            % 1s ISI
            if strcmp(participant{p},'FFR_S01') || strcmp(participant{p},'FFR_S02') || strcmp(participant{p},'FFR_X74') || strcmp(participant{p},'FFR_X10')
                % We know that these did not have 1s ISI
                current_average = []; % So that it's stored as a missing one in the matrix
            else
                if exist([root_dir '/Results/' participant{p} '/LLR_1s_' channel_to_average{cha} '.mat'],'file')
                    load([root_dir '/Results/' participant{p} '/LLR_1s_' channel_to_average{cha} '.mat']);
                    current_average = Average;
                else
                    current_average = []; % So that it's stored as a missing one in the matrix
                    warning(['No LLR 1s (' channel_to_average{cha} ') for ' participant{p}]);
                end
            end
            
            if ~isempty(current_average)
                
                % Adjust scale
                current_average = current_average*1e6;
                
                % Extract LLR means 400ms ISI
                for tl = 1:length(time_windows_LLR_labels) 
                    SR =  round(length(current_average)/0.500); % Sampling rate
                    % Define section to compute FFT on
                    time_samples=linspace(-100,400,((((-100*(-1)) + 400)/1000)*SR) +1);
                    [~,closestIndex] = min(abs(time_samples-(time_windows_LLR{tl}(1)*1000)));
                    init_time = closestIndex;
                    [~,closestIndex] = min(abs(time_samples-(time_windows_LLR{tl}(2)*1000)));
                    end_time = closestIndex;        
                    Average_section = current_average(1,init_time:end_time);
                    A = mean(Average_section);
                    eval(['LLR_1s_' time_windows_LLR_labels{tl} ' = mean(Average_section);'])
                end
                
            else % If it's empty, we still need the variables
                for tl = 1:length(time_windows_LLR_labels) 
                    eval(['LLR_1s_' time_windows_LLR_labels{tl} ' = [];'])
                end
                
            end
            
            % T1 VARIABLES
            pos_s_t1 = find(T1.RECID == str2double(participant{p}(5:end)));
            
            % If it's not empty, extract T1 measures
            if ~isempty(pos_s_t1)
                % If it appears > 1 in T1, subject completed several time points
                % Thus, pick the most recent one
                if length(pos_s_t1) > 1
                    new_pos = find(strcmp(T1.TIMEPT(pos_s_t1),'YR1'));
                    if isempty(new_pos) % no one year measurement
                        new_pos = find(strcmp(T1.TIMEPT(pos_s_t1),'WK26'));
                        if isempty(new_pos) % no six months measurement
                            new_pos = find(strcmp(T1.TIMEPT(pos_s_t1),'WK12'));
                            if isempty(new_pos) % no 3 months measurement
                                new_pos = find(strcmp(T1.TIMEPT(pos_s_t1),'BASELINE'));
                                if isempty(new_pos)
                                    error(['no recognized TIMEPT for ' participant{p}])
                                end
                            end
                        end
                    end
                    % So now the position of this participant in T1 is the most updated
                    pos_s_t1 = pos_s_t1(new_pos);
                    % If it is still duplicated, it probably is a repeated entry from
                    pos_s_t1 = pos_s_t1(end);
                end
                
                % Now that we have final position of subj, extract variables
                for t1v = 1:length(T1_variables)
                    % Find column 
                    pos_var = find(strcmp(table1_columns,T1_variables{t1v}));
                    % Create variable to store later (with same name than in list)
                    eval([T1_variables{t1v} ' = T1{pos_s_t1,pos_var};'])
                end
                
                % In this case, compute PSES too
                if isnan(DADSES) && isnan(MOMSES) 
                    PSES = [];
                elseif isnan(DADSES)
                    PSES = MOMSES;
                elseif isnan(MOMSES)
                    PSES = DADSES;
                else 
                    PSES = (DADSES + MOMSES)/2;
                end
                
            else % if it's empty we still need to define variables
                for t1v = 1:length(T1_variables)
                    eval([T1_variables{t1v} ' = [];'])
                end
                % And set PSES as empty too.
                PSES = [];
            end
            
            % T2 VARIABLES
            pos_s_t2 = find(T2.RECID == str2double(participant{p}(5:end)));
            
            % If it's not empty, extract T2 measures
            if ~isempty(pos_s_t2)
                % If it appears > 1 in T2, subject completed several time points
                % Thus, pick the most recent one
                if length(pos_s_t2) > 1
                    new_pos = find(strcmp(T2.TIMEPT(pos_s_t2),'YR1'));
                    if isempty(new_pos) % no one year measurement
                        new_pos = find(strcmp(T2.TIMEPT(pos_s_t2),'WK26'));
                        if isempty(new_pos) % no six months measurement
                            new_pos = find(strcmp(T2.TIMEPT(pos_s_t2),'WK12'));
                            if isempty(new_pos) % no 3 months measurement
                                new_pos = find(strcmp(T2.TIMEPT(pos_s_t2),'BASELINE'));
                                if isempty(new_pos)
                                    error(['no recognized TIMEPT for ' participant{p}])
                                end
                            end
                        end
                    end
                    % So now the position of this participant in T1 is the most updated
                    pos_s_t2 = pos_s_t2(new_pos);
                    % If it is still duplicated, it probably is a repeated entry from
                    pos_s_t2 = pos_s_t2(end);
                end
                
                % Now that we have final position of subj, extract variables
                for t2v = 1:length(T2_variables)
                    % Find column 
                    pos_var = find(strcmp(table2_columns,T2_variables{t2v}));
                    % Create variable to store later (with same name than in list)
                    eval([T2_variables{t2v} ' = T2{pos_s_t2,pos_var};'])
                end
                
            else % if it's empty we still need to define variables
                for t2v = 1:length(T2_variables)
                    eval([T2_variables{t2v} ' = [];'])
                end
            end
            
            % T3 VARIABLES
            pos_s_t3 = find(strcmp(T3.ID,participant{p}(5:end)));
            
            % If it's not empty, extract T3 measures (Age)
            if ~isempty(pos_s_t3)
                if length(pos_s_t3) > 1
                    % Should not be the case, but just pick the last one
                    pos_s_t3 = pos_s_t3(end);
                end
                % Find columns                 
                pos_var = find(strcmp(table3_columns,'Age'));
                AGE = str2double(T3{pos_s_t3,pos_var}); %#ok<*FNDSB> % Has to be in capital letters  
                pos_var = find(strcmp(table3_columns,'EEGSession'));
                Date_experiment = T3{pos_s_t3,pos_var};
            else % if it's empty we still need to define variables
                AGE = []; % Has to be in capital letters
                Date_experiment = [];
            end
            
            % T4 VARIABLES
            pos_s_t4 = find(strcmp(T4.ID, participant{p}));
            
            % If it's not empty, extract T4 measures
            if ~isempty(pos_s_t4)

                if length(pos_s_t4) > 1
                    % Should not happen, but if it does, pick last one
                    pos_s_t4 = pos_s_t4(end);
                end
                
                % Extract variables
                for t4v = 1:length(T4_variables)
                    % Find column 
                    pos_var = find(strcmp(table4_columns,T4_variables{t4v}));
                    % Do differently if outlier SIN
                    if strcmp(remove_outlier_SIN,'YES') && strcmp(T4_variables{t4v},'SIND') && strcmp(participant{p},'FFR_X54')
                        eval([T4_variables{t4v} ' = [];'])
                    else
                        % Create variable to store later (with same name than in list)
                        eval([T4_variables{t4v} ' = T4{pos_s_t4,pos_var};'])
                    end
                end

            else % if it's empty we still need to define variables
                for t4v = 1:length(T4_variables)
                    eval([T4_variables{t4v} ' = [];'])
                end
            end
            
            % PERSONALIZED VARIABLES
            
            % Psychoacoustic averages
            % QT (L/R)
            if strcmp(Quiet_treshold_type,'ChrLab')  
                if ~isempty(QT_L_125Hz) % If this is empty all other QT are
                    % QT average L
                    namesWorkspace = who;
                    QT_L_vars = namesWorkspace(find(startsWith(namesWorkspace,'QT_L') & ~contains(namesWorkspace,'average') & ~contains(namesWorkspace,'vars')));
                    for i = 1:length(QT_L_vars)
                        eval(['QT_L_average(i) = [' QT_L_vars{i} '];'])
                    end
                    QT_L_average = mean(QT_L_average);

                    % QT average L
                    namesWorkspace = who;
                    QT_R_vars = namesWorkspace(find(startsWith(namesWorkspace,'QT_R') & ~contains(namesWorkspace,'average') & ~contains(namesWorkspace,'vars')));
                    for i = 1:length(QT_R_vars)
                        eval(['QT_R_average(i) = [' QT_R_vars{i} '];'])
                    end
                    QT_R_average = mean(QT_R_average);
                else
                    QT_L_average = []; % Average across frequencies
                    QT_R_average = []; % Average across frequencies 
                end
            elseif strcmp(Quiet_treshold_type,'Original')  
                if ~isempty(QuiT_L_1000) % If this is empty all other QT are
                    % QT average L
                    namesWorkspace = who;
                    QT_L_vars = namesWorkspace(find(startsWith(namesWorkspace,'QuiT_L') & ~contains(namesWorkspace,'average') & ~contains(namesWorkspace,'vars')));
                    for i = 1:length(QT_L_vars)
                        eval(['QT_L_average(i) = [' QT_L_vars{i} '];'])
                    end
                    QT_L_average = mean(QT_L_average);

                    % QT average L
                    namesWorkspace = who;
                    QT_R_vars = namesWorkspace(find(startsWith(namesWorkspace,'QuiT_R') & ~contains(namesWorkspace,'average') & ~contains(namesWorkspace,'vars')));
                    for i = 1:length(QT_R_vars)
                        eval(['QT_R_average(i) = [' QT_R_vars{i} '];'])
                    end
                    QT_R_average = mean(QT_R_average);
                else
                    QT_L_average = []; % Average across frequencies
                    QT_R_average = []; % Average across frequencies 
                end
            end
            
            % FD
            if ~isempty(FD_250Hz) % If this is empty all other FD are
                % FD average
                namesWorkspace = who;
                FD_vars = namesWorkspace(find(startsWith(namesWorkspace,'FD_') & ~contains(namesWorkspace,'average') & ~contains(namesWorkspace,'vars')));
                for i = 1:length(FD_vars)
                    eval(['FD_average(i) = [' FD_vars{i} '];'])
                end
                FD_average = mean(FD_average);

            else
                FD_average = []; % Average across frequencies
            end
            
            % MD
            if ~isempty(MD_4Hz) % If this is empty all other MD are
                % MD average
                namesWorkspace = who;
                MD_vars = namesWorkspace(find(startsWith(namesWorkspace,'MD_') & ~contains(namesWorkspace,'average') & ~contains(namesWorkspace,'vars')));
                for i = 1:length(MD_vars)
                    eval(['MD_average(i) = [' MD_vars{i} '];'])
                end
                MD_average = mean(MD_average);

            else
                MD_average = []; % Average across frequencies
            end
            
            % ITD
            if ~isempty(ITD_500Hz) % If this is empty all other ITD are
                % ITD average
                namesWorkspace = who;
                ITD_vars = namesWorkspace(find(startsWith(namesWorkspace,'ITD_') & ~contains(namesWorkspace,'average') & ~contains(namesWorkspace,'vars')));
                for i = 1:length(ITD_vars)
                    eval(['ITD_average(i) = [' ITD_vars{i} '];'])
                end
                ITD_average = mean(ITD_average);
            else
                ITD_average = []; % Average across frequencies
            end
            
            % Durations of illness (compare with Date_experiment)
            % Prodromal symptoms
            if isempty(char(PROSDATE)) || isempty(Date_experiment)
                DAYS_SINCE_PRDM = [];
            else
                try
                    DAYS_SINCE_PRDM = daysact(char(PROSDATE), char(Date_experiment));
                catch % Sometimes instead of an empty cell is a NaN, which won't be detected
                    DAYS_SINCE_PRDM = [];
                end
            end
            
            % First episode
            if isempty(char(FPSSDATE)) || isempty(Date_experiment)
                DAYS_SINCE_1STEP = [];
            else
                try
                    DAYS_SINCE_1STEP = daysact(char(FPSSDATE), char(Date_experiment));
                catch
                    DAYS_SINCE_1STEP = [];
                end
            end
                        
            % Onset of the principal psychotic disorder
            if isempty(char(FPPDSDAT)) || isempty(Date_experiment)
                DAYS_SINCE_DISOR = [];
            else
                try
                    DAYS_SINCE_DISOR = daysact(char(FPPDSDAT), char(Date_experiment));
                catch
                    DAYS_SINCE_DISOR = [];
                end
            end
          
            %%%%%%%%%%%%%%%%%%%%%%%%%% Medication load %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if 1 == 1 % Silly way to compress it
            if strcmp(participant_group{pg},'FE')
                pos_row_med = find(T6.RECID == str2double(participant{p}(5:end)) & T6.MEDCODE == 5);
                if ~isempty(pos_row_med) 
                    % Retrieve dates from all these rows/entries
                    list_med_dates = T6.STMED(pos_row_med);
                    % Extract days from each date to Date_experiment
                    days_med_to_scan = {};
                    for lmd = 1:length(list_med_dates)
                        % Transform into proper format
                        med_date = {char(datetime(list_med_dates(lmd), 'InputFormat','MMM-dd-yyyy HH:mm:ss', 'Format','MM/dd/yyyy'))};
                        % Calculate number of days
                        days_med_to_scan{lmd} = daysact(char(med_date), char(Date_experiment));
                    end
                    % Check position of date with shortest delay (but positive, i.e. before the experiment)
                    days_med_to_scan = cell2mat(days_med_to_scan);
                    shortest_delay = min(days_med_to_scan(days_med_to_scan>0));
                    if isempty(shortest_delay) % No med date before the experiment
                        CPZ_equivalent = [];
                    else
                        pos_shortest_date = find(days_med_to_scan == shortest_delay);
                        if length(pos_shortest_date) > 1
                            pos_shortest_date = pos_shortest_date(end);
                        end
                        med_name = T6.MEDNAME{pos_row_med(pos_shortest_date)}; 
                        med_dose = T6.DOSE(pos_row_med(pos_shortest_date)); % Will always be in mg
                        if isempty(med_name) || isempty(med_dose) % Cannot calculate
                            CPZ_equivalent = [];
                        else
                            post7 = find(strcmpi(T7.MEDICATION,med_name));
                            if isempty(post7) % cannot find the medication name
                                CPZ_equivalent = [];
                            else
                                CPZ_equivalent = T7.CPZ_EQUIV(post7)*med_dose;
                            end
                        end
                    end
                else % Subject is not in that list
                    CPZ_equivalent = [];
                end
            else 
               CPZ_equivalent = []; 
            end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%%%%%%%%  Duration of illness variables %%%%%%%%%%%%%%%%%%%%%
            if 1 == 1 % Silly way to fold this piece of code
            % Time point does not really matter here as all of these measures will
            % be the same regardless of time point, but just in case
            pos_row_clin = find(T1.RECID == str2double(participant{p}(5:end)));
            if ~isempty(pos_row_clin)
                % In case it's repeated, get final one (hopefully most
                % updated) % PENDING TO ADJUST THIS!
                if length(pos_row_clin) > 1
                    pos_row_clin = pos_row_clin(end);
                end
                % Hospitalization_ER_visits_psychiatric
                pos_column_clin = find(strcmp(table1_columns,'HOSPITALIZATION_ERVISITS_PSYCHIATRIC_'));
                if isempty(pos_column_clin); error(['No HOSPITALIZATION_ERVISITS_PSYCHIATRIC_ variable found']);end
                hosp_er_p_time = table2array(T1(pos_row_clin,pos_column_clin));
                if isdatetime(hosp_er_p_time)
                    hosp_er_p_time = {char(hosp_er_p_time)};
                end
                if strcmp(hosp_er_p_time,'NaT')
                    hosp_er_p_time = {[]};
                end

                % Individual_treatment
                pos_column_clin = find(strcmp(table1_columns,'INDIVIDUALTREATMENT'));
                if isempty(pos_column_clin); error(['No INDIVIDUALTREATMENT variable found']);end
                ind_treat_time = table2array(T1(pos_row_clin,pos_column_clin));
                if isdatetime(ind_treat_time)
                    ind_treat_time = {char(ind_treat_time)};
                end
                if strcmp(ind_treat_time,'NaT')
                    ind_treat_time = {[]};
                end
                % Date of first psychotic symptoms
                pos_column_clin = find(strcmp(table1_columns,'FPSSDATE'));
                if isempty(pos_column_clin); error(['No FPSSDATE variable found']);end
                fpssdate_time = table2array(T1(pos_row_clin,pos_column_clin));
                if isdatetime(fpssdate_time)
                    fpssdate_time = {char(fpssdate_time)};
                end
                if strcmp(fpssdate_time,'NaT')
                    fpssdate_time = {[]};
                end
                % Consent date (always same than Date_experiment)
                condate_time = {Date_experiment};
            else
                hosp_er_p_time = {[]};
                ind_treat_time = {[]};
                fpssdate_time = {[]};
                condate_time = {Date_experiment};
            end

            % Medication date
            pos_row_med = find(T6.RECID == str2double(participant{p}(5:end)) & T6.MEDCODE == 5);
            if ~isempty(pos_row_med) 
                % Retrieve dates from all these rows/entries
                list_med_dates = T6.STMED(pos_row_med);
                % Ensure they are in order
                list_med_dates = sortrows(list_med_dates,'ascend');
                % First one is earliest and put it in the same format than Date_experiment 
                earliest_med_date = {char(datetime(list_med_dates(1), 'InputFormat','MMM-dd-yyyy HH:mm:ss', 'Format','MM/dd/yyyy'))};
            else % Subject is not in that list
                earliest_med_date = {[]};
            end

            % Calculate based on Dean's criteria (mail on Monday, May 16, 2022)
            % DUP % Duration in days of untreated psychosis
            if isempty(fpssdate_time{:}) % Cannot calculate DUP
                DUP = [];
            else
                if ~isempty(earliest_med_date{:})
                    DUP = daysact(char(fpssdate_time), char(earliest_med_date));
                    if DUP < 0 % Should never be the case that they take meds before
                        DUP = [];
                    end
                else 
                    % Will use hosp_er_p_time and ind_treat_time
                    if ~isempty(hosp_er_p_time{:}) && ~isempty(ind_treat_time{:})
                        % If both are present, find which one is earlier
                        which_earlier = daysact(char(hosp_er_p_time), char(ind_treat_time));
                        if which_earlier > 0 % hosp_er_p_time is earlier
                            DUP = daysact(char(fpssdate_time), char(hosp_er_p_time));
                            if DUP < 0 % if hospitalization came before start of symptoms, something is odd
                                DUP = [];
                            end   
                        elseif which_earlier < 0 % ind_treat_time is earlier
                            DUP = daysact(char(fpssdate_time), char(ind_treat_time));
                            if DUP < 0 % if treatment came before start of symptoms, something is odd
                                DUP = [];
                            end
                        elseif which_earlier == 0 % same day
                            % Doesn't matter what we use then, use ind_treat_time
                            DUP = daysact(char(fpssdate_time), char(ind_treat_time));
                            if DUP < 0 % if hospitalization came before start of symptoms, something is odd
                                DUP = [];
                            end
                        end
                    elseif ~isempty(hosp_er_p_time{:}) && isempty(ind_treat_time{:}) % use hosp_er_p_time
                        DUP = daysact(char(fpssdate_time), char(hosp_er_p_time));
                        if DUP < 0 % if hospitalization came before start of symptoms, something is odd
                            DUP = [];
                        end   
                    elseif isempty(hosp_er_p_time{:}) && ~isempty(ind_treat_time{:}) % use ind_treat_time
                        DUP = daysact(char(fpssdate_time), char(ind_treat_time));
                        if DUP < 0 % if hospitalization came before start of symptoms, something is odd
                            DUP = [];
                        end
                    end
                end
            end

            % PSYCH2SCAN % Time in days since first clinical contact for psychosis to scan
            % For controls only, otherwise it will use consent date in C too
            if strcmp(participant_group{pg},'FE')
                if ~isempty(hosp_er_p_time{:})
                    PSYCH2SCAN = daysact(char(hosp_er_p_time), char(Date_experiment));
                    if PSYCH2SCAN < 0 % Should not happen, so do not define
                        PSYCH2SCAN = [];
                    end
                else
                    if ~isempty(ind_treat_time{:})
                        PSYCH2SCAN = daysact(char(ind_treat_time), char(Date_experiment));
                        if PSYCH2SCAN < 0 % Should not happen, so do not define
                            PSYCH2SCAN = [];
                        end
                    else
                        if ~isempty(condate_time{:})
                            PSYCH2SCAN = daysact(char(condate_time{:}), char(Date_experiment));
                            if PSYCH2SCAN < 0 % Should not happen, so do not define
                                PSYCH2SCAN = [];
                            end
                        else 
                            % We have no data to stablish this
                            PSYCH2SCAN = [];
                        end
                    end
                end
            elseif strcmp(participant_group{pg},'C')
                PSYCH2SCAN = [];
            end

            % MED2SCAN % Time in days since first medication started (if any) to scan
            if ~isempty(earliest_med_date{:})
                MED2SCAN = daysact(char(earliest_med_date), char(Date_experiment));
                if MED2SCAN < 0 % Medication started AFTER the experiment
                    MED2SCAN = [];
                end
            else
                MED2SCAN = [];
            end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Define row position based on size (grows with every subject)
            pos = size(Mega_matrix,1);
            % Store the measures in the column corresponding to the header
            for hc = 1:length(header_measures)
                % Which column will this value go
                col = find(strcmp(header_measures,header_measures{hc}));
                % Store variable (which has the same name as column)
                eval(['Mega_matrix{pos+1,col} = ' header_measures{hc} ';'])
            end
        end    
    end    
end

    % Add header to matrix
    Mega_variable_FFR = [header_measures; Mega_matrix];
    
    % Before saving, be sure that destiny folders exist
    if ~exist([root_dir '/Statistics/' gavr_name], 'dir')
        mkdir([root_dir '/Statistics/'], gavr_name);
    end
    
    % Store matrix before moving to next channel to average
    save([root_dir '/Statistics/' gavr_name '/Mega_variable_FFR_' channel_to_average{cha} '.mat'],'Mega_variable_FFR');
    % Write table in Excel
    Mega_variable = array2table(Mega_matrix,'VariableNames',header_measures);
    writetable(Mega_variable, [root_dir '/Statistics/' gavr_name '/Mega_variable_FFR_' channel_to_average{cha} '.xlsx'])
end

clearvars('-except', initialVars{:});
disp 'DONE WITH extracting values for statistics (FFR_Sz)!!!'
disp(datetime)
toc

%% Psychoacoustic plots

% I want white backgrounds
set(0,'defaultfigurecolor',[1 1 1]); 

% We will get the data from the Mega_variable, so define which one
gavr_name = 'GAVR_12C_vs_14FE'; % Stats based on subjects from this average
groups_to_plot = {'FE','C'};
channel_data = 'Cz'; % 'Cz', 'cluster' doesn't matter for psychoacoustics
deviation_measure = 'err'; % 'dev' or 'err' for standard dev or error
color_group_sind = [[255 0 0]/256;[0 0 0]/256]; % Specific for SIND
color_group_string = {[255 0 0]/256;[0 0 0]/256}; % Specific for SIND
Quiet_treshold_type = 'Original'; % 'Original' OR 'ChrLab'

% Psychoacoustic vars (may be more in the future)
if strcmp(Quiet_treshold_type,'ChrLab')  
    Quiet_thresholds_L = {'QT_L_125Hz', 'QT_L_250Hz', 'QT_L_500Hz', ...
        'QT_L_1000Hz', 'QT_L_2000Hz','QT_L_4000Hz','QT_L_8000Hz'};
    Quiet_thresholds_R = {'QT_R_125Hz', 'QT_R_250Hz', 'QT_R_500Hz', 'QT_R_1000Hz',...
        'QT_R_2000Hz', 'QT_R_4000Hz','QT_R_8000Hz'};
elseif strcmp(Quiet_treshold_type,'Original')  
    Quiet_thresholds_L = {'QuiT_L_1000', 'QuiT_L_1500', 'QuiT_L_2000', 'QuiT_L_3000', 'QuiT_L_4000'};
    Quiet_thresholds_R = {'QuiT_R_1000', 'QuiT_R_1500', 'QuiT_R_2000', 'QuiT_R_3000', 'QuiT_R_4000'};
end
FD = {'FD_250Hz', 'FD_1000Hz', 'FD_4000Hz'};
ITD = {'ITD_500Hz', 'ITD_1000Hz', 'ITD_2000Hz', 'ITD_4000Hz'};
MD = {'MD_4Hz', 'MD_16Hz', 'MD_64Hz'};
SIND = {'SIND'};
% May add more in the future

% Load mega_variable
load([root_dir '/Statistics/' gavr_name '/Mega_variable_FFR_' channel_data '.mat']);

% QUIET THRESHOLDS BUTTERFLY %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Left and right ear, FE and C
figure;
h(1) = subplot(2,2,1); h(2) = subplot(2,2,2); 
h(3) = subplot(2,2,3); h(4) = subplot(2,2,4); 
% Prepare variable to plot graph
for pg = 1:length(groups_to_plot)
    % Position of subject group
    group_col = find(strcmp(Mega_variable_FFR(1,:),'Group'));
    pos_group = find(strcmp(Mega_variable_FFR(:,group_col),groups_to_plot{pg}));
    participant = Mega_variable_FFR(pos_group,1);
    % We need a graph
    values_l = [];
    values_r = [];
for p = 1:length(participant)
for qt = 1:length(Quiet_thresholds_L) % Left and right should be the same
        % Position of the variable
        pos_l = find(strcmp(Mega_variable_FFR(1,:),Quiet_thresholds_L{qt}));
        pos_r = find(strcmp(Mega_variable_FFR(1,:),Quiet_thresholds_R{qt}));
        
        % Retrieve values
        if isempty(Mega_variable_FFR{pos_group(p),pos_l})
            values_l(p,qt) = NaN;
        else
            values_l(p,qt) = Mega_variable_FFR{pos_group(p),pos_l};
        end
        if isempty(Mega_variable_FFR{pos_group(p),pos_r})
            values_r(p,qt) = NaN;
        else
            values_r(p,qt) = Mega_variable_FFR{pos_group(p),pos_r};
        end
        
end   
end
    if pg == 1
        values = [values_l values_r];
        current_max = max(values(:));
        current_min = min(values(:));
    else
        values = [values_l values_r];
        if max(values(:)) > current_max; current_max = max(values(:)); end
        if min(values(:)) < current_min; current_min = min(values(:)); end
    end
    % See values
    if strcmp(groups_to_plot{pg},'FE')
        hold(h(3),'on')
        plot(h(3),values_l(:,:)','-s','MarkerSize',6,'LineWidth', 1.5);
        hLeg = legend(h(3),participant);
        set(hLeg,'visible','off')
        current_title = [groups_to_plot{pg} ' QT Left Ear'];
        title(h(3),current_title)
        hold(h(4),'on')
        plot(h(4),values_r(:,:)','-s','MarkerSize',6,'LineWidth', 1.5);
        hLeg = legend(h(4),participant);
        set(hLeg,'visible','off')
        current_title = [groups_to_plot{pg} ' QT Right Ear'];
        title(h(4),current_title)
    elseif strcmp(groups_to_plot{pg},'C')
        hold(h(1),'on')
        plot(h(1),values_l(:,:)','-s','MarkerSize',6,'LineWidth', 1.5);
        hLeg = legend(h(1),participant);
        set(hLeg,'visible','off')
        current_title = [groups_to_plot{pg} ' QT Left Ear'];
        title(h(1),current_title)
        hold(h(2),'on')
        plot(h(2),values_r(:,:)','-s','MarkerSize',6,'LineWidth', 1.5);
        hLeg = legend(h(2),participant);
        set(hLeg,'visible','off')
        current_title = [groups_to_plot{pg} ' QT Right Ear'];
        title(h(2),current_title)
    end
%         plot(Grafic_P2(1,:),'color', color_Exp_cond{1}/256, 'LineWidth', 1.5);
%         hold on; plot(values_l(:,:),'-s','MarkerSize',6,'MarkerEdgeColor',[255 0 0]/256,'MarkerFaceColor',[0 0 0]/256,'HandleVisibility','off')
end
% Uniform scales, add axes, titles, legend, etc.
for i = 1:4
    hold (h(i),'on')
    ylim(h(i),[floor(current_min),ceil(current_max)]);
    if strcmp(Quiet_treshold_type,'ChrLab')  
        xticklabels(h(i),{'125','250','500','1000','2000','8000'})
    elseif strcmp(Quiet_treshold_type,'Original')  
        xticklabels(h(i),{'1000','1500','2000','3000','4000'})
    end
    if i == 3
        ylabel(h(i),'Threshold (dB)')
        xlabel(h(i),'Frequency (Hz)');
    end
end

% QUIET THRESHOLDS GAVR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Left and right ear, FE and C
figure;
h(1) = subplot(1,2,1); h(2) = subplot(1,2,2); 
% Prepare variable to plot graph
for pg = 1:length(groups_to_plot)
    % Position of subject group
    group_col = find(strcmp(Mega_variable_FFR(1,:),'Group'));
    pos_group = find(strcmp(Mega_variable_FFR(:,group_col),groups_to_plot{pg}));
    participant = Mega_variable_FFR(pos_group,1);
    % We need a graph
    values_l = [];
    values_r = [];
for p = 1:length(participant)
for qt = 1:length(Quiet_thresholds_L) % Left and right should be the same
        % Position of the variable
        pos_l = find(strcmp(Mega_variable_FFR(1,:),Quiet_thresholds_L{qt}));
        pos_r = find(strcmp(Mega_variable_FFR(1,:),Quiet_thresholds_R{qt}));
        
        % Retrieve values
        if isempty(Mega_variable_FFR{pos_group(p),pos_l})
            values_l(p,qt) = NaN;
        else
            values_l(p,qt) = Mega_variable_FFR{pos_group(p),pos_l};
        end
        if isempty(Mega_variable_FFR{pos_group(p),pos_r})
            values_r(p,qt) = NaN;
        else
            values_r(p,qt) = Mega_variable_FFR{pos_group(p),pos_r};
        end
        
end   
end
    if pg == 1
        values = [values_l values_r];
        current_max = max(values(:));
        current_min = min(values(:));
    else
        values = [values_l values_r];
        if max(values(:)) > current_max; current_max = max(values(:)); end
        if min(values(:)) < current_min; current_min = min(values(:)); end
    end
    
    % Correct for NaN
    values_l = rmmissing(values_l);
    values_r = rmmissing(values_r);
    % Compute GAVR and STDEV/ERR
    values_l_average = mean(values_l,1);
    n(pg) = size(values_l,1); % for legend label
    values_r_average = mean(values_r,1);
    % n(pg) = size(values_r,1); % for legend label
    eval(['n' groups_to_plot{pg} ' = size(values_r,1);'])
    values_l_stdev = std(values_l,1);
    values_r_stdev = std(values_r,1);
    values_l_stderr = values_l_stdev/(sqrt(size(values_l,1)));
    values_r_stderr = values_r_stdev/(sqrt(size(values_r,1)));
    if strcmp(deviation_measure,'dev') 
        dev_l = values_l_stdev;
        dev_r = values_r_stdev;
    elseif strcmp(deviation_measure,'err')
        dev_l = values_l_stderr;
        dev_r = values_r_stderr;
    end

    if strcmp(groups_to_plot{pg},'FE')
        color_group = [255 0 0];
    elseif strcmp(groups_to_plot{pg},'C')
        color_group = [0 0 0];
    end
    hold(h(1),'on')
    plot(h(1),values_l_average','-s','MarkerSize',6,'color',color_group/256,'LineWidth', 1.5);
    if strcmp(Quiet_treshold_type,'ChrLab')  
        errorbar(h(1),[1 2 3 4 5 6 7],values_l_average,dev_l,'color', color_group/256,'HandleVisibility','off')
    elseif strcmp(Quiet_treshold_type,'Original')  
        errorbar(h(1),[1 2 3 4 5],values_l_average,dev_l,'color', color_group/256,'HandleVisibility','off')
    end
    current_title = 'QT Left Ear';
    title(h(1),current_title)
    hold(h(2),'on')
    plot(h(2),values_r_average','-s','MarkerSize',6,'color',color_group/256,'LineWidth', 1.5);
    if strcmp(Quiet_treshold_type,'ChrLab') 
        errorbar(h(2),[1 2 3 4 5 6 7],values_r_average,dev_r,'color', color_group/256,'HandleVisibility','off')
    elseif strcmp(Quiet_treshold_type,'Original') 
        errorbar(h(2),[1 2 3 4 5],values_r_average,dev_r,'color', color_group/256,'HandleVisibility','off')
    end 
    current_title = 'QT Right Ear';
    title(h(2),current_title)
end

% Build legend 
defined_legend = {};
for i = 1:length(participant_group)
    defined_legend{i} = [participant_group{i} ' (n = ' num2str(n(i)) ')'];
end
% Uniform scales, add axes, titles, legend, etc.
for i = 1:2
    hold (h(i),'on')
    ylim(h(i),[floor(current_min),ceil(current_max)]);
    if strcmp(Quiet_treshold_type,'ChrLab') 
        xticklabels(h(i),{'125','250','500','1000','2000','8000'})
    elseif strcmp(Quiet_treshold_type,'Original') 
        xticklabels(h(i),{'1000','1500','2000','3000','4000'})
    end
    if i == 1
        hLeg = legend(h(i),defined_legend);
        ylabel(h(i),'Threshold (dB)');
        xlabel(h(i),'Frequency (Hz)');
    end
end

% FREQ THRESHOLDS BUTTERFLY %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FE and C
figure;
h(1) = subplot(1,2,1); h(2) = subplot(1,2,2); 
% Prepare variable to plot graph
for pg = 1:length(groups_to_plot)
    % Position of subject group
    group_col = find(strcmp(Mega_variable_FFR(1,:),'Group'));
    pos_group = find(strcmp(Mega_variable_FFR(:,group_col),groups_to_plot{pg}));
    participant = Mega_variable_FFR(pos_group,1);
    % We need a graph
    values = [];
for p = 1:length(participant)
for qt = 1:length(FD)
    % Position of the variable
    pos = find(strcmp(Mega_variable_FFR(1,:),FD{qt}));

    % Retrieve values
    if isempty(Mega_variable_FFR{pos_group(p),pos})
        values(p,qt) = NaN;
    else
        values(p,qt) = Mega_variable_FFR{pos_group(p),pos};
    end        
end   
end
    if pg == 1
        current_max = max(values(:));
        current_min = min(values(:));
    else
        if max(values(:)) > current_max; current_max = max(values(:)); end
        if min(values(:)) < current_min; current_min = min(values(:)); end
    end
    % Plot
    if strcmp(groups_to_plot{pg},'FE')
        hold(h(2),'on')
        plot(h(2),values(:,:)','-s','MarkerSize',6,'LineWidth', 1.5);
        hLeg = legend(h(2),participant);
        set(hLeg,'visible','off')
        current_title = [groups_to_plot{pg} ' FD'];
        title(h(2),current_title)
    elseif strcmp(groups_to_plot{pg},'C')
        hold(h(1),'on')
        plot(h(1),values(:,:)','-s','MarkerSize',6,'LineWidth', 1.5);
        hLeg = legend(h(1),participant);
        set(hLeg,'visible','off')
        current_title = [groups_to_plot{pg} ' FD'];
        title(h(1),current_title)
    end
end
% Uniform scales, add axes, titles, legend, etc.
for i = 1:2
    hold (h(i),'on')
    ylim(h(i),[floor(current_min),ceil(current_max)]);
    NumTicks = 3;
    L = get(h(i),'XLim');
    set(h(i),'XTick',linspace(L(1),L(2),NumTicks))
    xticklabels(h(i),{'250','1000','4000'})
    if i == 1
        ylabel(h(i),'Smallest detectable diff (Hz)')
        xlabel(h(i),'Frequency (Hz)');
    end
end

% FD THRESHOLDS GAVR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FE and C
figure; 
% Prepare variable to plot graph
for pg = 1:length(groups_to_plot)
    % Position of subject group
    group_col = find(strcmp(Mega_variable_FFR(1,:),'Group'));
    pos_group = find(strcmp(Mega_variable_FFR(:,group_col),groups_to_plot{pg}));
    participant = Mega_variable_FFR(pos_group,1);
    % We need a graph
    values = [];
for p = 1:length(participant)
for qt = 1:length(FD) % Left and right should be the same
        % Position of the variable
        pos = find(strcmp(Mega_variable_FFR(1,:),FD{qt}));
        
        % Retrieve values
        if isempty(Mega_variable_FFR{pos_group(p),pos})
            values(p,qt) = NaN;
        else
            values(p,qt) = Mega_variable_FFR{pos_group(p),pos};
        end
        
end   
end
    if pg == 1
        current_max = max(values(:));
        current_min = min(values(:));
    else
        if max(values(:)) > current_max; current_max = max(values(:)); end
        if min(values(:)) < current_min; current_min = min(values(:)); end
    end
    
    % Correct for NaN
    values = rmmissing(values);
    n(pg) = size(values,1); % For legend
    % Compute GAVR and STDEV/ERR
    values_average = mean(values,1);
    values_stdev = std(values,1);
    values_stderr = values_stdev/(sqrt(size(values,1)));
    if strcmp(deviation_measure,'dev') 
        dev = values_stdev;
    elseif strcmp(deviation_measure,'err')
        dev = values_stderr;
    end

    if strcmp(groups_to_plot{pg},'FE')
        color_group = [255 0 0];
    elseif strcmp(groups_to_plot{pg},'C')
        color_group = [0 0 0];
    end
    plot(values_average','-s','MarkerSize',6,'color',color_group/256,'LineWidth', 1.5);
    hold on
    errorbar([1 2 3],values_average,dev,'color', color_group/256,'HandleVisibility','off')
    current_title = 'Frequency discrimination thresholds';
    title(current_title)
end
% Uniform scales, add axes, titles, legend, etc.
hold on
ylim([floor(current_min),ceil(current_max)]);
NumTicks = 3;
L = get(gca,'XLim');
set(gca,'XTick',linspace(L(1),L(2),NumTicks))
xticklabels({'250','1000','4000'})
set(gca,'XLim',[0.5 3.5]); 
% Build legend 
defined_legend = {};
for i = 1:length(participant_group)
    defined_legend{i} = [participant_group{i} ' (n = ' num2str(n(i)) ')'];
end
legend(defined_legend);
ylabel('Smallest detectable diff (Hz)')
xlabel('Frequency (Hz)');

% AMP MODULATION THRESHOLDS BUTTERFLY %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FE and C
figure;
h(1) = subplot(1,2,1); h(2) = subplot(1,2,2); 
% Prepare variable to plot graph
for pg = 1:length(groups_to_plot)
    % Position of subject group
    group_col = find(strcmp(Mega_variable_FFR(1,:),'Group'));
    pos_group = find(strcmp(Mega_variable_FFR(:,group_col),groups_to_plot{pg}));
    participant = Mega_variable_FFR(pos_group,1);
    % We need a graph
    values = [];
for p = 1:length(participant)
for qt = 1:length(MD)
    % Position of the variable
    pos = find(strcmp(Mega_variable_FFR(1,:),MD{qt}));

    % Retrieve values
    if isempty(Mega_variable_FFR{pos_group(p),pos})
        values(p,qt) = NaN;
    else
        values(p,qt) = Mega_variable_FFR{pos_group(p),pos};
    end        
end   
end
    if pg == 1
        current_max = max(values(:));
        current_min = min(values(:));
    else
        if max(values(:)) > current_max; current_max = max(values(:)); end
        if min(values(:)) < current_min; current_min = min(values(:)); end
    end
    % Plot
    if strcmp(groups_to_plot{pg},'FE')
        hold(h(2),'on')
        plot(h(2),values(:,:)','-s','MarkerSize',6,'LineWidth', 1.5);
        hLeg = legend(h(2),participant);
        set(hLeg,'visible','off')
        current_title = [groups_to_plot{pg} ' MD'];
        title(h(2),current_title)
    elseif strcmp(groups_to_plot{pg},'C')
        hold(h(1),'on')
        plot(h(1),values(:,:)','-s','MarkerSize',6,'LineWidth', 1.5);
        hLeg = legend(h(1),participant);
        set(hLeg,'visible','off')
        current_title = [groups_to_plot{pg} ' MD'];
        title(h(1),current_title)
    end
end
% Uniform scales, add axes, titles, legend, etc.
for i = 1:2
    hold (h(i),'on')
    ylim(h(i),[floor(current_min),ceil(current_max)]);
    NumTicks = 3;
    L = get(h(i),'XLim');
    set(h(i),'XTick',linspace(L(1),L(2),NumTicks))
    xticklabels(h(i),{'4','16','64'})
    if i == 1
        ylabel(h(i),'Smallest detectable diff (dB)')
        xlabel(h(i),'Frequency (Hz)');
    end
end

% AMP MODULATION THRESHOLDS GAVR %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FE and C
figure; 
% Prepare variable to plot graph
for pg = 1:length(groups_to_plot)
    % Position of subject group
    group_col = find(strcmp(Mega_variable_FFR(1,:),'Group'));
    pos_group = find(strcmp(Mega_variable_FFR(:,group_col),groups_to_plot{pg}));
    participant = Mega_variable_FFR(pos_group,1);
    % We need a graph
    values = [];
for p = 1:length(participant)
for qt = 1:length(MD) % Left and right should be the same
        % Position of the variable
        pos = find(strcmp(Mega_variable_FFR(1,:),MD{qt}));
        
        % Retrieve values
        if isempty(Mega_variable_FFR{pos_group(p),pos})
            values(p,qt) = NaN;
        else
            values(p,qt) = Mega_variable_FFR{pos_group(p),pos};
        end
        
end   
end
    if pg == 1
        current_max = max(values(:));
        current_min = min(values(:));
    else
        if max(values(:)) > current_max; current_max = max(values(:)); end
        if min(values(:)) < current_min; current_min = min(values(:)); end
    end
    
    % Correct for NaN
    values = rmmissing(values);
    % Compute GAVR and STDEV/ERR
    n(pg) = size(values,1);
    values_average = mean(values,1);
    values_stdev = std(values,1);
    values_stderr = values_stdev/(sqrt(size(values,1)));
    if strcmp(deviation_measure,'dev') 
        dev = values_stdev;
    elseif strcmp(deviation_measure,'err')
        dev = values_stderr;
    end

    if strcmp(groups_to_plot{pg},'FE')
        color_group = [255 0 0];
    elseif strcmp(groups_to_plot{pg},'C')
        color_group = [0 0 0];
    end
    plot(values_average','-s','MarkerSize',6,'color',color_group/256,'LineWidth', 1.5);
    hold on
    errorbar([1 2 3],values_average,dev,'color', color_group/256,'HandleVisibility','off')
    current_title = 'Amplitude modulation discrimination thresholds';
    title(current_title)
end
% Uniform scales, add axes, titles, legend, etc.
hold on
ylim([floor(current_min),ceil(current_max)]);
NumTicks = 3;
L = get(gca,'XLim');
set(gca,'XTick',linspace(L(1),L(2),NumTicks))
xticklabels({'4','16','64'})
set(gca,'XLim',[0.5 3.5]); 
% Build legend 
defined_legend = {};
for i = 1:length(participant_group)
    defined_legend{i} = [participant_group{i} ' (n = ' num2str(n(i)) ')'];
end
legend(defined_legend);
ylabel('Smallest detectable diff (dB)')
xlabel('Frequency (Hz)');

% ITD THRESHOLDS BUTTERFLY %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FE and C
figure;
h(1) = subplot(1,2,1); h(2) = subplot(1,2,2); 
% Prepare variable to plot graph
for pg = 1:length(groups_to_plot)
    % Position of subject group
    group_col = find(strcmp(Mega_variable_FFR(1,:),'Group'));
    pos_group = find(strcmp(Mega_variable_FFR(:,group_col),groups_to_plot{pg}));
    participant = Mega_variable_FFR(pos_group,1);
    % We need a graph
    values = [];
for p = 1:length(participant)
for qt = 1:length(ITD)
    % Position of the variable
    pos = find(strcmp(Mega_variable_FFR(1,:),ITD{qt}));

    % Retrieve values
    if isempty(Mega_variable_FFR{pos_group(p),pos})
        values(p,qt) = NaN;
    else
        values(p,qt) = Mega_variable_FFR{pos_group(p),pos};
    end        
end   
end
    if pg == 1
        current_max = max(values(:));
        current_min = min(values(:));
    else
        if max(values(:)) > current_max; current_max = max(values(:)); end
        if min(values(:)) < current_min; current_min = min(values(:)); end
    end
    % Plot
    if strcmp(groups_to_plot{pg},'FE')
        hold(h(2),'on')
        plot(h(2),values(:,:)','-s','MarkerSize',6,'LineWidth', 1.5);
        hLeg = legend(h(2),participant);
        set(hLeg,'visible','off')
        current_title = [groups_to_plot{pg} ' ITD'];
        title(h(2),current_title)
    elseif strcmp(groups_to_plot{pg},'C')
        hold(h(1),'on')
        plot(h(1),values(:,:)','-s','MarkerSize',6,'LineWidth', 1.5);
        hLeg = legend(h(1),participant);
        set(hLeg,'visible','off')
        current_title = [groups_to_plot{pg} ' ITD'];
        title(h(1),current_title)
    end
end
% Uniform scales, add axes, titles, legend, etc.
for i = 1:2
    hold (h(i),'on')
    ylim(h(i),[floor(current_min),ceil(current_max)]);
    NumTicks = 4;
    L = get(h(i),'XLim');
    set(h(i),'XTick',linspace(L(1),L(2),NumTicks))
    xticklabels(h(i),{'500','1000','2000','4000'})
    if i == 1
        ylabel(h(i),'Smallest detectable diff (?s)')
        xlabel(h(i),'Frequency (Hz)');
    end
end

% ITD THRESHOLDS GAVR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FE and C
figure; 
% Prepare variable to plot graph
for pg = 1:length(groups_to_plot)
    % Position of subject group
    group_col = find(strcmp(Mega_variable_FFR(1,:),'Group'));
    pos_group = find(strcmp(Mega_variable_FFR(:,group_col),groups_to_plot{pg}));
    participant = Mega_variable_FFR(pos_group,1);
    % We need a graph
    values = [];
for p = 1:length(participant)
for qt = 1:length(ITD) % Left and right should be the same
        % Position of the variable
        pos = find(strcmp(Mega_variable_FFR(1,:),ITD{qt}));
        
        % Retrieve values
        if isempty(Mega_variable_FFR{pos_group(p),pos})
            values(p,qt) = NaN;
        else
            values(p,qt) = Mega_variable_FFR{pos_group(p),pos};
        end
        
end   
end
    if pg == 1
        current_max = max(values(:));
        current_min = min(values(:));
    else
        if max(values(:)) > current_max; current_max = max(values(:)); end
        if min(values(:)) < current_min; current_min = min(values(:)); end
    end
    
    % Correct for NaN
    values = rmmissing(values);
    % Compute GAVR and STDEV/ERR
    n(pg) = size(values,1);
    values_average = mean(values,1);
    values_stdev = std(values,1);
    values_stderr = values_stdev/(sqrt(size(values,1)));
    if strcmp(deviation_measure,'dev') 
        dev = values_stdev;
    elseif strcmp(deviation_measure,'err')
        dev = values_stderr;
    end

    if strcmp(groups_to_plot{pg},'FE')
        color_group = [255 0 0];
    elseif strcmp(groups_to_plot{pg},'C')
        color_group = [0 0 0];
    end
    plot(values_average','-s','MarkerSize',6,'color',color_group/256,'LineWidth', 1.5);
    hold on
    errorbar([1 2 3 4],values_average,dev,'color', color_group/256,'HandleVisibility','off')
    current_title = 'ITD discrimination thresholds';
    title(current_title)
end
% Uniform scales, add axes, titles, legend, etc.
hold on
ylim([floor(current_min),ceil(current_max)]);
NumTicks = 4;
L = get(gca,'XLim');
set(gca,'XTick',linspace(L(1),L(2),NumTicks))
xticklabels({'500','1000','2000','4000'})
set(gca,'XLim',[0.5 4.5]); 
% Build legend 
defined_legend = {};
for i = 1:length(participant_group)
    defined_legend{i} = [participant_group{i} ' (n = ' num2str(n(i)) ')'];
end
legend(defined_legend);
ylabel('Smallest detectable diff (?s)')
xlabel('Frequency (Hz)');

% SIND BUTTERFLY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 1 == 1 % Silly wat to compress section
pos_measu = find(strcmp(Mega_variable_FFR(1,:),'SIND'));
table_scatter = [];
for pg = 1:length(groups_to_plot)
    group_indices = find(strcmp(Mega_variable_FFR(:,2),groups_to_plot{pg}));
    for i = 1:length(group_indices)
        if isempty(Mega_variable_FFR{group_indices(i),pos_measu})
            table_scatter(i,pg) = NaN;
        else
            table_scatter(i,pg) = Mega_variable_FFR{group_indices(i),pos_measu};
        end
    end
end

% If different numbers of C and FE, it adds zeros to complete tables, correct for that
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if length(groups_to_plot) ~= 2 % Just to be sure in case we include chronics
    error('If using more than two groups, reprogram next lines');
end
for pg = 1:length(groups_to_plot)
    eval(['group_indices_' num2str(pg) ' = find(strcmp(Mega_variable_FFR(:,2),groups_to_plot{pg}));'])
end
% If they are the same size it won't do anything
if length(group_indices_1) > length(group_indices_2)
    difference =  length(group_indices_1) - length(group_indices_2);
    % So this means first column is 'difference' rows longer than second 
    table_scatter(end+1-difference:end,2) = NaN;
    % Therefore those 'extra' positions at the end of columnn 2 are NaN
elseif length(group_indices_2) > length(group_indices_1)
    difference = length(group_indices_2) - length(group_indices_1);
    % So this means second column is 'difference' rows longer than first 
    table_scatter(end+1-difference:end,1) = NaN;
    % Therefore those 'extra' positions at the end of columnn 1 are NaN
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compute an independent sample t test and retrieve p value
[~,p_value,~,t_stats] = ttest2(table_scatter(:,1),table_scatter(:,2));
% Get mean values
mean_plot_left = nanmean(table_scatter(:,1));
mean_plot_right = nanmean(table_scatter(:,2));

% Get std dev (for later use in GAVR)
stddev_plot_left = nanstd(table_scatter(:,1));
stddev_plot_right = nanstd(table_scatter(:,2));

% Get std err (for later use in GAVR)
size1 = sum(~isnan(table_scatter(:,1)),1);
size2 = sum(~isnan(table_scatter(:,2)),1);
stderr_plot_left = stddev_plot_left/(sqrt(size1));
stderr_plot_right = stddev_plot_right/(sqrt(size2));

point_settings = {'MarkerFaceColor',color_group_sind,'MarkerEdgeColor','white','PointSize',80,'LineWidth',1};
plot_settings = [point_settings]; % Something weird about additional wiskers (in case needed)
figure;
[xPositions, yPositions, Label, RangeCut, FigHandles] = UnivarScatter(table_scatter,plot_settings{:});

% set(gcf,'Position',[0,0,600,300])
set(gcf,'Position',[500,250,300,300])
y_title = 'SNR needed for 50% correct words';
y_title = strrep(y_title,'_',' ');
ylabel(y_title); 
xticklabels(groups_to_plot) 
h=gca; h.XAxis.TickLength = [0 0];
h.YGrid = 'on';
h.GridLineStyle = '--';

% Add p value text
if p_value < 0.05
    color_p_value = 'red';
else
    color_p_value = 'black';
end
if p_value < 0.001
    label_pvalue = 'p < 0.001';
else
    str_pvalue = num2str(p_value);
    label_pvalue = ['p = ' str_pvalue(1:5)];
end
title({['\color{' color_p_value '}' label_pvalue '']})

% Add longer mean lines
hold on;
x_values = xlim;
plot([x_values(1)+x_values(1)*0.25 x_values(2)-x_values(2)*0.45],[mean_plot_left,mean_plot_left],'LineWidth',3,'color',[0.5 0.5 0.5 0.5]);
hold on;
plot([x_values(2)-x_values(2)*0.35 x_values(2)-x_values(2)*0.05],[mean_plot_right,mean_plot_right],'LineWidth',3,'color',[0.5 0.5 0.5 0.5]);
end

% SIND GAVR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 1 == 1 % silly way to compress into a section
model_series = [mean_plot_left; mean_plot_right];
%Data to be plotted as the error bars
if strcmp(deviation_measure,'dev')
    model_error = [stddev_plot_left; stddev_plot_right]; 
elseif strcmp(deviation_measure,'err')
    model_error = [stderr_plot_left; stderr_plot_right]; 
end

figure;
hold on
for i = 1:length(model_series)
    h=bar(i,model_series(i));
    h.FaceColor = color_group_string{i};
end
set(gca, 'FontSize',12,'XTick',[1 2],'XTickLabel',{['FE (n =  ' num2str(size1) ')'],['C (n = ' num2str(size2) ')']});
ylabel('SNR needed for 50% correct words')
% Finding the number of groups and the number of bars in each group
ngroups = size(model_series, 1);
nbars = size(model_series, 2);
% Calculating the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));
hold on
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, model_series(:,i), model_error(:,i), 'Color', [0.5 0.5 0.5] , 'linestyle', 'none','HandleVisibility','off');
end
hold off
end

%% Correlations of EEG with neuropsychology/clinical/psychoacoustics/struct

% I want white backgrounds
set(0,'defaultfigurecolor',[1 1 1]); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MODIFY THIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
group_to_plot = 'FE'; % 'FE', 'C', 'ALL' % string
gavr_name = 'GAVR_12C_vs_14FE'; % Stats based on subjects from this average
% GAVR_11C_vs_12FE (largest "FFR but not necessarily psychoacoustics" sample without outliers)
% GAVR_SIN (only those who have SIN)
% GAVR_AMP (only  those who have at least all but SIN)
Quiet_treshold_type = 'Original'; % 'ChrLab' OR 'Original'
plot_only_significant_ones = 1; 
p_threshold = 0.1;
% GAVR_12C_vs_10FE
channel_data = 'Cz'; % 'Cz', 'cluster' string
Brain_signal = 'FFR'; % 'FFR' 'LLR'
FFR_section = 'Constant'; % If FFR, specify: % 'Transient', 'Constant', 'Total'
FFR_freq = 'high'; % 'low', 'medium', 'high'
% Which scales (matching vars, neuropsychology, clinical, psychoacoustics)
Correlate_with = 'psychoacoustics'; 
% 'matching_vars', 'neuropsychology', 'clinical', clinical_composite, 
% duration_of_illness, medication 'psychoacoustics','psychoacoustics_average'
specific_brain_signal = {}; % Empty ({}) by default: e.g. 'F0_SNR_low_Constant' (will cancel previous) % 'STR_xcorr_high','neur_lag_high'
% 'FD_average','MD_average'
specific_correlate_with = {}; % Empty ({}) by default: e.g. 'ROLEHIGH' (will cancel previous)
% 'FD_average','ITD_average','QT_L_average','QT_R_average','SIND','MD_average'
% 'PANSSP_RS',...
%     'PANSS_Affect','PANSS_Disorg','PANSS_Negative','PANSS_Positive','PANSS_Resistance',...
%     'BPRS_Total','BPRS_Positive','BPRS_Negative','BPRS_DeprAnx','BPRS_ActMania','BPRS_HostSusp'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% All variables
if strcmp(Quiet_treshold_type,'ChrLab')  
header_measures = {'Subj','Group',...
    'RMS_low_Baseline','RMS_low_Transient','RMS_low_Constant','RMS_low_Total',...
    'AMP_SNR_low_Transient','AMP_SNR_low_Constant','AMP_SNR_low_Total',...
    'STR_xcorr_low','neur_lag_low',...
    'pitch_err_low','pitch_str_low',...
    'F0_peak_low_Baseline','F0_peak_low_Transient','F0_peak_low_Constant','F0_peak_low_Total',...
    'F0_SNR_low_Baseline','F0_SNR_low_Transient','F0_SNR_low_Constant','F0_SNR_low_Total',...
    'RMS_medium_Baseline','RMS_medium_Transient','RMS_medium_Constant','RMS_medium_Total',...
    'AMP_SNR_medium_Transient','AMP_SNR_medium_Constant','AMP_SNR_medium_Total',...
    'STR_xcorr_medium','neur_lag_medium',...
    'pitch_err_medium','pitch_str_medium',...
    'F0_peak_medium_Baseline','F0_peak_medium_Transient','F0_peak_medium_Constant','F0_peak_medium_Total',...
    'F0_SNR_medium_Baseline','F0_SNR_medium_Transient','F0_SNR_medium_Constant','F0_SNR_medium_Total',...
    'RMS_high_Baseline','RMS_high_Transient','RMS_high_Constant','RMS_high_Total',...
    'AMP_SNR_high_Transient','AMP_SNR_high_Constant','AMP_SNR_high_Total',...
    'STR_xcorr_high','neur_lag_high',...
    'pitch_err_high','pitch_str_high',...
    'F0_peak_high_Baseline','F0_peak_high_Transient','F0_peak_high_Constant','F0_peak_high_Total',...
    'F0_SNR_high_Baseline','F0_SNR_high_Transient','F0_SNR_high_Constant','F0_SNR_high_Total',...
    'LLR_400ms_P50','LLR_400ms_N1','LLR_400ms_P2',...
    'LLR_1s_P50','LLR_1s_N1','LLR_1s_P2',...
    'AGE','SEX','VOCAB_TS','PSES',... % FOR MATCHING
    'OVERALLTSCR','MATRIX_TS','FULL2IQ',... % NEUROPSYCHO TESTS
    'SPEEDTSCR', 'ATT_VIGTSCR', 'WMTSCR', 'VERBTSCR', 'VISTSCR', 'RPSTSCR', 'SOCCOGTSCR','SANITM',...
    'SAPITM', 'ROLECURR', 'ROLELOW', 'ROLEHIGH', 'SOCIALCURR', 'SOCIALLOW', 'SOCIALHIGH','SFS_WITHDRAW_RS',...
    'SFS_INTERACT_RS', 'SFS_RECREAT_RS', 'SFS_OCCUP_RS', 'SFS_IND_PERF_RS', 'SFS_IND_COMP_RS','SFS_PROSOC_RS',...
    'PANSSP_RS', 'PANSSN_RS', 'PANSST_RS','PSYRATS_AUD_HALL', 'PSYRATS_DELUSIONS',... % CLINICAL TESTS
    'PANSS_Affect','PANSS_Disorg','PANSS_Negative','PANSS_Positive','PANSS_Resistance',... % COMPOSITE SCORES
    'P3','SANSSAPS_Level7_AudHall','SANSSAPS_Level4_RealityDis','BPRS_Positive',...
    'QT_L_125Hz', 'QT_L_250Hz', 'QT_L_500Hz', 'QT_L_1000Hz', 'QT_L_2000Hz', 'QT_L_4000Hz',... % PSYCHOACOUSTICS
    'QT_L_8000Hz','QT_R_125Hz', 'QT_R_250Hz', 'QT_R_500Hz', 'QT_R_1000Hz', 'QT_R_2000Hz', 'QT_R_4000Hz',...
    'QT_R_8000Hz','FD_250Hz', 'FD_1000Hz', 'FD_4000Hz', 'ITD_500Hz', 'ITD_1000Hz', 'ITD_2000Hz', 'ITD_4000Hz',...
    'MD_4Hz', 'MD_16Hz', 'MD_64Hz', 'SIND',...
    'QT_L_average','QT_R_average','FD_average','ITD_average',...
    'DAYS_SINCE_PRDM','DAYS_SINCE_1STEP','DAYS_SINCE_DISOR',...
    'SFS_Mean', 'HVLTRRAWSUM', 'HVLTRTSCR', 'FLUENRAW', 'FLUENTSCR'}; % DURATION OF ILLNESS (IN DAYS)
elseif strcmp(Quiet_treshold_type,'Original')  
    header_measures = {'Subj','Group',...
    'RMS_low_Baseline','RMS_low_Transient','RMS_low_Constant','RMS_low_Total',...
    'AMP_SNR_low_Transient','AMP_SNR_low_Constant','AMP_SNR_low_Total',...
    'STR_xcorr_low','neur_lag_low',...
    'pitch_err_low','pitch_str_low',...
    'F0_peak_low_Baseline','F0_peak_low_Transient','F0_peak_low_Constant','F0_peak_low_Total',...
    'F0_SNR_low_Baseline','F0_SNR_low_Transient','F0_SNR_low_Constant','F0_SNR_low_Total',...
    'RMS_medium_Baseline','RMS_medium_Transient','RMS_medium_Constant','RMS_medium_Total',...
    'AMP_SNR_medium_Transient','AMP_SNR_medium_Constant','AMP_SNR_medium_Total',...
    'STR_xcorr_medium','neur_lag_medium',...
    'pitch_err_medium','pitch_str_medium',...
    'F0_peak_medium_Baseline','F0_peak_medium_Transient','F0_peak_medium_Constant','F0_peak_medium_Total',...
    'F0_SNR_medium_Baseline','F0_SNR_medium_Transient','F0_SNR_medium_Constant','F0_SNR_medium_Total',...
    'RMS_high_Baseline','RMS_high_Transient','RMS_high_Constant','RMS_high_Total',...
    'AMP_SNR_high_Transient','AMP_SNR_high_Constant','AMP_SNR_high_Total',...
    'STR_xcorr_high','neur_lag_high',...
    'pitch_err_high','pitch_str_high',...
    'F0_peak_high_Baseline','F0_peak_high_Transient','F0_peak_high_Constant','F0_peak_high_Total',...
    'F0_SNR_high_Baseline','F0_SNR_high_Transient','F0_SNR_high_Constant','F0_SNR_high_Total',...
    'LLR_400ms_P50','LLR_400ms_N1','LLR_400ms_P2',...
    'LLR_1s_P50','LLR_1s_N1','LLR_1s_P2',...
    'AGE','SEX','VOCAB_TS','PSES',... % FOR MATCHING
    'OVERALLTSCR','MATRIX_TS','FULL2IQ',... % NEUROPSYCHO TESTS
    'SPEEDTSCR', 'ATT_VIGTSCR', 'WMTSCR', 'VERBTSCR', 'VISTSCR', 'RPSTSCR', 'SOCCOGTSCR','SANITM',...
    'SAPITM', 'ROLECURR', 'ROLELOW', 'ROLEHIGH', 'SOCIALCURR', 'SOCIALLOW', 'SOCIALHIGH','SFS_WITHDRAW_RS',...
    'SFS_INTERACT_RS', 'SFS_RECREAT_RS', 'SFS_OCCUP_RS', 'SFS_IND_PERF_RS', 'SFS_IND_COMP_RS','SFS_PROSOC_RS',...
    'PANSSP_RS', 'PANSSN_RS', 'PANSST_RS','PSYRATS_AUD_HALL', 'PSYRATS_DELUSIONS',... % CLINICAL TESTS
    'PANSS_Affect','PANSS_Disorg','PANSS_Negative','PANSS_Positive','PANSS_Resistance',... % COMPOSITE SCORES
    'P3','SANSSAPS_Level7_AudHall','SANSSAPS_Level4_RealityDis','BPRS_Positive',...
    'QuiT_L_1000', 'QuiT_L_1500', 'QuiT_L_2000', 'QuiT_L_3000', 'QuiT_L_4000',... % PSYCHOACOUSTICS
    'QuiT_R_1000', 'QuiT_R_1500', 'QuiT_R_2000', 'QuiT_R_3000', 'QuiT_R_4000',...
    'FD_250Hz', 'FD_1000Hz', 'FD_4000Hz', 'ITD_500Hz', 'ITD_1000Hz', 'ITD_2000Hz', 'ITD_4000Hz',...
    'MD_4Hz', 'MD_16Hz', 'MD_64Hz', 'SIND',...
    'QT_L_average','QT_R_average','FD_average','ITD_average',...
    'DAYS_SINCE_PRDM','DAYS_SINCE_1STEP','DAYS_SINCE_DISOR',...
    'SFS_Mean', 'HVLTRRAWSUM', 'HVLTRTSCR', 'FLUENRAW', 'FLUENTSCR'}; % DURATION OF ILLNESS (IN DAYS)
end

% Define Brain measures
if isempty(specific_brain_signal)
if strcmp(Brain_signal,'FFR')
% Define FFR measures
    if strcmp(FFR_freq, 'low') && strcmp(FFR_section, 'Transient')
        corr_A = {'RMS_low_Transient','AMP_SNR_low_Transient',...
            'STR_xcorr_low','neur_lag_low',...
            'F0_peak_low_Transient','F0_SNR_low_Transient','STR_xcorr_low','neur_lag_low'};
        % 'pitch_err_low','pitch_str_low'
    elseif strcmp(FFR_freq, 'low') && strcmp(FFR_section, 'Constant')
        corr_A = {'RMS_low_Constant','AMP_SNR_low_Constant',...
            'STR_xcorr_low','neur_lag_low',...
            'F0_peak_low_Constant','F0_SNR_low_Constant','STR_xcorr_low','neur_lag_low'};
        % 'pitch_err_low','pitch_str_low'
    elseif strcmp(FFR_freq, 'low') && strcmp(FFR_section, 'Total')
        corr_A = {'RMS_low_Total','AMP_SNR_low_Total',...
            'STR_xcorr_low','neur_lag_low',...
            'F0_peak_low_Total','F0_SNR_low_Total','STR_xcorr_low','neur_lag_low'};
        % 'pitch_err_low','pitch_str_low'
    elseif strcmp(FFR_freq, 'medium') && strcmp(FFR_section, 'Transient')
        corr_A = {'RMS_medium_Transient','AMP_SNR_medium_Transient',...
            'STR_xcorr_medium','neur_lag_medium',...
            'F0_peak_medium_Transient','F0_SNR_medium_Transient','STR_xcorr_medium','neur_lag_medium'};
        % 'pitch_err_medium','pitch_str_medium'
    elseif strcmp(FFR_freq, 'medium') && strcmp(FFR_section, 'Constant')
        corr_A = {'RMS_medium_Constant','AMP_SNR_medium_Constant',...
            'STR_xcorr_medium','neur_lag_medium',...
            'F0_peak_medium_Constant','F0_SNR_medium_Constant','STR_xcorr_medium','neur_lag_medium'};
        % 'pitch_err_medium','pitch_str_medium'
    elseif strcmp(FFR_freq, 'medium') && strcmp(FFR_section, 'Total')
        corr_A = {'RMS_medium_Total','AMP_SNR_medium_Total',...
            'STR_xcorr_medium','neur_lag_medium',...
            'F0_peak_medium_Total','F0_SNR_medium_Total','STR_xcorr_medium','neur_lag_medium'};
        % 'pitch_err_medium','pitch_str_medium'
    elseif strcmp(FFR_freq, 'high') && strcmp(FFR_section, 'Transient')
        corr_A = {'RMS_high_Transient','AMP_SNR_high_Transient',...
            'STR_xcorr_high','neur_lag_high',...
            'F0_peak_high_Transient','F0_SNR_high_Transient','STR_xcorr_high','neur_lag_high'};
        % 'pitch_err_high','pitch_str_high'
    elseif strcmp(FFR_freq, 'high') && strcmp(FFR_section, 'Constant')
        corr_A = {'RMS_high_Constant','AMP_SNR_high_Constant',...
            'STR_xcorr_high','neur_lag_high',...
            'F0_peak_high_Constant','F0_SNR_high_Constant','STR_xcorr_high','neur_lag_high'};
        % 'pitch_err_high','pitch_str_high'
    elseif strcmp(FFR_freq, 'high') && strcmp(FFR_section, 'Total')
        corr_A = {'RMS_high_Total','AMP_SNR_high_Total',...
            'STR_xcorr_high','neur_lag_high',...
            'F0_peak_high_Total','F0_SNR_high_Total','STR_xcorr_high','neur_lag_high'};
        % 'pitch_err_high','pitch_str_high'
    end
elseif strcmp(Brain_signal,'LLR')
    % Define LLR measures
    corr_A = {'LLR_400ms_P50','LLR_400ms_N1','LLR_400ms_P2',...
    'LLR_1s_P50','LLR_1s_N1','LLR_1s_P2'};
end
else
    corr_A = specific_brain_signal;
end

% Define what to correlate with 
if isempty(specific_correlate_with)
if strcmp(Correlate_with,'matching_vars')
    corr_B = {'AGE','SEX','VOCAB_TS','PSES'};
elseif strcmp(Correlate_with,'neuropsychology')
    corr_B = {'YRSED','OVERALLTSCR','MATRIX_TS','FULL2IQ','SPEEDTSCR',... % NEUROPSYCHO TESTS
    'ATT_VIGTSCR', 'WMTSCR', 'VERBTSCR', 'VISTSCR', 'RPSTSCR', 'SOCCOGTSCR','SANITM', 'SAPITM', 'ROLECURR',...
    'ROLELOW', 'ROLEHIGH', 'SOCIALCURR', 'SOCIALLOW', 'SOCIALHIGH','SFS_WITHDRAW_RS', 'SFS_INTERACT_RS',...
    'SFS_RECREAT_RS', 'SFS_OCCUP_RS', 'SFS_IND_PERF_RS', 'SFS_IND_COMP_RS','SFS_PROSOC_RS',...
    'SFS_Mean', 'HVLTRRAWSUM', 'HVLTRTSCR', 'FLUENRAW', 'FLUENTSCR'};
elseif strcmp(Correlate_with,'clinical') % Clinical
    corr_B = {'PANSSP_RS','PANSSN_RS', 'PANSST_RS','PSYRATS_AUD_HALL', 'PSYRATS_DELUSIONS'};    
elseif strcmp(Correlate_with,'clinical_composite') % Clinical composite
    corr_B = {'SANSSAPS_Level7_AudHall','SANSSAPS_Level7_UnusPercBeh','SANSSAPS_Level7_Delusions',... % COMPOSITE SCORES
    'SANSSAPS_Level7_ThDis','SANSSAPS_Level7_Inattention','SANSSAPS_Level7_Inexpress','SANSSAPS_Level7_Apathy',...
    'SANSSAPS_Level4_RealityDis','SANSSAPS_Level4_ThDis','SANSSAPS_Level4_Inexpress','SANSSAPS_Level4_Apathy',...
    'PANSS_Affect','PANSS_Disorg','PANSS_Negative','PANSS_Positive','PANSS_Resistance',...
    'BPRS_Total','BPRS_Positive','BPRS_Negative','BPRS_DeprAnx','BPRS_ActMania','BPRS_HostSusp'};
elseif strcmp(Correlate_with,'duration_of_illness') % Duration of illness (in days)
    corr_B = {'DAYS_SINCE_PRDM','DAYS_SINCE_1STEP','DAYS_SINCE_DISOR',...
    'DUP', 'PSYCH2SCAN', 'MED2SCAN'};
elseif strcmp(Correlate_with,'medication') % Medication load
    corr_B = {'CPZ_equivalent'};
elseif strcmp(Correlate_with,'psychoacoustics')
    if strcmp(Quiet_treshold_type,'ChrLab')  
        corr_B = {'QT_L_125Hz', 'QT_L_250Hz', 'QT_L_500Hz', 'QT_L_1000Hz', 'QT_L_2000Hz', 'QT_L_4000Hz',... 
    'QT_L_8000Hz','QT_R_125Hz', 'QT_R_250Hz', 'QT_R_500Hz', 'QT_R_1000Hz', 'QT_R_2000Hz', 'QT_R_4000Hz',...
    'QT_R_8000Hz','FD_250Hz', 'FD_1000Hz', 'FD_4000Hz', 'ITD_500Hz', 'ITD_1000Hz', 'ITD_2000Hz', 'ITD_4000Hz',...
    'MD_4Hz','MD_16Hz','MD_64Hz','SIND'};
    elseif strcmp(Quiet_treshold_type,'Original')  
        corr_B = {'QuiT_L_1000', 'QuiT_L_1500', 'QuiT_L_2000', 'QuiT_L_3000', 'QuiT_L_4000',...
    'QuiT_R_1000', 'QuiT_R_1500', 'QuiT_R_2000', 'QuiT_R_3000', 'QuiT_R_4000',...
    'FD_250Hz', 'FD_1000Hz', 'FD_4000Hz', 'ITD_500Hz', 'ITD_1000Hz', 'ITD_2000Hz', 'ITD_4000Hz',...
    'MD_4Hz','MD_16Hz','MD_64Hz','SIND'};
    end
elseif strcmp(Correlate_with,'psychoacoustics_average')
    corr_B = {'QT_L_average','QT_R_average','FD_average','MD_average','ITD_average','SIND'};
end
else
    corr_B = specific_correlate_with;
end

% Prepare for loop and load Matrix
pvals = []; p_vals_pos = 1; header_pvals = {};
load([root_dir '/Statistics/' gavr_name '/Mega_variable_FFR_' channel_data '.mat']);

% Adjust Matrix to contain FE or C
if strcmp(group_to_plot,'FE')
    % Find FE subjects
    warning('Selecting FE only...');
    group_indices = find(strcmp(Mega_variable_FFR(:,2),'FE'));
    group_indices = [1 group_indices']; % Add header column
    Mega_variable_FFR = Mega_variable_FFR([group_indices],:);
    color_group = [255 0 0];
elseif strcmp(group_to_plot,'C')
    % Find FE subjects
    warning('Selecting C only...');
    group_indices = find(strcmp(Mega_variable_FFR(:,2),'C'));
    group_indices = [1 group_indices']; % Add header column
    Mega_variable_FFR = Mega_variable_FFR([group_indices],:);
    color_group = [0 0 0];
elseif strcmp(group_to_plot,'ALL')
    warning('Selecting FE and Controls...');
    color_group = [50 50 50];
end

% Now correlate
for bm = 1:length(corr_A) % Brain measure
pos_measu = find(strcmp(Mega_variable_FFR(1,:),corr_A{bm}));
for i = 1:length(corr_B)
    pos_col = find(strcmp(Mega_variable_FFR(1,:),corr_B{i}));
    Cell_corr = Mega_variable_FFR(:,[pos_measu,pos_col]);
    % Correct for "[]" cells
    empty_cells = find(cellfun(@isempty,Cell_corr(:,:))); % Before: Cell_corr(:,:)
    Cell_corr(empty_cells) = num2cell(NaN); % Before: Cell_corr(empty_cells,2)
    Table_corr = cell2table(Cell_corr(2:end,:));
    Table_corr.Properties.VariableNames = Cell_corr(1,:);
    try
        [R, PValue] = corrplot(Table_corr,'type','Spearman','testR', 'on');
        if plot_only_significant_ones == 1
            if PValue(2,1) >= p_threshold
                fig = gcf;
                close(fig);
                continue;
            end
        end
        pvals(p_vals_pos) = PValue(2,1);
        table_columns = Table_corr.Properties.VariableNames;
        header_pvals{p_vals_pos} = [table_columns{1} '_&_' table_columns{2}];
        p_vals_pos = p_vals_pos + 1;
        % Check n included in this correlation
        Test_NaN = Table_corr{:,:}; % Convert table to Matrix
        [NaNrows, ~] = find(isnan(Test_NaN)); % Check rows with NaN
        n_corr = (size(Test_NaN,1)) - length(NaNrows); % determine n based on previous info
        % Delete all but the convenient subplot
        h = get(gcf, 'children');
        % get true x labels first (weird issue with corrplot)
        true_x_axis_labels = get(h(1), 'YTick'); 
        delete(h(1:5));
        % Adjust labels
        current_title = [corr_A{bm} ' (n = ' num2str(n_corr) ' ' group_to_plot ')'];
        current_title = strrep(current_title,'_',' ');
        xlabel(current_title,'Color','k');
        current_title = corr_B{i};
        current_title = strrep(current_title,'_',' ');
        ylabel(current_title,'Color','k');
        % Adjust x axis labels (weird issue with corrplot)
        xticklabels(true_x_axis_labels)
        % Adjust color and style
        hline = findobj(gcf, 'type', 'line');
        set(hline(1),'Color','k') % Line fit
        set(hline(2),'Color',color_group/256) % Actual dots
        set(hline(2),'LineWidt',3) % Actual dots
    catch
        p_vals_pos = p_vals_pos + 1;
        continue;
    end
end
end

% Define pvals variable to back-track the exact pvalues if needed
PVALS_STRING = {};
PVALS_STRING(1,:) = header_pvals;
PVALS_STRING(2,:) = num2cell(pvals);
PVALS_STRING = PVALS_STRING';

%% Scatter plots with single data values (C vs FE)

% I want white backgrounds in plots
set(0,'defaultfigurecolor',[1 1 1]); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MODIFY THIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
group_to_plot = {'FE','C'};
color_group = [[255 0 0]/256;[0 0 0]/256]; % Specific for scatter
gavr_name = 'GAVR_12C_vs_14FE'; % Stats based on subjects from this average
% GAVR_11C_vs_12FE (largest "FFR but not necessarily psychoacoustics" sample without outliers)
% GAVR_SIN (only those who have SIN)
% GAVR_AMP (only  those who have at least all but SIN)
% GAVR_adjacent_valley (with adjacent valley for spectral SNR)
Quiet_treshold_type = 'Original'; % 'ChrLab' OR 'Original'
% GAVR_12C_vs_10FE
channel_data = 'Cz'; % 'Cz', 'cluster' string
% Which scales to compare 
var_scatter = 'psychoacoustics';
% Brain_measures
% 'matching_vars', 'neuropsychology', 'clinical', clinical_composite, 
% duration_of_illness, medication 'psychoacoustics','psychoacoustics_average' 
if strcmp(var_scatter,'Brain_measures') % If it's brain, specify
    Brain_signal = 'FFR'; % 'FFR' 'LLR'
    FFR_section = 'Constant'; % If FFR, specify: % 'Transient', 'Constant', 'Total'
    FFR_freq = 'high'; % 'low', 'medium', 'high'
end
specific_var_scatter = {}; % Empty ({}) by default: e.g. 'F0_SNR_low_Constant' (will cancel previous)
% 'FD_average','ITD_average','QT_L_average','QT_R_average','SIND','MD_average'

% scatter_vars = {'DAYS_SINCE_PRDM','DAYS_SINCE_1STEP','DAYS_SINCE_DISOR',...
%         'DUP', 'PSYCH2SCAN', 'MED2SCAN'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% All variables
if strcmp(Quiet_treshold_type,'ChrLab')  
header_measures = {'Subj','Group',...
    'RMS_low_Baseline','RMS_low_Transient','RMS_low_Constant','RMS_low_Total',...
    'AMP_SNR_low_Transient','AMP_SNR_low_Constant','AMP_SNR_low_Total',...
    'STR_xcorr_low','neur_lag_low',...
    'pitch_err_low','pitch_str_low',...
    'F0_peak_low_Baseline','F0_peak_low_Transient','F0_peak_low_Constant','F0_peak_low_Total',...
    'F0_SNR_low_Baseline','F0_SNR_low_Transient','F0_SNR_low_Constant','F0_SNR_low_Total',...
    'RMS_medium_Baseline','RMS_medium_Transient','RMS_medium_Constant','RMS_medium_Total',...
    'AMP_SNR_medium_Transient','AMP_SNR_medium_Constant','AMP_SNR_medium_Total',...
    'STR_xcorr_medium','neur_lag_medium',...
    'pitch_err_medium','pitch_str_medium',...
    'F0_peak_medium_Baseline','F0_peak_medium_Transient','F0_peak_medium_Constant','F0_peak_medium_Total',...
    'F0_SNR_medium_Baseline','F0_SNR_medium_Transient','F0_SNR_medium_Constant','F0_SNR_medium_Total',...
    'RMS_high_Baseline','RMS_high_Transient','RMS_high_Constant','RMS_high_Total',...
    'AMP_SNR_high_Transient','AMP_SNR_high_Constant','AMP_SNR_high_Total',...
    'STR_xcorr_high','neur_lag_high',...
    'pitch_err_high','pitch_str_high',...
    'F0_peak_high_Baseline','F0_peak_high_Transient','F0_peak_high_Constant','F0_peak_high_Total',...
    'F0_SNR_high_Baseline','F0_SNR_high_Transient','F0_SNR_high_Constant','F0_SNR_high_Total',...
    'LLR_400ms_P50','LLR_400ms_N1','LLR_400ms_P2',...
    'LLR_1s_P50','LLR_1s_N1','LLR_1s_P2',...
    'AGE','SEX','VOCAB_TS','PSES',... % FOR MATCHING
    'OVERALLTSCR','MATRIX_TS','FULL2IQ',... % NEUROPSYCHO TESTS
    'SPEEDTSCR', 'ATT_VIGTSCR', 'WMTSCR', 'VERBTSCR', 'VISTSCR', 'RPSTSCR', 'SOCCOGTSCR','SANITM',...
    'SAPITM', 'ROLECURR', 'ROLELOW', 'ROLEHIGH', 'SOCIALCURR', 'SOCIALLOW', 'SOCIALHIGH','SFS_WITHDRAW_RS',...
    'SFS_INTERACT_RS', 'SFS_RECREAT_RS', 'SFS_OCCUP_RS', 'SFS_IND_PERF_RS', 'SFS_IND_COMP_RS','SFS_PROSOC_RS',...
    'PANSSP_RS', 'PANSSN_RS', 'PANSST_RS','PSYRATS_AUD_HALL', 'PSYRATS_DELUSIONS',... % CLINICAL TESTS
    'PANSS_Affect','PANSS_Disorg','PANSS_Negative','PANSS_Positive','PANSS_Resistance',... % COMPOSITE SCORES
    'P3','SANSSAPS_Level7_AudHall','SANSSAPS_Level4_RealityDis','BPRS_Positive',...
    'QT_L_125Hz', 'QT_L_250Hz', 'QT_L_500Hz', 'QT_L_1000Hz', 'QT_L_2000Hz', 'QT_L_4000Hz',... % PSYCHOACOUSTICS
    'QT_L_8000Hz','QT_R_125Hz', 'QT_R_250Hz', 'QT_R_500Hz', 'QT_R_1000Hz', 'QT_R_2000Hz', 'QT_R_4000Hz',...
    'QT_R_8000Hz','FD_250Hz', 'FD_1000Hz', 'FD_4000Hz', 'ITD_500Hz', 'ITD_1000Hz', 'ITD_2000Hz', 'ITD_4000Hz',...
    'MD_4Hz', 'MD_16Hz', 'MD_64Hz', 'SIND',...
    'QT_L_average','QT_R_average','FD_average','ITD_average',...
    'DAYS_SINCE_PRDM','DAYS_SINCE_1STEP','DAYS_SINCE_DISOR',...
    'SFS_Mean', 'HVLTRRAWSUM', 'HVLTRTSCR', 'FLUENRAW', 'FLUENTSCR'}; % DURATION OF ILLNESS (IN DAYS)
elseif strcmp(Quiet_treshold_type,'Original')  
    header_measures = {'Subj','Group',...
    'RMS_low_Baseline','RMS_low_Transient','RMS_low_Constant','RMS_low_Total',...
    'AMP_SNR_low_Transient','AMP_SNR_low_Constant','AMP_SNR_low_Total',...
    'STR_xcorr_low','neur_lag_low',...
    'pitch_err_low','pitch_str_low',...
    'F0_peak_low_Baseline','F0_peak_low_Transient','F0_peak_low_Constant','F0_peak_low_Total',...
    'F0_SNR_low_Baseline','F0_SNR_low_Transient','F0_SNR_low_Constant','F0_SNR_low_Total',...
    'RMS_medium_Baseline','RMS_medium_Transient','RMS_medium_Constant','RMS_medium_Total',...
    'AMP_SNR_medium_Transient','AMP_SNR_medium_Constant','AMP_SNR_medium_Total',...
    'STR_xcorr_medium','neur_lag_medium',...
    'pitch_err_medium','pitch_str_medium',...
    'F0_peak_medium_Baseline','F0_peak_medium_Transient','F0_peak_medium_Constant','F0_peak_medium_Total',...
    'F0_SNR_medium_Baseline','F0_SNR_medium_Transient','F0_SNR_medium_Constant','F0_SNR_medium_Total',...
    'RMS_high_Baseline','RMS_high_Transient','RMS_high_Constant','RMS_high_Total',...
    'AMP_SNR_high_Transient','AMP_SNR_high_Constant','AMP_SNR_high_Total',...
    'STR_xcorr_high','neur_lag_high',...
    'pitch_err_high','pitch_str_high',...
    'F0_peak_high_Baseline','F0_peak_high_Transient','F0_peak_high_Constant','F0_peak_high_Total',...
    'F0_SNR_high_Baseline','F0_SNR_high_Transient','F0_SNR_high_Constant','F0_SNR_high_Total',...
    'LLR_400ms_P50','LLR_400ms_N1','LLR_400ms_P2',...
    'LLR_1s_P50','LLR_1s_N1','LLR_1s_P2',...
    'AGE','SEX','VOCAB_TS','PSES',... % FOR MATCHING
    'OVERALLTSCR','MATRIX_TS','FULL2IQ',... % NEUROPSYCHO TESTS
    'SPEEDTSCR', 'ATT_VIGTSCR', 'WMTSCR', 'VERBTSCR', 'VISTSCR', 'RPSTSCR', 'SOCCOGTSCR','SANITM',...
    'SAPITM', 'ROLECURR', 'ROLELOW', 'ROLEHIGH', 'SOCIALCURR', 'SOCIALLOW', 'SOCIALHIGH','SFS_WITHDRAW_RS',...
    'SFS_INTERACT_RS', 'SFS_RECREAT_RS', 'SFS_OCCUP_RS', 'SFS_IND_PERF_RS', 'SFS_IND_COMP_RS','SFS_PROSOC_RS',...
    'PANSSP_RS', 'PANSSN_RS', 'PANSST_RS','PSYRATS_AUD_HALL', 'PSYRATS_DELUSIONS',... % CLINICAL TESTS
    'PANSS_Affect','PANSS_Disorg','PANSS_Negative','PANSS_Positive','PANSS_Resistance',... % COMPOSITE SCORES
    'P3','SANSSAPS_Level7_AudHall','SANSSAPS_Level4_RealityDis','BPRS_Positive',...
    'QuiT_L_1000', 'QuiT_L_1500', 'QuiT_L_2000', 'QuiT_L_3000', 'QuiT_L_4000',... % PSYCHOACOUSTICS
    'QuiT_R_1000', 'QuiT_R_1500', 'QuiT_R_2000', 'QuiT_R_3000', 'QuiT_R_4000',...
    'FD_250Hz', 'FD_1000Hz', 'FD_4000Hz', 'ITD_500Hz', 'ITD_1000Hz', 'ITD_2000Hz', 'ITD_4000Hz',...
    'MD_4Hz', 'MD_16Hz', 'MD_64Hz', 'SIND',...
    'QT_L_average','QT_R_average','FD_average','ITD_average',...
    'DAYS_SINCE_PRDM','DAYS_SINCE_1STEP','DAYS_SINCE_DISOR',...
    'SFS_Mean', 'HVLTRRAWSUM', 'HVLTRTSCR', 'FLUENRAW', 'FLUENTSCR'}; % DURATION OF ILLNESS (IN DAYS)
end

% Define variable to compare between groups with scatter plot
if isempty(specific_var_scatter)
    if strcmp(var_scatter,'Brain_measures')
        if strcmp(Brain_signal,'FFR')
            % Define FFR measures
            if strcmp(FFR_freq, 'low') && strcmp(FFR_section, 'Transient')
                scatter_vars = {'RMS_low_Transient','AMP_SNR_low_Transient',...
                    'F0_peak_low_Transient','F0_SNR_low_Transient','STR_xcorr_low','neur_lag_low'};
                % Add later 'pitch_err_low','pitch_str_low'
            elseif strcmp(FFR_freq, 'low') && strcmp(FFR_section, 'Constant')
                scatter_vars = {'RMS_low_Constant','AMP_SNR_low_Constant',...
                    'F0_peak_low_Constant','F0_SNR_low_Constant','STR_xcorr_low','neur_lag_low'};
                % 'pitch_err_low','pitch_str_low'
            elseif strcmp(FFR_freq, 'low') && strcmp(FFR_section, 'Total')
                scatter_vars = {'RMS_low_Total','AMP_SNR_low_Total',...
                    'F0_peak_low_Total','F0_SNR_low_Total','STR_xcorr_low','neur_lag_low'};
                % 'pitch_err_low','pitch_str_low'
            elseif strcmp(FFR_freq, 'medium') && strcmp(FFR_section, 'Transient')
                scatter_vars = {'RMS_medium_Transient','AMP_SNR_medium_Transient',...
                    'F0_peak_medium_Transient','F0_SNR_medium_Transient','STR_xcorr_medium','neur_lag_medium'};
                % 'pitch_err_medium','pitch_str_medium'
            elseif strcmp(FFR_freq, 'medium') && strcmp(FFR_section, 'Constant')
                scatter_vars = {'RMS_medium_Constant','AMP_SNR_medium_Constant',...
                    'F0_peak_medium_Constant','F0_SNR_medium_Constant','STR_xcorr_medium','neur_lag_medium'};
                % 'pitch_err_medium','pitch_str_medium'
            elseif strcmp(FFR_freq, 'medium') && strcmp(FFR_section, 'Total')
                scatter_vars = {'RMS_medium_Total','AMP_SNR_medium_Total',...
                    'F0_peak_medium_Total','F0_SNR_medium_Total','STR_xcorr_medium','neur_lag_medium'};
                % 'pitch_err_medium','pitch_str_medium'
            elseif strcmp(FFR_freq, 'high') && strcmp(FFR_section, 'Transient')
                scatter_vars = {'RMS_high_Transient','AMP_SNR_high_Transient',...
                    'F0_peak_high_Transient','F0_SNR_high_Transient','STR_xcorr_high','neur_lag_high'};
                % 'pitch_err_high','pitch_str_high'
            elseif strcmp(FFR_freq, 'high') && strcmp(FFR_section, 'Constant')
                scatter_vars = {'RMS_high_Constant','AMP_SNR_high_Constant',...
                    'F0_peak_high_Constant','F0_SNR_high_Constant','STR_xcorr_high','neur_lag_high'};
                % 'pitch_err_high','pitch_str_high'
            elseif strcmp(FFR_freq, 'high') && strcmp(FFR_section, 'Total')
                scatter_vars = {'RMS_high_Total','AMP_SNR_high_Total',...
                    'F0_peak_high_Total','F0_SNR_high_Total','STR_xcorr_high','neur_lag_high'};
                % 'pitch_err_high','pitch_str_high'
            end
        elseif strcmp(Brain_signal,'LLR')
            % Define LLR measures
            scatter_vars = {'LLR_400ms_P50','LLR_400ms_N1','LLR_400ms_P2',...
            'LLR_1s_P50','LLR_1s_N1','LLR_1s_P2'};
        end
    elseif strcmp(var_scatter,'matching_vars')
        scatter_vars = {'AGE','SEX','VOCAB_TS','PSES'};
    elseif strcmp(var_scatter,'neuropsychology')
        scatter_vars = {'YRSED','OVERALLTSCR','MATRIX_TS','FULL2IQ','SPEEDTSCR',... % NEUROPSYCHO TESTS
        'ATT_VIGTSCR', 'WMTSCR', 'VERBTSCR', 'VISTSCR', 'RPSTSCR', 'SOCCOGTSCR','SANITM', 'SAPITM', 'ROLECURR',...
        'ROLELOW', 'ROLEHIGH', 'SOCIALCURR', 'SOCIALLOW', 'SOCIALHIGH','SFS_WITHDRAW_RS', 'SFS_INTERACT_RS',...
        'SFS_RECREAT_RS', 'SFS_OCCUP_RS', 'SFS_IND_PERF_RS', 'SFS_IND_COMP_RS','SFS_PROSOC_RS',...
        'SFS_Mean', 'HVLTRRAWSUM', 'HVLTRTSCR', 'FLUENRAW', 'FLUENTSCR'};
    elseif strcmp(var_scatter,'clinical') % Clinical
        scatter_vars = {'PANSSP_RS','PANSSN_RS', 'PANSST_RS','PSYRATS_AUD_HALL', 'PSYRATS_DELUSIONS'};    
    elseif strcmp(var_scatter,'clinical_composite') % Clinical composite
        scatter_vars = {'SANSSAPS_Level7_AudHall','SANSSAPS_Level7_UnusPercBeh','SANSSAPS_Level7_Delusions',... % COMPOSITE SCORES
        'SANSSAPS_Level7_ThDis','SANSSAPS_Level7_Inattention','SANSSAPS_Level7_Inexpress','SANSSAPS_Level7_Apathy',...
        'SANSSAPS_Level4_RealityDis','SANSSAPS_Level4_ThDis','SANSSAPS_Level4_Inexpress','SANSSAPS_Level4_Apathy',...
        'PANSS_Affect','PANSS_Disorg','PANSS_Negative','PANSS_Positive','PANSS_Resistance',...
        'BPRS_Total','BPRS_Positive','BPRS_Negative','BPRS_DeprAnx','BPRS_ActMania','BPRS_HostSusp'};
    elseif strcmp(var_scatter,'duration_of_illness') % Duration of illness (in days)
        scatter_vars = {'DAYS_SINCE_PRDM','DAYS_SINCE_1STEP','DAYS_SINCE_DISOR',...
        'DUP', 'PSYCH2SCAN', 'MED2SCAN'};
    elseif strcmp(var_scatter,'medication') % Medication load
        scatter_vars = {'CPZ_equivalent'};
    elseif strcmp(var_scatter,'psychoacoustics')
        if strcmp(Quiet_treshold_type,'ChrLab')  
            scatter_vars = {'QT_L_125Hz', 'QT_L_250Hz', 'QT_L_500Hz', 'QT_L_1000Hz', 'QT_L_2000Hz', 'QT_L_4000Hz',... 
        'QT_L_8000Hz','QT_R_125Hz', 'QT_R_250Hz', 'QT_R_500Hz', 'QT_R_1000Hz', 'QT_R_2000Hz', 'QT_R_4000Hz',...
        'QT_R_8000Hz','FD_250Hz', 'FD_1000Hz', 'FD_4000Hz', 'ITD_500Hz', 'ITD_1000Hz', 'ITD_2000Hz', 'ITD_4000Hz',...
        'MD_4Hz','MD_16Hz','MD_64Hz','SIND'};
        elseif strcmp(Quiet_treshold_type,'Original')  
            scatter_vars = {'QuiT_L_1000', 'QuiT_L_1500', 'QuiT_L_2000', 'QuiT_L_3000', 'QuiT_L_4000',...
        'QuiT_R_1000', 'QuiT_R_1500', 'QuiT_R_2000', 'QuiT_R_3000', 'QuiT_R_4000',...
        'FD_250Hz', 'FD_1000Hz', 'FD_4000Hz', 'ITD_500Hz', 'ITD_1000Hz', 'ITD_2000Hz', 'ITD_4000Hz',...
        'MD_4Hz','MD_16Hz','MD_64Hz','SIND'};
        end
    elseif strcmp(var_scatter,'psychoacoustics_average')
        scatter_vars = {'QT_L_average','QT_R_average','FD_average','ITD_average','MD_average', 'SIND'};
    end
else
    scatter_vars = specific_var_scatter;
end

% Prepare for loop and load Matrix
load([root_dir '/Statistics/' gavr_name '/Mega_variable_FFR_' channel_data '.mat']);

% Now prepare tables
for sv = 1:length(scatter_vars) % Brain measure
pos_measu = find(strcmp(Mega_variable_FFR(1,:),scatter_vars{sv}));
table_scatter = [];
for pg = 1:length(group_to_plot)
    group_indices = find(strcmp(Mega_variable_FFR(:,2),group_to_plot{pg}));
    for i = 1:length(group_indices)
        if isempty(Mega_variable_FFR{group_indices(i),pos_measu})
            table_scatter(i,pg) = NaN;
        else
            table_scatter(i,pg) = Mega_variable_FFR{group_indices(i),pos_measu};
        end
    end
end

% If different numbers of C and FE, it adds zeros to complete tables, correct for that
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if length(group_to_plot) ~= 2 % Just to be sure in case we include chronics
    error('If using more than two groups, reprogram next lines');
end
for pg = 1:length(group_to_plot)
    eval(['group_indices_' num2str(pg) ' = find(strcmp(Mega_variable_FFR(:,2),group_to_plot{pg}));'])
end
% If they are the same size it won't do anything
if length(group_indices_1) > length(group_indices_2)
    difference =  length(group_indices_1) - length(group_indices_2);
    % So this means first column is 'difference' rows longer than second 
    table_scatter(end+1-difference:end,2) = NaN;
    % Therefore those 'extra' positions at the end of columnn 2 are NaN
elseif length(group_indices_2) > length(group_indices_1)
    difference = length(group_indices_2) - length(group_indices_1);
    % So this means second column is 'difference' rows longer than first 
    table_scatter(end+1-difference:end,1) = NaN;
    % Therefore those 'extra' positions at the end of columnn 1 are NaN
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compute an independent sample t test and retrieve p value
[~,p_value,~,t_stats] = ttest2(table_scatter(:,1),table_scatter(:,2));
% Get mean values
mean_plot_left = nanmean(table_scatter(:,1));
mean_plot_right = nanmean(table_scatter(:,2));

point_settings = {'MarkerFaceColor',color_group,'MarkerEdgeColor','white','PointSize',80,'LineWidth',1};
plot_settings = [point_settings]; % Something weird about additional wiskers (in case needed)
figure;
[xPositions, yPositions, Label, RangeCut, FigHandles] = UnivarScatter(table_scatter,plot_settings{:});

% set(gcf,'Position',[0,0,600,300])
set(gcf,'Position',[500,250,300,300])
y_title = scatter_vars{sv};
y_title = strrep(y_title,'_',' ');
ylabel(y_title); 
xticklabels(group_to_plot) 
h=gca; h.XAxis.TickLength = [0 0];
h.YGrid = 'on';
h.GridLineStyle = '--';

% Add p value text
if p_value < 0.05
    color_p_value = 'red';
else
    color_p_value = 'black';
end
if p_value < 0.001
    label_pvalue = 'p < 0.001';
else
    str_pvalue = num2str(p_value);
    if strcmp(str_pvalue,'1')
        label_pvalue = ['p = ' str_pvalue];
    else    
        label_pvalue = ['p = ' str_pvalue(1:5)];
    end
end
title({['\color{' color_p_value '}' label_pvalue '']})

% Add longer mean lines
hold on;
x_values = xlim;
plot([x_values(1)+x_values(1)*0.25 x_values(2)-x_values(2)*0.45],[mean_plot_left,mean_plot_left],'LineWidth',3,'color',[0.5 0.5 0.5 0.5]);
hold on;
plot([x_values(2)-x_values(2)*0.35 x_values(2)-x_values(2)*0.05],[mean_plot_right,mean_plot_right],'LineWidth',3,'color',[0.5 0.5 0.5 0.5]);
end

%% Compute Time Frequency shortened

% This is to compute TF with the same frequency band than ITPC (to compare)

tic
disp(' ');      
disp('-------------------------');  
disp('COMPUTING SHORTENED TIME FREQUENCY (FFR_Sz)');  
disp(datetime)
disp('-------------------------');     
disp(' '); 

for p = 1:length(participant)
    % Check log info about the subject
    pos_subj = find(strcmp({subject_array{:,1}},participant{p}));
    if strcmp(subject_array{pos_subj,3},'DONE') && strcmp(subject_array{pos_subj,20},'needs_short_TF')
    
    % Reload subject first
    disp(' ');      
    disp('-------------------------');
    disp(['loading participant ' participant{p}]);
    disp(datetime)
    disp(' '); 

    prot_subs = bst_get('ProtocolSubjects');
    current_sub = find(strcmp({prot_subs.Subject.Name}, participant{p}));
    db_reload_conditions(current_sub);

    % Retrieve average
    for fre = 1:length(fre_string)
        % Find files    
        folders = dir([root_dir_bs '/data/' participant{p} '/@intra/']);
        infolder_FFR_average = find(endsWith({folders.name},['FFR_average_' fre_string{fre} '.mat']));
        % Choose most recent one if there are more than one
        if length(infolder_FFR_average) > 1; infolder_FFR_average = infolder_FFR_average(end);end

        if isempty(infolder_FFR_average)
            warning(['No FFR @intra ' fre_string{fre} ' average for ' participant{p}]);
            continue; % Some subjects don't have FFR medium
        end

        sFiles_FFR_average = [participant{p} '/@intra/' folders(infolder_FFR_average).name];

        disp(' ');      
        disp('-------------------------');
        disp(['Computing shortened TF for ' participant{p} ' FFR ' fre_string{fre}]);
        disp(datetime)
        disp(' ');  


         % Delete any previous TF in brainstorm    
        if delete_previous_file == 1
            folders_delete = dir([root_dir_bs '/data/' participant{p} '/@intra']);
            infolder_delete = find(endsWith({folders_delete.name},['Time_Frequency_' fre_string{fre} '_shortened.mat']));
            if ~isempty(infolder_delete) % file exists, therefore delete it
               delete([root_dir_bs '/data/' participant{p} '/@intra/' folders_delete(infolder_delete).name]);
            end
        end
 
        % Process: Time-frequency (Morlet wavelets)
        sFiles_TF = bst_process('CallProcess', 'process_timefreq', sFiles_FFR_average, [], ...
            'sensortypes', choice_channel_EEG{1}, ...
            'edit',        struct(...
                 'Comment',         'TF_shortened', ...
                 'TimeBands',       [], ...
                 'Freqs',           Freq_window_ITPC{fre}, ...
                 'MorletFc',        1, ...
                 'MorletFwhmTc',    3, ...
                 'ClusterFuncTime', 'none', ...
                 'Measure',         'power', ...
                 'Output',          'all', ...
                 'SaveKernel',      0), ...
            'normalize',   'none');  % None: Save non-standardized time-frequency maps

        % Process: Add tag
        sFiles_TF = bst_process('CallProcess', 'process_add_tag', sFiles_TF, [], ...
            'tag',           ['Time_Frequency_' fre_string{fre} '_shortened'], ...
            'output',        2);  % Add to file name (1 to add a tag)

        % Process: Set name
        sFiles_TF = bst_process('CallProcess', 'process_set_comment', sFiles_TF, [], ...
            'tag',           ['Time_Frequency_' fre_string{fre} '_shortened'], ...
            'isindex',       1);

    end
        
    % If successful, update subject_array for this subject
    subject_array{pos_subj,20} = 'Short_TF_done';
    save([root_dir '/subject_array.mat'],'subject_array') 
    
    end  
end


clearvars('-except', initialVars{:});
disp 'DONE COMPUTING SHORTENED TIME FREQUENCY (FFR_Sz)!!!'
disp(datetime)
toc

%% Average Time Frequency (Short and Long) across subjects

tic
disp(' ');      
disp('-------------------------');  
disp('AVERAGING SHORT AND LONG TF ACROSS SUBJECTS (FFR_Sz)');  
disp(datetime)
disp('-------------------------');     
disp(' '); 


% Reload every subject first
for p = 1:length(participant)
    % Check log info about the subject
    pos_subj = find(strcmp({subject_array{:,1}},participant{p}));
    if strcmp(subject_array{pos_subj,3},'DONE')
    
    % Reload subject first
    disp(' ');      
    disp('-------------------------');
    disp(['loading participant ' participant{p}]);
    disp(datetime)
    disp(' '); 
    
    prot_subs = bst_get('ProtocolSubjects');
    current_sub = find(strcmp({prot_subs.Subject.Name}, participant{p}));
    db_reload_conditions(current_sub);
    
    end
end

% Average normal-length TF across groups
for fre = 1:length(fre_string)
    
    disp(' ');      
    disp('-------------------------');
    disp(['Averaging TF for FFR ' fre_string{fre}]);
    disp(datetime)
    disp(' ');  
    
    for pg = 1:length(participant_group)
        sFiles = {};
        for p = 1:length(participant)
            % Check log info about the subject
            pos_subj = find(strcmp({subject_array{:,1}},participant{p}));
            if ~strcmp(subject_array{pos_subj,3},'DONE'); continue; end
            if ~strcmp(subject_array{pos_subj,2},participant_group{pg})
                continue; % so only include participants that correspond to the group
            end
            
            files = dir([root_dir_bs '/data/' participant{p} '/@intra']);
            if isempty(files)
                error(['No intra folder for ' participant{p}]);
            end
            infolder = find(endsWith({files.name},['Time_Frequency_' fre_string{fre} '.mat'])); 
            if isempty(infolder)
               % It may be that this subject does not have e.g. FFR medium
               warning(['No TF for ' participant{p} ' ' fre_string{fre}]);
               continue;
            end  
            if length(infolder) > 1
                error(['More than one TF average for ' participant{p} ' ' fre_string{fre}]);
            end
            sFiles{p} = [participant{p} '/@intra/' files(infolder).name];
        end
        
        sFiles = sFiles(~cellfun('isempty', sFiles')); % to avoid empty cells
        
        if isempty(sFiles)
            error(['No TF files to perform GAVR for ' fre_string{fre}]);
        end
        
        gavr_n = num2str(length(sFiles));

        % If stated, find and delete any previous GAVR SENSOR data
        if delete_previous_file == 1
            % check if there is already GAVR source in Group analysis folder
            folders_delete = dir([root_dir_bs '/data/Group_analysis/@intra']);
            infolder_delete = find(endsWith({folders_delete.name}, ['Long_TF_' fre_string{fre} '_' participant_group{pg} '_n' gavr_n '.mat']));
            if ~isempty(infolder_delete) % file exists, therefore delete it
               delete([root_dir_bs '/data/Group_analysis/@intra/' folders_delete(infolder_delete).name]);
            end
        end

        % Process: Average: Everything
        sFiles = bst_process('CallProcess', 'process_average', sFiles, [], ...
            'avgtype',       1, ...  % Everything
            'avg_func',      1, ...  % Arithmetic average:  mean(x)
            'weighted',      0, ...
            'matchrows',     0, ...
            'iszerobad',     1);
        
        % error('PAUSED HERE TO SEE WHAT THE OUTCOME FILE IS NAMED (sFiles) TO RENAME ACCORDINGLY')

        % Process: Add tag
        sFiles = bst_process('CallProcess', 'process_add_tag', sFiles, [], ...
            'tag',           ['Long_TF_' fre_string{fre} '_' participant_group{pg} '_n' gavr_n], ...
            'output',        2);  % Add to file name (1 to add a tag)

        % Process: Set name
        sFiles = bst_process('CallProcess', 'process_set_comment', sFiles, [], ...
            'tag',           ['Long_TF_' fre_string{fre} '_' participant_group{pg} '_n' gavr_n], ...
            'isindex',       1);
    end
end

% Average short one across groups
for fre = 1:length(fre_string)
    
    disp(' ');      
    disp('-------------------------');
    disp(['Averaging short TF for FFR ' fre_string{fre}]);
    disp(datetime)
    disp(' ');  
    
    for pg = 1:length(participant_group)
        sFiles = {};
        for p = 1:length(participant)
            % Check log info about the subject
            pos_subj = find(strcmp({subject_array{:,1}},participant{p}));
            if ~strcmp(subject_array{pos_subj,3},'DONE') && strcmp(subject_array{pos_subj,20},'Short_TF_done'); continue; end
            if ~strcmp(subject_array{pos_subj,2},participant_group{pg})
                continue; % so only include participants that correspond to the group
            end
            
            files = dir([root_dir_bs '/data/' participant{p} '/@intra']);
            if isempty(files)
                error(['No intra folder for ' participant{p}]);
            end
            infolder = find(endsWith({files.name},['Time_Frequency_' fre_string{fre} '_shortened.mat'])); 
            if isempty(infolder)
               % It may be that this subject does not have e.g. FFR medium
               warning(['No shortened TF for ' participant{p} ' ' fre_string{fre}]);
               continue;
            end  
            if length(infolder) > 1
                error(['More than one shortened TF average for ' participant{p} ' ' fre_string{fre}]);
            end
            sFiles{p} = [participant{p} '/@intra/' files(infolder).name];
        end
        
        sFiles = sFiles(~cellfun('isempty', sFiles')); % to avoid empty cells
        
        if isempty(sFiles)
            error(['No short TF files to perform GAVR for ' fre_string{fre}]);
        end
        
        gavr_n = num2str(length(sFiles));

        % If stated, find and delete any previous GAVR SENSOR data
        if delete_previous_file == 1
            % check if there is already GAVR source in Group analysis folder
            folders_delete = dir([root_dir_bs '/data/Group_analysis/@intra']);
            infolder_delete = find(endsWith({folders_delete.name}, ['Short_TF_' fre_string{fre} '_' participant_group{pg} '_n' gavr_n '.mat']));
            if ~isempty(infolder_delete) % file exists, therefore delete it
               delete([root_dir_bs '/data/Group_analysis/@intra/' folders_delete(infolder_delete).name]);
            end
        end

        % Process: Average: Everything
        sFiles = bst_process('CallProcess', 'process_average', sFiles, [], ...
            'avgtype',       1, ...  % Everything
            'avg_func',      1, ...  % Arithmetic average:  mean(x)
            'weighted',      0, ...
            'matchrows',     0, ...
            'iszerobad',     1);
        
        % error('PAUSED HERE TO SEE WHAT THE OUTCOME FILE IS NAMED (sFiles) TO RENAME ACCORDINGLY')

        % Process: Add tag
        sFiles = bst_process('CallProcess', 'process_add_tag', sFiles, [], ...
            'tag',           ['Short_TF_' fre_string{fre} '_' participant_group{pg} '_n' gavr_n], ...
            'output',        2);  % Add to file name (1 to add a tag)

        % Process: Set name
        sFiles = bst_process('CallProcess', 'process_set_comment', sFiles, [], ...
            'tag',           ['Short_TF_' fre_string{fre} '_' participant_group{pg} '_n' gavr_n], ...
            'isindex',       1);
    end
end

clearvars('-except', initialVars{:});
disp 'DONE AVERAGING SHORT AND LONG TF ACROSS SUBJECTS (FFR_Sz)!!!'
disp(datetime)
toc

%% Compute ITPC

tic
disp(' ');      
disp('-------------------------');  
disp('COMPUTING ITPC (FFR_Sz)');  
disp(datetime)
disp('-------------------------');     
disp(' '); 

for p = 1:length(participant)
    % Check log info about the subject
    pos_subj = find(strcmp({subject_array{:,1}},participant{p}));
    if strcmp(subject_array{pos_subj,3},'DONE') && strcmp(subject_array{pos_subj,19},'needs_ITPC')
    
    % Reload subject first
    disp(' ');      
    disp('-------------------------');
    disp(['loading participant ' participant{p}]);
    disp(datetime)
    disp(' '); 

    prot_subs = bst_get('ProtocolSubjects');
    current_sub = find(strcmp({prot_subs.Subject.Name}, participant{p}));
    db_reload_conditions(current_sub);

    % Generate good trial files
    fre_string = {'low','medium','high'};
    pol_n = [1,2];
    for fre = 1:length(fre_string)
        for j = 1:length(pol_n)
            folders = dir([root_dir_bs '/data/' participant{p} '/Pol_' num2str(pol_n(j)) '_' fre_string{fre} '/']);
            if isempty(folders) % Some subjects don't have all frequencies
                warning([participant{p} ' has no files for FFR ' fre_string{fre}]);
                continue;
            end
            average_file = find(contains({folders.name},'_average_'));
            if isempty(average_file)
                error([participant{p} ' pol ' num2str(pol_n(j)) ' has no average ' fre_string{fre}]);
            elseif length(average_file) > 1
                error([participant{p} ' pol ' num2str(pol_n(j)) ' has more than one average ' fre_string{fre}]);
            end
            load([root_dir_bs '/data/' participant{p} '/Pol_' num2str(pol_n(j)) '_' fre_string{fre} '/' folders(average_file).name]);
            pos_list = find(contains(History(:,3),'List of averaged files'));
            if (isempty(pos_list)) || (length(pos_list) > 1)
                error([participant{p} ': cannot identify trials for average ' fre_string{fre}]);
            end
            raw_trials_names = History(pos_list+1:end,3);
            if isempty(raw_trials_names)
                error([participant{p} ': cannot identify trials for average ' fre_string{fre}]);
            end
            % Create for first one
            if pol_n(j) == 1
                trials = {}; pos = 1;
            end
            for i = 1:length(raw_trials_names)
                if ~contains(raw_trials_names{i},'_trial')
                    error([participant{p} ': something odd with trial names']);
                end
                trials{pos} = [participant{p} '/Pol_' num2str(pol_n(j)) '_' fre_string{fre} '/' raw_trials_names{i}(strfind(raw_trials_names{i},'data_Pol'):end)]; %#ok<SAGROW>
                pos = pos + 1;
            end
        end
        
    % If two polarities for eg., medium are empty, it will crash    
    if ~exist('trials') %#ok<EXIST>
        continue;
    end
    
    disp(' ');      
    disp('-------------------------');
    disp(['Extracting single-trial complex spectra for ' participant{p} ' FFR ' fre_string{fre}]);
    disp(datetime)
    disp(' ');  

    % Process: Time-frequency (Morlet wavelets)
    sFiles_single_trials = bst_process('CallProcess', 'process_timefreq', trials, [], ...
        'sensortypes', 'Cz', ...
        'edit',        struct(...
             'Comment',         'ITPC', ...
             'TimeBands',       [], ...
             'Freqs',           Freq_window_ITPC{fre}, ...
             'MorletFc',        1, ...
             'MorletFwhmTc',    3, ...
             'ClusterFuncTime', 'none', ...
             'Measure',         'none', ...
             'Output',          'all', ...
             'RemoveEvoked',    0, ...
             'SaveKernel',      0), ...
        'normalize',   'none');  % None: Save non-standardized time-frequency maps

    % Clear intermediate variables
    clear('trials');clear('raw_trials_names');
    
    % Process: Extract values: [all] 103-123Hz
    sFiles_extracted = bst_process('CallProcess', 'process_extract_values', sFiles_single_trials, [], ...
        'timewindow', [], ...
        'freqrange',  [Freq_window_ITPC{fre}(1), Freq_window_ITPC{fre}(end)], ...
        'rows',       '', ...
        'isabs',      0, ...
        'avgtime',    0, ...
        'avgrow',     0, ...
        'avgfreq',    0, ...
        'matchrows',  1, ...
        'dim',        2, ...  % Concatenate time (dimension 2)
        'Comment',    '');
    
    % Once the data is extracted, delete ITPC from each trial
    % Process: Delete selected files
    sFiles = bst_process('CallProcess', 'process_delete', sFiles_single_trials, [], ...
        'target', 1);  % Delete selected files
    
    % Calculate ITPC from complex spectra (Brian's function)
    data=load([root_dir_bs '/data/' sFiles_extracted.FileName]);
    S = length(data.TFmask(1,:)); % S = number of samples
    T = length(data.TF(1,:,1))/S; % T = Number of trials
    C = length(data.RowNames); % C = Number of channels
    F = length(data.Freqs); % F = Number of frequencies
    ComplexSpctrm = permute(data.TF,[3 1 2]); % Change dimorder to F C S*T
    ComplexSpctrm = reshape(ComplexSpctrm,[F C S T]); % Redim to F C S T
    ComplexSpctrm = permute(ComplexSpctrm,[4 2 3 1]); % Change dimorder to T C S F 
    ITPC=data;
    ITPC.Time = ITPC.Time(1:S);
    
    disp(' ');      
    disp('-------------------------');
    disp(['Computing ITPC for ' participant{p} ' FFR ' fre_string{fre}]);
    disp(datetime)
    disp(' ');  
    
    % compute inter-trial phase coherence (itpc)
    ITPC.TF       = ComplexSpctrm./abs(ComplexSpctrm);         % divide by amplitude
    ITPC.TF       = squeeze(abs(mean(ITPC.TF))); % this will give the itc
    
    % Reshape since it is only one channel
    ITPC.TF = reshape(ITPC.TF,[1 size(ITPC.TF,1) size(ITPC.TF,2)]);

    % Add comment to see in Brainstorm 
    ITPC.Comment = ['ITPC_FFR_' fre_string{fre}];
    
    % Incorporate generated variable to brainstorm
    temp = [participant{p} '/@intra/channel.mat'];
    [sStudy, iStudy] = bst_get('AnyFile', temp);    
    OutputFile = db_add(iStudy,ITPC);
        
    % Delete large file in brainstorm
    delete([root_dir_bs '/data/' sFiles_extracted.FileName])
    
    % Delete ITPC from workspace
    clear('ITPC');
    
    % Check if there is a previous file (in case of reruning)
    if delete_previous_file == 1
        prev_file = exist([root_dir_bs '/data/' participant{p} '/@intra/timefreq_morlet_ITPC_' fre_string{fre} '.mat'],'file');
        if prev_file ~= 0
            delete([root_dir_bs '/data/' participant{p} '/@intra/timefreq_morlet_ITPC_' fre_string{fre} '.mat'],'file');
        end
    end
    
    % Rename ITPC file to retrieve it later (
    movefile([root_dir_bs '/data/' OutputFile],[root_dir_bs '/data/' participant{p} '/@intra/timefreq_morlet_ITPC_' fre_string{fre} '.mat']);
        
    end
        
    % If successful, update subject_array for this subject
    subject_array{pos_subj,19} = 'ITPC_done';
    save([root_dir '/subject_array.mat'],'subject_array') 
    
    end  
end


clearvars('-except', initialVars{:});
disp 'DONE COMPUTING AND AVERAGING ITPC (FFR_Sz)!!!'
disp(datetime)
toc

%% Average ITPC across subjects

tic
disp(' ');      
disp('-------------------------');  
disp('AVERAGING ITPC (FFR_Sz)');  
disp(datetime)
disp('-------------------------');     
disp(' '); 


% Reload every subject first
for p = 1:length(participant)
    % Check log info about the subject
    pos_subj = find(strcmp({subject_array{:,1}},participant{p}));
    if strcmp(subject_array{pos_subj,3},'DONE') && strcmp(subject_array{pos_subj,19},'ITPC_done')
    
    % Reload subject first
    disp(' ');      
    disp('-------------------------');
    disp(['loading participant ' participant{p}]);
    disp(datetime)
    disp(' '); 
    
    prot_subs = bst_get('ProtocolSubjects');
    current_sub = find(strcmp({prot_subs.Subject.Name}, participant{p}));
    db_reload_conditions(current_sub);
    
    end
end

% Average across groups
for fre = 1:length(fre_string)
    
    disp(' ');      
    disp('-------------------------');
    disp(['Averaging ITPC for FFR ' fre_string{fre}]);
    disp(datetime)
    disp(' ');  
    
    for pg = 1:length(participant_group)
        sFiles = {};
        for p = 1:length(participant)
            % Check log info about the subject
            pos_subj = find(strcmp({subject_array{:,1}},participant{p}));
            if ~strcmp(subject_array{pos_subj,3},'DONE') && strcmp(subject_array{pos_subj,19},'ITPC_done'); continue; end
            if ~strcmp(subject_array{pos_subj,2},participant_group{pg})
                continue; % so only include participants that correspond to the group
            end
            
            files = dir([root_dir_bs '/data/' participant{p} '/@intra']);
            if isempty(files)
                error(['No intra folder for ' participant{p}]);
            end
            infolder = find(strcmp({files.name},['timefreq_morlet_ITPC_' fre_string{fre} '.mat'])); 
            if isempty(infolder)
               % It may be that this subject does not have e.g. FFR medium
               warning(['No ITPC for ' participant{p} ' ' fre_string{fre}]);
               continue;
            end  
            if length(infolder) > 1
                error(['More than one shortened ITPC for ' participant{p} ' ' fre_string{fre}]);
            end
            sFiles{p} = [participant{p} '/@intra/' files(infolder).name];
        end
        
        sFiles = sFiles(~cellfun('isempty', sFiles')); % to avoid empty cells
        
        if isempty(sFiles)
            error(['No files to perform GAVR for ' condition_mismatch_names{c} ' ' modality_data{mode}]);
        end
        
        gavr_n = num2str(length(sFiles));
        

        % If stated, find and delete any previous GAVR SENSOR data
        if delete_previous_file == 1
            % check if there is already GAVR source in Group analysis folder
            folders_delete = dir([root_dir_bs '/data/Group_analysis/@intra']);
            infolder_delete = find(endsWith({folders_delete.name}, ['ITPC_' fre_string{fre} '_' participant_group{pg} '_n' gavr_n '.mat']));
            if ~isempty(infolder_delete) % file exists, therefore delete it
               delete([root_dir_bs '/data/Group_analysis/@intra/' folders_delete(infolder_delete).name]);
            end
        end

        % Process: Average: Everything
        sFiles = bst_process('CallProcess', 'process_average', sFiles, [], ...
            'avgtype',       1, ...  % Everything
            'avg_func',      1, ...  % Arithmetic average:  mean(x)
            'weighted',      0, ...
            'matchrows',     0, ...
            'iszerobad',     1);
        
        % error('PAUSED HERE TO SEE WHAT THE OUTCOME FILE IS NAMED (sFiles) TO RENAME ACCORDINGLY')

        % Process: Add tag
        sFiles = bst_process('CallProcess', 'process_add_tag', sFiles, [], ...
            'tag',           ['IPTC_' fre_string{fre} '_' participant_group{pg} '_n' gavr_n], ...
            'output',        2);  % Add to file name (1 to add a tag)

        % Process: Set name
        sFiles = bst_process('CallProcess', 'process_set_comment', sFiles, [], ...
            'tag',           ['ITPC_' fre_string{fre} '_' participant_group{pg} '_n' gavr_n], ...
            'isindex',       1);
    end
end

clearvars('-except', initialVars{:});
disp 'DONE COMPUTING AND AVERAGING ITPC (FFR_Sz)!!!'
disp(datetime)
toc
