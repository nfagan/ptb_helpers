classdef XYSampler < handle
  
  properties (Access = public)
    %   SOURCE -- Source of (X, Y) coordinates.
    %
    %     Source is a handle to an object that is a subclass of
    %     ptb.XYSource, such as ptb.MouseSource or ptb.EyelinkSource. It is
    %     the object from which (X, Y) coordinates are drawn.
    %
    %     See also ptb.XYSampler, ptb.XYSource
    Source;  
  end
  
  properties (GetAccess = public, SetAccess = protected)
    %   X -- Latest sampled X-coordinate.
    %
    %     See also ptb.XYSampler, ptb.XYSampler.Y,
    %       ptb.XYSampler.IsValidSample
    X = nan;
    
    %   Y -- Latest sampled Y-coordinate.
    %
    %     See also ptb.XYSampler, ptb.XYSampler.X,
    %       ptb.XYSampler.IsValidSample
    Y = nan;
    
    %   ISVALIDSAMPLE -- True if the latest sample is valid.
    %
    %     The sampler may have a different definition of validity than the
    %     underlying source. In any case, if IsValidSample is true, then
    %     the current X and Y coordinates are considered valid and
    %     ready-to-use by the consumer of those coordinates.
    %
    %     See also ptb.XYSampler, ptb.XYSampler.X
    IsValidSample = false;
  end
  
  methods
    function obj = XYSampler(source)
      
      %   XYSAMPLER -- Abstract superclass for gaze position samplers.
      %
      %     An XYSampler is an intermediary between an XYSource and a
      %     consumer / user of that source, providing a means of processing
      %     raw samples before they are used downstream.
      %
      %     XYSamplers can be used to e.g. fill in brief loss-of-signal
      %     intervals, or apply smoothing to the raw data.
      %
      %     This class serves as an interface, and is not meant to be
      %     directly instantiated.
      %
      %     See also ptb.XYSampler.X, ptb.XYSampler.Y,
      %       ptb.XYSampler.IsValidSample, ptb.samplers.Missing,
      %       ptb.samplers.Pass
      
      if ( nargin < 1 )
        source = [];
      end
      
      obj.Source = source;
    end
    
    function set.Source(obj, source)
      try
        source = validate_source( obj, source );
      catch err
        throw( err );
      end
      
      obj.Source = source;
      
      on_set_source( obj, source );
    end
  end
  
  methods (Access = protected)
    
    function on_set_source(obj, source)
      % 
    end
    
    function source = validate_source(obj, source)
      if ( isempty(source) )
        source = [];
      else
        validateattributes( source, {'ptb.XYSource'}, {'scalar'}, mfilename, 'Source' );
      end
    end
  end
  
  methods (Abstract = true)
    
    %   UPDATE -- Update to latest sampled coordinates.
    %
    %     update( obj ); processes the latest sample from Source, and sets
    %     the X and Y properties accordingly. After the call to this
    %     function, the IsValidSample property can be used to determine if
    %     the X and Y coordinates are ready-to-use.
    %
    %     See also ptb.XYSampler, ptb.XYSampler.Source
    update(obj);
  end
  
end