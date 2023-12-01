/// {@macro core_foundation.stateless}
const stateless = Stateless();

/// {@template core_foundation.stateless}
/// Flags a class which should not contain any state.
///
///
/// Difference between stateless and immutable
/// in that it can contain in exterimely rare cases
/// some state (_isInitialized), but it should not
/// expose any state to other classes.
///
/// In other words it contains only Business Logic to make something.
/// Can be called Functional class.
/// {@endtemplate}
final class Stateless {
  /// {@macro core_foundation.stateless}
  const Stateless();
}

/// {@template core_foundation.state_distributor}
/// Flags a class which contain state,
/// but should not contain any business logic.
/// {@endtemplate}
const stateDistributor = StateDistributor();

/// {@macro core_foundation.state_distributor}
final class StateDistributor {
  /// {@macro core_foundation.state_distributor}
  const StateDistributor();
}

/// {@template core_foundation.heavy_computation}
/// Flags a function which contains heavy computation.
/// For example, loads a huge number of data,
/// or convert it or something different.
/// {@endtemplate}
const heavyComputation = HeavyComputation();

/// {@macro core_foundation.heavy_computation}
final class HeavyComputation {
  /// {@macro core_foundation.heavy_computation}
  const HeavyComputation();
}
