classdef TrapezoidTarget < Target
  
  properties
    window_rect;
    target_rect;
    x_vertices;
    y_vertices;
    side_name;
  end
  
  methods
    function obj = TrapezoidTarget(tracker, window_rect, target_rect, duration, side_name)
      
      obj = obj@Target(tracker, target_rect, duration);
      obj.window_rect = window_rect;
      obj.target_rect = target_rect;
      obj.side_name = side_name;
      
      obj.calculate_vertices();
    end
    
    function calculate_vertices(obj)
      
      trect = obj.target_rect;
      wrect = obj.window_rect;
      sname = obj.side_name;
      
      [xv, yv] = TrapezoidTarget.get_trapezoid_vertices( trect, wrect, sname );
      
      obj.x_vertices = xv;
      obj.y_vertices = yv;
    end
    
    function set.window_rect(obj, val)
      
      assert( isa(val, 'double') && numel(val) == 4 ...
        , 'Invalid value for window rect.' );
      obj.window_rect = val;
    end
    
    function set.target_rect(obj, val)
      
      assert( isa(val, 'double') && numel(val) == 4 ...
        , 'Invalid value for target rect.' );
      obj.target_rect = val;
    end
    
    function set.side_name(obj, val)
      
      assert( ischar(val) && any(strcmpi({'left', 'right'}, val)) ...
        , 'Invalid value for side name.' );
      obj.side_name = val;
    end
    
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
      xv = obj.x_vertices;
      yv = obj.y_vertices;
      within_bounds = inpolygon( x, y, xv, yv );
      if ( within_bounds )
        delta = toc( obj.timer ) - obj.last_frame;
        obj.cumulative = obj.cumulative + delta;
        obj.in_bounds = true;
      else
        obj.cumulative = 0;
        obj.in_bounds = false;
      end
      obj.last_frame = toc( obj.timer );
    end
  end
  
  methods (Static = true)
    function [xs, ys] = get_trapezoid_vertices(targ_rect, screen_rect, side_name)

      %   GET_TRAPEZOID_VERTICES -- Get vertices of a trapezoid whose far-plane 
      %     is the left or right side of the screen, and whose near plane is the
      %     left or right side of a stimulus on the screen.
      %
      %     IN:
      %       - `targ_rect` (double) -- 4-element vector (x1, y1, x2, y2)
      %         specifying the vertices of a target rectangle.
      %       - `screen_rect` (double) -- 4-element vector (x1, y1, x2, y2)
      %         specifying the vertices of the screen rectangle.
      %       - `side_name` (char) -- 'left' or 'right'

      assert( ischar(side_name) );
      assert( numel(targ_rect) == 4 && isa(targ_rect, 'double') );
      assert( numel(screen_rect) == 4 && isa(screen_rect, 'double') );

      side_name = lower( side_name );

      xs = zeros( 1, 4 );
      ys = zeros( 1, 4 );

      %   vertices defined counter-clockwise

      switch ( side_name )
        case 'left'
          xs(1) = screen_rect(1);
          ys(1) = screen_rect(2);

          xs(2) = screen_rect(1);
          ys(2) = screen_rect(4);

          xs(3) = targ_rect(1);
          ys(3) = targ_rect(4);

          xs(4) = targ_rect(1);
          ys(4) = targ_rect(2);
        case 'right'
          xs(1) = targ_rect(3);
          ys(1) = targ_rect(2);

          xs(2) = targ_rect(3);
          ys(2) = targ_rect(4);

          xs(3) = screen_rect(3);
          ys(3) = screen_rect(4);

          xs(4) = screen_rect(3);
          ys(4) = screen_rect(2);
        otherwise
          error( 'Unrecognized side name ''%s''.', side_name );
      end
    end
  end
  
end