import 'package:flutter/foundation.dart';

enum UserRole { pemilik, penitip }

extension UserRoleLabel on UserRole {
  String get label => switch (this) {
    UserRole.pemilik => 'Pemilik Hewan',
    UserRole.penitip => 'Penitip',
  };
}

/// Menyimpan status sesi dummy dan identitas yang digunakan oleh UI.
class AuthProvider extends ChangeNotifier {
  String _email = '';
  UserRole _role = UserRole.pemilik;
  bool _isLoggedIn = false;

  String get email => _email;
  UserRole get role => _role;
  bool get isLoggedIn => _isLoggedIn;

  String? login({
    required String email,
    required String password,
    required UserRole role,
  }) {
    final String normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty || password.isEmpty) {
      return 'Email dan kata sandi wajib diisi.';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(normalizedEmail)) {
      return 'Masukkan format email yang valid.';
    }
    if (password.length < 6) {
      return 'Kata sandi minimal 6 karakter.';
    }

    _email = normalizedEmail;
    _role = role;
    _isLoggedIn = true;
    notifyListeners();
    return null;
  }

  void logout() {
    _email = '';
    _role = UserRole.pemilik;
    _isLoggedIn = false;
    notifyListeners();
  }
}
