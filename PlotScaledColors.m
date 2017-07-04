%% PlotScaledColors( i_Rows, i_Title, i_XLabel, i_YLabel, i_Labels )
%
% Plot a scaled color image of all the rows. Shows the label with a
% interval of a 6th of the total row count.
%
%% Input
% i_Rows = Array of the data that needs to be plotted in a scaled color
% plot.
% i_Labels = The labels that fit with the value that the row represents.
% i_Title, i_XLabel, i_YLabel = Plotting labels.
%
% May 2017 - Jelle Femmo Millenaar

%% Function
function PlotScaledColors( i_Rows, i_Title, i_XLabel, i_YLabel, i_Labels, i_XLabels) 
    %Prepare plotting
    RowCount = size(i_Rows, 1);
    ColumnCount = size(i_Rows, 2);
    figure('Name', 'Scaled Color Plot');
    imagesc(i_Rows);
    set( gca, 'YDir', 'normal');
    if( nargin > 4 )
        set( gca, 'YTick', 1:floor(RowCount/6):RowCount)
        set( gca, 'YTickLabel', round(i_Labels(1:floor(RowCount/6):RowCount)))
    end
    if (nargin > 5 )
        set( gca, 'XTick', 1:floor(ColumnCount/6):ColumnCount)
        set( gca, 'XTickLabel', round(i_XLabels(1:floor(ColumnCount/6):ColumnCount)))
    end
    title(i_Title);
    xlabel(i_XLabel);
    ylabel(i_YLabel);
    axis tight;
    colorbar;
end