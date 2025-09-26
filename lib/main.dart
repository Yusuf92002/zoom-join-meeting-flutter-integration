import 'package:flutter/material.dart';
import 'package:zoom_demo_app/zoom_join_screen.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zoom Meeting Join',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2D8CFF)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const ZoomJoinScreen(),
    );
  }
}