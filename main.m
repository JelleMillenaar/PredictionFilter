%% INPUT SIGNAL
%clear;
%close all;
% tic;
% pAudioManager = AudioManager();
% pAudioManager.SetSound('brent2.wav');
% disp(toc);
% 
% %Audio output plot
% pAudioManager.PlotOriginal();
% %pAudioManager.PlotEnvelopes();
% pAudioManager.PlotSpectogram();

% Mcdermott version
%% Settings
MovingAlpha = 0.99995;
FrequencyBinCount = 30;
LowFrequency = 27.5; %Hz
HighFrequency = 22050; %Hz
SampleRate = 44100;
EnvelopeSampleRate = 400;
ModulationBinCount = 20;
LowModulationFrequency = 0.5; %Hz
HighModulationFrequency = 200; %Hz
global WindowSize;
WindowSize = SampleRate/2;
global SampleInverval;
SampleInverval = WindowSize/10;

%% Load a sound
pSound = Sound('Jungle Rain.wav', SampleRate);
pSound = pSound.MixSound('f1lcapae.wav');
NoiseSound = Sound('Jungle Rain.wav', SampleRate);
TargetSound = Sound('f1lcapae.wav', SampleRate, pSound.GetTotalSampleCount());
%NoiseStatistics = SoundStatistics(NoiseSound);
%NoiseStatistics = NoiseStatistics.MeasureAll(FrequencyBinCount, LowFrequency, HighFrequency, EnvelopeSampleRate, ...
%    ModulationBinCount, LowModulationFrequency, HighModulationFrequency);
%NoiseStatistics.PlotEnvelopes();
%TargetStatistics = SoundStatistics(TargetSound);
%TargetStatistics = TargetStatistics.MeasureAll(FrequencyBinCount, LowFrequency, HighFrequency, EnvelopeSampleRate, ...
%    ModulationBinCount, LowModulationFrequency, HighModulationFrequency);
%TargetStatistics.PlotEnvelopes();
%pSound.Play();

%% Original mix statistics
pOriginalSoundStatistics = SoundStatistics(pSound);
pOriginalSoundStatistics = pOriginalSoundStatistics.MeasureAll(FrequencyBinCount, LowFrequency, HighFrequency, EnvelopeSampleRate, ...
    ModulationBinCount, LowModulationFrequency, HighModulationFrequency);
pEditedSoundStatistics = pOriginalSoundStatistics;
pOriginalSoundStatistics.PlotEnvelopes();

%% Exponential Moving Average 
%[b, a] = butter(4,8000/(44100/2),'low');
EMA = zeros(1, FrequencyBinCount+2);
for i=1:pSound.GetTotalSampleCount()
    EMA(1:FrequencyBinCount+2) = (1-MovingAlpha) * pOriginalSoundStatistics.m_aBinsEnvelopes(i, :) + MovingAlpha * EMA(1:FrequencyBinCount+2); 
    pEditedSoundStatistics.m_aBinsEnvelopes(i, :) = max(0,pEditedSoundStatistics.m_aBinsEnvelopes(i, :) - EMA(1, :));
    %pEditedSoundStatistics.m_aBinsEnvelopes(i, :) = filtfilt(b, a, pEditedSoundStatistics.m_aBinsEnvelopes(i, :));
    %Butterworth filter
end
pEditedSoundStatistics = pEditedSoundStatistics.Reconstruct();

%% Normalize sound levels
OriginalSoundLevel = sum(abs(pOriginalSoundStatistics.m_pSound.m_aAudioData))/length(pOriginalSoundStatistics.m_pSound.m_aAudioData);
EditedSoundLevel = sum(abs(pEditedSoundStatistics.m_pSound.m_aAudioData))/length(pEditedSoundStatistics.m_pSound.m_aAudioData);
Normalizer = OriginalSoundLevel / EditedSoundLevel;
pEditedSoundStatistics.m_pSound.m_aAudioData = pEditedSoundStatistics.m_pSound.m_aAudioData .* Normalizer;
%pEditedSoundStatistics.m_pSound.Play();
pEditedSoundStatistics.PlotEnvelopes();

%% SNR
%OriginalSNR = pOriginalSoundStatistics.CalculateSNR(TargetSound.m_aAudioData);
%EditedSNR = pEditedSoundStatistics.CalculateSNR(TargetSound.m_aAudioData);
%SubtractedSNR = EditedSNR-OriginalSNR;

%OriginalSNR = (pOriginalSoundStatistics.m_pSound.m_aAudioData - TargetSound.m_aAudioData).^2;
%EditedSNR = (pEditedSoundStatistics.m_pSound.m_aAudioData - TargetSound.m_aAudioData).^2;
%SubtractedSNR = OriginalSNR- EditedSNR;

WindowSize = 100;
StepSize = 1;
OriginalSNR = SlidingSNR( TargetSound.m_aAudioData, NoiseSound.m_aAudioData, WindowSize, StepSize );
EditedSNR = SlidingSNR( pEditedSoundStatistics.m_pSound.m_aAudioData, (pEditedSoundStatistics.m_pSound.m_aAudioData - TargetSound.m_aAudioData), WindowSize, StepSize );
PlotSlidingSNR( OriginalSNR, EditedSNR);

%OriginalSNR = (TargetSound.m_aAudioData.^2)./(NoiseSound.m_aAudioData.^2);
%EditedSNR = (pEditedSoundStatistics.m_pSound.m_aAudioData.^2)./((pEditedSoundStatistics.m_pSound.m_aAudioData - TargetSound.m_aAudioData).^2);
%SubtractedSNR = (EditedSNR ./ OriginalSNR);

