%% PlotSlidingSNR( a_aOriginalSNR, a_aFilteredSNR )
%
% Plots the relative relationship of the SNR's overtime. 1 will be the
% baseline. Anything above 1 is an improvement to the SNR.
%
%% Input
% a_aOriginalSNR = Array of SNR data gathered with SlidingSNR() without any
% filtering to the data.
%
% a_aFilteredSNR = Array of SNR data gathered with SlidingSNR(), filtered
% with the intention to improve the SNR.
%
% May 2017- Jelle Femmo Millenaar

%% Function
function PlotSlidingSNR( a_aOriginalSNR, a_aFilteredSNR) 
    %Check for validity
    if( length(a_aOriginalSNR) ~= length(a_aFilteredSNR) )
       DisplayWarning("SNR arrays do not have the same length");
       return;
    end

    %Create the plot
    figure('Name', 'SlidingSNR' );
    
    %Plot and label
    plot( 1:length(a_aOriginalSNR), 10*log10(a_aFilteredSNR./a_aOriginalSNR));
    xlabel('WindowNumber');
    ylabel('SNR Ratio');
    axis tight;
end