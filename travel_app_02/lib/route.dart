// lib/route.dart
import 'package:flutter/material.dart';
import 'package:travel_app_02/views/Add_trip.dart';
import 'package:travel_app_02/views/CurrencyConverter.dart';
import 'package:travel_app_02/views/Home_page.dart';
import 'package:travel_app_02/views/NewCost.dart';
import 'package:travel_app_02/views/ProfilePage.dart';
import 'package:travel_app_02/views/RecapCost.dart';
import 'package:travel_app_02/views/StatsPage.dart';
import 'package:travel_app_02/views/start.dart'; 
import 'package:travel_app_02/views/login.dart';   
import 'package:travel_app_02/views/sign_up.dart'; 
import 'package:travel_app_02/models/viaggio.dart';
import 'package:travel_app_02/controllers/riepilogo_viaggio_controller.dart';
import 'package:travel_app_02/views/riepilogo_viaggio.dart';
import 'package:travel_app_02/views/Add_check.dart';

class AppRoutes {
  static const String start = '/';
  static const String login = '/login';      
  static const String register = '/register'; 
  static const String home = '/home';
  static const String currencyConverter = '/currency_converter';
  static const String profile = '/profile';
  static const String riepilogoViaggio = '/riepilogo_viaggio';
  static const String addTrip = '/add_trip';
  static const String statsPage = '/stats';
  static const String newCost = '/new_cost';
  static const String recapCost = '/recap_cost';
  static const String addCheck = '/add_check'; // Aggiunta costante per la checklist

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      start: (context) => const Start(),
      login: (context) => const Login(),                 
      register: (context) => const SignUp(), 
      home: (context) => const HomePage(),
      currencyConverter: (context) => const CurrencyConverter(),
      profile: (context) => const ProfilePage(),
      addTrip: (context) => const AddTrip(), // Mantenuto solo uno (eliminato il duplicato)
      riepilogoViaggio: (context) {
        final viaggioInArrivo = ModalRoute.of(context)!.settings.arguments as Viaggio;
        return RiepilogoViaggio(
          controller: RiepilogoViaggioController(trip: viaggioInArrivo),
        );
      },
      statsPage: (context) => const StatsPage(),
      newCost: (context) => const NewCost(),
      recapCost: (context) => const RecapCost(),
      addCheck: (context) => const AddCheck(), // Collegato il widget della checklist
    };
  }
}