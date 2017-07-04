%% Clean up
clear;
close all;

%% Set Variables
SampleRate = 44100; %Samples/Sec
LowBinFrequency = 27.5; %Hz
HighBinFrequency = 22050; %Hz
BinCount = 30;
LowBinModulationFrequency = 0.5; %Hz
HighBinModulationFrequency = 200; %Hz
ModulationBinCount = 20;
HertzPerHalving = 660; %Fluctuation counting towards 50% history
ModulationHertzPerHalving = 1; %Fluctations towards 50% history
FrequencyThreshold = 0.2;
TotalThreshold = 1;
MinSpeechAreaDistance = 441*2;
AnnotationsSpeech = [ Area(10000, 75000) Area(110000, 175000) Area(230000, 308700) ];
NoiseAudioFile = 'Fast running river.wav';
TargetAudioFile = 'f1lcapae.wav';

%% Set Settings
CalcModulation = true;
Fastversion = false;
    
%% Load the data
[TargetAudioData, SampleRate] = LoadAudioFile(TargetAudioFile, SampleRate, 44100*7);
[NoiseAudioData, SampleRate] = LoadAudioFile(NoiseAudioFile, SampleRate);
CombinedAudioData = CombineAudioData( TargetAudioData, NoiseAudioData.*3, length(NoiseAudioData) ); %dsp.SineWave(1, 1000 ,0,'SamplesPerFrame',SampleRate,'SampleRate', SampleRate);
%CombinedAudioData = CombinedAudioData();
%PlaySound( CombinedAudioData, 44100 );

