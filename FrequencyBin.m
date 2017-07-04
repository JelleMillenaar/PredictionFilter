classdef FrequencyBin
    properties (SetAccess = private)
        m_pData;    
        m_pEnvelope;
        m_iTargetFrequency;
        m_pFrequencyData;
    end %of properties
    methods
        function this = FrequencyBin(a_iFrequency)
            this.m_iTargetFrequency = a_iFrequency;
        end % of constructor
        
        function this = SetData(this, a_pData, a_pWindow, a_pAudioManager)
            %Load in the data
            this.m_pData = zeros(a_pAudioManager.GetSignalLength(),1);
            this.m_pFrequencyData = zeros(a_pAudioManager.GetSignalLength(),1);
            this.m_pData(a_pWindow) = this.m_pData(a_pWindow)+ a_pData;
            this.m_pFrequencyData = this.m_pData;
            nyqBin = floor(a_pAudioManager.GetSignalLength()/2) + 1;
            this.m_pData(nyqBin+1:end) = conj( this.m_pData(nyqBin  - (~logical(mod(a_pAudioManager.GetSignalLength(),2))) : -1 : 2) ); %?????
            this.m_pData = real(ifft(this.m_pData)); 
            
            %Create the envelope
            [this.m_pEnvelope, Lower] = envelope(this.m_pData, 500, 'peak');
            
        end %of SetData
        
        function PlotTimeAmplitude(this)
            AudioSamplesTime = 1:size(this.m_pData);
            AudioSamplesTime = AudioSamplesTime / AudioManager.m_cSampleRate;
            
            %Plot the data
             plot(AudioSamplesTime, this.m_pData);
        end %of PlotTimeAmplitude
        
        function PlotSpectralTime(this)
            AudioSamplesTime = 1:size(this.m_pData);
            AudioSamplesTime = AudioSamplesTime / AudioManager.m_cSampleRate;
            
            %Plot the data
             plot(AudioSamplesTime, 20*log10(abs(flipud(this.m_pFrequencyData))+eps) );
        end %of PlotSpectralTime()
    end % of methods
end % of classdef