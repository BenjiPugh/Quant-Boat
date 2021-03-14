function [waterline, moment_arm] = tilt(P, insideBoat, rho_water, deltaA, L, CoM, boatdisp)
    boatcolor = [0.9290 0.6940 0.1250]; % define the color of the boat
    watercolor = [0 0.4470 0.7410]; % define the color of the water
    
    W = 5; % Width [m]
    H = 3; % Depth [m]
    L = 0.6; % Length (of extrusion) [m]
    wrho = 1000; % water density kg/m^3
    g = 9.8; % gravity m/s^2


    dmin = min(P(2,:)); % find the minimum z coordinate of the boat
    dmax = max(P(2,:)); % find the maximum z coordinate of the boat
    d = fzero(@buoyancy,[dmin,dmax]); % find the waterline d
    underWater = (P(2,:) <= d)'; % test if each part of the meshgrid is under the water
    underWaterAndInsideBoat = insideBoat & underWater;  % the & returns 1 if both conditions are true
    watermasses = underWaterAndInsideBoat*rho_water*deltaA*L; % compute the mass of each underwater section
    watermass = sum(watermasses); % sum up the under water masses
    CoB = P*watermasses./watermass; % mass average of the under water boat points
    waterline = d; % save the waterline
    moment_arm = CoB(1, 1) - CoM(1, 1);
    
    hold off % prepare the figure
    scatter(P(1,insideBoat),P(2,insideBoat),[],boatcolor), axis equal, axis([-max(W,H) max(W,H) -max(W,H) max(W,H)]), hold on % plot the boat
    scatter(P(1,underWaterAndInsideBoat),P(2,underWaterAndInsideBoat),[],watercolor) % plot the underwater section
    scatter(CoM(1,1), CoM(2,1), 1000, 'r.'); % plot the COM
    scatter(CoB(1,1), CoB(2,1), 1000, 'k.'); % plot the COB
    drawnow % force the graphics
    function res = buoyancy(d)
        underWater = (P(2,:) <= d)'; % find meshgrid points under the water
        underWaterAndInsideBoat = insideBoat & underWater;
        watermasses = underWaterAndInsideBoat*rho_water*deltaA*L;
        watermass = sum(watermasses); 
        CoB = P * watermasses ./ watermass; % mass average of the under water boat points
        res = watermass - boatdisp; % difference between boat displacement and water displacement
    end
end