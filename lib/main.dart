import 'package:chatapp/app.dart';
import 'package:chatapp/splash_page.dart';
import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://drlqfvktfqzefkwlfrfv.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRybHFmdmt0ZnF6ZWZrd2xmcmZ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTYzMTg1ODQsImV4cCI6MjAxMTg5NDU4NH0.40SL6fqjLJuKF8dC8XFTe05lKj3i9F2dBVK40ZrOhYk',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Chat App',
      theme: appTheme,
      home: const SplashPage(),
    );
  }
}
