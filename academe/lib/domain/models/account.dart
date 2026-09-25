class Account {
  const Account({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;

  Account copyWith({String? firstName, String? lastName}) {
    return Account(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email,
    );
  }
}
