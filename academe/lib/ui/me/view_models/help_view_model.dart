import 'package:flutter/material.dart';

import '../../../data/repositories/feedback_repository.dart';
import '../../../domain/models/feedback.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

typedef FeedbackDraft = ({FeedbackCategory category, String message});

class HelpViewModel extends ChangeNotifier {
  HelpViewModel({required FeedbackRepository feedback}) : _feedback = feedback {
    submit = Command1(_submit)..addListener(notifyListeners);
  }

  final FeedbackRepository _feedback;
  late final Command1<void, FeedbackDraft> submit;

  Future<Result<void>> _submit(FeedbackDraft draft) =>
      _feedback.submit(category: draft.category, message: draft.message.trim());

  @override
  void dispose() {
    submit.dispose();
    super.dispose();
  }
}
