classdef SoundStatistics
    %Constant properties
    properties (Constant)
        %Settings
        CrossCorrelations = false;
        FrequencyModulations = false;
    end %of constants
    
    %Private properties
    properties %(SetAccess = private)
        %General
        m_pSound;
        m_iWindowSamples;
        
        %FrequencyBins
        m_iLowFrequency;
        m_iHighFrequency;
        m_iFrequencyBinCount;
        m_aFrequencyFilters;
        m_aFrequencies;
        m_aFrequencyFilterCutoffs;
        m_aBinsSpectralData;
        m_aBinsTemporalData;
        m_aBinsPhases;
        m_aBinsPhases2;
        m_aBinsPhases3;
        %FrequencyModulationBins
        m_iModulationBinCount;
        m_iLowModulationFrequency;
        m_iHighModulationFrequency;
        m_aModulationFilters;
        m_aModulationFrequencies;
        m_aModulationSpectralData;
        m_aModulationTemporalData;
        
        %Envelopes
        m_iEnvelopeSampleRate;
        m_aBinsEnvelopes;
        m_aBinsOldEnvelopes;
        m_aEnvelopeMean;
        m_aEnvelopeStdDev;
        
        %Statistics
        m_aFrequencyBinMean;
        m_aFrequencyBinStdDev;
        m_aFrequencyBinVariation;
        m_aFrequencyBinSkewness; 
        m_aFrequencyBinKurtosis;
        m_aFrequencyBinCrossCorrelation;
        m_aSNR;

    end
    
    %Methods
    methods
        function this = SoundStatistics(a_pSound)
            this.m_pSound = a_pSound;
        end % of constructor
        
        function this = MeasureAll(this, a_iFrequencyBinCount, a_iLowFrequency, a_iHighFrequency, a_iEnvelopeSampleRate, ...
                a_iModulationBinCount, a_iLowModulationFrequency, a_iHighModulationFrequency)
            %Create the filters
            this = this.SetFilters(a_iFrequencyBinCount, a_iLowFrequency, a_iHighFrequency, this.m_pSound.GetTotalSampleCount(), a_iEnvelopeSampleRate, ...
                a_iModulationBinCount, a_iLowModulationFrequency, a_iHighModulationFrequency);
            this = this.CalculateStatistics(this.m_pSound.m_aAudioData);
        end
        
        %This function needs to be called once before calling MeasureWindow
        %It will precalculate some useful data to speed up the process
        function this = PrepareMeasureWindow(this, a_iFrequencyBinCount, a_iLowFrequency, a_iHighFrequency, a_iWindowSamples, a_iEnvelopeSampleRate, ...
                a_iModulationBinCount, a_iLowModulationFrequency, a_iHighModulationFrequency)
           %Create the filters
            this = this.SetFilters(a_iFrequencyBinCount, a_iLowFrequency, a_iHighFrequency, a_iWindowSamples, a_iEnvelopeSampleRate, ...
                a_iModulationBinCount, a_iLowModulationFrequency, a_iHighModulationFrequency);
        end
        
        function this = MeasureWindow(this, a_iSamplesOffset)
           %TODO: Impelement this with a window of the data
           this = this.CalculateStatistics(this.m_pSound.m_aAudioData(a_iSamplesOffset : a_iSamplesOffset+this.m_iWindowSamples));
        end
        
        function PlotOriginal(this)
             %Prepare plotting
           figure('Name', 'Original Sound');
           
           %Plotting
           plot(1:length(this.m_pSound.m_aAudioData), this.m_pSound.m_aAudioData);
           
           %Layout
           xlabel('Samples');
           ylabel('Amplitude');
           title('Original Sound');
           axis tight;
        end %of PlotOriginal
        
        function PlotReconstructed(this)
             %Prepare plotting
           figure('Name', 'Reconstructed Sound');
           
           %Plotting
           ReconstructedAudio = zeros(length(this.m_iWindowSamples));
           for i=1:this.m_iFrequencyBinCount
               ReconstructedAudio = ReconstructedAudio + this.m_aBinsTemporalData(:,i);
           end
           plot(1:length(ReconstructedAudio), ReconstructedAudio);
           
           %Layout
           xlabel('Samples');
           ylabel('Amplitude');
           title('Reconstructed Sound');
           axis tight;
           hold off;
        end %of PlotReconstructed
        
        function PlotBinsTemporal(this, m_aBinIds)
            %Prepare plotting
           figure('Name', 'FrequencyBins Temporal');
           hold on;
           
           %Plotting
           LegendInfo = zeros(length(m_aBinIds), 1);
           for i=1:length(m_aBinIds)
                plot(1:this.m_iWindowSamples, this.m_aBinsTemporalData(:,m_aBinIds(i)));
                LegendInfo(i) = round(this.m_aFrequencyFilterCutoffs(1, i));
           end
           
           %Layout
           legend(string(LegendInfo));
           xlabel('Samples');
           ylabel('Amplitude');
           title('FrequencyBins Temporal');
           axis tight;
           hold off;
        end %of PlotBinsTemporal
        
        function PlotBinsPhase(this, m_aBinIds)
            %Prepare plotting
           figure('Name', 'FrequencyBins Phases');
           hold on;
           
           %Plotting
           LegendInfo = zeros(length(m_aBinIds), 1);
           for i=1:length(m_aBinIds)
               Data = sqrt(this.m_aBinsEnvelopes(:,m_aBinIds(i)).*conj(this.m_aBinsPhases(:,m_aBinIds(i))));
               plot(1:this.m_iWindowSamples, Data);
               LegendInfo(i) = round(this.m_aFrequencyFilterCutoffs(1, i));
           end
           
           %Layout
           legend(string(LegendInfo));
           xlabel('Samples');
           ylabel('Amplitude');
           title('FrequencyBins Phases');
           axis tight;
           hold off;
        end %of PlotBinsPhase
        
        function PlotEnvelopes(this)
            %Prepare plotting
            global WindowSize;
            global SampleInverval;
            figure('Name', 'Envelopes');
            FlippedEnvelopes = this.m_aBinsEnvelopes.';
            %imagesc(FlippedEnvelopes(:, WindowSize:end-SampleInverval));
            imagesc(FlippedEnvelopes);
            set( gca, 'YDir', 'normal');
            set( gca, 'YTick', 4:4:32)
            set( gca, 'YTickLabel', round(this.m_aFrequencyFilterCutoffs(4:4:32)))
            title(strcat('Envelopes: ', this.m_pSound.GetNames()));
            xlabel('Sound Samples');
            ylabel('Frequencies (Hz)');
            colorbar;
        end %of PlotEnvelopes
        
        function PlotSpectogram(this)
            %Prepare the plot
            figure('Name', 'Spectogram');

            %Plotting
            imagesc(20*log10(abs(flipud(this.m_aBinsSpectralData.'))+eps)); %Undefined function 'abs' for input arguments of type 'cell'.
            ytickVec = 1:this.m_iFrequencyBinCount;
            set(gca,'YTick',ytickVec);
            ytickLabel = round(this.m_aFrequencyFilterCutoffs);
            set(gca, 'YTickLabel', ytickLabel);
            xlabel('Samples');
            ylabel('Frequency (Hz)');
            title('Spectogram');
            hold off;
        end %of PlotSpectrogram
        
        function PlotFrequencyBinVariation(this)
            %Not showing much do to low numbers
            histogram(this.m_aFrequencyBinVariation, this.m_aFrequencyFilterCutoffs);
            axis tight;
        end
        
        function PlotFrequencyBinSkewness(this)
            figure('Name', 'FrequencyBin Skewness');
            semilogx(this.m_aFrequencyFilterCutoffs, this.m_aFrequencyBinSkewness);
        end
        
        function PlotFrequencyBinKurtosis(this)
            figure('Name', 'FrequencyBin Kurtosis');
            semilogx(this.m_aFrequencyFilterCutoffs, this.m_aFrequencyBinKurtosis);
        end
        
        function PlotCrossCorrelation(this)
            if(SoundStatistics.CrossCorrelation)
                figure('Name', 'Cross Correlation');
                imagesc(this.m_aFrequencyBinCrossCorrelation);
                set(gca, 'YDir', 'normal');
                set(gca, 'XTick', 1:5:32);
                set(gca, 'XTickLabel', round(this.m_aFrequencyFilterCutoffs(1:5:32)));
                xlabel('FrequencyBin (Hz)');
                set(gca, 'YTick', 1:5:32);
                set(gca, 'YTickLabel', round(this.m_aFrequencyFilterCutoffs(1:5:32)));
                ylabel('FrequencyBin (Hz)');
            end %Settings check
        end
        
        function PlotModulationTemporal(this, a_iFrequencyBin, m_aBinIds)
           if(SoundStatistics.FrequencyModulations)
               %Prepare plotting
               figure('Name', 'ModulationBins Temporal ' + string(this.m_aFrequencyFilterCutoffs(a_iFrequencyBin)) + ' Hz');
               hold on;

               %Plotting
               LegendInfo = zeros(length(m_aBinIds), 1);
               for i=1:length(m_aBinIds)
                    plot(1:length(this.m_aModulationTemporalData(:,m_aBinIds(i),a_iFrequencyBin)), this.m_aModulationTemporalData(:,m_aBinIds(i),a_iFrequencyBin));
                    LegendInfo(i) = round(this.m_aModulationFrequencies(m_aBinIds(i)));
               end

               %Layout
               legend(string(LegendInfo));
               xlabel('Samples');
               ylabel('Amplitude');
               title('ModulationBins Temporal ' + string(this.m_aFrequencyFilterCutoffs(a_iFrequencyBin)) + ' Hz');
               axis tight;
               hold off;
           end %Setting check
        end %of PlotBinsTemporal
        
        function this = Reconstruct(this)    
            %Reconstruct the sound from the analytic signal
            this.m_aBinsTemporalData = real(this.m_aBinsEnvelopes.*exp(complex(zeros(size(this.m_aBinsEnvelopes)), this.m_aBinsPhases)));
            TemporalData = zeros(length(this.m_aBinsTemporalData(:,1)), 1);
            for i=1:length(this.m_aBinsTemporalData(1,:))
               TemporalData = TemporalData + this.m_aBinsTemporalData(:,i);
            end
            this.m_pSound.m_aAudioData = TemporalData;
            
        end %of Reconstruct
        
        function SNR = CalculateSNR(this, a_pTarget)
            SNR = this.m_pSound.m_aAudioData ./ (this.m_pSound.m_aAudioData-a_pTarget);
        end %of CalculateSNR
       
    end
    
    %Private Menthods
    methods (Access = private)
        function this = SetFilters(this, a_iFrequencyBinCount, a_iLowFrequency, a_iHighFrequency, a_iWindowSamples, a_iEnvelopeSampleRate, ...
                a_iModulationBinCount, a_iLowModulationFrequency, a_iHighModulationFrequency)
            %% Set Variables
            this.m_iFrequencyBinCount = a_iFrequencyBinCount;
            this.m_iLowFrequency = a_iLowFrequency;
            this.m_iHighFrequency = a_iHighFrequency;
            this.m_iWindowSamples = a_iWindowSamples;
            this.m_iEnvelopeSampleRate = a_iEnvelopeSampleRate;
            this.m_iModulationBinCount = a_iModulationBinCount;
            this.m_iLowModulationFrequency = a_iLowModulationFrequency;
            this.m_iHighModulationFrequency = a_iHighModulationFrequency;
            
            %% Actually create the filters
            nfreqs = this.m_iWindowSamples/2; %does not include DC
            max_freq = this.m_pSound.m_iSampleRate/2;
            this.m_aFrequencies = [0:max_freq/nfreqs:max_freq]; %go all the way to nyquist
            
            cos_filts = zeros(nfreqs+1,this.m_iFrequencyBinCount);
            
            %Correct an unachieveable high frequency range
            if this.m_iHighFrequency>this.m_pSound.m_iSampleRate/2
                this.m_iHighFrequency = max_freq;
            end
            
            %make cutoffs evenly spaced on an erb scale
            this.m_aFrequencyFilterCutoffs = erb2freq([freq2erb(this.m_iLowFrequency) : (freq2erb(this.m_iHighFrequency)-freq2erb(this.m_iLowFrequency))/(this.m_iFrequencyBinCount+1) : freq2erb(this.m_iHighFrequency)]);
            
            %Create the filters
            for k=1:this.m_iFrequencyBinCount
                l = this.m_aFrequencyFilterCutoffs(k);
                h = this.m_aFrequencyFilterCutoffs(k+2); %adjacent filters overlap by 50%
                l_ind = min(find(this.m_aFrequencies>l));
                h_ind = max(find(this.m_aFrequencies<h));
                avg = (freq2erb(l)+freq2erb(h))/2;
                rnge = (freq2erb(h)-freq2erb(l));
                cos_filts(l_ind:h_ind,k) = cos((freq2erb( this.m_aFrequencies(l_ind:h_ind) ) - avg)/rnge*pi); %map cutoffs to -pi/2, pi/2 interval
            end
            
            %add lowpass and highpass to get perfect reconstruction
            this.m_aFrequencyFilters = zeros(nfreqs+1,this.m_iFrequencyBinCount+2);
            this.m_aFrequencyFilters(:,2:this.m_iFrequencyBinCount+1) = cos_filts;
            h_ind = max(find(this.m_aFrequencies<this.m_aFrequencyFilterCutoffs(2))); %lowpass filter goes up to peak of first cos filter
            this.m_aFrequencyFilters(1:h_ind,1) = sqrt(1 - this.m_aFrequencyFilters(1:h_ind,2).^2);
            l_ind = min(find(this.m_aFrequencies>this.m_aFrequencyFilterCutoffs(this.m_iFrequencyBinCount+1))); %highpass filter goes down to peak of last cos filter
            this.m_aFrequencyFilters(l_ind:nfreqs+1,this.m_iFrequencyBinCount+2) = sqrt(1 - this.m_aFrequencyFilters(l_ind:nfreqs+1,this.m_iFrequencyBinCount+1).^2);
            this.m_iFrequencyBinCount = this.m_iFrequencyBinCount +2;
            
            %% Modulation Filters
            ModulationWindow = ones(this.m_iEnvelopeSampleRate,1);
            ds_factor=round(this.m_pSound.m_iSampleRate/this.m_iEnvelopeSampleRate);
            EnvelopeSize = ceil(a_iWindowSamples/ds_factor);
            
            %Create the actual filters
            if rem(EnvelopeSize,2)==0 %even length
                nfreqs = EnvelopeSize/2;%does not include DC
                max_freq = this.m_iEnvelopeSampleRate/2;
                freqs = [0:max_freq/nfreqs:max_freq]; %go all the way to nyquist
            else %odd length
                nfreqs = (EnvelopeSize-1)/2;
                max_freq = this.m_iEnvelopeSampleRate*(EnvelopeSize-1)/2/EnvelopeSize; %max freq is just under nyquist
                freqs = [0:max_freq/nfreqs:max_freq];
            end   
            cos_filts = zeros(nfreqs+1,this.m_iModulationBinCount);

            if this.m_iHighModulationFrequency>this.m_iEnvelopeSampleRate/2
                this.m_iHighModulationFrequency = max_freq;
            end

            %make center frequencies evenly spaced on a log scale
            %want highest cos filter to go up to hi_lim
            this.m_aModulationFrequencies = 2.^([log2(this.m_iLowModulationFrequency) : (log2(this.m_iHighModulationFrequency)-log2(this.m_iLowModulationFrequency))/(this.m_iModulationBinCount-1) : log2(this.m_iHighModulationFrequency)]);

            %easy-to-implement version: filters are symmetric on linear scale
            for k=1:this.m_iModulationBinCount
                bw = this.m_aModulationFrequencies(k)/2; %Q == 2
                l = this.m_aModulationFrequencies(k)-bw; %so that half power point is at Cf-bw/2
                h = this.m_aModulationFrequencies(k)+bw;
                l_ind = find(freqs>l, 1 );
                h_ind = find(freqs<h, 1, 'last' );
                avg = this.m_aModulationFrequencies(k); %(log2(l+1)+log2(h+1))/2;
                rnge = h-l;%(log2(h+1)-log2(l+1));
                cos_filts(l_ind:h_ind,k) = cos((freqs(l_ind:h_ind) - avg)/rnge*pi); %map cutoffs to -pi/2, pi/2 interval
            end

            temp = sum(cos_filts'.^2);
            this.m_aModulationFilters=cos_filts/sqrt(mean(temp(freqs>=this.m_aModulationFrequencies(4) & freqs<=this.m_aModulationFrequencies(end-3))));
            
            %subplot(2,1,1); plot(this.m_aFrequencies,sum(this.m_aFrequencyFilters.^2,2))
            %subplot(2,1,2); semilogx(this.m_aFrequencies,sum(this.m_aFrequencyFilters.^2,2))
        end %of SetFilters
        
        function this = CalculateStatistics(this, a_iSignal)
            %% Calculating data
            [this.m_aBinsTemporalData, this.m_aBinsSpectralData] = SoundStatistics.GenerateSubbands(a_iSignal, this.m_aFrequencyFilters);
            
            %Envelopes
            Temp = hilbert(this.m_aBinsTemporalData);
            this.m_aBinsPhases = angle(Temp);
            this.m_aBinsEnvelopes = abs(Temp);
            %this.m_aBinsEnvelopes = this.m_aBinsEnvelopes.^0.3; %Envelopse compression
            %ds_factor=round(this.m_pSound.m_iSampleRate/this.m_iEnvelopeSampleRate);
            %this.m_aBinsEnvelopes = resample(this.m_aBinsEnvelopes,1,ds_factor); %resample to be a lot smaller
            %this.m_aBinsEnvelopes(this.m_aBinsEnvelopes<0)=0;
            
            
            %% Actual statistics
            this.m_aFrequencyBinVariation = var(this.m_aBinsTemporalData); %this is a row vector of the var of each subband
            
            %Loop through the frequencybins / envelopes
            if(SoundStatistics.FrequencyModulations)
                this.m_aModulationTemporalData = zeros(length(this.m_aBinsEnvelopes(:,1)), 20, this.m_iFrequencyBinCount);
                this.m_aModulationSpectralData = zeros(length(this.m_aBinsEnvelopes(:,1)), 20, this.m_iFrequencyBinCount);
            end %Settings Check
            for i = 1:this.m_iFrequencyBinCount
                %Frequencybin statistics
                this.m_aFrequencyBinMean(i) = mean(this.m_aBinsTemporalData(:,i));
                this.m_aFrequencyBinStdDev(i) = std(this.m_aBinsTemporalData(:,i));
                this.m_aFrequencyBinSkewness(i) = skewness(this.m_aBinsTemporalData(:,i));
                this.m_aFrequencyBinKurtosis(i) = kurtosis(this.m_aBinsTemporalData(:,i));
                
                %Envelope statistics
                this.m_aEnvelopeMean(i) = mean(this.m_aBinsEnvelopes(:,i));
                this.m_aEnvelopeStdDev(i) = std(this.m_aBinsEnvelopes(:,i));
                
                %Modulation
                if(SoundStatistics.FrequencyModulations)
                    [this.m_aModulationTemporalData(:,:,i), this.m_aModulationSpectralData(:,:,i)] = SoundStatistics.GenerateSubbands(this.m_aBinsEnvelopes(:,i), this.m_aModulationFilters);
                end %Settings check
                %this.m_aEnvelopeVariance(i) = stat_central_moment_win(subband_envs(:,j),2,measurement_win,S.env_mean(j));
                %this.m_aEnvelopeSkewness(i) = stat_central_moment_win(subband_envs(:,j),3,measurement_win,S.env_mean(j));
                %this.m_aEnvelopeKurtosis(i) = stat_central_moment_win(subband_envs(:,j),4,measurement_win,S.env_mean(j));
            end %of loop through frequencybins / envelopes
            
            %Calculate cross correlations
            if(SoundStatistics.CrossCorrelations)
                this.m_aFrequencyBinCrossCorrelation = zeros(this.m_iFrequencyBinCount);
                for y = 1:this.m_iFrequencyBinCount
                    for x = 1:this.m_iFrequencyBinCount
                        for i = 1:length(this.m_aBinsEnvelopes(:,x))
                            this.m_aFrequencyBinCrossCorrelation(x,y) = this.m_aFrequencyBinCrossCorrelation(x,y) + ...
                                ((this.m_aBinsEnvelopes(i,x) - this.m_aEnvelopeMean(x)) * (this.m_aBinsEnvelopes(i,y) - this.m_aEnvelopeMean(y))) / ...
                                (this.m_aEnvelopeStdDev(x) * this.m_aEnvelopeStdDev(y));
                        end %of loop through the bin
                    end %of loop through frequencybins x
                end %of loop through frequencybins y
            end %Settings check
            
        end %of CalculateFrequencyBins
    end %of Private methods
    
    methods(Static)
        function [TemporalData, SpectralData] = GenerateSubbands(a_aSignal, a_pFilters)
            if size(a_aSignal,1)==1 %turn into column vector
                a_aSignal = a_aSignal';
            end
            N=size(a_pFilters,2)-2;
            signal_length = length(a_aSignal);
            filt_length = size(a_pFilters,1);
            fft_sample = fft(a_aSignal);
            if rem(signal_length,2)==0 %even length - 
                fft_filts = [a_pFilters' fliplr(a_pFilters(2:filt_length-1,:)')]'; %generate negative frequencies in right place; filters are column vectors
            else %odd length
                fft_filts = [a_pFilters' fliplr(a_pFilters(2:filt_length,:)')]';
            end
            SpectralData = fft_filts.*(fft_sample*ones(1,N+2));%multiply by array of column replicas of fft_sample
            TemporalData = real(ifft(SpectralData)); %ifft works on columns; imag part is small, probably discretization error?
        end %of GenerateSubbands
        
    end %of Static Methods
end % of class