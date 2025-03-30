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
  
  // Create from Firestore document
  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      emailVerified: data['emailVerified'] ?? false,
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }
  
  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'emailVerified': emailVerified,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
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