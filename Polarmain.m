%% Polar Main Plotting Function

scrsz = get(0,'ScreenSize');
P1=[300 40 scrsz(3)/2 scrsz(4)/2];
P2=[40 80 scrsz(3)/2 scrsz(4)/2];
P3 = [400 120 scrsz(3)/2 scrsz(4)/2];

k    =[0.9 1 1.1];
beta = [0.8 0.9 1.0 1.1 1.2];
i=1;
figure('position', P1);

for kin = k
    for betain = beta
       [Theta, H]= XYPolar(betain,kin);
       subplot(3,5,i); 
       polar(Theta,H);
       i=i+1;
    end
end

figure('position', P2);
[T, H]= XYPolar(1.1,1.1);
polar(T,H);
grid on
title('Beam Form Pattern for both beta and tau at 1.1');

figure('position', P3);
plot(T,H);
xlabel('Angle');
ylabel('H(jw)');


%% End of Program