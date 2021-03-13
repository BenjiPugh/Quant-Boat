function [AMV] = letsgo(h)
W = 5; % Width [m]
H = 3; % Depth [m]
L = 0.6; % Length (of extrusion) [m]
rho80 = 0.8*1250;      % 100% infill [kg/m^3]
rho30 = 0.3 * 1250; %  50% infill [kg/m^3]
% Create density function
fun_rho = @(y) rho80 * (y < h) + rho30 * (y >= h);

% Generate grid of points
Npts = 200; % number of 1D spatial points (probably don't change)
xPoints = linspace(-W/2,W/2,Npts); % set of points in the x direction (horizontal)
zPoints = linspace(0,H,Npts); % set of points in the z direction (vertical)

[X, Z] = meshgrid(xPoints, zPoints); % create the meshgrid
P = [X(:)'; Z(:)'];

% Find interior points
insideBoat = transpose(P(2,:) >= H-(sqrt(2*pi)*exp(-(P(1,:).^2./2))) & P(1,:) <= H);
% Compute area elements
deltaA = (xPoints(2) - xPoints(1)) * (zPoints(2) - zPoints(1));

% Use the density function to vary the infill
masses = insideBoat .* fun_rho(P(2, :)') * deltaA * L;

% Compute the COM
CoM = (P*masses)/(dot(ones(size(masses)), masses));

rho_water = 1000; % density of water [kg/m^3]
masses_water = insideBoat * rho_water * deltaA * L;

mass_boat = sum(masses);
mass_water = sum(masses_water);

displacement_ratio = mass_boat / mass_water;

maxdisp = sum(masses_water); % find the maximum displacement
boatdisp = displacement_ratio*maxdisp;
dtheta = 1; % define the angle step
R = [cosd(dtheta) sind(dtheta); -sind(dtheta) cosd(dtheta)]; % define rotation matrix
j = 1; % set the counter
for theta = 0:dtheta:180 % loop over the angles
    [waterline, moment_arm]=  tilt(P, insideBoat, rho_water, deltaA, L, CoM, boatdisp);
    line(j)= waterline;
    marm(j) = moment_arm;
    angle(j) = theta; % define the angle
    P = R*P; % rotate the boat a little
    CoM = R*CoM; % rotate the center of mass too
    j = j + 1; % update the counter
end
AMV = amvFinder(marm);
function [AMV] = amvFinder(moment_arm)
    close = moment_arm(40:140);
    [d ix] = min(abs(close));
    val = close(ix-1:ix+1);
    a1 = find(moment_arm==val(1));
    a2 = find(moment_arm ==val(2));
    AMV = (a1+a2)/2;
end
end