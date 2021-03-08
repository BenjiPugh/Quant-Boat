function [insideBoat] = boat4_inside(scale)
% Note: This code has *almost* everything you need to generate a righting 
% arm curve. Your task is to complete the buoyancy(d) function below.
% The buoyancy(d) function is defined at the bottom of the file;
% this code will not run until you complete it!!!


%% design parameters
L = 10; % length m 
n = 2; % shape parameter

% Ratio of boat displacement to max diplacement; this is a function of the 
% infill percentage you choose in your print.
dispratio = 0.3; 
%% physical constants
wrho = 1000; % water density kg/m^3
g = 9.8; % gravity m/s^2

W = 5
H = 3
%% boat definition and key variables
Npts = 200; % number of 1D spatial points (probably don't change)
xPoints = linspace(-W/2,W/2,Npts); % set of points in the x direction (horizontal)
zPoints = linspace(0,H,Npts); % set of points in the z direction (vertical)

[X, Z] = meshgrid(xPoints, zPoints); % create the meshgrid
P = [X(:)'; Z(:)']; % pack the points into a matrix
insideBoat = transpose(P(2,:) >= scale * (1-cos(P(1,:))) & P(1,:) <= H); % find all the points inside the boat - a logical array

end