import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // Lấy dữ liệu AppUser từ Firestore
  Future<AppUser?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        return AppUser.fromMap(user.uid, doc.data()!);
      }
      return AppUser(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
        role: 'user',
      );
    } catch (e) {
      return null;
    }
  }

  // Đăng ký tài khoản kèm vai trò (admin hoặc user)
  Future<AppUser> register({
    required String email,
    required String password,
    required String displayName,
    String role = 'user',
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user?.updateDisplayName(displayName);

    final appUser = AppUser(
      uid: credential.user!.uid,
      email: email.trim(),
      displayName: displayName,
      role: role,
    );

    // Lưu vào collection users
    await _firestore.collection('users').doc(credential.user!.uid).set(appUser.toMap());
    return appUser;
  }

  // Đăng nhập
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Đăng xuất
  Future<void> logout() async {
    await _auth.signOut();
  }
}
