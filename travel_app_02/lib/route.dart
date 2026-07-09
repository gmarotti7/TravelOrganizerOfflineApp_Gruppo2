// lib/route.dart
import 'package:flutter/material.dart';
import 'package:travel_app_02/views/start.dart'; 
import 'package:travel_app_02/views/login.dart';   
import 'package:travel_app_02/views/sign_up.dart'; 
import 'package:travel_app_02/views/home_page.dart'; // 1. AGGIUNTO IMPORT HOME
import 'package:travel_app_02/views/BottomBar.dart';

class AppRoutes {
  static const String start = '/';
  static const String login = '/login';      
  static const String register = '/register'; 
  static const String home = '/home'; // 2. AGGIUNTA COSTANTE HOME

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      start: (context) => const Start(),
      login: (context) => const Login(),                 
      register: (context) => const SignUp(), 
      home: (context) => const HomePage(), // 3. MAPPATA LA HOME PAGE
    };
  }
}