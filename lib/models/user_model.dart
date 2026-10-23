class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String role; // 'admin' hoặc 'user'

  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.role = 'user',
  });

  bool get isAdmin => role == 'admin';

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      role: data['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}
