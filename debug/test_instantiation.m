function test_instantiation()

try
  [windex, wrect] = Screen( 'OpenWindow', 0 );
  
  %   start the tracker
  tracker = EyeTracker( 'test.edf', 'C:\Users\Setup3PictoDell\Desktop', windex );
  success = tracker.init();
  
  if ( ~success ), error( 'Initialization failed' ); end;
  
  %   create an image
  img1 = Image( windex, wrect, [500, 500], '3.png' );
  img1.put( 'center-left' );
  
  %   add a fixation target, for 5 seconds
  target1 = Target( tracker, img1.vertices, 5 );
  img1.add_target( target1 );
  
  %   create another image
  img2 = Image( windex, wrect, [500, 500], '1.png' );
  img2.put( 'center-right' );
  
  %   add another target
  target2 = Target( tracker, img2.vertices, 5 );
  img2.add_target( target2 );
  
  start = tic;

  while ( true )
    tracker.update_coordinates();
    img1.draw();
    img2.draw();
    Screen( 'Flip', windex );
    if ( toc(start) > 100 ), break; end;
    img1.update_targets();
    img2.update_targets();
    if ( img1.duration_met() )
      fprintf( '\n chose image 1' );
      break;
    end
    if ( img2.duration_met() )
      fprintf( '\n chose image 2' );
      break;
    end
    img2.shift( -.1, -.1 );
  end
  sca;
catch err
  sca;
  throw( err );
end

tracker.shutdown();

end