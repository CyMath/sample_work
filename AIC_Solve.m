function [ lambda ] = AIC_Solve( controlPoints, flowFieldFnHandle )
%% AIC_Solve - This function computes the aerodynamic influence coefficient
% (AIC) matrix for a given set of control points (defining the body shape)
% and a given (FUNCTION HANDLE) flow field function. Note that the last
% control point is assumed to connect to the first one, so as to make the
% body properly closed.
% Once the function computes the AIC matrix A, it uses it to solve for the
% density coefficients of each panel by inverting the associated matrix
% equation (A*lambda = b <=> lambda = A^-1 * b). These lambda values are
% then returned as the function output.
% NB: controlPoints is passed as a 2-column matrix, each row w/ 1 point.

disp('Starting AIC Solve...');

% get number of panels.
[N, ~] = size(controlPoints);

% general procedure: A_ij = the untreated (density 1) velocity from sheet j
% at the midpoint of sheet i * the normal direction of sheet i

%% 1. Compute the normal directions for each sheet
% normals are vectors, so like controlPoints will be a 2-column matrix.
normals = zeros(size(controlPoints));
for i=1:N
    % rotate B - A by 90 degrees
    normals(i, :) = ([0 -1; 1 0] * (controlPoints(mod(i, N) + 1, :) - controlPoints(i, :))')';
    normals(i, :) = normals(i, :) / norm(normals(i, :));
end

%% 2. Compute the AIC matrix and b.
A = zeros(N, N);
b = zeros(1, N);
for i=1:N
    M = (controlPoints(mod(i, N) + 1, :) + controlPoints(i, :)) / 2;
    [midnormalu, midnormalv] = flowFieldFnHandle(M);
    b(i) = -dot(normals(i, :), [midnormalu, midnormalv]);
    for j=1:N
        CA = controlPoints(j, :);
        CB = controlPoints(mod(j, N) + 1, :);
        
        if i == j
            % evaluate lim h->0 v(0, h) for untreated SS
            A(i, j) = 0.5;
        else
            [u, v] = UntreatedVelocitySS(CA, CB, M);
            A(i, j) = dot([u v], normals(i, :));
        end
    end
end

%disp(A);
%disp(b);
%% 3. Invert the AIC matrix and solve for lambda.
lambda = (inv(A) * b')';
end

