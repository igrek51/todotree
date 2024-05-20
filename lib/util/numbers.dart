extension IntExtension on int {
  int? nonNegative() {
    if (this < 0) return null;
    return this;
  }

  int clampMin(int lowerLimit) {
    if (this < lowerLimit) return lowerLimit;
    return this;
  }

  int clampMax(int upperLimit) {
    if (this > upperLimit) return upperLimit;
    return this;
  }
}

extension DoubleExtension on double {
  double clampMin(double lowerLimit) {
    if (this < lowerLimit) return lowerLimit;
    return this;
  }

  double clampMax(double upperLimit) {
    if (this > upperLimit) return upperLimit;
    return this;
  }
}
