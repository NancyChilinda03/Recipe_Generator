import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import '../screens/profile.dart';


void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SIGN UP',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      routes: {
        '/profile': (context) => const ProfilePage(),
        '/login': (context) => const LoginPage(), // Add your LoginPage here
      },
      home: const LoginPage(),
    );
  }
}




