% Load parameters with default ymax values
[params, y0] = Zeigler2016_ODE_loadParams();

% Create table to store simulation results
resultsTable = table('Size', [numel(params{3}), numel(params{3})+1], 'VariableTypes', [{'string'}, repmat({'double'}, 1, numel(params{3}))], 'VariableNames', [{'Species Name'}, params{4}]);

% Assign species names to the first column of the table
resultsTable(:, 1) = params{4}';

% Run simulation for each species with ymax set to 0
for i = 1:numel(params{3})
    % Set ymax to 0 for current species
    ymax_modified = params{3};
    ymax_modified(i) = 0;
    
    % Update parameters with modified ymax
    params_modified = params;
    params_modified{3} = ymax_modified;
    
    % Run single simulation
    tspan = [0 10];
    options = [];
    [t, y] = ode23(@Zeigler2016_ODE, tspan, y0, options, params_modified);
    
    % Store simulation results in the table
    resultsTable(i, 2:end) = num2cell(y(end, :));
end

% Save the table as a CSV file
writetable(resultsTable, 'sensitivity_results.csv');
