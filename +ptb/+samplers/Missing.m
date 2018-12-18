classdef Missing < ptb.XYSampler
  
  properties (Access = public)    
    %   ALLOWMISSING -- Reuse expired sample if no valid sample is available.
    %
    %     AllowMissing is a logical flag indicating whether to re-use the
    %     most recent sample from Source in the case that the current
    %     sample is invalid. Default is false.
    %
    %     AllowMissing is useful when Source can report brief intervals of
    %     invalid data / loss of signal, such as during a blink.
    %
    %     See also ptb.samplers.Missing, 
    %       ptb.samplers.Missing.MaxMissingDuration, 
    %       ptb.samplers.Missing.Source
    AllowMissing = false;
    
    %   MAXMISSINGDURATION -- Maximum missing duration in seconds.
    %
    %     MaxMissingDuration is a non-negative numeric scalar giving the
    %     maximum number of seconds over which an expired sample can be
    %     re-used, in the case that the current sample is invalid. Only has
    %     an effect if AllowMissing is true. Default is 0.
    %
    %     For example, if AllowMissing is true, and MaxMissingDuration is
    %     0.1, then, at maximum, the object will use the most recent sample
    %     from Source for 0.1 seconds. If 0.1 seconds elapse without a new
    %     valid sample, then the X and Y coordinates will be NaN.
    %
    %     See also ptb.samplers.Missing, ptb.samplers.Missing.AllowMissing
    MaxMissingDuration = 0;
  end
  
  properties (GetAccess = public, SetAccess = private)
    
    %   ISMISSINGSAMPLE -- True if the current sample has been re-used.
    %
    %     IsMissingSample is a read-only logical scalar indicating whether 
    %     the current X and Y coordinates come from a previous sample
    %     that has been re-used because the most recent sample was invalid,
    %     and fewer than MaxMissingDuration seconds have elapsed since the
    %     last valid sample.
    %
    %     In this way, IsValidSample indicates whether the current X and Y
    %     coordinates are considered useable by the consumer, and
    %     IsMissingSample indicates whether those valid coordinates have 
    %     been re-used.
    %
    %     See also ptb.samplers.Missing, ptb.samplers.missing.AllowMissing,
    %       ptb.samplers.Missing.MaxMissingDuration,
    %       ptb.samplers.Missing.IsValidSample
    IsMissingSample = false;
  end
  
  properties (Access = private)   
    last_valid_x = nan;
    last_valid_y = nan;
    
    last_valid_sample_timer = nan;
    last_valid_frame = nan;
    
    was_one_valid_sample = false;
  end
  
  methods
    function obj = Missing(varargin)
      
      %   MISSING -- Optionally fill in missing signal intervals in Source.
      %
      %     obj = ptb.samplers.Missing(); creates an XYSampler object that
      %     has the ability to re-use a previous sample in the event that
      %     the current sample is missing, e.g. due to a brief loss of
      %     signal during a blink.
      %
      %     obj = ptb.samplers.Missing( source ); draws raw samples from
      %     the ptb.XYSource object `source`.
      %
      %     By default, no missing samples are ever used; you must
      %     explicitly set the AllowMissing and MaxMissingDuration
      %     properties to enable this behavior.
      %
      %     See also ptb.XYSampler, ptb.samplers.Missing.AllowMissing,
      %       ptb.samplers.Missing.MaxMissingDuration,
      %       ptb.XYSource, ptb.samplers.Pass
      
      obj = obj@ptb.XYSampler( varargin{:} );
    end
    
    function set.AllowMissing(obj, v)
      validateattributes( v, {'numeric', 'logical'}, {'scalar'}, mfilename, 'AllowMissing' );
      obj.AllowMissing = logical( v );
    end
    
    function set.MaxMissingDuration(obj, v)
      validateattributes( v, {'numeric'}, {'scalar', 'nonnegative'} ...
        , mfilename, 'MaxMissingDuration' );
      obj.MaxMissingDuration = double( v );
    end
  end
  
  methods (Access = public)
    
    function update(obj)
      
      x = nan;
      y = nan;
      
      has_source = ~isempty( obj.Source );
      
      if ( has_source )
        is_valid_sample = obj.Source.IsValidSample;
      else
        is_valid_sample = false;
      end
      
      is_missing_sample = false;
      is_useable_sample = false;
      
      if ( is_valid_sample )
        if ( ~obj.was_one_valid_sample )
          obj.last_valid_sample_timer = tic();
          obj.was_one_valid_sample = true;
        end
        
        obj.last_valid_frame = toc( obj.last_valid_sample_timer );
        
        x = obj.Source.X;
        y = obj.Source.Y;
        
        is_useable_sample = true;
        
      elseif ( obj.AllowMissing && has_source && obj.was_one_valid_sample )        
        current_missing_frame = toc( obj.last_valid_sample_timer );
        elapsed_missing = current_missing_frame - obj.last_valid_frame;

        if ( elapsed_missing <= obj.MaxMissingDuration )            
          % If we're within the window of MaxMissingDuration, use the
          % most-recent valid gaze position
          x = obj.last_valid_x;
          y = obj.last_valid_y;

          is_missing_sample = true;
          is_useable_sample = true;
        end
      end
      
      obj.X = x;
      obj.Y = y;
      
      obj.IsMissingSample = is_missing_sample;
      obj.IsValidSample = is_useable_sample;
    end
  end
  
  methods (Access = protected)
    function on_set_source(obj, source)
      invalidate( obj );
    end
  end
  
  methods (Access = private)
    function invalidate(obj)
      obj.last_valid_frame = nan;
      obj.last_valid_sample_timer = nan;
      obj.was_one_valid_sample = false;
      obj.last_valid_x = nan;
      obj.last_valid_y = nan;
    end
  end
  
end