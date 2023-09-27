import 'package:chatapp/app.dart';
import 'package:chatapp/splash_page.dart';
import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    // TODO: Replace credentials with your own
    url: 'https://ulswvpmukekrktlggjqw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVsc3d2cG11a2Vrcmt0bGdnanF3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTUzNTQ2NTksImV4cCI6MjAxMDkzMDY1OX0.auxavradWhk-uK9aq8QmbuKsMMj5MgGE9XQHFxcaEEA',
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
