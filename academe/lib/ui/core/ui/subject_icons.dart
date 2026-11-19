import 'package:flutter/material.dart';

abstract final class SubjectIcons {
  static IconData of(String subject) => switch (subject) {
    'maths' => Icons.calculate_rounded,
    'science' || 'chemistry' => Icons.science_rounded,
    'social-science' || 'geography' => Icons.public_rounded,
    'english' => Icons.menu_book_rounded,
    'hindi' => Icons.translate_rounded,
    'sanskrit' => Icons.history_edu_rounded,
    'computer' => Icons.computer_rounded,
    'physics' => Icons.bolt_rounded,
    'biology' => Icons.eco_rounded,
    'computer-science' => Icons.terminal_rounded,
    'physical-education' => Icons.sports_soccer_rounded,
    'psychology' => Icons.psychology_rounded,
    'economics' => Icons.trending_up_rounded,
    'accountancy' => Icons.receipt_long_rounded,
    'business-studies' => Icons.business_center_rounded,
    'commerce' => Icons.storefront_rounded,
    'history' || 'history-civics' => Icons.museum_rounded,
    'political-science' => Icons.gavel_rounded,
    _ => Icons.auto_stories_rounded,
  };

  static IconData stream(String stream) => switch (stream) {
    'pcm' => Icons.bolt_rounded,
    'pcb' => Icons.eco_rounded,
    'commerce' => Icons.receipt_long_rounded,
    _ => Icons.museum_rounded,
  };
}
