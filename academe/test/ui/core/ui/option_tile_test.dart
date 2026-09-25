import 'package:academe/ui/core/themes/app_theme.dart';
import 'package:academe/ui/core/ui/option_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a selected option is amber, latched down and announced', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              OptionTile(label: 'Class 9', isSelected: true),
              OptionTile(label: 'Class 10', isSelected: false),
            ],
          ),
        ),
      ),
    );

    AnimatedContainer face(String label) => tester.widget<AnimatedContainer>(
      find.ancestor(
        of: find.text(label),
        matching: find.byType(AnimatedContainer),
      ),
    );
    Color? fill(String label) =>
        (face(label).decoration! as BoxDecoration).color;

    expect(fill('Class 9'), AppColors.selected);
    expect(
      face('Class 9').transform!.getTranslation().y,
      AppKeycap.optionDepth,
    );
    expect(fill('Class 10'), AppColors.lightSurface);
    expect(face('Class 10').transform!.getTranslation().y, 0);
    expect(
      tester.getSemantics(find.text('Class 9')),
      matchesSemantics(
        isSelected: true,
        isButton: true,
        isEnabled: true,
        hasEnabledState: true,
        hasSelectedState: true,
        label: 'Class 9',
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });
}
