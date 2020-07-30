clear
clc

%% TEST 1 - Plot flow field from a single source sheet.
% A = [-0.25 -0.25];
% B = [0.25 0.25];
% 
% range = -0.5:0.026:0.5;
% [x, y] = meshgrid(range, range);
% [u, v] = UVSS_List(A, B, x, y);
% 
% quiver(x, y, u, v);
% hold on
% plot([A(1) B(1)], [A(2) B(2)], 'r');

%% TEST 2 - Solve AIC for a freestream and plot the flow field.
% freestream = @(P) [1 0];
% controlPoints = [-0.5 0; 0 0.5; 0.5 0; 0 -0.5]; % diamond body
% lambda = AIC_Solve(controlPoints, freestream);
% 
% % plot resulting flow field
% range = -1:0.021:1;
% [x, y] = meshgrid(range, range);
% u = zeros(size(x)) + 1; % freestream
% v = zeros(size(x));
% for i=1:4
%    [nu, nv] = UVSS_List(controlPoints(i, :), controlPoints(mod(i, 4) + 1, :), x, y);
%    u = u + lambda(i) * nu;
%    v = v + lambda(i) * nv;
% end
% quiver(x, y, u, v);
% PlotControlPoints(controlPoints);
% hold on;
% streamline(x, y, u, v, zeros(size(-0.5:0.011:0.5)) - 0.75, -0.5:0.011:0.5);

%% TEST 3 - More complex body with freestream
freestream = @(P) VelocityFreestreamVortices([0.5 0.25], [1, -2*pi], [-0.6 0; -0.25 0.5], P);
% ORIGINAL TESTING BODY
%controlPoints = [-0.5 0.05; -0.4 0.3; 0 0.5; 0.3 0.3; 0.5 0.05; 0.5 -0.05; 0.3 -0.3; 0 -0.5; -0.3 -0.3; -0.5 -0.05];
% NEW ACTUAL BODY
%controlPoints = [-0.5 0; -1/3 1/3-0.02; -1/3+0.02 1/3; -1/6 1/3+0.02; -1/6+0.02 1/3; 0 0; 1/6 1/6; 1/3 0; 1/6 -1/6; 0 0; -1/6 -1/3; -1/3 -1/3];
%controlPoints = [-1/6 -1/3; -1/3 -1/3; -1/2 0; -1/3 1/3; -1/6 1/3; 0 0; 1/6 1/6; 1/3 0; 1/6 -1/6; 0 0];
%[CN, ~] = size(controlPoints);
%for k=1:CN
%    controlPoints(k,:) = controlPoints(k,:) + (rand / 100);
%end

% NB probably good to increase resolution before smoothing.
% These are trial numbers, can be adjusted
%controlPoints = IncreaseCPResolution(controlPoints, 0.04);
%controlPoints = IncreaseCPSmoothness(controlPoints, 3);

% USING NEW BODY GENERATING FUNCTION
controlPoints = FishCPFromRods([-1/2 0], [0 0], [sqrt(2)/3 sqrt(2)/3]);

tic
lambda = AIC_Solve(controlPoints, freestream);
toc

for k=1:3
    PlotControlPoints(FishCPFromRods([-1/2 0], [0 0], [sqrt(2)/3 sqrt(2)/3]));
end

%return

[N, ~] = size(controlPoints);

% plot resulting flow field
range = -1:0.02:1;
[x, y] = meshgrid(range, range);
u = zeros(size(x));
v = zeros(size(x));
[nx, ~] = size(x);
for i=1:nx
    for j=1:nx
        [u(i, j), v(i, j)] = freestream([x(i, j), y(i, j)]);
    end
end
for i=1:N
   [nu, nv] = UVSS_List(controlPoints(i, :), controlPoints(mod(i, N) + 1, :), x, y);
   u = u + lambda(i) * nu;
   v = v + lambda(i) * nv;
end

b = PnPolyMesh(controlPoints, x, y);
[nx, ~] = size(x);
[ny, ~] = size(y);
for i=1:nx
    for j=1:ny
        if b(i, j)
            u(i, j) = 0;
            v(i, j) = 0;
        end
    end
end

quiver(x, y, u, v);
PlotControlPoints(controlPoints);
com = [sum(controlPoints(:, 1)), sum(controlPoints(:, 2))] * 2 / numel(controlPoints);
hold on;
scatter(com(1), com(2));
streamline(x, y, u, v, zeros(size(-0.5:0.05:0.5)) - 0.75, -0.5:0.05:0.5);