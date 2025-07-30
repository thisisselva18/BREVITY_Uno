class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final bool emailVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.emailVerified = false,
    this.createdAt,
    this.updatedAt,
  });
  
  // Convert to map for sending data to the backend
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'emailVerified': emailVerified,
      'createdAt': createdAt?.toIso8601String(), // Convert DateTime to ISO 8601 string
      'updatedAt': updatedAt?.toIso8601String(), // Convert DateTime to ISO 8601 string
    };
  }
  
  // Create empty user
  factory UserModel.empty() {
    return UserModel(
      uid: '',
      displayName: '',
      email: '',
    );
  }
}
