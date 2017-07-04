% Diff = CalculateDerivative( i_Signal )
%
% Calculates the derivative of the function.
%
%% Input
% i_Signal = The signal to derivative.
%
%% Output
% Diff = Differentation of the signal.
%
% June 2017 - Jelle Femmo Millenaar

%% Function
function Diff = CalculateDerivative( i_Signal )
    %Prepare data
    Diff = zeros(size(i_Signal));
    for i=2:size(i_Signal,1)
       Diff(i) = i_Signal(i) - i_Signal(i-1); 
    end
end