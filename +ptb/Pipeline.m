classdef Pipeline < handle
  
  properties (Access = private)
    sources = {};
    samplers = {};
    targets = {};
  end
  
  methods
    function obj = Pipeline()
    end
  end
  
  methods (Access = public)
    function add_component(obj, component)
      
      if ( isa(component, 'ptb.XYSource') )
        if ( ~any(cellfun(@(x) x == component, obj.sources)) )
          obj.sources{end+1} = component;
        end
        return
      end
      
      if ( isa(component, 'ptb.XYSampler') )
        if ( ~any(cellfun(@(x) x == component, obj.samplers)) )
          obj.samplers{end+1} = component;
        end
        return
      end
      
      if ( isa(component, 'ptb.XYTarget') )
        if ( ~any(cellfun(@(x) x == component, obj.targets)) )
          obj.targets{end+1} = component;
        end
        return
      end
      
      error( 'Unrecognized component type "%s".', class(component) );
    end
    
    function update(obj)
      update_component_set( obj, obj.sources );
      update_component_set( obj, obj.samplers );
      update_component_set( obj, obj.targets );
    end
    
    function update_component_set(obj, component_set)
      N = numel( component_set );
      
      for i = 1:N
        update( component_set{i} );
      end
    end
  end
  

end