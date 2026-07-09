import 'package:flutter/material.dart';
import class TravelLoginPage {
  
}

void main() {
  runApp(const TravelApp());
}

class TravelApp extends StatelessWidget {
  const TravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Rimosso il const da qui per permettere dinamicità all'interno delle pagine
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travel Organizer',
      home: const TravelLoginPage(),
    );
  }
}

