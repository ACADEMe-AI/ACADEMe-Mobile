import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _bundledFamilies = {
  'Baloo2',
  'Archivo',
  'ArchivoWordmark',
  'NotoSans',
  'MaterialIcons',
};

void expectOnlyAppFonts(WidgetTester tester) {
  final strays = <String>[];

  void check(InlineSpan span, String? inherited) {
    final family = span.style?.fontFamily ?? inherited;
    if (span is! TextSpan) return;
    final text = span.text?.trim() ?? '';
    if (text.isNotEmpty && !_bundledFamilies.contains(family)) {
      strays.add('"$text" in ${family ?? 'the platform default'}');
    }
    for (final child in span.children ?? const <InlineSpan>[]) {
      check(child, family);
    }
  }

  for (final paragraph in tester.renderObjectList<RenderParagraph>(
    find.byType(RichText),
  )) {
    check(paragraph.text, null);
  }
  expect(strays, isEmpty, reason: 'text must use the bundled fonts');
}
