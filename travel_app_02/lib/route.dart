import 'package:flutter/material.dart';
// Importiamo la pagina start appena creata nella cartella views
import 'package:travel_app_02/views/start.dart'; 
import 'package:travel_app_02/views/login.dart';   // Sbloccato import login
import 'package:travel_app_02/views/sign_up.dart'; // Sbloccato import registrazione

class AppRoutes {
  static const String start = '/';
  static const String login = '/login';      // Sbloccato
  static const String register = '/register'; // Sbloccato

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      start: (context) => const Start(),
      login: (context) => const Login(),                 // Sbloccato e collegato alla classe Login
      register: (context) => const SignUp(), // Sbloccato e collegato alla classe TravelRegisterPage
    };
  }
}