%define uniform linear array
hmic = phased.OmnidirectionalMicrophoneElement('FrequencyRange',[10 80e3]);

Nele = 2;
ha = phased.ULA(Nele,0.05,'Element',hmic);
c = 340;                         % sound speed, in m/s
%%Next, we simulate the multichannel signals received by the microphone
%%array. We begin by loading two recorded speeches and one laughter recording.
%%We also load the laughter audio segment as interference. The sampling frequency of the audio signals is 8 kHz.
%%The incident direction of the first speech signal is -30 degrees in
%%azimuth and 0 degrees in elevation. The direction of the second speech signal is -10 degrees in azimuth and 10 
%%degrees in elevation. The interference comes from 20 degrees in azimuth and 0 degrees in elevation.
%% THE K BETA CALCULATION THAT WAS MADE WILL BE INCLUDED HERE AS A FUNCTION CALL
%%
ang_dft = [-30; 0];
ang_cleanspeech = [-10; 10];
ang_laughter = [20; 0];
%%Now we can use a wideband collector to simulate a 3-second multichannel
%%signal received by the array. Notice that this approach assumes that each 
%%input single-channel signal is received at the origin of the array by a single microphone.
fs = 8000;
hCollector = phased.WidebandCollector('Sensor',ha,'PropagationSpeed',c,...
    'SampleRate',fs,'NumSubbands',1000,'ModulatedInput', false);

t_duration = 3;  % 3 seconds
t = 0:1/fs:t_duration-1/fs;
%%We generate a white noise signal with a power of 1e-4 watts to represent the thermal noise for each sensor.
%%A local random number stream ensures reproducible results.
prevS = rng(2008);
noisePwr = 1e-4; % noise power
%%We now start the simulation. At the output, the received signal is stored
%%in a 10-column matrix. Each column of the matrix represents the signal collected by one microphone.
% Note that we are also playing back the audio using the streaming approach during the simulation.

% preallocate
NSampPerFrame = 1000;
NTSample = t_duration*fs;
sigArray = zeros(NTSample,Nele);
voice_dft = zeros(NTSample,1);
voice_cleanspeech = zeros(NTSample,1);
voice_laugh = zeros(NTSample,1);

% set up audio player
isAudioSupported = helperMicrophoneExampleAudioSupported;
if isAudioSupported
    hap = dsp.AudioPlayer('SampleRate',fs);
end

%%changes must be made here
dftFileReader = dsp.AudioFileReader('S_01_01-noisy.wav',...
    'SamplesPerFrame',NSampPerFrame);
speechFileReader = dsp.AudioFileReader('S_01_01.wav',...
    'SamplesPerFrame',NSampPerFrame);
laughterFileReader = dsp.AudioFileReader('talker_mixture.wav',...
    'SamplesPerFrame',NSampPerFrame);
%% INPUT FILE FFTS WILL BE HERE, NOISE FFT, SECOND SPEECH FFT> DONT BE SCARED WITH SECOND SPEECH FFT AS IT IS A TESTING MEASURE
%% INITIAL SNR, clean signal power, Noise power has to be displayed
%% POLAR PLOT XY PLOT OF BEAMPATTERN INCLUDED HERE AS A FUNCTION CALL
%%
%simulate
for m = 1:NSampPerFrame:NTSample
    sig_idx = m:m+NSampPerFrame-1;
    x1 = step(dftFileReader);
    x2 = step(speechFileReader);
    x3 = 2*step(laughterFileReader);
    temp = step(hCollector,[x1 x2 x3],...
        [ang_dft ang_cleanspeech ang_laughter]) + ...
        sqrt(noisePwr)*randn(NSampPerFrame,Nele);
    if isAudioSupported
        step(hap,0.5*temp(:,3));%%step changes need to be made not to exceed matrix dimension
    end
    sigArray(sig_idx,:) = temp;
    voice_dft(sig_idx) = x1;
    voice_cleanspeech(sig_idx) = x2;
    voice_laugh(sig_idx) = x3;
end
%%Notice that the laughter masks the speech signals, rendering them
%%unintelligible. We can plot the signal in channel 3 as follows

%%
plot(t,sigArray(:,3));
xlabel('Time (sec)'); ylabel ('Amplitude (V)');
title('Signal Received at Channel 3'); ylim([-3 3]);

%%
%%Process with a Time Delay Beamformer
%%The time delay beamformer compensates for the arrival time differences across 
%%the array for a signal coming from a specific direction. The time aligned multichannel
%%signals are coherently averaged to improve the signal-to-noise ratio (SNR).
%%Now, define a steering angle corresponding to the incident direction of the first
%%speech signal and construct a time delay beamformer.
angSteer = ang_dft;
hbf = phased.TimeDelayBeamformer('SensorArray',ha,'SampleRate',fs,...
    'Direction',angSteer,'PropagationSpeed',c)
%%Next, we process the synthesized signal, plot and listen to the output of
%%the conventional beamformer. Again, we play back the beamformed audio signal during the processing.
hsig = dsp.SignalSource('Signal',sigArray,...
    'SamplesPerFrame',NSampPerFrame);

cbfOut = zeros(NTSample,1);

for m = 1:NSampPerFrame:NTSample
    temp = step(hbf,step(hsig));
    if isAudioSupported
        step(hap,temp);
    end
    cbfOut(m:m+NSampPerFrame-1,:) = temp;
end

%% %Output file saved in a wave(outfile='out.wav; filewavwrite(outputY,fs,16,outfile);)
%% POWER OF THE SIGNAL Y
%% a frequency plot  final wave

plot(t,cbfOut);
xlabel('Time (Sec)'); ylabel ('Amplitude (V)');
title('Time Delay Beamformer Output'); ylim([-3 3]);
%%One can measure the speech enhancement by the array gain, which is the
%%ratio of output signal-to-interference-plus-noise ratio (SINR) to input SINR.
agCbf = pow2db(mean((voice_cleanspeech+voice_laugh).^2+noisePwr)/...
    mean((cbfOut - voice_dft).^2))
%%The first speech signal begins to emerge in the time delay beamformer
%%output. We obtain an SINR improvement of 9.4 dB. However, the background 
%%laughter is still comparable to the speech. To obtain better beamformer performance, use a Frost beamformer.
