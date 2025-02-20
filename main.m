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
        features = [model_outputs_ML velocity_table gesture];
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

%% Sliding windows %%
    % Define window sizes and overlap
window_sizes = [20, 50, 100];  % Window sizes: 20, 50, and 100 frames
overlaps = [10, 25, 50];  % Overlaps: 10, 25, and 50 frames

% Initialize cell arrays to store the windows
%%position_windows = {};
%%velocity_windows = {};


% Apply sliding windows to Position data
%all_features_small = create_sliding_windows(all_features, window_sizes(1), overlaps(1));

% Apply sliding windows to Velocity data
%all_features_medium = create_sliding_windows(all_features, window_sizes(2), overlaps(2));

% Apply sliding windows to Acceleration data
all_features_big = create_sliding_windows(all_features, window_sizes(3), overlaps(3));

disp("Done with windowing")

%%

labels = all_features_big.gesture;
features = all_features_big(:, setdiff(all_features_big.Properties.VariableNames, {'gesture'}));

%% Normalize data
[norm_features, C, S] = normalize(features);

%% Split data
% Create a partition: 80% for training, 20% for testing
cv = cvpartition(length(labels), 'HoldOut', 0.2);  % 80% training, 20% testing

% Create training and test sets using the partition
x_train = features(training(cv), :);  
y_train = labels(training(cv), :);    

x_test = features(test(cv), :);       
y_test = labels(test(cv), :);         


%% Testing base classification tree
mdl = fitcknn(x_test, y_test, 'NumNeighbors',8;

%% Cross validation
% Perform k-fold cross-validation (e.g., 5-fold) for better model evaluation
cv = cvpartition(length(labels), 'KFold', 5);
cvmdl = fitcknn(features, labels, 'NumNeighbors', 8, 'NSMethod', 'kdtree', 'CrossVal', 'on');

% Calculate cross-validation loss
cvLoss = kfoldLoss(cvmdl);
disp(['Cross-validation loss: ', num2str(cvLoss)]);
%%
% Predict on a test set (X_test)
predicted_labels = predict(mdl, x_test);

% Evaluate using confusion matrix or accuracy
confusionMatrix = confusionmat(y_test, predicted_labels);
accuracy = sum(predicted_labels == y_test) / length(y_test);
disp(['Accuracy: ', num2str(accuracy)]);

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


%test_trial = [accel_table model_outputs_ML velocity_table rshoulder_crp lshoulder_crp rhipamp lhipamp rshoulderamp lshoulderamp];
test_trial = [model_outputs_ML velocity_table];   
norm_test_trial = normalize(test_trial, 'center', C, 'scale', S);

%%
% Predict on a test set (X_test)
predicted_labels = predict(mdl, norm_test_trial);

gesture_predict = mode(predicted_labels);
disp(gesture)
disp(gesture_predict)