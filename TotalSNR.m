%% [o_SNR, o_Weight] = TotalSNR( i_SnrAreas, i_SpeechAreas )
%
% Calculates the the TotalSNR of all the SNR_Areas given, as long as they
% fall within the SpeechAreas given. If no SpeechAreas are given, all
% SNRAreas are deemed valid.
%
%% Input
% i_SnrAreas = The SNRAreas to check
% i_SpeechAreas (Optional) = The boundaries that the SNRAreas must fall under
%
%% Output
% o_SNR = The Calculate SNR of the given input.
% o_Weight = The weighting of the SNR calculated. AKA number of samples.
%
%% Function
function [o_SNR, o_Weight] = TotalSNR( i_SnrAreas, i_SpeechAreas )
    %Loop through the SNRAreas - Bands
    o_SNR = 0;
    o_Weight = 0;
    for i=1:size( i_SnrAreas, 1)
        %Loop through the SNRAreas individually
         for k=1:size(i_SnrAreas{i}, 2)
             %Check if we must use this SNRArea
             Valid = (nargin <= 1);
             if( ~Valid )
                 for p=1:size(i_SpeechAreas, 2)
                     if( i_SnrAreas{i}(k).m_StartIndex > i_SpeechAreas(p).m_StartIndex && i_SnrAreas{i}(k).m_EndIndex < i_SpeechAreas(p).m_EndIndex )
                        Valid = true; 
                        break;
                     end
                 end
             end
             %Valid Area - Calculate the SNR
             if( Valid )
                 %Update SNR
                 AreaWeight = i_SnrAreas{i}(k).GetSize();
                 o_SNR = o_SNR * o_Weight + i_SnrAreas{i}(k).GetAverageSNR() * AreaWeight;
                 o_Weight = o_Weight + AreaWeight;
                 o_SNR = o_SNR / o_Weight;
             end
         end
    end
end