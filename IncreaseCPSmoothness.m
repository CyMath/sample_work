function [ controlPoints ] = IncreaseCPSmoothness( controlPoints, depth )
%% IncreaseCPSmoothness takes a set of control points, finds the "corners"
% of the control points, and for each corner smooths out the points to a
% given iteration depth (by connecting midpoints across corners).

% NOTE - the number of added points will be equal to:
% depth * number of corners
% this will require reallocation of the controlPoints matrix a number of
% times equal to the number of corner points, so be careful

% iterate over all control points until we find a corner, and then smooth
% it out by connecting midpoints iteratively.
[N, ~] = size(controlPoints);
k = 1;
while k <= N
    % delta1 = P_i - P_{i-1}. delta2 = P_{i+1} - P_{i-1}.
    % P_i is a corner point iff deltas point in the same direction.
    delta1 = controlPoints(k, :) - controlPoints(mod(k - 2, N) + 1, :);
    delta2 = controlPoints(mod(k, N) + 1, :) - controlPoints(mod(k - 2, N) + 1, :);
    
    % check direction match
    delta1 = delta1 / norm(delta1);
    delta2 = delta2 / norm(delta2);
    
    if dot(delta1, delta2) < 0.999
        % corner point!
        % Get smoothed points and swap them in for the corner point P_i
        smoothed = SmoothCorner(controlPoints(mod(k - 2, N) + 1, :), controlPoints(k, :), controlPoints(mod(k, N) + 1, :), depth);
        if k == 1
            controlPoints = [smoothed; controlPoints(2:end, :)];
        else
            controlPoints = [controlPoints(1:k-1, :); smoothed; controlPoints(k+1:end, :)];
        end
        % update size
        [Nprime, ~] = size(controlPoints);
        k = k + (Nprime - N) - 1;
        N = Nprime;
    end
    
    k = k + 1;
end

end

