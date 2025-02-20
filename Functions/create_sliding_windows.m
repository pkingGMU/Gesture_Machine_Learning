% Example function to create sliding windows for a table
function windows_table = create_sliding_windows(data, window_size, overlap)
    num_rows = height(data);  % Get number of rows in the data
    step_size = window_size - overlap;  % Calculate the step size
    
    % Initialize a cell array to store windows
    windows_table = table();
    
    % Loop through the data, applying sliding windows
    for start_idx = 1:step_size:(num_rows - window_size + 1)
        end_idx = start_idx + window_size - 1;  % Calculate the window end index
        
        % Extract the current window and concatenate it with the previous windows
        current_window = data(start_idx:end_idx, :);
        
        % Add the current window to the final table
        windows_table = [windows_table; current_window];  % Append rows
    end
end