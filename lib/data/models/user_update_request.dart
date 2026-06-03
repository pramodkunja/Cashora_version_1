/// Partial-update payload for PATCH /users/update/{userId}.
///
/// Only non-null fields are included in the serialized body so the backend
/// never receives accidental null overwrites for fields the caller didn't
/// intend to change. `email` is intentionally omitted — the backend does not
/// allow email changes through this endpoint.
class UserUpdateRequest {
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? role;
  final bool? isActive;
  final int? departmentId;

  const UserUpdateRequest({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.role,
    this.isActive,
    this.departmentId,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (firstName != null) map['first_name'] = firstName;
    if (lastName != null) map['last_name'] = lastName;
    if (phoneNumber != null) map['phone_number'] = phoneNumber;
    if (role != null) map['role'] = role;
    if (isActive != null) map['is_active'] = isActive;
    if (departmentId != null) map['department_id'] = departmentId;
    return map;
  }
}
