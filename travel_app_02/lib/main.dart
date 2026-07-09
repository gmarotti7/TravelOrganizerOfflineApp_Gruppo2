import 'package:flutter/material.dart';
import 'package:travel_app_02/route.dart'; // Unico import necessario

void main() {
  runApp(const TravelApp());
}

class TravelApp extends StatelessWidget {
  const TravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travel Organizer',
      
      // Gestione delle schermate delegata a route.dart
      initialRoute: AppRoutes.start, 
      routes: AppRoutes.getRoutes(),
    );
  }
}