function [ hiresPoints ] = IncreaseCPResolution( controlPoints, resolution )
%% IncreaseCPResolution takes a set of control points, a target resolution,
% and returns control points that are a target resolution away from one
% another (e.g. within 0.01 of one another) such that the old set of
% control points is a SUBSET of the new control points.

[N, ~] = size(controlPoints);

% Start by determining how many points there will be in total
ssLengths = zeros(N, 1);
panelNumPoints = zeros(N, 1);
for i=1:N
    ssLengths(i) = norm(controlPoints(mod(i, N) + 1, :) - controlPoints(i, :));
    panelNumPoints(i) = ceil(ssLengths(i) / resolution);
end

hiresPoints = zeros(sum(panelNumPoints), 1);

% Now for each panel i, set the new points epsilon away from eachother
sumNumPoints = 0;
for i=1:N
    % equally space points along the panel
    delta = ssLengths(i) / panelNumPoints(i);
    A = controlPoints(i, :);
    B = controlPoints(mod(i, N) + 1, :);
    AB = (B - A) / norm(B - A);
    for j=1:panelNumPoints(i)
        hiresPoints(sumNumPoints + j, 1:2) = A + AB * delta * (j - 1);
    end
    sumNumPoints = sumNumPoints + panelNumPoints(i);
end

end

