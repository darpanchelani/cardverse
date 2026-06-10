abstract final class NumberFormatUtils {
  static String compact(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return '$value';
  }

  static String percentage(double value) => '${value.toStringAsFixed(1)}%';
}
