%% Beam Plotter

ANGLE_RES           =500;           % Number of angle points to calculate
numElements         = 2;            % Number of array elements
d                   = 0.01;         % Element separation in metres
freq                = 1000.0;       % Signal frequency in Hz 
C                   = 343.0;   

thetas=0:ANGLE_RES;
i=1;

%% Processing Section

for E = (1:numElements).*d
    o(:,i)=abs(exp(2*pi*freq*E*sin(thetas)./C));
    i=i+1;
end

B=20*log10(sum(o,2)/numElements);
