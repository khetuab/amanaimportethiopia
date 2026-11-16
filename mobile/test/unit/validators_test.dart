import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/validators.dart';

void main() {
  group('email', () {
    test('rejects empty', () => expect(Validators.email(''), isNotNull));
    test('rejects invalid', () => expect(Validators.email('abc'), isNotNull));
    test('accepts valid', () => expect(Validators.email('a@b.co'), isNull));
  });

  group('ethiopian phone', () {
    test(
      'accepts 09',
      () => expect(Validators.ethiopianPhone('0911223344'), isNull),
    );
    test(
      'accepts +2519',
      () => expect(Validators.ethiopianPhone('+251911223344'), isNull),
    );
    test(
      'rejects others',
      () => expect(Validators.ethiopianPhone('123'), isNotNull),
    );
  });

  group('password', () {
    test('too short', () => expect(Validators.password('a1'), isNotNull));
    test('no digit', () => expect(Validators.password('abcdefgh'), isNotNull));
    test('valid', () => expect(Validators.password('abcd1234'), isNull));
  });

  group('positive number', () {
    test(
      'rejects negative',
      () => expect(Validators.positiveNumber('-5'), isNotNull),
    );
    test(
      'accepts positive',
      () => expect(Validators.positiveNumber('42'), isNull),
    );
  });
}
