extension IntExtension on int {
  int? nonNegative() {
    if (this < 0) return null;
    return this;
  }
}