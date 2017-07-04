% Alphas = CalculateAlphas( i_Frequencies, i_HertzPerHalving )
%
% CalculateAlphas calculates the alpha scalar for calculating the moving
% average for all the frequencies. It is tuned around the fact that higher
% frequencies should adjust faster, while lower frequencies should adjust
% slower.
%
%% Input
% i_Frequencies = Array of all frequencies used
% i_HertzPerHalving = The amount of fluctuations that contribute to half of
% the history. 
%
%% Output
% Alphas = Array of alphas for all frequencies to hse for
% CalculateMovingAverage()
%
%% Function
function Alphas = CalculateAlphas( i_Frequencies, i_HertzPerHalving, i_SampleRate )
    %Prepare array
    Alphas = zeros( 1, size(i_Frequencies,2));
    
    %Loop through frequencies
    for i=1:size(i_Frequencies,2)
       SamplesPerHertz = i_SampleRate / i_Frequencies(i);
       SamplesPerHalving = i_HertzPerHalving * SamplesPerHertz;
       %Alphas ^ SamplesPerHalving = 0.5 
       Alphas(i) = 0.5 ^ (1/SamplesPerHalving);
    end
end