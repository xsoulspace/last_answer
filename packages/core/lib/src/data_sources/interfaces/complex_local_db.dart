abstract interface class ComplexLocalDb {
  Future<void> open() async {}
  Future<void> close() async {}
}

final class MockComplexLocalDb extends ComplexLocalDb {}
