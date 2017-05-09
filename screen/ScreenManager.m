classdef ScreenManager < handle
  
  properties
    screens = {};
  end
  
  methods
    function obj = ScreenManager()
      %   
    end
    
    function win = open_window(obj, varargin)
      
      %   OPEN_WINDOW -- Open a window on a given screen.
      %
      %     IN:
      %       - `index` (double) -- Index of screen in which to open the
      %         window.
      %     OUT:
      %       - `win` (Window) -- Window object.
      
      if ( nargin == 1 )
        index = 0;
      else
        index = varargin{1};
        varargin = varargin(2:end);
      end
      [windex, wrect] = Screen( 'OpenWindow', index, varargin{:} );
      win = Window( obj, windex, wrect );
      ind = obj.find_screen( index );
      if ( isempty(ind) )
        obj.screens{end+1} = struct( 'index', index, 'windows', {{ win }} );
      else
        obj.screens{ind}.windows{end+1} = win;
      end
    end
    
    function ind = find_screen(obj, index)
      
      %   FIND_SCREEN -- Find the screen associated with a given screen
      %     index.
      %
      %     IN:
      %       - `index` (double) -- Index of screen to find.
      %     OUT:
      %       - `ind` (double) -- Found index of `index` in obj.screens, or
      %         [] if not found.
      
      if ( isempty(obj.screens) ), ind = []; return; end;
      ind = find( cellfun(@(x) x.index == index, obj.screens) );
    end
  end
  
end

