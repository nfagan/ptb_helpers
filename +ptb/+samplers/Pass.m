classdef Pass < ptb.XYSampler
  
  methods
    function obj = Pass(varargin)
      
      %   PASS -- Pass coordinates from Source unmodified.
      %
      %     obj = ptb.samplers.Pass(); creates an XYSampler object that
      %     simply copies the coordinates of its source, without additional
      %     processing. If no source is manually set, the coordinates will
      %     remain NaN.
      %
      %     obj = ptb.samplers.Pass( source ); draws raw samples from
      %     the ptb.XYSource object `source`.
      %
      %     See also ptb.XYSampler, ptb.XYSource, ptb.samplers.Missing
      
      obj = obj@ptb.XYSampler( varargin{:} );
    end
  end
  
  methods (Access = public)
    function update(obj)
      
      x = nan;
      y = nan;
      is_valid_sample = false;
      
      if ( ~isempty(obj.Source) && obj.Source.IsValidSample )
        x = obj.Source.X;
        y = obj.Source.Y;
        is_valid_sample = true;
      end
      
      obj.X = x;
      obj.Y = y;
      obj.IsValidSample = is_valid_sample;      
    end
  end
  
end