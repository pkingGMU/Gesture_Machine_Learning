%% Read in .mat files %%

clc
clear

% Imports
addpath('Functions')

data_path = fullfile(pwd, 'Data');
    
% Get a list of folders within the 'Data' directory
dir_info = dir(data_path);
is_folder = [dir_info.isdir];
folder_names = {dir_info(is_folder).name};

% Filter out '.' and '..' which represent current and parent directories
folder_names = folder_names(~ismember(folder_names, {'.', '..'}));

% Display list dialog to select subject folders
if isempty(folder_names)
    uialert(uifigure, 'No folders found in Data directory.', 'Folder Error');
else
    [selection, ok] = listdlg('PromptString', 'Select Subject Folders:', ...
                              'SelectionMode', 'multiple', ...
                              'ListString', folder_names);

    % If OK and made a selection
    if ok
        selected_folders = fullfile(data_path, folder_names(selection));
        disp('Selected folders for processing:');
        disp(selected_folders);
    else
        disp('No folders selected.');
    end
end

all_features = [];

 % Each subject folder
for i = 1:length(selected_folders)
    subject = selected_folders(i);

    % Get subject data for subject folder

    trial_dir_info = dir(subject{1,1});
    is_folder = [trial_dir_info.isdir];
    trial_folder_names = {trial_dir_info(is_folder).name};
    
    % Filter out '.' and '..' which represent current and parent directories
    trial_folder_names = trial_folder_names(~ismember(trial_folder_names, {'.', '..'}));
    
    

    for trial = 1:length(trial_folder_names)
        trial_path = trial_folder_names{trial};
        trial_data_folder = fullfile(subject{1}, trial_path, 'Idv');
        saved_files = dir(fullfile(trial_data_folder, '*.mat'));
        
        for mat_files = 1:numel(saved_files)
            file = fullfile(trial_data_folder, saved_files(mat_files).name);
            load(file);
        end

        accel_table.Properties.VariableNames = strcat("accel_", accel_table.Properties.VariableNames);
        model_outputs_ML.Properties.VariableNames = strcat("model_", model_outputs_ML.Properties.VariableNames);
        velocity.Properties.VariableNames = strcat("velocity_", velocity_table.Properties.VariableNames);
        rshoulder_crp = array2table(rshoulder_crp, "VariableNames", {'rshoulder_crp'});
        lshoulder_crp = array2table(lshoulder_crp, "VariableNames", {'lshoulder_crp'});
        gesture = table(repmat(gesture, height(accel_table), 1));
        gesture.Properties.VariableNames = {'gesture'};
        rhipamp = table(repmat(rhipamp, height(accel_table), 1));
        rhipamp.Properties.VariableNames = {'rhipamp'};
        lhipamp = table(repmat(lhipamp, height(accel_table), 1));
        lhipamp.Properties.VariableNames = {'lhipamp'};
        rshoulderamp = table(repmat(rshoulderamp, height(accel_table), 1));
        rshoulderamp.Properties.VariableNames = {'rshoulderamp'};
        lshoulderamp = table(repmat(lshoulderamp, height(accel_table), 1));
        lshoulderamp.Properties.VariableNames = {'lshoulderamp'};

       
        %features = [accel_table model_outputs_ML velocity_table rshoulder_crp lshoulder_crp rhipamp lhipamp rshoulderamp lshoulderamp gesture];
       features = [model_outputs_ML gesture];

        all_features = [all_features; features];

    end

    
    

    %%% new arrange table for Obstacle Crossing?

    % Easy naming convention
    % Regex to get subject name
    subject = char(subject);
    parts = strsplit(subject, 'Data');
    subject_name = parts{2};
    subject_name = regexprep(subject_name, '[\\/]', '');

    % Display subject for debugging
    subject =  'sub' + string(subject_name);

    subject = regexprep(subject, ' ', '_');

    

end

%%
clearvars -except all_features


labels = all_features.gesture;
features = all_features(:, setdiff(all_features.Properties.VariableNames, {'gesture'}));



% Standardization
for i = 1:size(features, 2)
    norm_features(:, i) = rescale(table2array(features(:, i)), 0, 1);
end

%% Permutation

rng(1)
p = randperm(height(labels));
xx = norm_features(p, :);
yy = labels(p, :);





%% test different data sets

trial_data_folder = fullfile(pwd, 'Data', '010_Ohio', 'DTWalk08', 'Idv');
saved_files = dir(fullfile(trial_data_folder, '*.mat'));

for mat_files = 1:numel(saved_files)
    file = fullfile(trial_data_folder, saved_files(mat_files).name);
    load(file);
end

accel_table.Properties.VariableNames = strcat("accel_", accel_table.Properties.VariableNames);
model_outputs_ML.Properties.VariableNames = strcat("model_", model_outputs_ML.Properties.VariableNames);
velocity.Properties.VariableNames = strcat("velocity_", velocity_table.Properties.VariableNames);
rshoulder_crp = array2table(rshoulder_crp, "VariableNames", {'rshoulder_crp'});
lshoulder_crp = array2table(lshoulder_crp, "VariableNames", {'lshoulder_crp'});
%%gesture = table(repmat(gesture, height(accel_table), 1));
%%gesture.Properties.VariableNames = {'gesture'};
rhipamp = table(repmat(rhipamp, height(accel_table), 1));
rhipamp.Properties.VariableNames = {'rhipamp'};
lhipamp = table(repmat(lhipamp, height(accel_table), 1));
lhipamp.Properties.VariableNames = {'lhipamp'};
rshoulderamp = table(repmat(rshoulderamp, height(accel_table), 1));
rshoulderamp.Properties.VariableNames = {'rshoulderamp'};
lshoulderamp = table(repmat(lshoulderamp, height(accel_table), 1));
lshoulderamp.Properties.VariableNames = {'lshoulderamp'};

test_trial = [accel_table model_outputs_ML velocity_table rshoulder_crp lshoulder_crp rhipamp lhipamp rshoulderamp lshoulderamp ];

norm_test_trial = normalize(test_trial, 'center', C, 'scale', S);

% Perform K-means clustering on test trial data
[cluster_test_idx, ~] = kmeans(norm_test_trial, k, 'Start', cluster_centers);

% Display results: output the predicted cluster for the test data
disp(['Predicted cluster: ', num2str(cluster_test_idx)])