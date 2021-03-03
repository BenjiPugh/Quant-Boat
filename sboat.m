function [angle, moment_arm] = sboat(W, H)
% Note: This code has *almost* everything you need to generate a righting 
% arm curve. Your task is to complete the buoyancy(d) function below.
% The buoyancy(d) function is defined at the bottom of the file;
% this code will not run until you complete it!!!

%% housekeeping
clf % clear the current figure
boatcolor = [0.9290 0.6940 0.1250]; % define the color of the boat
watercolor = [0 0.4470 0.7410]; % define the color of the water
%% design parameters
L = 10; % length m 
n = 2; % shape parameter

% Ratio of boat displacement to max diplacement; this is a function of the 
% infill percentage you choose in your print.
dispratio = 0.3; 
%% physical constants
wrho = 1000; % water density kg/m^3
g = 9.8; % gravity m/s^2
%% boat definition and key variables
Npts = 200; % number of 1D spatial points (probably don't change)
xPoints = linspace(-W/2,W/2,Npts); % set of points in the x direction (horizontal)
zPoints = linspace(0,H,Npts); % set of points in the z direction (vertical)

[X, Z] = meshgrid(xPoints, zPoints); % create the meshgrid
P = [X(:)'; Z(:)']; % pack the points into a matrix
insideBoat = transpose(P(2,:) >= W/3 & P(1,:) <= H); % find all the points inside the boat - a logical array

dx = xPoints(2)-xPoints(1); % delta x
dz = zPoints(2)-zPoints(1); % delta z
dA = dx*dz; % define the area of each small section
boatmasses = insideBoat*wrho*dA*L; % find the water mass of each small section
maxdisp = sum(boatmasses); % find the maximum displacement
boatdisp = dispratio*maxdisp; % set the displacement of the boat
CoD = P*boatmasses/maxdisp; % find the centroid of the boat
P = P - CoD; % center the boat on the centroid
CoD = CoD - CoD; % update the centroid
CoM = CoD; % set the center of mass

%% main loop over the heel angles
dtheta = 1; % define the angle step
R = [cosd(dtheta) sind(dtheta); -sind(dtheta) cosd(dtheta)]; % define rotation matrix
j = 1; % set the counter
figure(1);

for theta = 0:dtheta:180 % loop over the angles
    dmin = min(P(2,:)); % find the minimum z coordinate of the boat
    dmax = max(P(2,:)); % find the maximum z coordinate of the boat
    d = fzero(@buoyancy,[dmin,dmax]); % find the waterline d
    underWater = (P(2,:) <= d)'; % test if each part of the meshgrid is under the water
    underWaterAndInsideBoat = insideBoat & underWater;  % the & returns 1 if both conditions are true
    watermasses = underWaterAndInsideBoat*wrho*dA*L; % compute the mass of each underwater section
    watermass = sum(watermasses); % sum up the under water masses
    CoB = P*watermasses./watermass; % mass average of the under water boat points
    waterline(j) = d; % save the waterline
    moment_arm(j) = CoB(1, 1) - CoM(1, 1);
    AVS = find(moment_arm == 0);
    angle(j) = theta; % define the angle
    hold off % prepare the figure
    scatter(P(1,insideBoat),P(2,insideBoat),[],boatcolor), axis equal, axis([-max(W,H) max(W,H) -max(W,H) max(W,H)]), hold on % plot the boat
    scatter(P(1,underWaterAndInsideBoat),P(2,underWaterAndInsideBoat),[],watercolor) % plot the underwater section
    scatter(CoM(1,1), CoM(2,1), 1000, 'r.'); % plot the COM
    scatter(CoB(1,1), CoB(2,1), 1000, 'k.'); % plot the COB
    drawnow % force the graphics
    P = R*P; % rotate the boat a little
    CoM = R*CoM; % rotate the center of mass too
    j = j + 1; % update the counter
end
%% plot the moment arm versus the angle
%figure(2); clf;
%plot(angle, moment_arm) % plot the data
%AVS = find(moment_arm ==0);
%xlabel('heel angle (degrees)') 
%ylabel('Moment arm (m)')
%grid on

%% TODO: Complete the bouyancy function - should be zero when balanced
function res = buoyancy(d)
    underWater = (P(2,:) <= d)'; % find meshgrid points under the water
    underWaterAndInsideBoat = insideBoat & underWater;
    watermasses = underWaterAndInsideBoat*wrho*dA*L;
    watermass = sum(watermasses); 
    CoB = P * watermasses ./ watermass; % mass average of the under water boat points
    res = watermass - boatdisp; % difference between boat displacement and water displacement
end

end