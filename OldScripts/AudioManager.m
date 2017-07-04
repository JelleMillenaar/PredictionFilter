classdef AudioManager < handle
    properties (Constant)
        m_cFrequencyBinCount = 10;
        m_cExpectedMaxFreq = 22050;
    end % of Constants
    properties (SetAccess = private)
        %Audio Variables
        m_sFileName;
        m_pAudioData;
        m_iSampleRate;
        
        %Processing variables
        m_aFrequencyBins = FrequencyBin.empty(AudioManager.m_cFrequencyBinCount,0,1);
    end % of private properties
    methods
        function this = AudioManager()
            %Create the correct amount of FrequencyBins
            for i = 1:AudioManager.m_cFrequencyBinCount
                Stop1 = max((AudioManager.m_cExpectedMaxFreq / AudioManager.m_cFrequencyBinCount * (i-1)), 1);
                Stop2 = min((AudioManager.m_cExpectedMaxFreq / AudioManager.m_cFrequencyBinCount * i),AudioManager.m_cExpectedMaxFreq-1);
                Top = (AudioManager.m_cExpectedMaxFreq / AudioManager.m_cFrequencyBinCount * (i-0.5));
                this.m_aFrequencyBins(i) = FrequencyBin(Stop1, Top, Stop2);
            end % of For loop
        end % of AudioManager()        
        function SetSound(this, a_sFileName)
            %Load the sound
            this.m_sFileName = a_sFileName;
            [this.m_pAudioData, this.m_iSampleRate] = audioread(this.m_sFileName);
            
            %Update the FrequencyBins
            for i = 1:AudioManager.m_cFrequencyBinCount
                this.m_aFrequencyBins(i) = this.m_aFrequencyBins(i).ProcessSound(this.m_pAudioData);
            end % of forloop
        end % of SetSound()
        function PlotAmplitudeTimeWithBins(this) 
            %Calculate length of X-axis
            AudioSamplesTime = 1:size(this.m_pAudioData);
            AudioSamplesTime = AudioSamplesTime / this.m_iSampleRate;
            
            %Prepare the plot
            figure('Name', 'Time Domain');
            xlabel('Time(S)');
            ylabel('Amplitute');
            title('Amplitude - Time');
            
            %Plot the data
            plot(AudioSamplesTime, this.m_pAudioData);
            hold on;
            
            %Plot the Bins
            for i = 1:AudioManager.m_cFrequencyBinCount
                plot(AudioSamplesTime, this.m_aFrequencyBins(i).m_pSoundData);
            end % of forloop
            
        end % of PlotAmplitudeTimeWithBins()
    end % of methods
end % of class