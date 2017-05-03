classdef Stimulus < handle
  
  properties
    window;
    window_rect = [];
    window_center = [];
    placement;
    color;
    vertices;
    last_frame_timer = NaN;
    is_blinking = false;
    should_blink = false;
    should_show = true;
    blink_rate = NaN;
    targets = {};
  end
  
  methods
    function obj = Stimulus(window, wrect)
      
      %   STIMULUS -- Instantiate a Stimulus object.
      
      obj.window = window;
      obj.window_rect = wrect;
      obj.window_center = round( [mean(wrect([1 3])), mean(wrect([2 4]))] );
    end
    
    function set.window_rect(obj, val)
      
      %   SET.WINDOW_RECT -- Validate and update the window_rect property.
      %
      %     The new window_rect must be a 4 element vector.
      
      obj.assert__isa(val, 'double', 'the window rect' );
      assert( numel(val) == 4, ['Expected window rect to have 4 elements' ...
        , ' but %d were present.'], numel(val) );
      obj.window_rect = val;
    end
    
    %{
        EYE TRACKING
    %}
    
    function add_target(obj, target)
      
      %   ADD_TARGET -- Add a fixation target.
      %
      %     IN:
      %       - `target` (Target) -- New fixation target to add.
      
      obj.assert__isa(target, 'Target', 'the fixation target' );
      obj.targets{end+1} = target;
    end
    
    function make_target(obj, tracker, duration)
      
      %   MAKE_TARGET -- Add a fixation target whose bounds are the
      %     vertices of the stimulus.
      %
      %     IN:
      %       - `tracker` (EyeTracker)
      %       - `duration` (double) -- Number specifying the minimum
      %         fixation duration to the target, in seconds.
      
      obj.targets{end+1} = Target( tracker, obj.vertices, duration );
    end
    
    function update_targets(obj)
      
      %   UPDATE_TARGETS -- Update cumulative fixations 
      
      cellfun( @(x) x.update(), obj.targets );
    end
    
    function reset_targets(obj)
      
      %   RESET_TARGETS -- Reset cumulative fixation duration to 0 for each
      %     target.
      
      cellfun( @(x) x.reset(), obj.targets );
    end
    
    function tf = duration_met(obj)
      
      %   DURATION_MET -- Return whether, for each target, the cumulative
      %     fixation to that target has met the given threshold.
      %
      %     OUT:
      %       - `tf` (logical) -- 1xN vector where N is the number of
      %         fixation targets in the object.
      
      tf = cellfun( @(x) x.duration_met(), obj.targets );
    end
    
    %{
        DRAW
    %}
    
    function blink(obj, rate)
      
      %   BLINK -- Set the stimulus to blink at a given rate.
      %
      %     IN:
      %       - `rate` (double) -- Number specifying the interval between
      %         draw-calls, in seconds.
      
      obj.should_blink = true;
      obj.blink_rate = rate;      
    end
    
    function stop_blink(obj)
      
      %   STOP_BLINK -- Stop the stimulus from blinking.
      
      obj.should_blink = false;
    end
    
    function blink_check(obj)
      
      %   BLINK_CHECK -- Update whether the object should be displayed.
      
      if ( ~obj.should_blink )
        obj.should_show = true;
        return;
      end
      if ( isnan(obj.last_frame_timer) )
        obj.should_show = true;
        obj.last_frame_timer = tic;
      else
        delta = toc( obj.last_frame_timer );
        if ( delta >= obj.blink_rate )
          obj.should_show = ~obj.should_show;
          obj.last_frame_timer = tic;
        end
      end
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
    
    function assert__file_exists(obj, file, file_kind)
      
      %   ASSERT__FILE_EXISTS -- Ensure a file exists.
      %
      %     IN:
      %       - `file` (char) -- Path to the file.
      %       - `file_kind` (char) |OPTIONAL| -- Optionally provide a more
      %         descriptive name for the file in case the assertion fails.
      
      if ( nargin < 3 ), file_kind = 'file'; end;
      assert( exist(file, 'file') == 2, 'The %s ''%s'' does not exist.' ...
        , file_kind, file );
    end
  end
end