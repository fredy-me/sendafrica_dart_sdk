import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('package release artifacts are present', () {
    expect(File('LICENSE').existsSync(), isTrue);
    expect(File('README.md').existsSync(), isTrue);
    expect(File('CHANGELOG.md').existsSync(), isTrue);
  });
}
