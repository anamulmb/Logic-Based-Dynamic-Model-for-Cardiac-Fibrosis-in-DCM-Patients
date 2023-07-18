% to run this, place this in the same folder as ODE and parameter folder
% Run the command : [optimalParams = optimizeParametersGA();]
% Result in 1D array 0f w = []
function optimalParams = optimizeParametersGA()
    % Load parameters and initial conditions
    [params, y0] = Card_Muscle_Contraction_ODE_loadParams();

    % Set the desired initial condition for H
    y0(4) = 0.5;

    % Set the experimental measurements
    experimentalTNNC1 = 0.1;
    experimentalTNNI3 = 0.3;

    % Define the objective function
    objectiveFunction = @(w) calculateMSE(w, params, y0, experimentalTNNC1, experimentalTNNI3);

    % Set the bounds for w
    lb = zeros(18, 1);  % Lower bounds for w
    ub = ones(18, 1);   % Upper bounds for w

    % Set up the genetic algorithm options
    gaOptions = optimoptions('ga', 'Display', 'iter');

    % Solve the optimization problem using the genetic algorithm
    optimalParams = ga(objectiveFunction, 18, [], [], [], [], lb, ub, [], gaOptions);
end

function mseTotal = calculateMSE(w, params, y0, experimentalTNNC1, experimentalTNNI3)
    % Update the parameter values
    params{1}(1:18) = w;

    % Run the simulation
    tspan = [0 10];
    options = [];
    [~, y] = ode23(@(t, y) Card_Muscle_Contraction_ODE(t, y, params), tspan, y0, options);

    % Extract simulated values of TNNC1 and TNNI3
    simulatedTNNC1 = y(:, 10);
    simulatedTNNI3 = y(:, 11);

    % Calculate total MSE
    mseTotal = mean((simulatedTNNC1 - experimentalTNNC1).^2 + (simulatedTNNI3 - experimentalTNNI3).^2);
end