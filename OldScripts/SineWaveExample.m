Fs = 100e6;  % Sampling frequency
fSz = 5000;  % Frame size

sin1 = dsp.SineWave(1e0,  5e6,0,'SamplesPerFrame',fSz,'SampleRate',Fs);
sin2 = dsp.SineWave(1e-1,15e6,0,'SamplesPerFrame',fSz,'SampleRate',Fs);
sin3 = dsp.SineWave(1e-2,25e6,0,'SamplesPerFrame',fSz,'SampleRate',Fs);
sin4 = dsp.SineWave(1e-3,35e6,0,'SamplesPerFrame',fSz,'SampleRate',Fs);
sin5 = dsp.SineWave(1e-4,45e6,0,'SamplesPerFrame',fSz,'SampleRate',Fs);

scope = dsp.SpectrumAnalyzer;
scope.SampleRate = Fs;
scope.SpectralAverages = 1;
scope.PlotAsTwoSidedSpectrum = false;
scope.RBWSource = 'Auto';
scope.PowerUnits = 'dBW';
for idx = 1:1e2
     y1 = sin1();
     y2 = sin2();
     y3 = sin3();
     y4 = sin4();
     y5 = sin5();
     scope(y1+y2+y3+y4+y5+0.0001*randn(fSz,1));
end