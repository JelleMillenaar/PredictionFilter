% SpeechIndexSamples = DetectSpeech( i_Signal, FrequencyThreshold, TotalThreshold, i_Annotation, i_MinSpeechAreaDistance )
%
% Detect where speech is located. Within an annotated region, the average
% spectral power is calculated per bin. Whenever a threshold is passed, it will be
% deemed as speech.
%
%% Input
% i_Signal = The signal envelopes including the speech.
% i_Annotation = An array of Area objects that carry Indexes of speech regions.
% i_Threshold = The threshold scalar that signifies speech. 
%
%% Output
% SpeechIndexSamples = An array of the speech that indicates speech or
% none-speech. 
%
% June 2017 - Jelle Femmo Millenaar

%% Function
function SpeechAreas = DetectSpeech( i_Signal, FrequencyThreshold, TotalThreshold, i_Annotation, i_MinSpeechAreaDistance )
    %Prepare data
    SpeechAreas = cell(size(i_Signal,2),1);

    %Loop through all the annotated speech areas.
    for i=1:size(i_Annotation, 2)
        %Calculate the minimum threshold
        MinimumThreshold = mean(i_Signal(i_Annotation(i).m_StartIndex:i_Annotation(i).m_EndIndex, :)) * TotalThreshold;
        MinimumThreshold = mean(MinimumThreshold);
        
        %Loop through the frequencies
        for k=1:size(i_Signal, 2)
            %Calculate the average spectral power in the annotation area.
            ThresholdValue = mean(i_Signal(i_Annotation(i).m_StartIndex:i_Annotation(i).m_EndIndex, k)) * FrequencyThreshold;
            ThresholdValue = max( ThresholdValue, MinimumThreshold);
            
            %Loop through the annotated area to define speech.
            StartPoint = 0;
            EndPoint = 0;
            for p=i_Annotation(i).m_StartIndex:i_Annotation(i).m_EndIndex
                %Start point
                if( i_Signal(p, k) >= ThresholdValue )
                    if( EndPoint && p > EndPoint + i_MinSpeechAreaDistance )
                         %Lock in area
                        SpeechAreas{k} = [SpeechAreas{k} SnrArea(StartPoint, EndPoint)];
                        StartPoint = p;
                        EndPoint = 0;
                    elseif( EndPoint )
                        %Combine areas
                        EndPoint = 0;
                    elseif( ~StartPoint ) 
                        %First startpoint
                        StartPoint = p;
                    end                   
                end
                
                %End point
                if( StartPoint && ~EndPoint && i_Signal(p, k) < ThresholdValue )
                    %Add end point
                    EndPoint = p;
                end
            end
            
            %Insert final endpoint
            if( EndPoint )
                SpeechAreas{k} = [SpeechAreas{k} SnrArea(StartPoint, EndPoint)];
            elseif( StartPoint )
                SpeechAreas{k} = [SpeechAreas{k} SnrArea(StartPoint, i_Annotation(i).m_EndIndex) ];
            end
        end
    end
end