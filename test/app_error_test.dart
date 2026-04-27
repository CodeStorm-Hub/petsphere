import 'package:flutter_test/flutter_test.dart';
import 'package:pet_dating_app/utils/app_error.dart';

void main() {
  group('AppError.from', () {
    test('passes through existing AppError values unchanged', () {
      const err = NotFoundError();
      expect(AppError.from(err), same(err));
    });

    test('maps unknown plain exceptions to UnknownError with raw text', () {
      final mapped = AppError.from(StateError('boom'));
      expect(mapped, isA<UnknownError>());
      expect((mapped as UnknownError).raw, contains('boom'));
      expect(mapped.userMessage, isNot(contains('boom')));
    });

    test('NotFoundError has a friendly user message', () {
      expect(const NotFoundError().userMessage, contains('couldn'));
    });

    test('PermissionError has a friendly user message', () {
      expect(const PermissionError().userMessage, contains('permission'));
    });
  });
}
