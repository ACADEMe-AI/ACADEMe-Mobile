import '../../../domain/models/profile.dart';
import 'app_l10n.dart';

String? syllabusLabelForProfile(AppLocalizations l10n, Profile profile) {
  final level = profile.classLevel;
  if (level == null) return null;
  final board = profile.board;
  return board == null
      ? l10n.meClassOnly(level)
      : l10n.meClassBoard(level, board.code);
}
