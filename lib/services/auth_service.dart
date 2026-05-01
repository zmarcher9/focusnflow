import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Only allow campus email domain
  static const String _campusDomain = 'student.gsu.edu';

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  bool _isCampusEmail(String email) {
    return email.trim().toLowerCase().endsWith('@$_campusDomain');
  }

  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String displayName,
    required String major,
    required List<String> courses,
  }) async {
    if (!_isCampusEmail(email)) {
      throw Exception('Please use your campus email (@$_campusDomain)');
    }

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = UserModel(
      uid: credential.user!.uid,
      email: email,
      displayName: displayName,
      major: major,
      courses: courses,
      campusLocation: '',
      createdAt: DateTime.now(),
    );

    await _db
        .collection('users')
        .doc(credential.user!.uid)
        .set(user.toMap());

    await credential.user!.updateDisplayName(displayName);
    return user;
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final doc = await _db
        .collection('users')
        .doc(credential.user!.uid)
        .get();

    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserModel?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }
}