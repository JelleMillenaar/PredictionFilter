% o_AudioData = CombineAudioData( i_AudioData1, i_AudioData2, i_Length )
%
% This function combines two audio data buffers into one. 
%
%% Input
% i_AudioData1 & i_AudioData2 are audiobuffers and recommend to be loaded
% by LoadAudioFile().
%
% i_Length becomes enforced whenever given, otherwise i_AudioData1's
% length is used.
%
%% Output
% o_AudioData = Audiobuffer that represent the combination of the two
% audiobuffers provided.
%
% May 2017 - Jelle Femmo Millenaar

%% Function
function o_AudioData = CombineAudioData( i_AudioData1, i_AudioData2, i_Length)
    %Follow the length of the first sample, unless a length is given.    
    if( nargin < 3 )
        i_Length = length(i_AudioData1);
    end
    
    %Adjust lengths of the samples
    if( length(i_AudioData1) < i_Length )
        i_AudioData1 = [i_AudioData1 zeros(i_Length-length(i_AudioData1),1)];
    elseif( length(i_AudioData1) > i_Length )
        i_AudioData1 = i_AudioData1(1:i_Length);   
    end
    if( length(i_AudioData2) < i_Length )
        i_AudioData2 = [i_AudioData2 zeros(i_Length-length(i_AudioData2),1)];
    elseif( length(i_AudioData2) > i_Length )
        i_AudioData2 = i_AudioData2(1:i_Length);   
    end
    
    %Add the audio files together
    o_AudioData = i_AudioData1 + i_AudioData2;
end