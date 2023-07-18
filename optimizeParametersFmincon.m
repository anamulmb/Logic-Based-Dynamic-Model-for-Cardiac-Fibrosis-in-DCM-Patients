% to run this, place this in the same folder as ODE and parameter folder
% Run the command : [optimalParams = optimizeParametersFmincon();]
% Result in a list of w
function optimalParams = optimizeParametersFmincon()
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
    lb = zeros(18, 1);   % Lower bounds for w
    ub = ones(18, 1);    % Upper bounds for w

    % Set up the optimization problem
    problem = struct();
    problem.objective = objectiveFunction;
    problem.x0 = ones(18, 1);  % Initial guess for w
    problem.lb = lb;
    problem.ub = ub;
    problem.solver = 'fmincon';  % Use fmincon solver
    problem.options = optimoptions(@fmincon, 'Algorithm', 'sqp', 'MaxIterations', 1500);

    % Solve the optimization problem using fmincon
    optimalParams = fmincon(problem);
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
