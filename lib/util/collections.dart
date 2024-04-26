import 'package:todotree/util/numbers.dart';

class Pair<T, U> {
  final T first;
  final U second;

  Pair(this.first, this.second);

  @override
  String toString() {
    return 'Pair($first, $second)';
  }
}

extension ListExtension<T> on List<T> {
  List<T> dropLast(int num) {
    final end = (length - num).clampMin(0);
    return sublist(0, end);
  }

  List<T> dropFirst(int num) {
    final start = num.clampMax(length);
    return sublist(start);
  }
}

extension ListNullableExtension<T> on List<T?> {
  List<T> filterNotNull() {
    return where((e) => e != null).map((e) => e as T).toList();
  }
}
