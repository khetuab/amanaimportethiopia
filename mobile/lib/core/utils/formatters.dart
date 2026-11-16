import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _etbFull = NumberFormat.currency(
    locale: 'en_ET',
    symbol: 'ETB ',
    decimalDigits: 0,
  );
  static final _etbCompact = NumberFormat.compactCurrency(
    locale: 'en',
    symbol: 'ETB ',
    decimalDigits: 1,
  );
  static final _dateShort = DateFormat('d MMM yyyy', 'en');
  static final _dateTime = DateFormat('d MMM yyyy · HH:mm', 'en');

  static String etb(num? value, {bool compact = false}) {
    if (value == null) return '—';
    return compact ? _etbCompact.format(value) : _etbFull.format(value);
  }

  static String date(DateTime? d) =>
      d == null ? '—' : _dateShort.format(d.toLocal());

  static String dateTime(DateTime? d) =>
      d == null ? '—' : _dateTime.format(d.toLocal());

  static String relative(DateTime? d) {
    if (d == null) return '—';
    final diff = DateTime.now().difference(d.toLocal());
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return _dateShort.format(d.toLocal());
  }

  static String humanize(String? s) {
    if (s == null || s.isEmpty) return '—';
    return s
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
