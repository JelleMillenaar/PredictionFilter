% RestSignal = RemovePrediction( i_Signal, i_Prediction, i_AllowNeg )
%
% The predicted signal gets subtracted from the the given signal in
% i_Signal. Some signals should not be able to go below 0 and therefore
% will be capped at 0 if AllowNeg = false.
%
%% Input
% i_Signal = The original signal.
% i_Prediction = The prediction signal to subtract.
% i_AllowNeg = A boolean that whenever false, caps the lowest number to 0.
%
%% Output
% RestSignal = A filtered signal that has it's prediction removed.
%
% June 2017 - Jelle Femmo Millenaar

%% Function
function RestSignal = RemovePrediction( i_Signal, i_Prediction, i_AllowNeg)
    %Subtraction
    RestSignal = i_Signal - i_Prediction;
    
    %Allow Negativity
    if( nargin > 2 && ~i_AllowNeg)
        RestSignal = max(0,RestSignal);
    end
end