import 'package:flutter/material.dart';
import 'package:travel_app_02/route.dart'; // <-- AGGIUNTO QUESTO IMPORT

void main() {
  runApp(const TravelApp());
}

class TravelApp extends StatelessWidget {
  const TravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp( // Rimesso const qui perché TravelLoginPage ha un costruttore const
      debugShowCheckedModeBanner: false,
      title: 'Travel Organizer',
      home: TravelLoginPage(),
    );
  }
}

