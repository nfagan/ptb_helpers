classdef Rect < ptb.RectPrimitive
  
  properties (Access = public)
    %   X1 -- Minimum X.
    %
    %     X1 is a double scalar giving the minimum X component of the rect.
    %     It must be less than the value of X2, or else be NaN.
    %
    %     See also ptb.Rect, ptb.Rect.X2
    X1 = nan;
    
    %   Y1 -- Minimum Y.
    %
    %     Y1 is a double scalar giving the minimum Y component of the rect.
    %     It must be less than the value of Y2, or else be NaN.
    %
    %     See also ptb.Rect, ptb.Rect.Y2, ptb.Rect.X1
    Y1 = nan;
    
    %   X2 -- Maximum X.
    %
    %     X2 is a double scalar giving the maximum X component of the rect.
    %     It must be greater than the value of X1, or else be NaN.
    %
    %     See also ptb.Rect, ptb.Rect.X1, ptb.Rect.Y1
    X2 = nan;
    
    %   Y2 -- Maximum Y.
    %
    %     Y2 is a double scalar giving the maximum Y component of the rect.
    %     It must be greater than the value of Y1, or else be NaN.
    %
    %     See also ptb.Rect, ptb.Rect.X1, ptb.Rect.Y1
    Y2 = nan;
  end
  
  properties (GetAccess = public, SetAccess = private)
    %   ISNONNEGATIVE -- True if Rect components cannot be negative.
    %
    %     IsNonNegative is a read-only logical scalar indicating whether
    %     the components of the Rect object must be non-negative. If true,
    %     attempting to assign a negative value to X1, X2, Y1, or Y2 will
    %     throw an error.
    %
    %     See also ptb.Rect, ptb.Rect.Configured, ptb.Rect.NonNegative, 
    %       ptb.Rect.IsInteger
    IsNonNegative = false;
    
    %   ISINTEGER -- True if Rect components must be integer-valued.
    %
    %     IsInteger is a read-only logical scalar indicating whether the
    %     components of the Rect object must be integer-valued. If true,
    %     attempting to assign a floating point value to X1, X2, Y1, or Y2
    %     will throw an error. The only exception is that NaN values are
    %     permitted and treated as integer-valued, unless IsNonNan is also
    %     true.
    %
    %     See also ptb.Rect, ptb.Rect.Configured, ptb.Rect.IsNonNan
    IsInteger = false;
    
    %   ISNONNAN -- True if Rect components cannot be NaN.
    %
    %     IsNonNan is a read-only logical scalar indicating whether the
    %     components of the Rect object must be non-nan. If true,
    %     attempting to assign a NaN value to X1, X2, Y1, or Y2 will throw
    %     an error.
    %
    %     In this case, X1 and Y1 default to 0, and X2 and Y2 default to 1.
    %
    %     See also ptb.Rect, ptb.Rect.Configured, ptb.Rect.IsInteger, 
    %       ptb.Rect.IsNonNegative
    IsNonNan = false;
  end
  
  properties (Access = private)
    is_setting_all = false;
  end
  
  methods
    function obj = Rect(r)
      
      %   RECT -- Create Rect.
      %
      %     r = ptb.Rect(); returns an object that represents a bounding
      %     rect, with minimum x, minimum y, maximum x, and maximum y
      %     components. These components are mapped to properties named 
      %     X1, Y1, X2, and Y2, respectively.
      %
      %     Use the `get` method to return a 4-element vector suitable for
      %     use with Screen() functions; use the `set` method to set the
      %     contents from a standard vector.
      %
      %     By default, components can be negative, floating point, and /
      %     or NaN. To restrict component attributes -- e.g., to disallow
      %     NaN or negative components -- see the ptb.Rect.Configured 
      %     method.
      %
      %     See also ptb.Rect.set, ptb.Rect.X1, ptb.Rect.get, 
      %       ptb.Rect.Configured, ptb.Rect.IsNonNegative, 
      %       ptb.Rect.NonNegative
      
      if ( nargin > 0 )
        try
          obj = set( obj, r );
        catch err
          throw( err );
        end
      end
    end
    
    function obj = set.X1(obj, v)
      try
        obj.X1 = validate_component( obj, v, 'X1', 'X2', true );
      catch err
        throw( err );
      end
    end
    
    function obj = set.X2(obj, v)
      try
        obj.X2 = validate_component( obj, v, 'X2', 'X1', false );
      catch err
        throw( err );
      end
    end
    
    function obj = set.Y1(obj, v)
      try
        obj.Y1 = validate_component( obj, v, 'Y1', 'Y2', true );
      catch err
        throw( err );
      end
    end
    
    function obj = set.Y2(obj, v)
      try
        obj.Y2 = validate_component( obj, v, 'Y2', 'Y1', false );
      catch err
        throw( err );
      end
    end
  end
  
  methods (Access = public)
    
    function tf = eq(obj, B)
      
      %   EQ -- True if operands are equal-valued ptb.Rect objects.
      %
      %     tf = eq( A, B ); returns true if `A` and `B` are both ptb.Rect
      %     objects with equivalent contents.
      %
      %     See also ptb.Rect, ptb.Rect.set
      
      cls = 'ptb.Rect';
      tf = false;
      
      if ( ~isa(obj, cls) || ~isa(B, cls) )
        return
      end
      
      tf = isequaln( obj.X1, B.X1 ) && isequaln( obj.X2, B.X2 ) && ...
        isequaln( obj.Y1, B.Y1 ) && isequaln( obj.Y2, B.Y2 );      
    end
    
    function tf = ne(obj, B)
      
      %   EQ -- True if operands are not equal-valued ptb.Rect objects.
      %
      %     tf = ne( A, B ); returns true if `A` and `B` are not both
      %     ptb.Rect objects, or if they are ptb.Rect objects with
      %     non-equivalent contents.
      %
      %     See also ptb.Rect, ptb.Rect.set
      
      tf = ~eq( obj, B );
    end
    
    function [tf, reason] = is_settable_from(obj, r)
      
      %   IS_SETTABLE_FROM -- True if A's contents can be set from B.
      %
      %     tf = is_settable_from( A, B ) returns true if `A` and
      %     `B` are both ptb.Rect objects, and if `A`'s contents can be set
      %     to those of `B`.
      %
      %     [..., reason] = is_settable_from(...) also returns `reason`,
      %     a char vector indicating the reason why `A` and `B` were
      %     considered inconsistent, or else an empty string ('') if `A`'s
      %     contents can be set to those of `B`.
      %
      %     (In)Consistency is defined as follows:
      %
      %       - If A and B have the same property values for IsNonNegative,
      %         IsNonNan, and IsInteger, then they are consistent.
      %       - If A is non-negative, and some components of B are
      %         negative, then they are inconsistent.
      %       - If A is integer-valued, and some components of B are
      %         floating point, then they are inconsistent.
      %       - If A is non-NaN, and some components of B are NaN, then
      %         they are inconsistent.
      %       - Otherwise, they are consistent.
      %
      %     See also ptb.Rect, ptb.Rect.IsNonNegative, ptb.Rect.IsInteger,
      %       ptb.Rect.IsNonNan
      
      cls = 'ptb.Rect';
      tf = false;
      reason = '';
      
      if ( ~isa(obj, cls) || ~isa(r, cls) )
        reason = 'Classes of A and B do not match.';
        return
      end 
      
      if ( obj.IsNonNegative ~= r.IsNonNegative )
        if ( obj.IsNonNegative && any(get(r) < 0) )
          reason = 'Rect A is non-negative, but Rect B has negative elements.';
          return
        end
      end
      
      if ( obj.IsInteger ~= r.IsInteger )
        if ( obj.IsInteger && ~ptb.Rect.all_is_integer(get(r)) )
          reason = 'Rect A is integer-valued, but Rect B has non-integer elements.';
          return
        end
      end
      
      if ( obj.IsNonNan ~= r.IsNonNan )
        if ( obj.IsNonNan && any(isnan(get(r))) )
          reason = 'Rect A is non-NaN, but Rect B has NaN elements.';
          return
        end
      end
      
      tf = true;
    end
    
    function r = get(obj)
      
      %   GET -- Obtain contents in vector form.
      %
      %     get( obj ) returns the contents of `obj` as a 4-element vector:
      %     [ X1, Y1, X2, Y2 ].
      %
      %     See also ptb.Rect, ptb.Rect.set
      
      r = [ obj.X1, obj.Y1, obj.X2, obj.Y2 ];
    end
    
    function obj = set_extents(obj, x, y)
      
      %   SET_EXTENTS -- Set X and Y extents, simultaneously.
      %
      %     See also ptb.Rect, ptb.Rect.set_x_extent
      %
      %     IN:
      %       - `x` (double)
      %       - `y` (double)
      
      try
        obj = set_x_extent( obj, x );
        obj = set_y_extent( obj, y );
      catch err
        throw( err );
      end
    end
    
    function obj = set_x_extent(obj, extent, varargin)
      
      %   SET_X_EXTENT -- Set maximum X to extend from minimum X.
      %
      %     set_x_extent( obj, extent ) sets the X1 and X2 properties such
      %     that X2 - X1 == extent. `extent` must be a positive scalar; if
      %     X1 is NaN, it is set to 0.
      %
      %     set_x_extent( ..., X1_fallback ) sets X1 to `X1_fallback` in
      %     the event that X1 is NaN, instead of to 0. `X1_fallback` cannot
      %     be NaN.
      %
      %     See also ptb.Rect, ptb.Rect.set_y_extent, ptb.Rect.set_extents
      
      try
        obj = set_extent( obj, extent, 'X1', 'X2', varargin{:} );
      catch err
        throw( err );
      end
    end
    
    function obj = set_y_extent(obj, extent, varargin)
      
      %   SET_Y_EXTENT -- Set maximum Y to extend from minimum Y.
      %
      %     set_y_extent( obj, extent ) sets the Y1 and Y2 properties such
      %     that Y2 - Y1 == extent. `extent` must be a positive scalar; if
      %     X1 is NaN, it is set to 0.
      %
      %     set_y_extent( ..., Y1_fallback ) sets Y1 to `Y1_fallback` in
      %     the event that Y1 is NaN, instead of to 0. `Y1_fallback` cannot
      %     be NaN.
      %
      %     See also ptb.Rect, ptb.Rect.set_x_extent, ptb.Rect.set_extents
      
      try
        obj = set_extent( obj, extent, 'Y1', 'Y2', varargin{:} );
      catch err
        throw( err );
      end
    end
    
    function obj = set(obj, rect)
      
      %   SET -- Set Rect contents.
      %
      %     set( obj, rect ) where `rect` is a 4-element vector, sets the
      %     X1, Y1, X2, and Y2 properties from the corresponding elements
      %     of `rect`.
      %
      %     set( obj, rect ) where `rect` is another ptb.Rect object, sets
      %     the contents to match those of `rect`. An error is thrown if
      %     `rect` is inconsistent with `obj`.
      %
      %     See also ptb.Rect, ptb.Rect.get, ptb.Rect.is_settable_from
      
      if ( isa(rect, 'ptb.Rect') && isa(obj, 'ptb.Rect') )
        try
          obj = set_from_rect_object( obj, rect );
        catch err
          throw( err );
        end
        return
      end
      
      if ( isempty(obj) )
        return
      end
      
      classes = { 'numeric' };
      attrs = { 'numel', 4 };
      
      if ( obj.IsNonNegative )
        attrs{end+1} = 'nonnegative';
      end
      
      if ( obj.IsNonNan )
        attrs{end+1} = 'nonnan';
      end

      try
        validateattributes( rect, classes, attrs, mfilename, 'rect' );
      catch err
        throw( err );
      end
      
      if ( obj.IsInteger && ~ptb.Rect.all_is_integer(rect) )
        error( 'Expected all rect elements to be integer-valued.' );
      end

      if ( rect(3) <= rect(1) )
        error( 'X1 must be greater than X2.' );
      end

      if ( rect(4) <= rect(2) )
        error( 'Y1 must be greater than Y2.' );
      end
      
      obj.is_setting_all = true;

      rect = double( rect );
      
      obj.X1 = rect(1);
      obj.X2 = rect(3);
      
      obj.Y1 = rect(2);
      obj.Y2 = rect(4);
      
      obj.is_setting_all = false;
    end
  end
  
  methods (Access = private)    
    function obj = initialize_set_non_nan(obj)
      
      if ( obj.IsNonNan )
        obj.X1 = 0;
        obj.Y1 = 0;
        obj.X2 = 1;
        obj.Y2 = 1;
      end
    end
    
    function obj = set_extent(obj, extent, prop1, prop2, fill_with)
      
      if ( nargin < 5 )
        fill_with = 0;
      else
        validateattributes( fill_with, {'numeric'}, {'scalar', 'nonnan'} ...
          , mfilename, 'fill_with' );
        
        fill_with = double( fill_with );
      end
      
      validateattributes( extent, {'numeric'}, {'scalar', 'positive'} ...
        , mfilename, 'extent' );
      
      if ( isempty(obj) )
        return
      end
      
      if ( isnan(obj.(prop1)) )
        obj.(prop1) = fill_with;
      end
      
      obj.(prop2) = obj.(prop1) + extent;
    end
    
    function obj = set_from_rect_object(obj, r)
      
      if ( isempty(r) )
        return
      end
      
      if ( isempty(obj) )
        obj = r;
        return
      end
      
      [is_consistent, reason] = is_settable_from( obj, r );
      
      if ( ~is_consistent )
        error( reason );
      end
      
      obj = set( obj, get(r) );
    end
    
    function value = validate_component(obj, value, prop, other_prop, is_minimum)
      
      classes = { 'numeric' };
      attrs = { 'scalar' };
      
      if ( obj.IsNonNegative )
        attrs{end+1} = 'nonnegative';
      end
      
      if ( obj.IsNonNan )
        attrs{end+1} = 'nonnan';
      end
      
      validateattributes( value, classes, attrs, mfilename, prop );
      
      if ( obj.IsInteger && ~ptb.Rect.all_is_integer(value) )
        error( 'Expected "%s" to be integer-valued.', prop );
      end
      
      value = double( value );
      
      other_val = obj.(other_prop);
      
      if ( isnan(other_val) )
        return;
      end
      
      %   Do not try to enforce X1 < X2, etc. relationship if we're 
      %   setting all elements.
      if ( obj.is_setting_all )
        return
      end
      
      if ( is_minimum && other_val <= value )
        error( 'The value of "%s" must be less than the value of "%s".' ...
          , prop, other_prop );
      end
      
      if ( ~is_minimum && other_val >= value )
        error( 'The value of "%s" must be greater than the value of "%s".' ...
          , prop, other_prop );
      end
    end
  end
  
  methods (Access = private, Static = true)
    function tf = all_is_integer(r)
      
      %   ALL_IS_INTEGER -- True if all elements of an array are
      %     integer-valued, treating NaN as integer-valued.
      
      non_nans = r( ~isnan(r) );
      tf = all( rem(non_nans, 1) == 0 );
    end
  end
  
  methods (Access = public, Static = true)    
    function rect = Configured(varargin)
      
      %   CONFIGURED -- Get Rect configured with component attributes.
      %
      %     r = ptb.Rect.Configured( 'name1', value1, ... ) configures a 
      %     Rect object via 'name', value paired inputs. This is the only
      %     way to configure an object to e.g. only accept positive
      %     components, as such properties are fixed after the object
      %     is created.
      %
      %     r = ptb.Rect.Configured(), with no inputs, is the same as
      %     ptb.Rect()
      %
      %     EXAMPLE //
      %
      %     % Create a ptb.Rect object whose components cannot be NaN.
      %     r = ptb.Rect.Configured( 'IsNonNan', true );
      %     % Create a ptb.Rect object whose components must be
      %     % non-negative, and integer-valued
      %     r = ptb.Rect.Configured( 'IsNonNegative', true, 'IsInteger', true );
      %
      %     See also ptb.Rect, ptb.Rect.IsNonNan, ptb.Rect.IsNonNegative,
      %       ptb.Rect.IsInteger
      
      logical_scalar_validator = ...
        @(v, prop) validateattributes(v, {'logical'}, {'scalar'}, mfilename, prop);
      
      logical_scalar_props = { 'IsNonNan', 'IsNonNegative', 'IsInteger', 'Empty' };
      
      p = inputParser();
      
      for i = 1:numel(logical_scalar_props)
        prop = logical_scalar_props{i};
        addParameter( p, prop, false, @(x) logical_scalar_validator(x, prop) );
      end
      
      addParameter( p, 'Rect', [] );
      
      parse( p, varargin{:} );
      
      results = p.Results;
      
      rect = ptb.Rect();
      
      rect.IsNonNan = results.IsNonNan;
      rect.IsNonNegative = results.IsNonNegative;
      rect.IsInteger = results.IsInteger;
      
      rect = initialize_set_non_nan( rect );
      
      if ( ~isempty(results.Rect) )
        rect = set( rect, results.Rect );
      end
      
      if ( results.Empty )
        rect(1) = [];
      end
    end
    
    function rect = NonNegative(r)
      
      %   NONNEGATIVE -- Create Rect object whose components are nonnegative.
      %
      %     See also ptb.Rect.IsNonNegative, ptb.Rect, ptb.Rect.Configured,
      %       ptb.Rect.Integer, ptb.Rect.NonnegativeInteger
      
      if ( nargin < 1 )
        r = [];
      end
      
      try
        rect = ptb.Rect.Configured( 'IsNonNegative', true, 'Rect', r );
      catch err
        throw( err );
      end
    end
  end
  
end