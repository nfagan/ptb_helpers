classdef MatchOldRectangle < ptb.XYBounds
  
  properties (Access = public)
    %   RECTANGLE -- Rectangle object defining the underlying bounds-rect.
    %
    %     Rectangle is a handle to a (non-ptb-prefixed) Rectangle object
    %     from which the initial bounding rect will be drawn. If no X or Y
    %     offset is applied, and Padding is 0 (as is the default), the
    %     `test` function will indicate whether a given (X, Y) coordinate
    %     is exactly in bounds of the Rectangle.
    %
    %     Rectangle can also be set to the empty matrix ([]), in which case
    %     the bounding rect is (somewhat uselessly) a vector of zeros.
    %
    %     See also ptb.bounds.MatchOldRectangle, ptb.XYBounds,
    %       ptb.bounds.MatchOldRectangle.Padding
    Rectangle;
    
    %   PADDING -- Padding to be applied to the bounds-rect.
    %
    %     Padding is a 4-element vector giving the amount of padding to be
    %     applied to the minimum x, minimum y, maximum x, and maximum y 
    %     elements of the bounds-rect, respectively. For example, a 
    %     padding vector of [-50, -60, 50, 60] enlarges the accept-window
    %     in the X-dimension by 100px, and in the Y-dimension by 120px.
    %
    %     Padding can also be set to a scalar value, in which case it 
    %     implicitly expands or contracts the accept-window in both X and Y 
    %     dimensions by that amount of pixels. For example, Padding = 10 
    %     implicitly sets padding to [-5, -5, 5, 5], for a padding of 10px 
    %     in both dimensions.
    %
    %     Similarly, padding can be set as a 2-element vector, in which 
    %     case the X and Y dimensions, respectively, are padded by the 
    %     corresponding number of pixels. For example, Padding = [10, 20]
    %     implicitly sets padding to [-5, -10, 5, 10], for a padding of
    %     10px in the X dimension and 20px in the Y dimension.
    %
    %     See also ptb.bounds.MatchOldRectangle
    Padding;
    
    %   XOFFSET -- Shift bounding-rect in X dimension.
    %
    %     XOffset is a scalar numeric value indicating how much the
    %     bounding rect will be shifted in the X-dimension relative to the
    %     actual bounding rect of the underlying Rectangle object. For
    %     example, XOffset = 20 shifts the bounds 20px to the right of the
    %     underying Rectangle's bounds. Default is 0.
    %
    %     See also ptb.bounds.MatchOldRectangle.XOffset, 
    %       ptb.bounds.MatchOldRectangle.Padding
    XOffset = 0;
    
    %   YOFFSET -- Shift bounding-rect in Y dimension.
    %
    %     YOffset is a scalar numeric value indicating how much the
    %     bounding rect will be shifted in the Y-dimension relative to the
    %     actual bounding rect of the underlying Rectangle object. For
    %     example, YOffset = 20 shifts the bounds 20px downwards relative
    %     to the underying Rectangle's bounds (downwards, because the
    %     Y-axis in Psychtoolbox is inverted).
    %
    %     See also ptb.bounds.MatchOldRectangle.Padding
    YOffset = 0;
  end
  
  methods
    function obj = MatchOldRectangle(r)
      
      %   MATCHOLDRECTANGLE -- Use bounds drawn from Rectangle.
      %
      %     obj = ptb.bounds.MatchOldRectangle( r ); constructs an object
      %     that tests whether an (X, Y) coordinate is in bounds of a
      %     rectangle given by `r`. `r` is a handle to a Rectangle object.
      %
      %     See also Rectangle, ptb.bounds.MatchOldRectangle.Padding
      
      if ( nargin < 1 )
        r = [];
      end
      
      obj = obj@ptb.XYBounds();
      obj.Rectangle = r;
      obj.Padding = zeros( 1, 4 );
    end
    
    function set.Rectangle(obj, v)
      if ( isempty(v) )
        obj.Rectangle = [];
      else
        validateattributes( v, {'Rectangle'}, {'scalar'}, mfilename, 'Rectangle' );
        obj.Rectangle = v;
      end
    end
    
    function set.XOffset(obj, v)
      validateattributes( v, {'numeric'}, {'scalar'}, mfilename, 'XOffset' );
      obj.XOffset = double( v );
    end
    
    function set.YOffset(obj, v)
      validateattributes( v, {'numeric'}, {'scalar'}, mfilename, 'YOffset' );
      obj.YOffset = double( v );
    end
    
    function set.Padding(obj, v)
      
      validateattributes( v, {'numeric'}, {'nonempty', 'nonnan'} ...
        , mfilename, 'Padding' );
      
      nv = numel( v );
      
      if ( nv == 1 )
        obj.Padding = double( [-v/2, -v/2, v/2, v/2] );
      elseif ( nv == 2 )
        x = v(1);
        y = v(2);
        
        obj.Padding = double( [-x/2, -y/2, x/2, y/2] );
      else
        assert( nv == 4 ...
          , 'Padding must be a scalar, 2-element vector, or 4-element vector.' );
        
        obj.Padding = double( v(:)' );
      end
    end
  end
  
  methods (Access = public)
    
    function bounds = get_bounding_rect(obj)
      
      %   GET_BOUNDING_RECT -- Get 4-element bounding rect of the object.
      %
      %     bounds = get_bounding_rect( obj ); returns the 4-element vector
      %     giving the [x0, y0, x1, y1] bounding rect, used to test whether
      %     an (x, y) coordinate is in bounds. This rect incorporates the
      %     XOffset, YOffset, and Padding properties.
      %
      %     See also ptb.bounds.XYBounds, ptb.bounds.MatchOldRectangle
      %
      %     OUT:
      %       - `bounds` (double)
      
      if ( isempty(obj.Rectangle) )
        rect = zeros( 1, 4 );
      else
        rect = obj.Rectangle.vertices;
      end
      
      x1 = rect(1) + obj.XOffset + obj.Padding(1);
      x2 = rect(3) + obj.XOffset + obj.Padding(3);
      
      y1 = rect(2) + obj.YOffset + obj.Padding(2);
      y2 = rect(4) + obj.YOffset + obj.Padding(4);
      
      bounds = [x1, y1, x2, y2];
    end
    
    function tf = test(obj, x, y)
      
      %   TEST -- True if (x, y) position is in bounds.
      %
      %     See also ptb.bounds.MatchOldRectangle.get_bounding_rect,
      %       ptb.XYBounds
      
      rect = get_bounding_rect( obj );
      
      x1 = rect(1);
      x2 = rect(3);
      y1 = rect(2);
      y2 = rect(4);
      
      tf = x >= x1 && x <= x2 && y >= y1 && y <= y2;
    end
  end
  
  
end