%% Create the required filters
[ BinFilters, BinFrequencies ] = CreateFilters( FilterType.Erb, LowBinFrequency, HighBinFrequency, BinCount, length(CombinedAudioData), length(CombinedAudioData) ); %ErbFilters
if( CalcModulation )
    [ BinModulationFilters, BinModulationFrequencies ] = CreateFilters( FilterType.Log, LowBinModulationFrequency, HighBinModulationFrequency, ModulationBinCount, length(CombinedAudioData), length(CombinedAudioData) ); %LogFilters
    PlotFilters( BinModulationFilters, BinModulationFrequencies );
    ModulationAlphas = CalculateAlphas(BinModulationFrequencies, ModulationHertzPerHalving, SampleRate);
    PlotScaledColors([ModulationAlphas.^((1:SampleRate).')].', "History Contribution Modulation", "Samples", "Frequencies (Hz)", flipud(BinModulationFrequencies) );
end
PlotFilters( BinFilters, BinFrequencies);

%% Generate the bins, envelopes and modulations bins
TemporalBins = GenerateSubbands(CombinedAudioData, BinFilters);
[BinEnvelopes, BinPhases] = HilbertTransform(TemporalBins);
PlotScaledColors(BinEnvelopes.', "Envelopes Original Sound", "Samples", "Frequencies (Hz)", flipud(BinFrequencies));
if( Fastversion )
   clear TemporalBins; 
   clear BinFilters;
end

%% Exponential Moving Average
FrequencyAlphas = CalculateAlphas(BinFrequencies, HertzPerHalving, SampleRate);
%FrequencyAlphas(1:32) = 0.99995; %Old Alpha's
PlotScaledColors([FrequencyAlphas.^((1:SampleRate).')].', "History Contribution", "Samples", "Frequencies (Hz)", flipud(BinFrequencies) );
EnvelopeMovingAverage = CalculateMovingAverage( BinEnvelopes, FrequencyAlphas );
FilteredEnvelope = RemovePrediction( BinEnvelopes, EnvelopeMovingAverage, false );
PlotScaledColors(FilteredEnvelope.', "Envelopes Filtered Sound", "Samples", "Frequencies (Hz)", flipud(BinFrequencies));
if( Fastversion )
   clear EnvelopeMovingAverage; 
end


%Modulation Moving Average
if (CalcModulation )
    %Calculate modulations & Mean Modulation
    %ModulationBins = zeros( size(BinEnvelopes, 1), size(BinModulationFrequencies, 2), size(BinFrequencies, 2));
    ModulationBinEnvelopes = zeros ( size(BinEnvelopes, 1), size( BinModulationFrequencies, 2), size( BinFrequencies, 2));
    ModulationBinPhases = zeros ( size(BinPhases, 1), size( BinModulationFrequencies, 2), size( BinFrequencies, 2));
    OriginalModulationPowers = zeros( size(BinModulationFrequencies, 2), 1); 
    for i=1:size(BinFrequencies, 2)
        %Change first argument in GenerateSubbands to switch from original
        %to Filtered or reverse,
        %ModulationBins(:,:,i) = GenerateSubbands(FilteredEnvelope(:,i), BinModulationFilters);
        ModulationsInBin = GenerateSubbands(FilteredEnvelope(:,i), BinModulationFilters);
        [ModulationBinEnvelopes(:,:,i), ModulationBinPhases(:,:,i)] = HilbertTransform(ModulationsInBin);
        OriginalModulationPowers( :, i) = mean(ModulationBinEnvelopes(:,:,i).^2);
    end
    
    %Plot modulations
    PlotScaledColors( OriginalModulationPowers.', "Original Modulation", "ModulationFrequencies (Hz)", "Frequencies (Hz)", flipud(BinFrequencies), BinModulationFrequencies);
    %PlotScaledColors( ModulationBins(:,:,16).', "Modulation of Frequency", "Samples", "ModulationFrequency (Hz)", flipud(BinModulationFrequencies));
    

    
    FilteredModulationPowers = zeros( size(OriginalModulationPowers) ); 
    FilteredModulationBins = zeros (size(ModulationBinEnvelopes) );
    for i=1:size(ModulationBinEnvelopes,3)
        ModulationMA = CalculateMovingAverage( ModulationBinEnvelopes(:,:,i), ModulationAlphas );
        FilteredModulationBins(:,:,i) = RemovePrediction( ModulationBinEnvelopes(:,:,i), ModulationMA, false );
        FilteredModulationPowers( :, i) = mean(FilteredModulationBins(:,:,i).^2);
    end
    %Plot modulations
    PlotScaledColors( FilteredModulationPowers.', "Filtered Modulation", "ModulationFrequencies (Hz)", "Frequencies (Hz)", flipud(BinFrequencies), BinModulationFrequencies);
    
    %Reconstruction
    for i=1:size(BinFrequencies, 2)
        FilteredEnvelope(:,i) = ReconstructSignal( ModulationBinEnvelopes(:,:,i), ModulationBinPhases(:,:,i) );
    end
    
    if( Fastversion )
        clear ModulationBins;
        clear BinModulationFilters;
    end
end

%% Modulation reconstruction
if( CalcModulation )
   PlotScaledColors(FilteredEnvelope.', "Envelopes Modulation Filtered Sound", "Samples", "Frequencies (Hz)", flipud(BinFrequencies));
    if( Fastversion )
       clear FilteredModulationBins; 
    end
end

%% SNR Calculation
OriginalSnrAreas = DetectSpeech( FilteredEnvelope, FrequencyThreshold, TotalThreshold, AnnotationsSpeech, MinSpeechAreaDistance);
%Create copies
FilteredSnrAreas = OriginalSnrAreas;

%Calculate SNR
OriginalSnrAreas = CalculateSNR( BinEnvelopes, OriginalSnrAreas, MinSpeechAreaDistance);
FilteredSnrAreas = CalculateSNR( FilteredEnvelope, FilteredSnrAreas, MinSpeechAreaDistance);
TotalOriginalSNR = TotalSNR( OriginalSnrAreas );
%disp("End");
FilteredSNR = TotalSNR( FilteredSnrAreas );
disp( "OriginalSNR: "+TotalOriginalSNR+"; FilteredSNR: "+FilteredSNR+";");
PlotSpeechAreas( FilteredEnvelope, OriginalSnrAreas );
if( Fastversion )
   clear OriginalSnrAreas;
   clear FilteredSnrAreas;
   clear BinEnvelopes;
end

%% Reconstruction
ReconstructedAudio = ReconstructSignal( FilteredEnvelope, BinPhases );
%PlaySound( ReconstructedAudio, 44100 );
if( Fastversion )
   clear FilteredEnvelope;
   clear BinPhases;
end

%% Save results
%Create the folder
FolderName = datestr(now,'dd_mm_HH_MM');
mkdir(FolderName);

%Create the audio file
audiowrite(char(FolderName+"/FilteredAudio.wav"), ReconstructedAudio, SampleRate);
audiowrite(char(FolderName+"/OriginalAudio.wav"), CombinedAudioData, SampleRate);

%Save results
ResultsFile = fopen(char(FolderName+"/Results.txt"), 'wt');
fprintf( ResultsFile, '%s: %f\n', "OriginalSNR", TotalOriginalSNR );
fprintf( ResultsFile, '%s: %f\n', "FilteredSNR", FilteredSNR );
fclose(ResultsFile);

%Txt file with variables
TxtFile = fopen(char(FolderName+"/Variables.txt"), 'wt');
fprintf( TxtFile, '%s: %i\n', "SampleRate", SampleRate );
fprintf( TxtFile, '%s: %f\n', "LowBinFrequency", LowBinFrequency );
fprintf( TxtFile, '%s: %i\n', "HighBinFrequency", HighBinFrequency );
fprintf( TxtFile, '%s: %i\n', "BinCount", BinCount );
fprintf( TxtFile, '%s: %f\n', "LowBinModulationFrequency", LowBinModulationFrequency );
fprintf( TxtFile, '%s: %f\n', "HighBinModulationFrequency", HighBinModulationFrequency );
fprintf( TxtFile, '%s: %i\n', "ModulationBinCount", ModulationBinCount );
fprintf( TxtFile, '%s: %i\n', "HertzPerHalving", HertzPerHalving );
fprintf( TxtFile, '%s: %i\n', "ModulationHertzPerHalving", ModulationHertzPerHalving );
fprintf( TxtFile, '%s: %f\n', "FrequencyThreshold", FrequencyThreshold );
fprintf( TxtFile, '%s: %f\n', "TotalThreshold", TotalThreshold );
fprintf( TxtFile, '%s: %i\n', "MinSpeechAreaDistance", MinSpeechAreaDistance );
fprintf( TxtFile, '%s: %s\n', "NoiseAudioFile", NoiseAudioFile );
fprintf( TxtFile, '%s: %s\n', "TargetAudioFile", TargetAudioFile );
fclose(TxtFile);

%Save figures
h = get(0,'children');
for i=1:length(h)
  saveas(h(i), [FolderName '/figure' num2str(i) '.png']);
end