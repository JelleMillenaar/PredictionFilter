% MovingAverage = CalculateMovingAverage( i_Data, i_Alphas )
%
% The moving average start at 0(t=0) is calculated along the data arrays. The standard
% formula for Exponential Moving Average is used:
% EMA(t) = (1-Alpha) * i_Data(t) + Alpha * EMA(t-1)
%
%% Input
% i_Data = The data (can be an array of arrays) that has contains an array
% of timedata. Initially created for BinEnvelopes of the audiodata.
% i_Alphas = Array of scalars that decide the weighting of the past to the
% current average.
%
%% Output
% MovingAverage is an array of the moving average over the time starting at 0.
% The output is the same dimensions as the input (i_Data).
%
% June 2017 - Jelle Femmo Millenaar

%% Function
function MovingAverage = CalculateMovingAverage( i_Data, i_Alphas )
    %Prepare data
    MovingAverage = zeros( size(i_Data));
    MovingAverage(1, :) = i_Data(1, :);
    
    %Calculate over time
    for i=2:size(i_Data,1)
       MovingAverage(i, :) = (1-i_Alphas) .* i_Data(i, :) + i_Alphas .* MovingAverage(i-1, :);
    end
end