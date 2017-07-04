%% DisplayWarning( a_sMessage )
%
% Display a warning message in the Command Window
%
%% Input
% a_sMessage = The warning message that will be displayed
%
% May 2017 - Jelle Femmo Millenaar

%% Function
function DisplayWarning( a_sMessage )
    disp( "Warning: " + a_sMessage );   
end

%% DisplayError( a_sMessage )
%
% Display an error message in the Command Window
%
%% Input
% a_sMessage = The error message that will be displayed
%
% May 2017 - Jelle Femmo Millenaar

function DisplayError( a_sMessage )
    disp( "Error: " + a_sMessage );
end