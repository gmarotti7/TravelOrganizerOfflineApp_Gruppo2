import 'package:flutter/material.dart';
// Importiamo la pagina start appena creata nella cartella views
import 'package:travel_app_02/views/start.dart'; 

class AppRoutes {
  // Stringhe costanti identificative per le pagine
  static const String start = '/';
  // static const String login = '/login';       // Sblocco futuro
  // static const String register = '/register'; // Sblocco futuro
  // static const String home = '/home';         // Sblocco futuro

  // Mappa delle rotte dell'applicazione
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      start: (context) => const TravelStartPage(),
      // login: (context) => const TravelLoginPage(),
      // register: (context) => const TravelRegisterPage(),
      // home: (context) => const TravelHomePage(),
    };
  }
}