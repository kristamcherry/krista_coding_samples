%This program illustrates the sensitivity of initial conditions 
%in the Lorenz equation by numerically solving using 
%slightly different initial conditions.

clear all; close all; clc;

% Define Lorenz system parameters
Beta = [10; 28; 8/3];

% Initial conditions
x0_1 = [1,1,1];
x0_2 = [1.1,1,1];
dt = 0.001;
tspan = 0:dt:40;

% Define Lorenz function
Lorenz = @(t, x, Beta) [
    Beta(1) * (x(2) - x(1));
    x(1) * (Beta(2) - x(3)) - x(2);
    x(1) * x(2) - Beta(3) * x(3)
];

% Solve and plot for initial condition x0_1
[t, x1] = ode45(@(t, x) Lorenz(t, x, Beta), tspan, x0_1);
figure;
plot(tspan, x1(:, 1));
title('Lorenz System with Initial Condition [1,1,1]');
xlabel('Time'); ylabel('x(1)');

% Solve and plot for initial condition x0_2
[t, x2] = ode45(@(t, x) Lorenz(t, x, Beta), tspan, x0_2);
figure;
plot(tspan, x2(:, 1));
title('Lorenz System with Initial Condition [1.1,1,1]');
xlabel('Time'); ylabel('x(1)');

% Plot 3D trajectory for initial condition x0_1
figure;
plot3(x1(:, 1), x1(:, 2), x1(:, 3), 'LineWidth', 1.5);
title('3D Trajectory of Lorenz System');
xlabel('x(1)'); ylabel('x(2)'); zlabel('x(3)');