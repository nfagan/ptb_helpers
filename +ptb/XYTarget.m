classdef XYTarget < handle
  
  properties (Access = public)
    %   BOUNDS -- Object defining target boundaries.
    %
    %     Bounds is a handle to an object that is a subclass of
    %     ptb.XYBounds, and is used to determine whether the current (X, Y) 
    %     sample is in bounds of the target.
    %
    %     The object should implement a public method called `test` that 
    %     receives, in addition to the object instance, the current X and Y
    %     coordinate and returns a logical scalar value indicating whether 
    %     that coordinate is "in bounds".
    %
    %     In this way, you can define e.g. a polygon with an arbitrary
    %     number of vertices, and test whether a coordinate is in bounds of
    %     that polygon.
    %
    %     For debugging and other purposes, see also ptb.bounds.Never, and
    %     ptb.bounds.Always, which report coordinates as being never and
    %     always in bounds, respectively.
    %
    %     See also ptb.XYBounds, ptb.XYTarget, ptb.XYTarget.Source, 
    %       ptb.bounds.Always, ptb.bounds.Never, ptb.XYTarget.IsInBounds
    Bounds;
    
    %   SOURCE -- Source of (X, Y) coordinates.
    %
    %     Source is a handle to an object that is a subclass of
    %     ptb.XYSource, such as ptb.MouseSource or ptb.EyelinkSource. It is
    %     the object from which (X, Y) coordinates are drawn.
    %
    %     See also ptb.XYTarget, ptb.XYSource, ptb.XYTarget.Duration
    Source;
    
    %   DURATION -- Amount of cumulative time to be spent in bounds.
    %
    %     Duration is a non-negative scalar number indicating the amount of
    %     time in seconds that must be spent in bounds before the
    %     IsDurationMet property is set to true. Default is Inf.
    %
    %     See also ptb.XYTarget, ptb.XYTarget.IsDurationMet
    Duration = inf;
    
    %   ALLOWMISSING -- Reuse expired sample if no valid sample is available.
    %
    %     AllowMissing is a logical flag indicating whether to re-use the
    %     most recent sample from Source in the case that the current
    %     sample is invalid. Default is false.
    %
    %     AllowMissing is useful when Source can report brief intervals of
    %     invalid data / loss of signal, such as during a blink.
    %
    %     See also ptb.XYTarget, ptb.XYTarget.MaxMissingDuration, 
    %       ptb.XYTarget.Source
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
    %     valid sample, then IsInBounds will be false.
    %
    %     See also ptb.XYTarget, ptb.XYTarget.AllowMissing
    MaxMissingDuration = 0;
  end
  
  properties (GetAccess = public, SetAccess = private)
    %   ISINBOUNDS -- True if the current sample is considered in bounds.
    %
    %     ISINBOUNDS is a read-only logical scalar indicating whether the
    %     most recent (X, Y) coordinate was considered in bounds.
    %
    %     See also ptb.XYTarget, ptb.XYTarget.Bounds
    IsInBounds = false;
    
    %   ISDURATIONMET -- True if Cumulative is greater than Duration.
    %
    %     ISDURATIONMET is a read-only logical scalar indicating whether
    %     the Cumulative amount of time spent in bounds is greater than the
    %     current Duration.
    %
    %     See also ptb.XYTarget, ptb.XYTarget.Duration,
    %       ptb.XYTarget.Cumulative
    IsDurationMet = false;
    
    %   CUMULATIVE -- Total amount of consecutive time spent in bounds.
    %
    %     Cumulative is a read-only number giving the total amount of time
    %     spent consecutively in bounds of the target, in seconds. It is 
    %     reset to 0 whenever a sample is considered to be not in bounds, 
    %     or after a call to the `reset` function.
    %
    %     See also ptb.XYTarget, ptb.XYTarget.reset
    Cumulative = 0;
  end
  
  properties (Access = private)
    last_frame = nan;
    cumulative_timer;
    
    was_valid_sample = true;
    missing_sample_timer;
  end
  
  methods
    function obj = XYTarget(source, bounds)
      
      %   XYTARGET -- Create XYTarget object instance.
      %
      %     XYTarget objects keep track of whether and for how long an 
      %     (X, Y) coordinate is in bounds of a target. 
      %
      %     obj = ptb.XYTarget( source ); creates an XYTarget whose
      %     coordinates are drawn from `source`, a subclass of ptb.XYSource
      %     such as ptb.MouseSource. The Bounds property of `obj`, which
      %     tests whether a coordinate from `source` is in bounds, is set
      %     to an object that never returns true.
      %
      %     obj = ptb.XYTarget( ..., bounds ) creates the object and sets
      %     the Bounds property to `bounds`. `bounds` must be a subclass of
      %     ptb.XYBounds.
      %
      %     See also ptb.XYTarget.Bounds, ptb.XYTarget.Source,
      %       ptb.XYTarget.Duration, ptb.XYBounds
      %
      %     IN:
      %       - `source` (ptb.XYSource)
      %       - `bounds` (ptb.XYBounds) |OPTIONAL|
      
      if ( nargin < 2 )
        bounds = ptb.bounds.Never();
      end
      
      obj.Source = source;
      obj.Bounds = bounds;
      
      obj.cumulative_timer = tic;
    end
    
    function set.Bounds(obj, v)
      validateattributes( v, {'ptb.XYBounds'}, {'scalar'}, mfilename, 'Bounds' );
      obj.Bounds = v;
    end
    
    function set.Source(obj, v)
      validateattributes( v, {'ptb.XYSource'}, {'scalar'}, mfilename, 'Source' );
      obj.Source = v;
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
    
    function set.Duration(obj, v)
      validateattributes( v, {'numeric'}, {'scalar', 'nonnegative'} ...
        , mfilename, 'Duration' );
      obj.Duration = double( v );
    end
  end
  
  methods (Access = public)
    
    function reset(obj)
      
      %   RESET -- Reset the Cumulative amount of time spent in bounds.
      %
      %     See also ptb.XYTarget, ptb.XYTarget.Cumulative,
      %       ptb.XYTarget.Duration
      
      obj.Cumulative = 0;
    end
    
    function update(obj)
      
      %   UPDATE -- Update the in-bounds state of the XYTarget.
      %
      %     update( obj ) checks whether the current sample is in bounds,
      %     and if so, updates the Cumulative total amount of time spent in
      %     bounds.
      %
      %     This function is most sensibly called in a loop after updating 
      %     the underlying source's position.
      %
      %     See also ptb.XYTarget, ptb.XYTarget.Source
      
      x = obj.Source.X;
      y = obj.Source.Y;
      is_valid_sample = obj.Source.IsValidSample;
      
      if ( obj.AllowMissing && ~is_valid_sample )
        % Missing data is allowed, and this is a missing sample.
        
        if ( obj.was_valid_sample )
          % This is the first frame of a missing sample, so start the
          % timer.
          
          obj.missing_sample_timer = tic();
        end
        
        % If we're within the window of MaxMissingDuration, test bounds
        % using the most-recent gaze position.
        should_test_bounds = toc( obj.missing_sample_timer ) < obj.MaxMissingDuration;
      else
        should_test_bounds = is_valid_sample;
      end
      
      if ( should_test_bounds )
        is_in_bounds = test( obj.Bounds, x, y );
      else
        is_in_bounds = false;
      end
      
      current_frame = toc( obj.cumulative_timer );
      
      if ( is_in_bounds && ~isnan(obj.last_frame) )
        delta = current_frame - obj.last_frame;
        obj.Cumulative = obj.Cumulative + delta;
      else
        obj.Cumulative = 0;
      end
      
      obj.IsInBounds = is_in_bounds;
      obj.IsDurationMet = obj.Cumulative >= obj.Duration;
      
      obj.last_frame = current_frame;
      obj.was_valid_sample = is_valid_sample;      
    end
  end
end