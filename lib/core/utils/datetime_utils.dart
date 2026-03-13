/// UTC enforcement policy for LifeOS.
///
/// Rule: Every DateTime written to the database is UTC.
///       Every DateTime read from the database is treated as UTC.
///       Conversion to local time happens ONLY at the presentation layer.
///
/// This prevents timezone-related query bugs across 100k+ records over years.

extension DateTimeUtcExtension on DateTime {
  /// Converts to UTC if not already UTC. Use before every DB write.
  DateTime toUtcSafe() => isUtc ? this : toUtc();

  /// Returns start of day in UTC (00:00:00.000).
  DateTime toStartOfDayUtc() {
    final utc = toUtcSafe();
    return DateTime.utc(utc.year, utc.month, utc.day);
  }

  /// Returns end of day in UTC (23:59:59.999).
  DateTime toEndOfDayUtc() {
    final utc = toUtcSafe();
    return DateTime.utc(utc.year, utc.month, utc.day, 23, 59, 59, 999);
  }

  /// Returns true if this date is the same calendar day as [other] (UTC comparison).
  bool isSameDayAs(DateTime other) {
    final a = toUtcSafe();
    final b = other.toUtcSafe();
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// Generates a UTC timestamp for right now.
/// Use this everywhere instead of DateTime.now() when writing to DB.
DateTime nowUtc() => DateTime.now().toUtc();
