classdef Target < handle
  
  properties
    tracker;
    bounds = [];
    padding = [ 0, 0, 0, 0 ];
    x_offset = 0;
    y_offset = 0;
    in_bounds = false;
    cumulative = 0;
    duration = [];
    timer = [];
    last_frame = 0;
  end
  
  methods
    
    function obj = Target(tracker, bounds, duration)
      
      %   TARGET -- Instantiate a fixation target.
      %
      %     IN:
      %       - `tracker` (EyeTracker) -- EyeTracker instance.
      %       - `bounds` (double) -- 4-element vector specifying the
      %         target-bounds.
      %       - `duration` (double) -- Number specifying the minimum
      %         fixation time, in seconds.
      
      obj.tracker = tracker;
      obj.bounds = bounds;
      obj.duration = duration;
      obj.timer = tic;
    end
    
    %{
        PROPERTY SETTING + VALIDATION
    %}
    
    function set.tracker(obj, val)      
      
      %   SET.TRACKER -- Validate and update the tracker property.
      %
      %     The tracker must be an EyeTracker instance.
      %
      %     IN:
      %       - `val` (char)
      
      obj.assert__isa( val, 'EyeTracker', 'the eyetracker instance' );
      obj.tracker = val;
    end
    
    function set.bounds(obj, val)
      
      %   SET.BOUNDS -- Validate and update the bounds property.
      %
      %     The boundaries must be a 4-element position vector.
      %
      %     IN:
      %       - `val` (char)
      
      obj.assert__isa( val, 'double', 'the target bounds' );
      assert( numel(val) == 4, ['Expected the target bounds to have 4' ...
        , ' elements, but %d were present'], numel(val) );
      obj.bounds = val;
    end
    
    function set.padding(obj, pad)
      
      %   SET.PADDING -- Validate and update the padding property.
      %
      %     If padding is a scalar value, it will be applied evenly to +/-
      %     x and +/- y. Otherwise, specify padding as a 4-element vector
      %     to control +/- x and +/- y individually.
      %
      %     IN:
      %       - `pad` (double) -- 4-element vector or scalar.
      
      obj.assert__isa( pad, 'double', 'the target padding' );
      if ( numel(pad) == 1 )
        pad = [ -pad, -pad, pad, pad ];
      else
        assert( numel(pad) == 4, ['Paddding must be specified as a' ...
          , ' 4-element vector or a scalar.'] );
      end
      obj.padding = pad;
    end
    
    %{
        CUMULATIVE GAZE HANDLING
    %}
    
    function update(obj)
      
      %   UPDATE -- Update cumulative looking to the target.
      %
      %     If a fixation does not fall within the given boundaries, the
      %     cumulative fixation time is reset to 0. Otherwise, the
      %     cumulative fixation time is updated based on the delta from the
      %     last call to update().
      
      if ( ~obj.tracker.gaze_ready )
        obj.last_frame = toc( obj.timer );
        return;
      end
      x = obj.tracker.coordinates(1);
      y = obj.tracker.coordinates(2);
      x_off = obj.x_offset;
      y_off = obj.y_offset;
      offsets = [ x_off, y_off, x_off, y_off ];
      gaze_bounds = obj.bounds + obj.padding + offsets;
      within_x = x >= gaze_bounds(1) && x < gaze_bounds(3);
      within_y = y >= gaze_bounds(2) && y < gaze_bounds(4);
      if ( within_x && within_y )
        delta = toc( obj.timer ) - obj.last_frame;
        obj.cumulative = obj.cumulative + delta;
        obj.in_bounds = true;
      else
        obj.cumulative = 0;
        obj.in_bounds = false;
      end
      obj.last_frame = toc( obj.timer );
    end
    
    function tf = duration_met(obj)
      
      %   DURATION_MET -- Return whether the given fixation duration
      %     has been met or exceeded.
      %
      %     OUT:
      %       - `tf` (true, false)
      
      tf = obj.cumulative >= obj.duration;
    end
    
    function reset(obj)
      
      %   RESET -- Reset the cumulative looking time to the fixation
      %     target to 0.
      
      obj.cumulative = 0;
      obj.last_frame = toc( obj.timer );
    end
    
    %{
        PLACEMENT
    %}
    
    function shift(obj, dx, dy)
      
      %   SHIFT -- Move the fixation target by an x and y amount.
      %
      %     IN:
      %       - `dx` (double) -- X displacement.
      %       - `dy` (double) -- Y displacement.
      
      shift_vec = [ dx, dy, dx, dy ];
      obj.bounds = obj.bounds + shift_vec;    
    end
  
    %{
        ASSERTIONS
    %}
  
    function assert__isa(obj, var, kind, var_name)
      
      %   ASSERT__ISA -- Ensure a variable is of a given kind.
      %
      %     IN:
      %       - `var` (/any/) -- Variable to check.
      %       - `kind` (char) -- Expected class of `var`.
      %       - `var_name` (char) |OPTIONAL| -- Optionally provide a more
      %         descriptive name for the variable in case the assertion
      %         fails.
      
      if ( nargin < 4 ), var_name = 'input'; end;
      assert( isa(var, kind), 'Expected %s to be a ''%s''; was a ''%s''.' ...
        , var_name, kind, class(var) );
    end
  end  
end