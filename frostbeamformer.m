%% By attaching FIR filters to each sensor, the Frost beamformer has more
%%beamforming weights to suppress the interference. It is an adaptive algorithm 
%that places nulls at learned interference directions to better suppress the interference.
%In the steering direction, the Frost beamformer uses distortionless constraints to ensure
%desired signals are not suppressed. Let us create a Frost beamformer with a 20-tap FIR after each sensor.
hbf = phased.FrostBeamformer('SensorArray',ha,'SampleRate',fs,...
    'PropagationSpeed',c,'FilterLength',20,'DirectionSource','Input port');
%Next, process the synthesized signal using the Frost beamformer
reset(hsig);
FrostOut = zeros(NTSample,1);
for m = 1:NSampPerFrame:NTSample
    FrostOut(m:m+NSampPerFrame-1,:) = step(hbf,step(hsig),ang_dft);
end
%We can play and plot the entire audio signal once it is processed.
if isAudioSupported
    release(hap);
    step(hap,FrostOut);
end

plot(t,FrostOut);
xlabel('Time (sec)'); ylabel ('Amplitude (V)');
title('Frost Beamformer Output'); ylim([-3 3]);

% Calculate the array gain
agFrost = pow2db(mean((voice_cleanspeech+voice_laugh).^2+noisePwr)/...
    mean((FrostOut - voice_dft).^2))
%Notice that the interference is now canceled. The Frost beamformer has an
%array gain of 14 dB, which is 4.5 dB higher than that of the time delay beamformer. 
%The performance improvement is impressive, but has a high computational cost. 
%In the preceding example, an FIR filter of order 20 is used for each microphone.
%With all 10 sensors, one needs to invert a 200-by-200 matrix, which may be expensive in real-time processing.

%% USING DIagonal Loading
%Next, we want to steer the array in the direction of the second speech
%signal. Suppose we do not know the exact direction of the second speech signal 
%except a rough estimate of azimuth -5 degrees and elevation 5 degrees.

release(hbf);
ang_cleanspeech_est = [-5; 5];  % Estimated steering direction

reset(hsig);
FrostOut2 = zeros(NTSample,1);
for m = 1:NSampPerFrame:NTSample
    FrostOut2(m:m+NSampPerFrame-1,:) = step(hbf,step(hsig),...
        ang_cleanspeech_est);
end

if isAudioSupported
    step(hap,FrostOut2);
end

plot(t,FrostOut2);
xlabel('Time (sec)'); ylabel ('Amplitude (V)');
title('Frost Beamformer Output');  ylim([-3 3]);

% Calculate the array gain
agFrost2 = pow2db(mean((voice_dft+voice_laugh).^2+noisePwr)/...
    mean((FrostOut2 - voice_cleanspeech).^2))
%%
%%The speech is barely audible. Despite the 6.1 dB gain from the
%%beamformer, performance suffers from the inaccurate steering direction.
%One way to improve the robustness of the Frost beamformer is to use diagonal loading. 
%This approach adds a small quantity to the diagonal elements of the estimated covariance matrix.
%Here we use a diagonal value of 1e-3.

release(hbf);
hbf.DiagonalLoadingFactor = 1e-3; % Specify diagonal loading value

reset(hsig);
FrostOut2_dl = zeros(NTSample,1);
for m = 1:NSampPerFrame:NTSample
    FrostOut2_dl( m:m+NSampPerFrame-1,:) = step(hbf,step(hsig),...
        ang_cleanspeech_est);
end

if isAudioSupported
    step(hap,FrostOut2_dl);
end

plot(t,FrostOut2_dl);
xlabel('Time (sec)');
ylabel ('Amplitude (V)');
title('Frost Beamformer Output');
ylim([-3 3]);

% Calculate the array gain
agFrost2_dl = pow2db(mean((voice_dft+voice_laugh).^2+noisePwr)/...
    mean((FrostOut2_dl - voice_cleanspeech).^2))
release(hbf);
release(hsig);
%Now the output speech signal is improved and we obtain a 0.3 dB gain
%improvement from the diagonal loading technique.
if isAudioSupported
    pause(3); % flush out AudioPlayer buffer
    release(hap);
end
rng(prevS);