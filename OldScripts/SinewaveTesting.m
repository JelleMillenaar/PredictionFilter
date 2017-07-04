Fs = 100000;  % Sampling frequency
fSz = 5000;  % Frame size
%Create the audio file
pSinewave = dsp.SineWave(1, 5e6, 0,'SamplesPerFrame',fSz,'SampleRate',Fs);

%Audio output
pDeviceWriter = audioDeviceWriter('SampleRate', pSinewave.SampleRate);

%Create a visualisation
gTimeAmplitute = dsp.TimeScope('SampleRate', pSinewave.SampleRate, 'YLimits', [-1,1], 'ShowGrid', true, 'BufferLength', 2^32, 'TimeSpan', 2.0);
gSpectrum = dsp.SpectrumAnalyzer;
gSpectrum.PlotAsTwoSidedSpectrum = false;
gSpectrum.SampleRate = Fs;
gSpectrum.SpectralAverages = 1;

%Loop through the audio file
for Iter = 1:fSz
    FrameData = pSinewave();
    %pDeviceWriter(FrameData);
    gTimeAmplitute(FrameData);
    gSpectrum(FrameData);
end


%Clean up
release(pAudioFile);
release(gTimeAmplitute);
%release(gSpectrum);