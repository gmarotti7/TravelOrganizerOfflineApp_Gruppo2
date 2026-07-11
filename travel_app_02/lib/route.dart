// lib/route.dart
import 'package:flutter/material.dart';
import 'package:travel_app_02/views/Add_trip.dart';
import 'package:travel_app_02/views/CurrencyConverter.dart';
import 'package:travel_app_02/views/Home_page.dart';
import 'package:travel_app_02/views/NewCost.dart';
import 'package:travel_app_02/views/ProfilePage.dart';
import 'package:travel_app_02/views/RecapCost.dart';
import 'package:travel_app_02/views/StatsPage.dart';
import 'package:travel_app_02/views/NewStay.dart';
import 'package:travel_app_02/views/RecapStay.dart';
import 'package:travel_app_02/views/start.dart'; 
import 'package:travel_app_02/views/login.dart';   // Sbloccato import login
import 'package:travel_app_02/views/sign_up.dart'; // Sbloccato import registrazione
import 'package:travel_app_02/models/trip.dart';
import 'package:travel_app_02/controllers/rec_trip_controller.dart';
import 'package:travel_app_02/views/RecapTrip.dart';

class AppRoutes {
  static const String start = '/';
  static const String login = '/login';      // Sbloccato
  static const String register = '/register'; // Sbloccato
  static const String home = '/home';
  static const String currencyConverter = '/currency_converter';
  static const String profile = '/profile';
  static const String riepilogoViaggio = '/riepilogo_viaggio';
  static const String addTrip = '/add_trip';
  static const String statsPage = '/stats_page';
  static const String recapCost = '/recap_cost';
  static const String newCost = '/new_cost';
  static const String newStage = '/new_stage';
  static const String recapStage = '/recap_stage';



  static Map<String, WidgetBuilder> getRoutes() {
    return {
      start: (context) => const Start(),
      login: (context) => const Login(),                 // Sbloccato e collegato alla classe Login
      register: (context) => const SignUp(), // Sbloccato e collegato alla classe TravelRegisterPage
      home: (context) => const HomePage(),
      currencyConverter: (context) => const CurrencyConverter(),
      profile: (context) => const ProfilePage(),
      addTrip: (context) => const AddTrip(),
      riepilogoViaggio: (context) {
        final viaggioInArrivo = ModalRoute.of(context)!.settings.arguments as Trip;
        return RecapTrip(
          controller: RecTripController(trip: viaggioInArrivo),
        );
      },
      addTrip: (context) => const AddTrip(),
      statsPage: (context) => const StatsPage(),
      recapCost: (context) => const RecapCost(),
      newCost: (context) => const NewCost(),
      newStage: (context) => const NewStay(),
      recapStage: (context) => const RecapStay(),
    };
  }
}