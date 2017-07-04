classdef FrequencyBin
   %Constants
   properties (Constant)
       m_cAttentuationStrength = 80; %dB
       m_cFluxtuationLevel = 1; %dB
       m_cSampleRate = 44100; %MaxFrequency = SampleRate / 2
       m_cMaxFrequency = FrequencyBin.m_cSampleRate / 2;
   end % of constant properties
   %Properties that can only be set during constructor
   properties (SetAccess = immutable)
       m_iStartFreq;
       m_iTopFreq;
       m_iEndFreq;
       m_pBandpassFilter;
   end % of immutable properties
   properties (SetAccess = private)
       m_pSoundData;
   end % of private properties
   methods
       function this = FrequencyBin(a_iStartFreq, a_iTopFreq, a_iEndFreq)
           %Set standard variables
           this.m_iStartFreq = a_iStartFreq;
           this.m_iTopFreq = a_iTopFreq;
           this.m_iEndFreq = a_iEndFreq;
           
           %Create Bandpass
           BandpassDesign = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2', this.m_iStartFreq/FrequencyBin.m_cMaxFrequency, this.m_iTopFreq/FrequencyBin.m_cMaxFrequency, (this.m_iTopFreq+1)/FrequencyBin.m_cMaxFrequency, this.m_iEndFreq/FrequencyBin.m_cMaxFrequency, FrequencyBin.m_cAttentuationStrength, FrequencyBin.m_cFluxtuationLevel, FrequencyBin.m_cAttentuationStrength);
           %normalizefreq(BandpassDesign, false, FrequencyBin.m_cSampleRate);
           this.m_pBandpassFilter = design(BandpassDesign, 'FIR');
       end % of FrequencyBin()
       function this = ProcessSound(this, a_pSoundData)
           this.m_pSoundData = filter(this.m_pBandpassFilter, a_pSoundData);
       end % of ProcessSound()
   end % of methods
end % of class