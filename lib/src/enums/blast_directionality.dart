/// {@template confetti_blast_direction}
/// Controls whether particles launch in one direction or burst outward from
/// the emitter.
///
/// Use [directional] for cannon-style effects where [ConfettiWidget] or
/// `Confetti.show` provides a `blastDirection` in radians.
///
/// Use [explosive] for radial bursts where particles travel in every direction.
/// {@endtemplate}
enum ConfettiBlastDirection {
  directional,
  explosive,
}

@Deprecated(
  'Use ConfettiBlastDirection instead. '
  'This alias will be removed in a future release.',
)
typedef BlastDirectionality = ConfettiBlastDirection;
