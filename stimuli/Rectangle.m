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
      %         width] of the rectangle.
      
      obj = obj@Stimulus( window, wrect );
      obj.len = dims(1);
      obj.width = dims(2);
      obj.vertices = zeros( 1, 4 );
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
    
    function show(obj, func)
      
      %   SHOW -- Display the rectangle as a frame or filled rect.
      %
      %     IN:
      %       - `func` (char) -- Function name to pass to Screen()
      
      should_draw_rect = true;
      if ( obj.should_blink )
        if ( isnan(obj.last_frame_timer) )
          obj.is_blinking = false;
          obj.last_frame_timer = tic;
        else
          delta = toc( obj.last_frame_timer );
          if ( delta >= obj.blink_rate )
            obj.is_blinking = ~obj.is_blinking;
            obj.last_frame_timer = tic;
          end
        end
        should_draw_rect = ~obj.is_blinking;
      end
      if ( should_draw_rect )
        Screen( func, obj.window, obj.color, obj.vertices );
      end
    end
    
    function draw(obj)
      
      %   DRAW -- Draw the rectangle.
      
      obj.show( 'FillRect' );
    end
    
    function draw_frame(obj)
      
      %   DRAW_FRAME -- Draw the rectangle as a frame.
      
      obj.show( 'FrameRect' );
    end
    
  end
  
end