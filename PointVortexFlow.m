function [ complexVelocity ] = PointVortexFlow(gamma, origin, range)
%POINTVORTEX Return complex (x + iy) velocity at all points in range for
%   vortex with strength gamma with center origin.
reframe = range - origin;

reframe = reframe ./ (reframe .* conj(reframe)); % divide by square of modulus
complexVelocity = reframe .* 1i .* gamma ./ (2 * pi);
end


