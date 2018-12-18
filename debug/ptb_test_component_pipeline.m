rectangle = Rectangle( 0, [0, 0, 400, 400], [100, 100] );

bounds = ptb.bounds.MatchOldRectangle( rectangle );

source = ptb.MouseSource();

sampler = ptb.samplers.Missing( source );
sampler.AllowMissing = true;
sampler.MaxMissingDuration = 0.1;

target = ptb.XYTarget( sampler, bounds );
target.Duration = 1;

pipeline = ptb.Pipeline();

add_components( pipeline, source, sampler, target );

while ( true )
  
  update( pipeline );
  
  if ( target.IsDurationMet || ptb.util.is_esc_down() )
    break
  end
  
end

fprintf( '\n Done' );