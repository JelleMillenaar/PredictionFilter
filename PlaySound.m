% PlaySound( i_AudioData )
%
% The i_AudioData is used to play the sound through the speakers
%
%% Input
% i_AudioData must be audiobuffer. Obtained from LoadAudioFile(),
% CombineAudioData() or audioread().
%
% May 2017 - Jelle Femmo Millenaar

%% Function
function PlaySound( i_AudioData, i_Samplerate )
    %Create the AudioDeviceWriter
    AudioDevice = audioDeviceWriter('SampleRate', i_Samplerate, 'SupportVariableSizeInput', true);
    
    %Play samples of 2 seconds length each
    Offset = 1;
    while(Offset < length(i_AudioData))
        EndPoint = Offset + 2*(i_Samplerate-1);
        EndPoint = min(EndPoint, length(i_AudioData));
        AudioDevice(i_AudioData(Offset:EndPoint)); 
        Offset = EndPoint;
    end

    %Clean up
    release(AudioDevice);
end
