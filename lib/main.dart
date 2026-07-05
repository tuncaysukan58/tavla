import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const ProviderScope(child: TavlaApp()));
}

class TavlaApp extends StatelessWidget {
  const TavlaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tavla (Backgammon)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown, brightness: Brightness.light),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const GameScreen(),
    );
  }
}
