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
import 'package:travel_app_02/views/Add_check.dart';
import 'package:travel_app_02/views/RecapChecklist.dart';
import 'package:travel_app_02/views/RecapPacklist.dart';
import 'package:travel_app_02/views/EditTripField.dart';
import 'package:travel_app_02/views/start.dart'; 
import 'package:travel_app_02/views/login.dart';   
import 'package:travel_app_02/views/sign_up.dart'; 
import 'package:travel_app_02/models/trip.dart';
import 'package:travel_app_02/controllers/rec_trip_controller.dart';
import 'package:travel_app_02/views/RecapTrip.dart';

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
  static const String newStay = '/new_stay';
  static const String recapStay = '/recap_stay';
  static const String addCheck = '/add_check';
  static const String recapChecklist = '/recap_checklist';
  static const String recapPacklist = '/recap_packlist';
  static const String editTripField = '/edit_trip_field';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      start: (context) => const Start(),
      login: (context) => const Login(),
      register: (context) => const SignUp(),
      home: (context) => const HomePage(),
      currencyConverter: (context) => const CurrencyConverter(),
      profile: (context) => const ProfilePage(),
      addTrip: (context) => const AddTrip(),
      statsPage: (context) => const StatsPage(),
      newCost: (context) => const NewCost(),
      recapCost: (context) => const RecapCost(),
      newStay: (context) => const NewStay(),
      recapStay: (context) => const RecapStay(),
      addCheck: (context) => const AddCheck(),
      recapChecklist: (context) => const RecapChecklist(),
      recapPacklist: (context) => const RecapPacklist(),
      editTripField: (context) => const EditTripField(),
      riepilogoViaggio: (context) {
        final viaggioInArrivo = ModalRoute.of(context)!.settings.arguments as Trip;
        return RecapTrip(
          controller: RecTripController(trip: viaggioInArrivo),
        );
      },
    };
  }
}