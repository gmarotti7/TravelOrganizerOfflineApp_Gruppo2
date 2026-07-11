// lib/route.dart
import 'package:flutter/material.dart';
import 'package:travel_app_02/views/Add_trip.dart';
import 'package:travel_app_02/views/CurrencyConverter.dart';
import 'package:travel_app_02/views/Home_page.dart';
import 'package:travel_app_02/views/NewCost.dart';
import 'package:travel_app_02/views/ProfilePage.dart';
import 'package:travel_app_02/views/RecapCost.dart';
import 'package:travel_app_02/views/RecapTrip.dart';
import 'package:travel_app_02/views/StatsPage.dart';
import 'package:travel_app_02/views/NewStay.dart';
import 'package:travel_app_02/views/RecapStay.dart';
import 'package:travel_app_02/views/start.dart'; 
import 'package:travel_app_02/views/login.dart';   // Sbloccato import login
import 'package:travel_app_02/views/sign_up.dart'; // Sbloccato import registrazione


class AppRoutes {
  static const String start = '/';
  static const String login = '/login';      // Sbloccato
  static const String register = '/register'; // Sbloccato
  static const String home = '/home';
  static const String currencyConverter = '/currency_converter';
  static const String profile = '/profile';
  static const String riepilogoViaggio = '/riepilogo_viaggio';
  static const String addTrip = '/add_trip';
  static const String statsPage = '/stats';
  static const String newCost = '/new_cost';
  static const String recapCost = '/recap_cost';
  static const String recapStay = '/recap_stay';
  static const String newStay = '/new_stay';  




  static Map<String, WidgetBuilder> getRoutes() {
    return {
      start: (context) => const Start(),
      login: (context) => const Login(), 
      register: (context) => const SignUp(),
      home: (context) => const HomePage(),
      currencyConverter: (context) => const CurrencyConverter(),
      profile: (context) => const ProfilePage(),
      riepilogoViaggio: (context) => RecapTrip(),
      addTrip: (context) => const AddTrip(),
      statsPage: (context) => const StatsPage(),
      newCost: (context) => const NewCost(),
      recapCost: (context) => const RecapCost(),
      recapStay: (context) => const RecapStay(),
      newStay: (context) => const NewStay(),

    };
  }
}