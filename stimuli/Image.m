classdef Image < Rectangle
  
  properties
    filename;
    image;
  end
  
  methods
    function obj = Image(window, wrect, dims, image)
      
      %   IMAGE -- Instantiate an Image object stimulus.
      %
      %     IN:
      %       - `window` (number) -- Window index.
      %       - `wrect` (double) -- 4-element vector specifying the window
      %         dimensions.
      %       - `dims` (double) -- 2-element vector specifying [length,
      %         width] of the image.
      %       - `filename` (char) -- Full path to the image-file.
      
      obj = obj@Rectangle( window, wrect, dims );
      obj.image = image;
    end
    
    %{
        DISPLAY IMAGE
    %}
    
    function draw(obj)
      
      %   DRAW -- Display the image.
      
      texture = Screen( 'MakeTexture', obj.window, obj.image );
      Screen( 'DrawTexture', obj.window, texture, [], obj.vertices );
    end
  end
    
  methods (Static = true)

    function ar = get_aspect(filename)

      %   GET_ASPECT -- Get the aspect ratio from an image file.
      %
      %     IN:
      %       - `filename` (char) -- Path to the image file.
      
      img = imread( filename );
      ar = size( img, 1 ) / size( img, 2 );
    end
  end
  
end