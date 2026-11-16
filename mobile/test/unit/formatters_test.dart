import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/formatters.dart';

void main() {
  test('etb formats non-null numbers', () {
    expect(Formatters.etb(1000), contains('1,000'));
  });

  test('etb handles null', () {
    expect(Formatters.etb(null), '—');
  });

  test('humanize replaces underscores', () {
    expect(Formatters.humanize('awaiting_payment'), 'Awaiting Payment');
  });

  test('relative returns valid bucket', () {
    final now = DateTime.now().subtract(const Duration(minutes: 5));
    expect(Formatters.relative(now), '5m ago');
  });
}