%Plot the SNR
% figure('Name', 'SNR');
% hold on;
% plot(1:length(OriginalSNR), OriginalSNR);
% plot(1:length(EditedSNR), EditedSNR);
% plot(1:length(SubtractedSNR), SubtractedSNR);
% legend('OriginalSNR', 'EditedSNR', 'Subtracted');
% xlabel('Samples');
% ylabel('SNR (Decibel)');

%Calculate the complete SNR
OriginalNoise = sum(OriginalSNR) / length(OriginalSNR);
% EditedNoise = sum(EditedSNR) / length(EditedSNR);
% Improvement = OriginalNoise - EditedNoise;
% %disp("Original: "+OriginalNoise+"; Edited: "+EditedNoise+"; Improvement: "+Improvement);
% disp("Percentual improvement: "+(Improvement/OriginalNoise)*100+"%");
return;

%% Mean Calculatation
pWindowedSoundStatistics = SoundStatistics(pSound);
pWindowedSoundStatistics = pWindowedSoundStatistics.PrepareMeasureWindow(FrequencyBinCount, LowFrequency, HighFrequency, WindowSize, EnvelopeSampleRate, ...
     ModulationBinCount, LowModulationFrequency, HighModulationFrequency);
 
%Loop throught the sound
CurrentStartSample = 1;
Index = 1;
while( CurrentStartSample + WindowSize < length(pSound.m_aAudioData))
    %Calculate data
   pWindowedSoundStatistics = pWindowedSoundStatistics.MeasureWindow(CurrentStartSample);
   CalculatedMean(1:FrequencyBinCount+2, Index) = pWindowedSoundStatistics.m_aEnvelopeMean;
   
   %Add prediction
   if( CurrentStartSample + WindowSize + SampleInverval < length(pSound.m_aAudioData))
    pEditedSoundStatistics.m_aBinsEnvelopes(CurrentStartSample + WindowSize:CurrentStartSample + WindowSize + SampleInverval,:) = abs(pEditedSoundStatistics.m_aBinsEnvelopes(CurrentStartSample + WindowSize:CurrentStartSample + WindowSize + SampleInverval,:) - (CalculatedMean(1:FrequencyBinCount+2, Index).')); 
   end
   
   %Prepare next loop
   CurrentStartSample = CurrentStartSample + SampleInverval;
   Index = Index + 1;
   disp(Index);
end
pEditedSoundStatistics.PlotEnvelopes();




%pTargetSound = Sound('Voice/f1lcapae.wav', SampleRate);
%pTargetSound.Play();
%pSoundStatistics = SoundStatistics(pSound);
%pFullSoundStatistics = SoundStatistics(pSound);
%pFullSoundStatistics = pFullSoundStatistics.MeasureAll(FrequencyBinCount, LowFrequency, HighFrequency, EnvelopeSampleRate, ...
%    ModulationBinCount, LowModulationFrequency, HighModulationFrequency);
%pFullSoundStatistics.PlotEnvelopes();

%pSoundStatistics = pSoundStatistics.MeasureAll(FrequencyBinCount, LowFrequency, HighFrequency, EnvelopeSampleRate, ...
 %   ModulationBinCount, LowModulationFrequency, HighModulationFrequency);

 %% Prediction test
 
%Generate the mean overtime
% pSoundStatistics = pSoundStatistics.PrepareMeasureWindow(FrequencyBinCount, LowFrequency, HighFrequency, WindowSize, EnvelopeSampleRate, ...
%     ModulationBinCount, LowModulationFrequency, HighModulationFrequency);
% 
% %Loop throught the sound
% CurrentStartSample = 1;
% Index = 1;
% while( CurrentStartSample + WindowSize < length(pSound.m_aAudioData))
%     %Calculate data
%    pSoundStatistics = pSoundStatistics.MeasureWindow(CurrentStartSample);
%    CalculatedMean(1:FrequencyBinCount+2, Index) = pSoundStatistics.m_aEnvelopeMean;
%    
%    %Apply subtraction
%    for k = 1:FrequencyBinCount+2
%        if( CurrentStartSample + WindowSize + SampleInverval < length(pSound.m_aAudioData))
%           pFullSoundStatistics.m_aBinsTemporalData(CurrentStartSample+WindowSize : CurrentStartSample + WindowSize + SampleInverval, k) = pFullSoundStatistics.m_aBinsTemporalData(CurrentStartSample+WindowSize : CurrentStartSample + WindowSize + SampleInverval, k) - CalculatedMean(k, Index);
%        end
%    end
%    
%    %Prepare next loop
%    CurrentStartSample = CurrentStartSample + SampleInverval;
%    Index = Index + 1;
%    disp(Index);
% end
% 
% %Plotting
% pFullSoundStatistics.PlotOriginal();
% pFullSoundStatistics.PlotReconstructed();
% 
% %Plot
% figure('Name', 'Mean of Envelopes over Time');
% hold on;
% %for i = 1: size(CalculatedMean, 2)
%     plot(1:SampleInverval:(Index-1)*SampleInverval, CalculatedMean(12,:));
% %end
% 
% hold off;
% pFullSoundStatistics.PlotEnvelopes(12:12);

%% Plotting
%pSoundStatistics.PlotOriginal();
%pSoundStatistics.PlotBinsTemporal(1:FrequencyBinCount);
%pSoundStatistics.PlotReconstructed();
%pSoundStatistics.PlotSpectogram();
%pSoundStatistics.PlotEnvelopes(29:32);
%pSoundStatistics.PlotFrequencyBinVariation();
%pSoundStatistics.PlotFrequencyBinSkewness();
%pSoundStatistics.PlotFrequencyBinKurtosis();
%pSoundStatistics.PlotCrossCorrelation();
%pSoundStatistics.PlotModulationTemporal(28, 1:4:20);