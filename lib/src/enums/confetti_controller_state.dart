/// {@template confetti_controller_state}
/// Represents the lifecycle state of a [ConfettiController].
///
/// - [playing]: emission is active.
/// - [stopped]: emission has stopped, but visible particles can keep animating.
/// - [stoppedAndCleared]: emission has stopped and visible particles are
///   cleared immediately.
/// - [disposed]: the controller has been disposed and should not be reused.
/// {@endtemplate}
enum ConfettiControllerState {
  playing,
  stopped,
  stoppedAndCleared,
  disposed,
}
