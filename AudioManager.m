classdef AudioManager < handle
    properties (Constant)
        m_cSampleRate = 44100; %fs
        m_cMaxFrequency = AudioManager.m_cSampleRate/2; %fmax
        m_cMinFrequency = 27.5; %fmin
        m_cBinsPerOctave = 4; %B
        m_cGamma = 20; %gamma
    end % of Constants
    properties (SetAccess = private)
        %Audio Variables
        m_sFileName;
        m_pAudioData;
        m_iSampleRate;
        m_pRestoredData;
        m_aAudioSampleTimes;
        m_aQConstantM;
             
        %Bins
        m_iBinCount;
        m_aBinsFrequency;
        m_aBinsTimeData;
        m_aBinsSpectralData;
        m_aBinsEnvelopes;
        
    end % of private properties
    methods
        function this = AudioManager()

        end % of AudioManager()  
        
        function SetSound(this, a_sFileName, a_iSampleSec)
            %% Load the sound
            this.m_sFileName = a_sFileName;
            if( nargin == 3)
               [this.m_pAudioData, this.m_iSampleRate] = audioread(this.m_sFileName, [1, a_iSampleSec * AudioManager.m_cSampleRate]);
            else
                [this.m_pAudioData, this.m_iSampleRate] = audioread(this.m_sFileName);
            end
            %this.m_pAudioData = dsp.SineWave(10, 22000, 0, 'SampleRate', 44100, 'SamplesPerFrame', 44100).step();% + dsp.SineWave(10, 44000, 0, 'SampleRate', 44100, 'SamplesPerFrame', 44100).step();
            %this.m_iSampleRate = 44100;
            
            
            %% Samplerate check
            if( this.m_iSampleRate ~= AudioManager.m_cSampleRate )
                warning('Input sound %s does not have the fixed samplerate of 44100 Hz', this.m_sFileName );
            end %if
            
            %% Calculate Audio stuff
            this.m_aAudioSampleTimes = 1:size(this.m_pAudioData);
            this.m_aAudioSampleTimes = this.m_aAudioSampleTimes / this.m_iSampleRate;
            
            %% Do the Q-constant Transformation
            QConstantResults = cqt(this.m_pAudioData, AudioManager.m_cBinsPerOctave, AudioManager.m_cSampleRate, ...
                AudioManager.m_cMinFrequency, AudioManager.m_cMaxFrequency, 'rasterize', 'full','gamma', AudioManager.m_cGamma);
            this.m_aQConstantM = QConstantResults.M;
            
            %% Save the FrequencyData + 2 extra bins 
            %(Bin 1 = 0-MinFreq; Bin N = Bin (N-1)-MaxFreq
            this.m_iBinCount = (size(QConstantResults.c,1))+2;
            this.m_aBinsSpectralData = cell(1, this.m_iBinCount);
            this.m_aBinsSpectralData(2:end-1) = num2cell(QConstantResults.c.', 1);
            this.m_aBinsSpectralData(1) = {QConstantResults.cDC.'};
            this.m_aBinsSpectralData(end) = {QConstantResults.cNyq.'};
            
            %% Set the Target Frequencies
            this.m_aBinsFrequency = cell(1, this.m_iBinCount);
            for k=2:this.m_iBinCount-1
                this.m_aBinsFrequency(k) = num2cell(QConstantResults.fbas(k-1), 1);
            end
            
            %% Set the TimeData
            %Precalculate a lot of stuff
            SpectralData = this.m_aBinsSpectralData;
            if iscell(SpectralData) == 0 % If matrix format coefficients were used, convert to
                % cell
                if ndims(SpectralData) == 2
                    [N,chan_len] = size(SpectralData); CH = 1;
                    SpectralData = mat2cell(SpectralData.',chan_len,ones(1,N)).';
                else
                    [N,chan_len,CH] = size(SpectralData);
                    ctemp = mat2cell(permute(SpectralData,[2,1,3]),chan_len,ones(1,N),ones(1,CH));
                    SpectralData = permute(ctemp,[2,3,1]);
                    clear ctemp;
                end
            else
                [CH, N] = size(SpectralData);
            end

            posit = cumsum(QConstantResults.shift);      % Calculate positions from shift vector
            NN = posit(end);            % Reconstruction length before truncation
            posit = posit-QConstantResults.shift(1);   % Adjust positions
            
            %Loop and calculate time data
            this.m_aBinsTimeData = zeros(this.GetSignalLength(), this.m_iBinCount);
            this.m_aBinsEnvelopes = zeros(this.GetSignalLength(), this.m_iBinCount);
            for k=1:this.m_iBinCount
                %Calculations
                Lg = length(QConstantResults.g{k}); 
                win_range = mod(posit(k)+(-floor(Lg/2):ceil(Lg/2)-1),NN)+1;
                temp = fft(SpectralData{k},[],1)*length(SpectralData{k});
    
                if strcmp(QConstantResults.phasemode,'global')
                   %shift the center frequency back to baseband prior to
                   %reconstruction (after having them shifted to the 'true alias
                   %frequency')
                   fsNewBins = size(SpectralData{k},1);
                   fkBins = posit(k);
                   displace = fkBins - floor(fkBins/fsNewBins) * fsNewBins;
                   temp = circshift(temp, -displace);
                end

                temp = temp(mod([end-floor(Lg/2)+1:end,1:ceil(Lg/2)]-1,...
                    length(temp))+1,:);
                this.m_aBinsTimeData(win_range, k) = this.m_aBinsTimeData(win_range, k) + bsxfun(@times,temp,QConstantResults.g{k}([Lg-floor(Lg/2)+1:Lg,1:ceil(Lg/2)]));
                nyqBin = floor(this.GetSignalLength()/2) + 1;
                this.m_aBinsTimeData(nyqBin+1:end, k) = conj( this.m_aBinsTimeData(nyqBin  - (~logical(mod(this.GetSignalLength(),2))) : -1 : 2, k) );
                this.m_aBinsTimeData(:, k) = real(ifft(this.m_aBinsTimeData(:, k)));
                
                %Create the envelope 
                [this.m_aBinsEnvelopes(:, k), Lower] = envelope(this.m_aBinsTimeData(:, k), 500, 'peak');
            end
            
            %% Convert matrixes
            %Clear Extra frequencyBins
            this.m_aBinsSpectralData(:,1) = [];
            this.m_aBinsSpectralData(:,end) = [];
            this.m_aBinsSpectralData = cell2mat(this.m_aBinsSpectralData).';
            this.m_aBinsFrequency = cell2mat(this.m_aBinsFrequency);
            this.m_iBinCount = this.m_iBinCount - 2;
            
            %% TODO: Reconstruction
        end % of SetSound()
        
        function SignalLength = GetSignalLength(this)
            SignalLength = length(this.m_pAudioData);
        end %of GetSignalLength
        
        function PlotOriginal(this)
            %Prepare the plot
             figure('Name', 'Original Amplitude - Time');
             xlabel('Time(S)');
             ylabel('Amplitute');
             title('Original Amplitude - Time');
             
             %Plot the data
             plot(this.m_aAudioSampleTimes, this.m_pAudioData);
        end % of PlotOriginal
        
        function PlotReconstruction(this)
            %% TODO: Plot code
        end % of PlotReconstruction
        
        function PlotEnvelopes(this) 
            %Prepare the plot
            figure('Name', 'Frequency Envelopes');
            xlabel('Time(S)');
            ylabel('Amplitute');
            title('Frequency Envelopes');

            %Plot the Bins
            LegendInfo = zeros(this.m_iBinCount, 1);
            for i = 1:this.m_iBinCount
                plot(this.m_aAudioSampleTimes, this.m_aBinsEnvelopes(:, i));
                LegendInfo(i) = this.m_aBinsFrequency(1, i);
                hold on;
            end % of forloop
            
            %Add Legend
            legend(string(LegendInfo));
            
        end % of PlotEnvelopes()
        
        function PlotSpectogram(this)
            %Prepare the plot
            figure('Name', 'Spectogram');

            %Plotting
            imagesc(20*log10(abs(flipud(this.m_aBinsSpectralData))+eps)); %Undefined function 'abs' for input arguments of type 'cell'.
            SamplePerSec = (size(this.m_aBinsSpectralData,2)/(AudioManager.m_cSampleRate/this.GetSignalLength()))/10;
            xtickVec = 0:SamplePerSec:size(this.m_aBinsSpectralData,2);
            xtickLabel = 0:100:(length(xtickVec)-1)*100;
            set(gca,'XTick',xtickVec);
            set(gca,'XTickLabel',xtickLabel);
            ytickVec = 0:AudioManager.m_cBinsPerOctave:size(this.m_aBinsSpectralData,1)-1;
            set(gca,'YTick',ytickVec);
            ytickLabel = round(AudioManager.m_cMinFrequency * 2.^( (size(this.m_aBinsSpectralData,1)-ytickVec)/AudioManager.m_cBinsPerOctave));
            set(gca, 'YTickLabel', ytickLabel);
            xlabel('Time (ms)');
            ylabel('Frequency (Hz)');
            title('Spectogram');
            
        end % of PlotSpectogram
        
    end % of methods
end % of class