class User {
  final String id;
  final String name;
  final String email;
  final String unitNumber;
  final String phone;
  final String role; // resident, admin, staff, etc.
  final String? profileImageUrl;
  final Map<String, dynamic>? additionalInfo;
  final DateTime? joinDate;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.unitNumber,
    required this.phone,
    required this.role,
    this.profileImageUrl,
    this.additionalInfo,
    this.joinDate,
  });

  // Create a User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      unitNumber: json['unitNumber'],
      phone: json['phone'],
      role: json['role'],
      profileImageUrl: json['profileImageUrl'],
      additionalInfo: json['additionalInfo'],
      joinDate: json['joinDate'] != null 
          ? DateTime.parse(json['joinDate'])
          : null,
    );
  }

  // Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'unitNumber': unitNumber,
      'phone': phone,
      'role': role,
      'profileImageUrl': profileImageUrl,
      'additionalInfo': additionalInfo,
      'joinDate': joinDate?.toIso8601String(),
    };
  }

  // Create a copy of the User with some updated fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? unitNumber,
    String? phone,
    String? role,
    String? profileImageUrl,
    Map<String, dynamic>? additionalInfo,
    DateTime? joinDate,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      unitNumber: unitNumber ?? this.unitNumber,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      joinDate: joinDate ?? this.joinDate,
    );
  }
}
