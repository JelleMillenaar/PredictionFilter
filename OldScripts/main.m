%Clean the screen
close all;

%Load the audio file
pAudioManager = AudioManager();
pAudioManager.SetSound('rain01.wav');
pAudioManager.PlotAmplitudeTimeWithBins();

%Filter with a bandpass filter
%Testbin = FrequencyBin(900,1000,1100);
%Testbin = Testbin.ProcessSound(pAudioData);

%Plotting the Amplitude - Time graph
% AudioSamplesTime = 1:size(pAudioData);
% AudioSamplesTime = AudioSamplesTime / iSampleRate;
% figure('Name', 'Time Domain');
% plot(AudioSamplesTime, pAudioData);
% hold on;
% plot(AudioSamplesTime, Testbin.m_pSoundData);
% hold off;
% xlabel('Time(S)');
% ylabel('Amplitute');
% title('Amplitude - Time');
% 
% %Spectral power plotting
% N = length(pAudioData);
% xdft = fft(pAudioData); %Fast Fourier Transform
% xdft = xdft(1:N/2+1);
% psdx = (1/(iSampleRate*N)) * abs(xdft).^2;
% psdx(2:end-1) = 2*psdx(2:end-1);
% freq = 0:iSampleRate/N:iSampleRate/2;
% figure('Name', 'Spectral Domain');
% plot(freq, psdx);
% hold on;
% %Bandpass filter
% NewXdft = fft(Testbin.m_pSoundData);
% NewXdft = NewXdft(1:N/2+1);
% NewPsdx = (1/(iSampleRate*N)) * abs(NewXdft).^2;
% NewPsdx(2:end-1) = 2*NewPsdx(2:end-1);
% plot(freq, NewPsdx);
% hold off;
% xlabel('Frequency (kHz)');
% xticks([0 1000 2000 3000 4000 5000 10000 15000 20000 25000]);
% ylabel('Spectral Power');


