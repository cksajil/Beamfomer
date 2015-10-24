%% Beam Form Plotter

%% Screen Display Settings

%Measure Screen Size of the device
%Calculate position values of figure windows
scrsz = get(0,'ScreenSize');
P1 = [50 300 scrsz(3)/2 scrsz(4)/2];
P2 = [50 80 scrsz(3)/2 scrsz(4)/2];
%P3 = [620 500 scrsz(3)/2 scrsz(4)/2];
%P4 = [620 80 scrsz(3)/2 scrsz(4)/2];

%% Parameter Specifications

ANGLE_RES           = 500;          % Number of angle points to calculate
numElements         = 2;            % Number of array elements
d                   = 0.1;         % Element separation in metres
f                   = 1000.0;       % Signal frequency in Hz 
C                   = 343.0;   
Thetas              = 0:ANGLE_RES-1;

%% Processing Section

%Calculate the planewave arrival angle
angle = -90 + 180.0 * Thetas/ (ANGLE_RES-1);
angleRad = deg2rad(angle);
 

%% Iterate Through Sensor Elements

for n = 0:numElements-1;
    
    position = n * d;
    delay = position * sin(angleRad) / C;

    realSum(n+1,:) = cos(2.0 * pi * f * delay);
    imagSum(n+1,:) = sin(2.0 * pi * f * delay);
    
end

%% Mix the Individual Beams
realSum =sum(realSum,1);
imagSum =sum(imagSum,1);
     
output = sqrt(realSum .* realSum + imagSum .* imagSum) / numElements;

%% Take Log Output
logOutput = 20 * log10(output);
     
     if(logOutput < -50) 
          logOutput = -50;
     end
%% Plotting the Resultant Beams

figure('position', P1);
plot(angle,logOutput)
grid on
title('Beam Form Pattern');
xlabel('Angle in Degrees');
ylabel('dB');
legend('Beamform');

figure('position', P2);
polar(angle,output)
title('Polar Beam Form Pattern');



