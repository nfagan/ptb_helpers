function ptb_test_component_pipeline()

ptb.util.try_add_ptoolbox();

rectangle = Rectangle( 0, [0, 0, 400, 400], [100, 100] );
rect = ptb.rects.MatchOldRectangle( rectangle );

bounds = ptb.bounds.Rect( rect );

source = ptb.MouseSource();

sampler = ptb.samplers.Pass( source );

target = ptb.XYTarget( sampler, bounds );
target.Duration = 1;

updater = ptb.ComponentUpdater();

add_components( updater, source, sampler, target );

stp = 0;
N = 1e4;
ts = nan( N, 1 );

while ( stp <= N )
  
  update( updater );
  
  if ( target.IsDurationMet || ptb.util.is_esc_down() )
    break
  end
  
  if ( stp == 0 )
    t = tic();
  else
    ts(stp) = toc( t );
    t = tic();
  end
  
  stp = stp + 1;
  
end

fprintf( '\n Done: %0.3f ms', nanmean(ts)*1e3 );

end