import 'package:flutter/material.dart';
import 'package:genfive/src/features/home/home.dart';

class GenFiveApp extends StatelessWidget {
  const GenFiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}
