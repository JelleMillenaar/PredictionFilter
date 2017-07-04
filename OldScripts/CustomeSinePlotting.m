%Load a sinewave
iSampleRate = 8000;
f = 100;
t =  0:1/iSampleRate:1-1/iSampleRate;
signal = sin(2*pi*f*t);

%Plotting the Amplitude - Time graph
AudioSamplesTime = 1:size(iSampleRate);
AudioSamplesTime = AudioSamplesTime /iSampleRate;
figure;
plot(t, signal);
xlabel('Time(S)');
ylabel('Amplitute');
title('Amplitude - Time');

%Spectral power plotting
N = length(signal);
xdft = fft(signal); %Fast Fourier Transform
xdft = xdft(1:N/2+1);
psdx = (1/(iSampleRate*N)) * abs(xdft).^2;
psdx(2:end-1) = 2*psdx(2:end-1);
freq = 0:iSampleRate/N:iSampleRate/2;
figure;
plot(freq, psdx);