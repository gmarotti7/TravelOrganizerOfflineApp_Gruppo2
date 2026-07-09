import 'package:flutter/material.dart';
import 'package:travel_app_02/route.dart';
import 'package:travel_app_02/views/BottomBar.dart';
import 'package:travel_app_02/views/CurrencyConverter.dart';
import 'package:travel_app_02/views/NewCost.dart';
import 'package:travel_app_02/views/ProfilePage.dart';
import 'package:travel_app_02/views/RecapCost.dart';
import 'package:travel_app_02/views/StatsPage.dart';
import 'package:travel_app_02/views/start.dart'; // <-- AGGIUNTO QUESTO IMPORT

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
      home: CurrencyConverter(),
    );
  }
}