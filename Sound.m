classdef Sound
    %Private properties
    properties %(SetAccess = private)
        m_sFileName;
        m_sMixName;
        m_sNames;
        m_aAudioData;
        m_iSampleRate;
    end
    
    %Methods
    methods
        function this = Sound(a_sFile, a_iTargetSampleRate, a_iMaxSamples)
            %Load the file
            this.m_sFileName = a_sFile;
            [this.m_aAudioData, this.m_iSampleRate] = audioread(this.m_sFileName);
            
            %Correct the samplerate
            if this.m_iSampleRate ~= a_iTargetSampleRate
                this.m_aAudioData = resample(this.m_aAudioData, a_iTargetSampleRate, this.m_iSampleRate);
                this.m_iSampleRate = a_iTargetSampleRate;
            end
            
            %Max samples
            if nargin > 2
               this.m_aAudioData = this.m_aAudioData(1:a_iMaxSamples); 
            end
            this.m_aAudioData = this.m_aAudioData;
            %Make the samplecount even for erb filters
            if rem(length(this.m_aAudioData),2)==1
                this.m_aAudioData = [this.m_aAudioData; 0];
            end
            
        end %of constructor
        
        function this = MixSound(this, a_sFile)
            %Load the new file
            if( ~length(this.m_sMixName))
                this.m_sMixName = a_sFile;
                [NewAudioData, NewSampleRate] = audioread(this.m_sMixName);

                %Correct the samplerate
                if this.m_iSampleRate ~= NewSampleRate
                    NewAudioData = resample(NewAudioData, this.m_iSampleRate, NewSampleRate);
                end

                %Generate a random part of the voice sample
                if( length(NewAudioData) > length(this.m_aAudioData))
                    RandomStart = 1; %randi([1 length(NewAudioData)-length(this.m_aAudioData)]);
                    NewAudioData = NewAudioData(RandomStart:RandomStart+length(this.m_aAudioData)-1);
                else
                    NewAudioData = [NewAudioData, zeros(1, length(this.m_aAudioData) - length(NewAudioData))];
                end

                %Addition of sounds
                this.m_aAudioData = this.m_aAudioData + NewAudioData;
            else
                disp('Error adding mix, can only mix two sounds atm');
            end
            
        end %of MixSound()
        
        function Play(this)
            AudioDevice = audioDeviceWriter('SampleRate', this.m_iSampleRate, 'SupportVariableSizeInput', true);
            Offset = 1;
            while(Offset < length(this.m_aAudioData))
                EndPoint = Offset + 2*(this.m_iSampleRate-1);
                EndPoint = min(EndPoint, length(this.m_aAudioData));
                AudioDevice(this.m_aAudioData(Offset:EndPoint)); 
                Offset = EndPoint;
            end
            
            %Clean up
            release(AudioDevice);
            
        end %of Play
        
        function TotalSampleCount = GetTotalSampleCount(this)
            TotalSampleCount = length(this.m_aAudioData);
        end
        
        function Name = GetNames(this)
            FileName = strsplit(this.m_sFileName, '.');
            FileName = FileName(1);
            if(length(this.m_sMixName))
                MixName = strsplit(this.m_sMixName, '.');
                MixName = MixName(1);
                Name = strcat(FileName, ' +  ', MixName);
            else
                Name = FileName;
            end
        end
    end
end %of class