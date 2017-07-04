%% PlotFilters ( i_Filters, i_Frequencies )
%
% Plots the shapes of all the filters
%
%% Input
% i_Filters = An array of the shapes of the filters
% i_Frequencies = The center frequency for the filters
%
% May 2017 - Jelle Femmo Millenaar

function PlotFilters( i_Filters, i_Frequencies )
    % Calculate the size
    FilterCount = length(i_Filters(1,:));
    LegendInfo = zeros(FilterCount, 1);
    MaxFrequency = round(i_Frequencies(length(i_Frequencies)));

    %Create the plot
    figure('Name', 'Filters' ); 
    hold on;
    
    %Plot and label
    for i=1:FilterCount
        plot( 1:MaxFrequency, i_Filters(1:MaxFrequency,i));
        LegendInfo(i) = i_Frequencies(i);
    end
    legend(string(LegendInfo));
    xlabel('Frequency');
    ylabel('Filter Weight');
    axis tight;
end