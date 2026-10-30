/// Date formatting and relative time helpers
class AppDateUtils {
  static String formatShortDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes <= 1) return 'Just now';
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      return formatShortDate(date);
    }
  }

  static String cadenceLabel(int days) {
    if (days <= 1) return 'Daily';
    if (days == 7) return 'Every week';
    if (days == 14) return 'Every 2 weeks';
    if (days == 30) return 'Monthly';
    if (days == 90) return 'Quarterly';
    return 'Every $days days';
  }
}
