%Clean the screen
close all;

%Load the audio file
sFileName = 'rain01.wav';
[pAudioData,iSampleRate] = audioread(sFileName);

%Filter with a bandpass filter
Bandpass = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2', 0.1, 0.15, 0.20, 0.25, 60, 1, 60);
Equiripple = design(Bandpass, 'FIR');
NewData = filter(Equiripple, pAudioData);

%Plotting the Amplitude - Time graph
AudioSamplesTime = 1:size(pAudioData);
AudioSamplesTime = AudioSamplesTime / iSampleRate;
figure('Name', 'Time Domain');
plot(AudioSamplesTime, pAudioData);
hold on;
plot(AudioSamplesTime, NewData);
hold off;
xlabel('Time(S)');
ylabel('Amplitute');
title('Amplitude - Time');

%Spectral power plotting
N = length(pAudioData);
xdft = fft(pAudioData); %Fast Fourier Transform
xdft = xdft(1:N/2+1);
psdx = (1/(iSampleRate*N)) * abs(xdft).^2;
psdx(2:end-1) = 2*psdx(2:end-1);
freq = 0:iSampleRate/N:iSampleRate/2;
figure('Name', 'Spectral Domain');
plot(freq, psdx);
hold on;
%Bandpass filter
NewXdft = fft(NewData);
NewXdft = NewXdft(1:N/2+1);
NewPsdx = (1/(iSampleRate*N)) * abs(NewXdft).^2;
NewPsdx(2:end-1) = 2*NewPsdx(2:end-1);
plot(freq, NewPsdx);
hold off;
xlabel('Frequency (kHz)');
ylabel('Spectral Power');

%Plot Envelope of Bandpass
[up,lo] = envelope(NewData, 1000, 'peak');
figure('Name', 'Envelope');
plot(AudioSamplesTime, up, AudioSamplesTime, lo);

%Spectogram
figure('Name', 'Spectrogram');
NFFT = 512;
spectrogram(NewData,NFFT,NFFT/2,NFFT,SR,'yaxis');

