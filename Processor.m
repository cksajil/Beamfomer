%% Denoising Module

%% 20/10/2015 01:00 PM
%Version 1.0
%Sajil C. K., sajilck@gmail.com

%% Screen Display Specifications

%Measure screen size of the device
%Calculate position values of figure Windows

scrsz = get(0,'ScreenSize');
P1=[40 500 scrsz(3)/3 scrsz(4)/3];
P2=[40 80 scrsz(3)/3 scrsz(4)/3];
P3=[600 500 scrsz(3)/3 scrsz(4)/3];
P4=[600 80 scrsz(3)/3 scrsz(4)/3];
P5=[1000 500 scrsz(3)/3 scrsz(4)/3];
P6=[1000 80 scrsz(3)/3 scrsz(4)/3];

%% Loading Optimum Beta and K values
d       =   0.01;
C       =   340;
beta    =   1.1;
k       =   1.1;
tau     =   k*d/C;
theta   =   deg2rad(10);

%% Reading Mic1 and Mic2 recorded data
[clean, Fs0] = wavread('S_01_01.wav');
[x, Fs1] = wavread('sp01_airport_sn5.wav');
[y, Fs2] = wavread('cafeteria_babble');
y        = y(1:length(x));

%% Computation Part

shift   =  round(((d/C)*cos(theta)+tau));

y       =  circshift(y,shift);
y       =  [zeros(1,shift) y(shift+1:end)];

Out     = x-y;
soundsc(Out,Fs1);

%% End of Program



