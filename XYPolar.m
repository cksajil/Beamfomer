function [Thetas,H]  = XYPolar(beta, k)

%% Default Parameters
ANGLE_RES           = 500;          % Number of angle points to calculate
d                   = 0.01;         % Element separation in metres
f                   = 1000.0;       % Signal frequency in Hz 
C                   = 343.0;   
Thetas              = 0:2*pi/ANGLE_RES:2*pi;

%% Transfer Function

H      = abs(1-beta*exp(-1i*2*pi*f*d/C*(cos(Thetas)+k)));
