function [ ] = PlotControlPoints( controlPoints )
%% PlotControlPoints plots lines between the control points given onto the
% current figure.
% NB controlPoints must be a 2-column matrix, each row giving a point.
hold on;
plot([controlPoints(:, 1)', controlPoints(1, 1)], [controlPoints(:, 2)', controlPoints(1, 2)], 'r');
scatter(controlPoints(:, 1), controlPoints(:, 2));
hold off;
end


