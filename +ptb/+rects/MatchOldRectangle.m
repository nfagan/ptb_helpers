classdef MatchOldRectangle < ptb.RectPrimitive
  
  properties (Access = public)
    %   RECTANGLE -- Rectangle object defining the underlying bounds-rect.
    %
    %     Rectangle is a handle to a (non-ptb-prefixed) Rectangle object
    %     from which the base rect will be drawn.
    %
    %     Rectangle can also be set to the empty matrix ([]), in which case
    %     the base rect is a vector of NaN.
    %
    %     See also ptb.rects.MatchOldRectangle, ptb.XYBounds
    Rectangle;
  end
  
  methods
    function obj = MatchOldRectangle(r)
      
      %   MATCHOLDRECTANGLE -- Use rect drawn from Rectangle.
      %
      %     obj = ptb.rects.MatchOldRectangle( r ); constructs an object
      %     whose get() method returns the bounding rect of `r`, a
      %     Rectangle object.
      %
      %     See also Rectangle, ptb.rects.MatchOldRectangle.get
      
      if ( nargin < 1 )
        r = [];
      end
      
      obj = obj@ptb.RectPrimitive();
      
      obj.Rectangle = r;
    end
    
    function obj = set.Rectangle(obj, v)
      if ( isempty(v) )
        obj.Rectangle = [];
      else
        validateattributes( v, {'Rectangle'}, {'scalar'}, mfilename, 'Rectangle' );
        obj.Rectangle = v;
      end
    end
  end
  
  methods (Access = public)
    function r = get(obj)
      
      %   GET -- Get rect.
      %
      %     get( obj ) returns the bounding rect of the underlying
      %     Rectangle object in `obj`, if the Rectangle property is
      %     non-empty. Otherwise, the bounding rect is a 4-element vector
      %     of NaN.
      %
      %     See also ptb.rects.MatchOldRectangle, Rectangle
      
      if ( isempty(obj.Rectangle) )
        r = nan( 1, 4 );
      else
        r = obj.Rectangle.vertices;
      end
    end
  end
end