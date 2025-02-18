%% Read in .mat files %%

clc
clear

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

        features = [accel_table model_outputs_ML velocity_table rshoulder_crp lshoulder_crp];

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