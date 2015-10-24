%% Coclear Implant Enhancement

% The program takes two signals from two microphones which are seperated by a
% distance. Mic1 is close to the sound source and Mic2 is close to noise or 
% rear side. The processed signal is a clean speech of interest to the patient.
%18/10/15 October 4:30 PM IST

%% Screen Display Settings

%Measure Screen Size of the device
%Calculate position values of figure windows
scrsz = get(0,'ScreenSize');
P1 = [50 300 scrsz(3)/3 scrsz(4)/3];
%P2 = [50 80 scrsz(3)/3 scrsz(4)/3];
%P3 = [620 500 scrsz(3)/3 scrsz(4)/3];
%P4 = [620 80 scrsz(3)/2 scrsz(4)/2];

%% Parameters Initilisation

warning('off', 'all')
FrameRate = 1024;     %Set Frame Rate
C = 343;                    %Speed of Sound in Air meters/sec
d = 0.01;                   %Microphone distance in meters

%% Create and Configure System Objects

Mic1 = dsp.AudioFileReader('S_01_01.wav',  ...
              'SamplesPerFrame', 1024, ...
              'PlayCount', Inf, ...
              'OutputDataType', 'double');
          
Mic2 = dsp.AudioFileReader('S_01_01-noisy.wav',  ...
              'SamplesPerFrame', 1024, ...
              'PlayCount', Inf, ...
              'OutputDataType', 'double');
          
Fs = Mic1.SampleRate;

Player = dsp.AudioPlayer('SampleRate',Fs);

%% Stream Processing Loop
% 
% disp('Playing the clean front signal')
% 
% while ~isDone(Mic1)
%    audio = step(Mic1);
%    step(Player,audio);
% end
%  
% pause(Player.QueueDuration);  % Wait until audio plays to the end
% 
% disp('Playing the Rear Noisy signal')
% 
% while ~isDone(Mic2)
%    audio = step(Mic2);
%    step(Player,audio);
% end
%  
% pause(Player.QueueDuration);  % Wait until audio plays to the end

%% Processing Section

[y1, Fs1] = wavread('S_01_01.wav');       % Clean Speech Signal
[y2, Fs2] = wavread('S_01_01-noisy.wav'); % Noise+Speech Signal

T=1/Fs;
L=length(y1);
t=(0:T:(L-1)/Fs)';


y1=normc(y1);
y2=normc(y2);

noise = y2-y1; 

SNR =(sqrt(mean(y1.^2))/sqrt(mean(noise.^2)));
SNRdB = 20*log10(SNR); % in dB

%% Plotting Waveforms

figure('position', P1);
figure(1);
plot(t,y1);
grid on
title('Clean Speech Signal');
xlabel('Time in Seconds');
ylabel('Amplitude');
legend('Clean Signal');



%% Release Hardware
release(Player);
release(Mic1);

%% End of Program

