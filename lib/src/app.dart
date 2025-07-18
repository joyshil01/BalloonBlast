import 'package:flutter/material.dart';
import 'screen/selectionScreen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PlayerSelectionScreen(),
    );
  }
}
