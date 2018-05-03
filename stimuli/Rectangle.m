classdef Rectangle < Stimulus
  
  properties
    len;
    width;
  end
  
  methods    
    function obj = Rectangle(window, wrect, dims)
      
      %   RECTANGLE -- Instantiate a Rectangle object.
      %
      %     IN:
      %       - `window` (number) -- Window index.
      %       - `wrect` (double) -- 4-element vector specifying the window
      %         dimensions.
      %       - `dims` (double) -- 2-element vector specifying the [length,
      %         width] of the rectangle, or scalar value specifying the
      %         length of the square.
      
      obj = obj@Stimulus( window, wrect );
      if ( numel(dims) == 1 ), dims = [ dims, dims ]; end;
      obj.len = dims(2);
      obj.width = dims(1);
      obj.vertices = [ 0, 0, dims(1), dims(2) ];
    end
    
    %{
        PLACEMENT
    %}
    
    function move(obj, verts)
      
      %   MOVE -- Update the vertices and targets in the object.
      %
      %     IN:
      %       - `VERTS` (double) -- New vertices.
      
      obj.assert__isa( verts, 'double', 'the vertices' );
      current_vertices = obj.vertices;
      offset = verts - current_vertices;
      dx = offset(1);
      dy = offset(2);
      cellfun( @(x) x.shift(dx, dy), obj.targets );
      obj.vertices = verts;
    end
    
    function center_on(obj, x, y)
      
      %   CENTER_ON -- Center the target on a given coordinate.
      %
      %     IN:
      %       - `x` (double)
      %       - `y` (double)
      
      if ( nargin == 2 )
        if ( numel(x) == 1 )
          y = x;
        else
          assert( numel(x) == 2, 'Specify coordinate at 2-element vector.' );
          y = x(2);
          x = x(1);
        end
      end
      y_size = obj.len;
      x_size = obj.width;      
      position = round( [-x_size/2, -y_size/2, x_size/2, y_size/2] );
      position([1, 3]) = position([1, 3]) + x;
      position([2, 4]) = position([2, 4]) + y;
      obj.move( position );
    end
    
    function randomize(obj)
      
      %   RANDOMIZE -- Randomly position the object.
      
      min_x = obj.width/2;
      min_y = obj.len/2;
      max_x = (obj.window_rect(3) - obj.window_rect(1)) - min_x;
      max_y = (obj.window_rect(4) - obj.window_rect(2)) - min_y;
      
      x = (rand() * (max_x - min_x)) + min_x;
      y = (rand() * (max_y - min_y)) + min_y;
      
      obj.center_on( x, y );
    end
    
    function randomize_from_center(obj, eccentricity, center_offset)
      
      %   RANDOMIZE_FROM_CENTER -- Randomly position from center, within
      %     eccentricity.
      %
      %     IN:
      %       - `eccentricity` (double)
      %       - `center_offset` (double) |OPTIONAL|
      
      if ( nargin < 3 ), center_offset = 0; end
      
      center = obj.window_center;
      max_eccentric = center + eccentricity;
      
      x = (rand() * (max_eccentric(1) - center(1)));
      y = (rand() * (max_eccentric(2) - center(2)));
      
      if ( rand() > .5 )
        x = x + center(1) + center_offset;
      else
        x = center(1) - x - center_offset;
      end
      
      if ( rand() > .5 )
        y = y + center(2) + center_offset;
      else
        y = center(2) - y - center_offset;
      end
      
      obj.center_on( x, y );
    end
      
    function scale(obj, by)
      
      %   SCALE -- Increase the vertices by a scaled amount.
      %
      %     IN:
      %       - `by` (double);
      
      if ( numel(by) == 1 )
        by = [ by, by ]; 
      else
        assert( numel(by) == 2, ['Expected the scale factor to have' ... 
          , ' 1 or 2 elements; %d were given'], numel(by) );
      end
      verts = obj.vertices;
      obj.width = obj.width * by(1);
      obj.len = obj.len * by(2);
      x = verts(1) + ((verts(3) - verts(1)) / 2);
      y = verts(2) + ((verts(4) - verts(2)) / 2);
      obj.center_on( [x, y] );
    end
    
    function put(obj, placement)
      
      %   PUT -- Put the object in a given location.
      %
      %     IN:
      %       - `placement` (char) -- Position specifier, e.g.
      %       'center-left', 'center'
      
      obj.assert__isa( placement, 'char', 'the placement' );
      y_size = obj.len;
      x_size = obj.width;      
      center = obj.window_center;
      win_rect = obj.window_rect;
      position = round( [-x_size/2, -y_size/2, x_size/2, y_size/2] );

      switch ( placement )
        case 'center'
          center = [ center, center ];
          bounds = center + position;
        case 'center-left'
          dx = center(1) - center(1)/2;
          dy = center(2);
          bounds = [ dx, dy, dx, dy ] + position;
        case 'center-right'
          dx = center(1) + center(1)/2;
          dy = center(2);
          bounds = [ dx, dy, dx, dy ] + position;
        case 'top-left'
          bounds = [ 0, 0, x_size, y_size ];
        case 'top-right'
          win_width = win_rect(3);
          bounds = [ win_width-x_size, 0, win_width, y_size ];
        otherwise
          error( 'Unrecognized object placement ''%s''', placement );
      end

      obj.placement = placement;
      obj.move( bounds );
    end
    
    function shift(obj, dx, dy)
      
      %   SHIFT -- Displace the object's center by a given x and y amount.
      %
      %     IN:
      %       - `dx` (double)
      %       - `dy` (double)
      
      xs = obj.vertices( [1, 3] );
      ys = obj.vertices( [2, 4] );
      new_vertices = [ xs(1)+dx, ys(1)+dy, xs(2)+dx, ys(2)+dy ];
      obj.move( new_vertices );
    end
    
    %{
        DISPLAY
    %}
    
    function show(obj, func, varargin)
      
      %   SHOW -- Display the rectangle as a frame or filled rect.
      %
      %     IN:
      %       - `func` (char) -- Function name to pass to Screen()
      
      obj.blink_check();
      if ( obj.should_show )
        Screen( func, obj.window, obj.color, obj.vertices, varargin{:} );
      end
    end
    
    function draw(obj)
      
      %   DRAW -- Draw the rectangle.
      
      obj.show( 'FillRect' );
    end
    
    function draw_frame(obj)
      
      %   DRAW_FRAME -- Draw the rectangle as a frame.
      
      obj.show( 'FrameRect', obj.pen_width );
    end
    
  end
  
end