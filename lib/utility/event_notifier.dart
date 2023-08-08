import 'package:flutter/material.dart';

class EventNotifier with ChangeNotifier {
  void emit() {
    notifyListeners();
  }
}
