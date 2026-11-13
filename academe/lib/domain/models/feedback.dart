enum FeedbackCategory {
  wrongAnswer('wrong_answer', 'Report a wrong answer'),
  bug('bug', 'Something isn’t working'),
  feature('feature', 'Suggest a feature');

  const FeedbackCategory(this.code, this.label);

  final String code;
  final String label;
}
