import 'package:academe/domain/models/app_language.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('hello puts the local greeting before the name', () {
    expect(AppLanguage.english.hello('Ada'), 'Hi, Ada!');
    expect(AppLanguage.hindi.hello('Ada'), 'नमस्ते, Ada!');
    expect(AppLanguage.telugu.hello('Ada'), 'నమస్తే, Ada!');
    expect(AppLanguage.assamese.hello('Ada'), 'নমস্কাৰ, Ada!');
  });

  test('materialLocale falls back to English', () {
    expect(AppLanguage.hindi.locale, const Locale('hi'));
    expect(AppLanguage.materialLocale(null), const Locale('en'));
    expect(AppLanguage.materialLocale(AppLanguage.tamil), const Locale('ta'));
    expect(AppLanguage.materialLocale(AppLanguage.assamese), const Locale('as'));
  });

  test('fromCode resolves Assamese', () {
    expect(AppLanguage.fromCode('as'), AppLanguage.assamese);
    expect(AppLanguage.assamese.code, 'as');
  });
}
