%% i_SnrAreas = CalculateSNR ( i_Data, i_SnrAreas, i_NoiseAreaSize )
%
% CalculateSNR calculates the SNR over all areas indicated by the indexies
% over the Data. The predicted noise is calculated by averaging the last
% NoiseAreaSize samples from the data before the StartIndex of the area.
%
%% Input
% i_Data = The data to use for SNR calculation.
% i_SnrAreas = The SnrArea objects that indicate the areas that need to
% have SNR calculation to be performed on.
% i_NoiseAreaSize = The amount of samples before the SnrArea that are used
% to calculate the mean noise.
%
%% Output
% i_SnrAreas = The same SnrAreas but now updated with the results
%
%% Function
function i_SnrAreas = CalculateSNR( i_Data, i_SnrAreas, i_NoiseAreaSize )
    %Loop through the Areas - Bands
    for i=1:size( i_SnrAreas, 1)
        for k=1:size(i_SnrAreas{i}, 2)
            %Calculate the Noise
            Noise = mean( i_Data(i_SnrAreas{i}(k).m_StartIndex-i_NoiseAreaSize:i_SnrAreas{i}(k).m_StartIndex) );
            Noise = max( eps(1), Noise );
            i_SnrAreas{i}(k) = i_SnrAreas{i}(k).CalculateSNR( i_Data(:,i), Noise );
        end
    end
end
