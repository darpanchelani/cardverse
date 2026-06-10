abstract final class DateTimeUtils {
  static String formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '${_month(local.month)} ${local.day}, ${local.year} • '
        '$hour:$minute $period';
  }

  static String formatDate(DateTime dateTime) {
    final local = dateTime.toLocal();
    return '${_month(local.month)} ${local.day}, ${local.year}';
  }

  static String _month(int month) {
    return const [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][month - 1];
  }
}
