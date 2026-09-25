import '../../domain/models/account.dart';
import '../../domain/models/app_language.dart';
import '../../domain/models/board.dart';
import '../../domain/models/chat.dart';
import '../../domain/models/profile.dart';
import '../../domain/models/subject.dart';

class ApiException implements Exception {
  const ApiException(this.code, {this.statusCode, this.details = const {}});

  static const network = 'network';
  static const invalidResponse = 'invalid_response';

  final String code;
  final int? statusCode;
  final Map<String, Object?> details;

  @override
  String toString() => 'ApiException($code, $statusCode)';
}

class ApiTokens {
  const ApiTokens({required this.accessToken, required this.refreshToken});

  factory ApiTokens.fromJson(Map<String, Object?> json) => ApiTokens(
    accessToken: json['accessToken']! as String,
    refreshToken: json['refreshToken']! as String,
  );

  final String accessToken;
  final String refreshToken;
}

class ApiSession {
  const ApiSession({
    required this.account,
    required this.tokens,
    required this.isNew,
  });

  factory ApiSession.fromJson(Map<String, Object?> json) => ApiSession(
    account: accountFromJson(json['account']! as Map<String, Object?>),
    tokens: ApiTokens.fromJson(json['tokens']! as Map<String, Object?>),
    isNew: json['created'] as bool? ?? false,
  );

  final Account account;
  final ApiTokens tokens;
  final bool isNew;
}

Account accountFromJson(Map<String, Object?> json) => Account(
  id: json['id']! as String,
  firstName: json['firstName']! as String,
  lastName: json['lastName']! as String,
  email: json['email']! as String,
  hasPassword: json['hasPassword'] as bool? ?? true,
  googleEmail: json['googleEmail'] as String?,
);

Map<String, Object?> accountToJson(Account account) => {
  'id': account.id,
  'firstName': account.firstName,
  'lastName': account.lastName,
  'email': account.email,
  'hasPassword': account.hasPassword,
  'googleEmail': ?account.googleEmail,
};

Profile profileFromJson(Map<String, Object?> json) => Profile(
  language: AppLanguage.fromCode(json['language'] as String?),
  birthYear: json['birthYear'] as int?,
  classLevel: json['class'] as int?,
  board: Board.fromCode(json['board'] as String?),
  setupDone: json['setupDone']! as bool,
  xp: json['xp']! as int,
);

Map<String, Object?> profileUpdateToJson(ProfileUpdate update) => {
  if (update.language case final language?) 'language': language.code,
  'birthYear': ?update.birthYear,
  'class': ?update.classLevel,
  if (update.board case final board?) 'board': board.code,
};

Subject subjectFromJson(Map<String, Object?> json) =>
    Subject(id: json['id']! as String, name: json['name']! as String);

ChatThread chatThreadFromJson(Map<String, Object?> json) => ChatThread(
  id: json['id']! as String,
  mode: ChatMode.fromCode(json['mode']! as String),
  title: json['title']! as String,
  updatedAt: DateTime.parse(json['updatedAt']! as String),
);

ChatMessage chatMessageFromJson(Map<String, Object?> json) => ChatMessage(
  id: json['id']! as int,
  role: json['role'] == 'pebby' ? ChatRole.pebby : ChatRole.student,
  body: json['body']! as String,
  rating: json['rating'] as int? ?? 0,
);
