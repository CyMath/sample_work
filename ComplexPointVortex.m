clear all;
clc;

omega = 50;
gamma = 2*pi*omega;
z_0 = 0+0i;
[x,y] = ndgrid(-1:0.01:1);
zrange = x + 1i*y;
complexFlow1 = PointVortexFlow(gamma, z_0, zrange);
complexFlow2 = PointVortexFlow(2 * gamma, z_0 + 0.25i, zrange);

complexFlow = complexFlow1 + complexFlow2;

quiver(real(zrange), imag(zrange), real(complexFlow), imag(complexFlow));
