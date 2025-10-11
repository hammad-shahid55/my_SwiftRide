import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Simple Tests', () {
    test('basic test should pass', () {
      expect(1 + 1, equals(2));
    });

    test('string test should pass', () {
      expect('hello', equals('hello'));
    });

    test('list test should pass', () {
      expect([1, 2, 3], hasLength(3));
    });
  });
}
