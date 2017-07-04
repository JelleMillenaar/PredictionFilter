%Create the audio file
AudioFileName = 'rain01.wav';
pAudioFile = dsp.AudioFileReader(AudioFileName);
pAudioInfo = audioinfo(AudioFileName);

%Audio output
pDeviceWriter = audioDeviceWriter('SampleRate', pAudioFile.SampleRate);

%Create a visualisation
gTimeAmplitute = dsp.TimeScope('SampleRate', pAudioFile.SampleRate, 'YLimits', [-1,1], 'ShowGrid', true, 'BufferLength', 2^18, 'TimeSpan', pAudioInfo.Duration+0.1);
gSpectrum = dsp.SpectrumAnalyzer();
gSpectrum.PlotAsTwoSidedSpectrum = false;

%Loop through the audio file
while ~isDone(pAudioFile)
    FrameData = pAudioFile();
    pDeviceWriter(FrameData);
    gTimeAmplitute(FrameData); 
    gSpectrum(FrameData);
end


%Clean up
release(pAudioFile);
release(gTimeAmplitute);