classdef Window < handle
  
  properties
    screen;    
    index;
    rect;
    center;
    items;
  end
  
  methods
    function obj = Window(screen, index, rect)
      
      %   WINDOW -- Instantiate a Window object.
      %
      %     IN:
      %       - `screen` (ScreenManager) -- ScreenManager instance.
      %       - `index` (double) -- Id of opened window.
      %       - `rect` (double) -- 4-element vector specifying the window
      %         dimensions, or [] to use the full screen.
      
      obj.screen = screen;
      obj.index = index;
      obj.rect = rect;
      obj.center = round( [mean(rect([1 3])), mean(rect([2 4]))] );
    end
    
    function [rect, id] = Rectangle(obj, dims)
      
      %   RECTANGLE -- Create a rectangle.
      %
      %     IN:
      %       - `dims` (double) -- 2-element vector specifying L x W.
      %     OUT:
      %       - `rect` (Rectangle) -- Created Rectangle object.
      %       - `id` (double) -- Identifier.
      
      rect = Rectangle( obj.index, obj.rect, dims );
      id = obj.add_item( rect );
    end
    
    function [img, id] = Image(obj, dims, img)
      
      %   IMAGE -- Create an image.
      %
      %     IN:
      %       - `dims` (double) -- 2-element vector specifying L x W.
      %       - `img` (double) -- Image matrix as loaded by imread()
      %     OUT
      %       - `img` (Image) -- Created Image object.
      %       - `id` (double) -- Identifier.
      
      img = Image( obj.index, obj.rect, dims, img );
      id = obj.add_item( img );
    end
    
    function id = add_item(obj, object)
      
      %   ADD_ITEM -- Add an item to the window.
      %
      %     IN:
      %       - `object` (Stimulus)
      
      id = obj.create_id();
      kind = class( object );
      obj.items{end+1} = struct( 'class', kind, 'id', id, 'object', object );
    end
    
    function id = create_id(obj)
      
      %   CREATE_ID -- Create a unique identifier.
      %
      %     OUT:
      %       - `id` (double)
      
      id = floor( rand()*10e5 );
      while ( obj.id_exists(id) )
        id = floor( rand()*10e5 );
      end
    end
    
    function tf = id_exists(obj, id)
      
      %   ID_EXISTS -- Return whether a given id is already in use.
      %
      %     IN:
      %       - `id` (double)
      %     OUT:
      %       - `tf` (true, false)
      
      if ( isempty(obj.items) ), tf = false; return; end;
      ids = cellfun( @(x) x.id, obj.items );
      tf = any( ids == id );
    end
  end  
end