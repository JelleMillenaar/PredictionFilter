% TemporalData = GenerateSubbands( a_aSignal, a_pFilters )
%
% GenerateSubbands uses a set of filters to split a time domain signal into
% different frequency bins, generated by the filters.
%
%% Input
% a_aSignal = Audiodata that needs to be split into subbands.
% a_pFilters = Filteres, generated by CreateErbFilters() that help split
% the signal. Incase the filters are made like that, it will support
% perfect reconstruction using the Reconstruct() function
%
%% Output
% TemporalData = An array of x subbands, where x is the amount of filters.
% The subbands will contain temporal data for the frequency activity within
% the subband.

%% function
function TemporalData = GenerateSubbands(a_aSignal, a_pFilters)
    if size(a_aSignal,1)==1 %turn into column vector
        a_aSignal = a_aSignal';
    end
    N=size(a_pFilters,2)-2;
    signal_length = length(a_aSignal);
    filt_length = size(a_pFilters,1);
    fft_sample = fft(a_aSignal);
    if rem(signal_length,2)==0 %even length - 
        fft_filts = [a_pFilters' fliplr(a_pFilters(2:filt_length-1,:)')]'; %generate negative frequencies in right place; filters are column vectors
    else %odd length
        fft_filts = [a_pFilters' fliplr(a_pFilters(2:filt_length,:)')]';
    end
    SpectralData = fft_filts.*(fft_sample*ones(size(a_aSignal,2),N+2));%multiply by array of column replicas of fft_sample
    TemporalData = real(ifft(SpectralData)); %ifft works on columns; imag part is small, probably discretization error?
end %of GenerateSubbands