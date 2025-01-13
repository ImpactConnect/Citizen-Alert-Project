class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String? avatarUrl;
  final String role;
  final bool isGuest;

  const UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.avatarUrl,
    this.role = 'user',
    this.isGuest = false,
  });

  factory UserModel.guest() {
    return const UserModel(
      uid: 'guest',
      role: 'guest',
      isGuest: true,
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? avatarUrl,
    String? role,
    bool? isGuest,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isGuest: isGuest ?? this.isGuest,
    );
  }

  String get fullName => displayName ?? 'User';
}
