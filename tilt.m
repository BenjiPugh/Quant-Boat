function [waterline, moment_arm] = tilt(P, insideBoat, rho_water, deltaA, L, CoM, boatdisp)
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
    function res = buoyancy(d)
        underWater = (P(2,:) <= d)'; % find meshgrid points under the water
        underWaterAndInsideBoat = insideBoat & underWater;
        watermasses = underWaterAndInsideBoat*rho_water*deltaA*L;
        watermass = sum(watermasses); 
        CoB = P * watermasses ./ watermass; % mass average of the under water boat points
        res = watermass - boatdisp; % difference between boat displacement and water displacement
    end
end