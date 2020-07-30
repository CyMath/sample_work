function [ controlPoints ] = FishCPFromRods( HEAD, ANCHOR, TAIL )
%% FishCPFromRods takes the 3 points defining the controlled rod setup and
% returns a set of control points defining the fish body.
% NB at the moment, a few of these points might not fully contain the rods
% due to smoothing - this should hopefully not matter since the centre of
% mass in the rods will be at the very middle.

%% 1. Head
hDelta = HEAD - ANCHOR;
hNormal = ([0 -1; 1 0] * (-hDelta)')';
headPts = [(1/3) * hDelta - (2/3) * hNormal; (2/3) * hDelta - (2/3) * hNormal; hDelta; (2/3) * hDelta + (2/3) * hNormal; (1/3) * hDelta + (2/3) * hNormal; 0 0];
for k=1:6
    headPts(k, :) = headPts(k, :) + ANCHOR;
end

%% 2. Tail
tDelta = TAIL - ANCHOR;
tNormal = ([0 -1; 1 0] * tDelta')';
tailPts = [(1/2) * tDelta + (1/4) * tNormal; tDelta; (1/2) * tDelta - (1/4) * tNormal; 0 0];
for k=1:4
    tailPts(k, :) = tailPts(k, :) + ANCHOR;
end

%% 3. Combine points
controlPoints = [headPts; tailPts];
for k=1:10
    nx = randn;
    ny = randn;
    if abs(nx) > 10
        nx = nx * 10 / abs(nx);
    end
    if abs(ny) > 10
        ny = ny * 10 / abs(ny);
    end
    controlPoints(k, :) = controlPoints(k, :) + [nx, ny] / 10000;
end

%% 4. Increase body resolution and then apply smoothing!
controlPoints = IncreaseCPResolution(controlPoints, 0.04);
controlPoints = IncreaseCPSmoothness(controlPoints, 3);

end

