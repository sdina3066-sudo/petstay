import 'package:flutter/foundation.dart';

import '../data/models/pet.dart';
import '../data/repositories/pet_stay_repository.dart';

/// CRUD profil hewan dalam memori untuk sesi aplikasi.
class PetProvider extends ChangeNotifier {
  PetProvider(PetStayRepository repository)
    : _pets = repository.getPets().toList();

  final List<Pet> _pets;

  List<Pet> get pets => List.unmodifiable(_pets);

  String? addPet(Pet pet) {
    try {
      if (_pets.any((Pet item) => item.id == pet.id)) {
        return 'Data hewan dengan identitas tersebut sudah ada.';
      }
      _pets.add(pet);
      notifyListeners();
      return null;
    } catch (error) {
      return 'Hewan gagal ditambahkan. Silakan coba lagi.';
    }
  }

  String? updatePet(Pet pet) {
    try {
      final int index = _pets.indexWhere((Pet item) => item.id == pet.id);
      if (index < 0) return 'Data hewan tidak ditemukan.';
      _pets[index] = pet;
      notifyListeners();
      return null;
    } catch (error) {
      return 'Data hewan gagal diperbarui. Silakan coba lagi.';
    }
  }

  String? deletePet(String id) {
    try {
      final int count = _pets.length;
      _pets.removeWhere((Pet pet) => pet.id == id);
      if (_pets.length == count) return 'Data hewan tidak ditemukan.';
      notifyListeners();
      return null;
    } catch (error) {
      return 'Hewan gagal dihapus. Silakan coba lagi.';
    }
  }

  Pet? findById(String id) {
    for (final Pet pet in _pets) {
      if (pet.id == id) return pet;
    }
    return null;
  }
}
