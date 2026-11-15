import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/pet.dart';
import '../data/models/review.dart';
import '../data/models/sitter.dart';
import '../data/repositories/pet_stay_repository.dart';

/// Mengelola hasil pencarian, filter penitip, dan simulasi koneksi.
class SitterProvider extends ChangeNotifier {
  SitterProvider(this._repository) {
    unawaited(loadSitters());
  }

  final PetStayRepository _repository;
  List<Sitter> _sitters = [];
  bool _isLoading = false;
  bool _isOffline = false;
  String? _errorMessage;
  String _query = '';
  PetType? _petTypeFilter;
  int? _maximumPrice;
  double _minimumRating = 0;
  bool _disposed = false;

  List<Sitter> get sitters => List.unmodifiable(_sitters);
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;
  String? get errorMessage => _errorMessage;
  String get query => _query;
  PetType? get petTypeFilter => _petTypeFilter;
  int? get maximumPrice => _maximumPrice;
  double get minimumRating => _minimumRating;

  List<Sitter> get filteredSitters {
    final String normalizedQuery = _query.trim().toLowerCase();
    return _sitters
        .where((Sitter sitter) {
          final bool matchesQuery =
              normalizedQuery.isEmpty ||
              sitter.name.toLowerCase().contains(normalizedQuery) ||
              sitter.location.toLowerCase().contains(normalizedQuery) ||
              sitter.acceptedPetTypes.any(
                (PetType type) =>
                    type.label.toLowerCase().contains(normalizedQuery),
              );
          final bool matchesType =
              _petTypeFilter == null ||
              sitter.acceptedPetTypes.contains(_petTypeFilter);
          final bool matchesPrice =
              _maximumPrice == null || sitter.pricePerDay <= _maximumPrice!;
          return matchesQuery &&
              matchesType &&
              matchesPrice &&
              sitter.rating >= _minimumRating;
        })
        .toList(growable: false);
  }

  Future<void> loadSitters() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    await Future<void>.delayed(const Duration(seconds: 1));
    if (_disposed) return;
    if (_isOffline) {
      _isLoading = false;
      _errorMessage = 'Koneksi terputus. Periksa simulasi koneksi Anda.';
      notifyListeners();
      return;
    }
    try {
      _sitters = _repository.getSitters().toList();
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Daftar penitip gagal dimuat. Silakan coba lagi.';
      notifyListeners();
    }
  }

  Future<void> retry() => loadSitters();

  Future<void> setOffline(bool value) async {
    if (_isOffline == value) return;
    _isOffline = value;
    notifyListeners();
    if (value) {
      _isLoading = false;
      _errorMessage = 'Koneksi terputus. Periksa simulasi koneksi Anda.';
      notifyListeners();
    } else {
      await loadSitters();
    }
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setPetTypeFilter(PetType? value) {
    _petTypeFilter = value;
    notifyListeners();
  }

  void setMaximumPrice(int? value) {
    _maximumPrice = value;
    notifyListeners();
  }

  void setMinimumRating(double value) {
    _minimumRating = value.clamp(0, 5).toDouble();
    notifyListeners();
  }

  void resetFilter() {
    _petTypeFilter = null;
    _maximumPrice = null;
    _minimumRating = 0;
    notifyListeners();
  }

  Sitter? findById(String id) {
    for (final Sitter sitter in _sitters) {
      if (sitter.id == id) return sitter;
    }
    return null;
  }

  void addReview(Review review) {
    final int index = _sitters.indexWhere(
      (Sitter sitter) => sitter.id == review.sitterId,
    );
    if (index < 0) return;
    final Sitter current = _sitters[index];
    final int reviewCount = current.reviewCount + 1;
    final double rating =
        ((current.rating * current.reviewCount) + review.rating) / reviewCount;
    _sitters[index] = current.copyWith(
      rating: rating,
      reviewCount: reviewCount,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
