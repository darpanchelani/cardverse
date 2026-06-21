import 'package:cardverse/features/auth/controllers/auth_controller.dart';
import 'package:cardverse/features/customization/models/cosmetic_item_model.dart';
import 'package:cardverse/features/customization/services/themes_api_service.dart';
import 'package:flutter/material.dart';

class CustomizationController extends ChangeNotifier {
  CustomizationController({
    required ThemesApiService service,
    required AuthController auth,
  }) : _service = service,
       _auth = auth;

  final ThemesApiService _service;
  final AuthController _auth;

  Map<String, List<CosmeticItemModel>> catalog = {};
  bool isLoading = false;
  String? errorMessage;

  String get cardTheme => _auth.user?.equippedCardTheme ?? 'classic';
  String get tableTheme => _auth.user?.equippedTableTheme ?? 'green_felt';
  String get avatarFrame => _auth.user?.avatarFrame ?? 'default';

  Future<void> loadThemes() async {
    if (!_auth.isAuthenticated) {
      catalog = _guestCatalog;
      notifyListeners();
      return;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      catalog = await _service.load();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> purchase(CosmeticItemModel item) async {
    try {
      _auth.replaceUser(await _service.purchase(item.type, item.id));
      await loadThemes();
      return true;
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> equip(CosmeticItemModel item) async {
    try {
      _auth.replaceUser(await _service.equip(item.type, item.id));
      await loadThemes();
      return true;
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }

  List<Color> get tableGradient {
    switch (tableTheme) {
      case 'royal_table':
        return const [Color(0xFF102B20), Color(0xFF4A3513)];
      case 'night_casino':
        return const [Color(0xFF070A16), Color(0xFF17264A)];
      case 'desert_table':
        return const [Color(0xFF3A281A), Color(0xFF8A622D)];
      default:
        return const [Color(0xFF0B2F25), Color(0xFF0B2B22)];
    }
  }

  Color get tableColor => tableGradient.first;

  static const _guestCatalog = <String, List<CosmeticItemModel>>{
    'cardTheme': [
      CosmeticItemModel(
        id: 'classic',
        name: 'Classic',
        type: 'cardTheme',
        price: 0,
        isUnlocked: true,
        isEquipped: true,
      ),
      CosmeticItemModel(
        id: 'royal_gold',
        name: 'Royal Gold',
        type: 'cardTheme',
        price: 500,
        isUnlocked: false,
        isEquipped: false,
      ),
    ],
    'tableTheme': [
      CosmeticItemModel(
        id: 'green_felt',
        name: 'Green Felt',
        type: 'tableTheme',
        price: 0,
        isUnlocked: true,
        isEquipped: true,
      ),
    ],
    'avatarFrame': [
      CosmeticItemModel(
        id: 'default',
        name: 'Default',
        type: 'avatarFrame',
        price: 0,
        isUnlocked: true,
        isEquipped: true,
      ),
    ],
  };
}
