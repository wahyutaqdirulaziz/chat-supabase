import 'package:chatapp/app.dart';
import 'package:chatapp/splash_page.dart';
import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    // TODO: Replace credentials with your own
    url: 'https://yqhibptmxxhzkeprqcfa.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlxaGlicHRteHhoemtlcHJxY2ZhIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTUyMDI4ODMsImV4cCI6MjAxMDc3ODg4M30.cyomKHqp1WKGfgL3w2XkV0nFEZjb36bQ7tRnh5ECTVg',
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
