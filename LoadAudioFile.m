% [o_AudioData, o_SampleRate] = LoadAudioFile(i_FileName, i_SampleRate, i_MaxSamples)
%
% Loads an audio file and prepares the data for further processing.
% 
%% Input
% i_FileName is a string for the location of the audiofile to load.
%
% i_SampleRate is the enforced samplerate of the sample. If the samplerate
% of the audiofile doesn't match, a resample is performed.
%
% i_MaxSamples is the maximum amount of samples that the audiodata may
% contain. Any extra samples will be discarded from the end of the file.
%
%% Output 
% o_AudioData = Audiobuffer that represent the audiodata.
% o_SampleRate = The samplerate that the Audiobuffer is sampled in.
%
% May 2017 - Jelle Femmo Millenaar

%% Function
function [o_AudioData, o_SampleRate] = LoadAudioFile(i_FileName, i_SampleRate, i_MaxSamples)
    %Load the file
    [o_AudioData, o_SampleRate] = audioread(i_FileName);

    %Correct the samplerate
    if nargin > 1
        if o_SampleRate ~= i_SampleRate
            o_AudioData = resample(o_AudioData, i_SampleRate, o_SampleRate);
            o_SampleRate = i_SampleRate;
        end
    end

    %Max samples
    if nargin > 2
       o_AudioData = o_AudioData(1:i_MaxSamples); 
    end

    %Make the samplecount even for erb filters
    if rem(length(o_AudioData),2)==1
        o_AudioData = [o_AudioData; 0];
    end
end