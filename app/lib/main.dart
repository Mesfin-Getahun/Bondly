import 'package:flutter/material.dart';
import 'app.dart';
import 'core/firebase/firebase_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInitializer.initialize();
  runApp(const BondlyApp());
}
