classdef ComponentUpdater < handle
  
  properties (Access = private, Constant = true)
    aggregate_classes = { 'ptb.XYSource', 'ptb.XYSampler', 'ptb.XYTarget' };
    aggregate_property_names = { 'Sources', 'Samplers', 'Targets' };
  end
  
  properties (GetAccess = public, SetAccess = private)
    Sources = {};
    Samplers = {};
    Targets = {};
  end
  
  methods
    function obj = ComponentUpdater()
      
      %   UPDATER -- Create ComponentUpdater object instance.
      %
      %     obj = ptb.ComponentUpdater() creates an ComponentUpdater object 
      %     -- a utility that updates an arbitrary number of source, 
      %     sampler, and target objects, in logical order.
      %
      %     Calling `update` on the object updates all sources, then all
      %     samplers, and finally all targets, avoiding potential coding
      %     errors.
      %
      %     After creating the object, use the `add_component` method to
      %     add a source, sampler, or target object to the corresponding
      %     list of to-be-updated components.
      %
      %     EXAMPLE //
      %
      %       mouse = ptb.MouseSource();
      %       sampler = ptb.samplers.Pass( mouse );
      %       updater = ptb.ComponentUpdater();
      %
      %       add_components( updater, mouse, sampler );
      %
      %       while ~ptb.util.is_esc_down()
      %         update( updater );
      %       end
      %
      %     See also ptb.ComponentUpdater.add_component, 
      %       ptb.ComponentUpdater.Sources
      
    end
  end
  
  methods (Access = public)
    function was_added = add_component(obj, component)
      
      %   ADD_COMPONENT -- Add updateable component.
      %
      %     add_component( obj, component ); adds `component` to the current
      %     list of ptb.XYSources, ptb.XYSamplers, or ptb.XYTargets, 
      %     according to the class of `component`, so long as it has not 
      %     already been added.
      %
      %     was_added = add_component(...) returns whether `component` was
      %     newly added to the corresponding list.
      %
      %     An error is thrown if `component` is not of one of the above
      %     types.
      %
      %     See also ptb.ComponentUpdater, 
      %       ptb.ComponentUpdater.add_components, ptb.XYSource
      %
      %     IN:
      %       - `component` (ptb.XYSource, ptb.XYSampler, ptb.XYTarget)
      %     OUT:
      %       - `was_added` (logical)
            
      classes = obj.aggregate_classes;
      props = obj.aggregate_property_names;
      N = numel( props );
      
      was_added = false;
      
      for i = 1:N
        if ( isa(component, classes{i}) )
          was_added = check_add_component( obj, component, props{i} );
          return
        end
      end
      
      validateattributes( component, obj.aggregate_classes, {} ...
        , mfilename, 'component' );
    end
    
    function was_added = add_components(obj, varargin)
      
      %   ADD_COMPONENTS -- Add arbitrary number of updateable components.
      %
      %     add_components( obj, component1, component2, ... ) adds any
      %     number of updateable components to `obj`. An error is thrown,
      %     and no components added, if any input is an invalid type.
      %
      %     See also ptb.ComponentUpdater.add_component, ptb.ComponentUpdater
      
      for i = 1:numel(varargin)
        validateattributes( varargin{i}, obj.aggregate_classes, {} ...
          , mfilename, 'a "component"', i );
      end
      
      was_added = false( size(varargin) );
      
      for i = 1:numel(varargin)
        was_added(i) = add_component( obj, varargin{i} );
      end
    end
    
    function update(obj)
      
      %   UPDATE -- Update components.
      %
      %     update( obj ) updates each source, sampler, and target in `obj`
      %     in logical order. Sources are updated first, followed by
      %     samplers, followed by targets.
      %
      %     See also ptb.ComponentUpdater
      
      update_component_set( obj, obj.Sources );
      update_component_set( obj, obj.Samplers );
      update_component_set( obj, obj.Targets );
    end
  end
  
  methods (Access = private)
    function was_added = check_add_component(obj, component, aggregate)
      
      %   CHECK_ADD_COMPONENT -- Add component if not already added.
            
      if ( ~any(cellfun(@(x) x == component, obj.(aggregate))) )
        obj.(aggregate){end+1} = component;
        was_added = true;
      else
        was_added = false;
      end
    end
    
    function update_component_set(obj, component_set)
      N = numel( component_set );
      
      for i = 1:N
        update( component_set{i} );
      end
    end
  end
end