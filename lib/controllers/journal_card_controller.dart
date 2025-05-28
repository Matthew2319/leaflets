import 'package:flutter/material.dart';

class JournalCardController extends ChangeNotifier {
  String? _activeCardId;

  String? get activeCardId => _activeCardId;

  void setActiveCard(String? cardId) {
    if (_activeCardId != cardId) {
      _activeCardId = cardId;
      notifyListeners();
    }
  }

  void clearActiveCard() {
    if (_activeCardId != null) {
      _activeCardId = null;
      notifyListeners();
    }
  }
}

// Global instance to be used across the app
final journalCardController = JournalCardController(); 