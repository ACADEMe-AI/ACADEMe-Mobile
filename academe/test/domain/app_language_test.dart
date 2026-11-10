import 'package:academe/domain/models/app_language.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('hello puts the local greeting before the name', () {
    expect(AppLanguage.english.hello('Ada'), 'Hi, Ada!');
    expect(AppLanguage.hindi.hello('Ada'), 'नमस्ते, Ada!');
    expect(AppLanguage.telugu.hello('Ada'), 'నమస్తే, Ada!');
  });
}
