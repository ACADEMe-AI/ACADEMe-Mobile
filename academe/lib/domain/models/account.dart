class Account {
  const Account({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.hasPassword = true,
    this.googleEmail,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final bool hasPassword;
  final String? googleEmail;

  bool get hasGoogle => googleEmail != null;

  Account copyWith({String? firstName, String? lastName}) {
    return Account(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email,
      hasPassword: hasPassword,
      googleEmail: googleEmail,
    );
  }
}
