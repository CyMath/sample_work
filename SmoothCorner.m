function [ midpoints ] = SmoothCorner( P1, P2, P3, depth )
%% SmoothCorner takes 3 points (P1->P2->P3 w/ P2 a corner) and an
% iteration depth to smooth out the curve to. depth 1 is minimal.
% returns the MIDPOINTS (what replaces P1).

midpoints = [(P1 + P2) / 2; (P2 + P3) / 2];
depth = depth - 1;
while depth > 0
    % add last point first and work backwards
    midpoints = [midpoints; (midpoints(end, :) + P3) / 2];
    [M, ~] = size(midpoints);
    for k=1:M-2
        midpoints(end - k, :) = (midpoints(end - k, :) + midpoints(end - k - 1, :)) / 2;
    end
    midpoints(1, :) = (midpoints(1, :) + P1) / 2;
    
    depth = depth - 1;
end

end

