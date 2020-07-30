function [force, torque] = ForceTorqueCalc (controlPoints, flowFieldFnHandle, stagPressure)
% ForceTorqueCalc calcualtes the resulting force and torques acting on the 
% body due to the pressures forces acting on the body

%% STEP 0: Define variables used throughout program
% Number of panels in shape
controlPoints = FishCPFromRods([0.5 0], [0.7 0], [0.75 0.25]);
N = size(controlPoints)
% Desity of saltwater [kg/m^3] (Need to find a reputable source for this)
RHO = 1020;
% Thickness of each panel [m](maybe should be a parameter that gets passed
% in?)
THICKNESS = 0.1;
% Center of mass of shape
COM = sum(controlPoints) / N;

%% STEP 1: Determine normal vectors for each panel
% Normal vector pointing outward from shape for each panel
normals = zeros(size(controlPoints));

for i=1:N
    % rotate B - A by 90 degrees
    normals(i, :) = ([0 -1; 1 0] * (controlPoints(mod(i, N) + 1, :) - controlPoints(i, :))')';
    normals(i, :) = normals(i, :) / norm(normals(i, :));
end

%% STEP 2: Calculate Midpoint and Length for each panel
% Coordinatees of the midpoint for each panel 
midpoints = zeros(size(controlPoints));
% The length of each panel
lengths = zeros(N,1);

for i=1:N
    midpoints(i,:) = (controlPoints(i) + controlPoints(mod(i,N)+1)) / 2;
    lengths(i) = vecnorm(controlPoints(i) - controlPoints(mod(i,N)+1));
end

%% STEP 3: Force due to pressure at each panel's midpoint
% Calcualte the force due to pressure acting at the midpoint of each panel
pressureForce = zeros(size(controlPoints));

for i=1:N
    % get x and y components of velocity at midpoint of panel using
    % TotalFlow function and then calcualte corresponding pressure force.
    % Note that pressure force acts in inward-direction to shape.
    [u,v] = TotalFlow( controlPoints, lambda, flowFieldFnHandle, midpoints(i,:));
    pressureForce(i,:) = ((stagPressure - 0.5* RHO * vecnorm([u,v])^2) * length(i) * THICKNESS) * -normals(i,:);
end

%% STEP 4: Total force due to pressure acting at COM
% Gives a single force acting at the center of mass of the body

force = sum(pressureForce);

%% STEP 5: Torque due to pressure acting on body
% Gives a single torque that acts about the COM of the body.
% Recall: Torque = position x force.

% NOTE 1: To use cross porduct in MATLAB, vecotr needs to be 1x3 or 3x1
% vectors
% NOTE 2: Need to genereate position vector (ie location force is acting 
% relative to COM) for each pressure force. This is achieved by creating a
% vector from the COM to the midpoint of the segment that the pressure
% force is acting on.

% position of force vectors realtive to COM with column of zeros added to
% make the position vectors 3x1
position = horzcat((midpoints - COM),zeros(N,1));

% temporary vector to put the forces into 3x1 vectors
tempForce = horzcat(pressureForce,zeros(N,1));

% Calcualtes the cross product for total torque acting on the body. 
torque = sum(cross(position,tempForce,2));







