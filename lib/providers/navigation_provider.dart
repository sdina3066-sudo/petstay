import 'package:flutter/foundation.dart';

/// Menjaga tab utama tetap terpilih saat halaman dibangun ulang.
class NavigationProvider extends ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void selectTab(int index) {
    if (index < 0 || index > 3 || index == _selectedIndex) return;
    _selectedIndex = index;
    notifyListeners();
  }
}
