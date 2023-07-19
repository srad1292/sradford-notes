import 'package:flutter/material.dart';

import 'app.dart';
import 'utils/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupServiceLocator();

  runApp(SradfordNotesApp());
}






