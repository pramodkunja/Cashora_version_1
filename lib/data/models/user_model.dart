class User {
  final String id;
  final String email;
  final String name; // Full Name
  final String firstName;
  final String lastName;
  final String role;
  final String orgName;
  final String orgCode;
  final String phoneNumber;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.firstName = '',
    this.lastName = '',
    required this.role,
    this.orgName = '',
    this.orgCode = '',
    this.phoneNumber = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final org = json['organization'] is Map
        ? json['organization']
        : <String, dynamic>{};

    String fName = json['first_name']?.toString() ?? '';
    String lName = json['last_name']?.toString() ?? '';
    String fullName =
        json['full_name']?.toString() ?? json['name']?.toString() ?? '';

    // If API doesn't send "name" or "full_name", but sends first/last, construct it.
    if ((fullName.isEmpty || fullName == 'Unknown') &&
        (fName.isNotEmpty || lName.isNotEmpty)) {
      fullName = '$fName $lName'.trim();
    }

    // If still empty, default to Unknown
    if (fullName.isEmpty) fullName = 'Unknown';

    // Fallback: If fName/lName empty but fullName exists (e.g. legacy/other payload), split it
    if (fName.isEmpty && fullName != 'Unknown') {
      final parts = fullName.split(' ');
      fName = parts.first;
      if (parts.length > 1) {
        lName = parts.sublist(1).join(' ');
      }
    }

    return User(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: fullName,
      firstName: fName,
      lastName: lName,
      role: json['role']?.toString() ?? 'requestor',
      orgName: org['name']?.toString() ?? json['org_name']?.toString() ?? '',
      orgCode:
          org['org_code']?.toString() ?? json['org_code']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'full_name': name,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'org_name': orgName,
      'org_code': orgCode,
      'phone_number': phoneNumber,
    };
  }
}
