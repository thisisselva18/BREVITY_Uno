import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newsai/models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Singleton pattern
  static final UserRepository _instance = UserRepository._internal();
  factory UserRepository() => _instance;
  UserRepository._internal();
  
  // Get user data from Firestore
  Future<UserModel> getUserProfile(String uid) async {
    try {
      final DocumentSnapshot doc = 
          await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists && doc.data() != null) {
        return UserModel.fromFirestore(doc.data() as Map<String, dynamic>);
      } else {
        throw Exception('User profile not found');
      }
    } catch (e) {
      throw Exception('Failed to load user profile: $e');
    }
  }
  
  // Update user profile data
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update({
        'displayName': user.displayName,
        'updatedAt': FieldValue.serverTimestamp(),
        // Add other fields you want to update
      });
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
  
  // Stream user profile for real-time updates
  Stream<UserModel> userProfileStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) {
          if (doc.exists && doc.data() != null) {
            return UserModel.fromFirestore(doc.data()!);
          } else {
            return UserModel.empty();
          }
        });
  }
}
