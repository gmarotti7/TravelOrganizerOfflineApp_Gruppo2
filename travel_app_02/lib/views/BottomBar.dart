import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white, size: 30), 
            onPressed: () {
              // Logica per navigare alla Home
            }
          ),
          IconButton(
            icon: const Icon(Icons.autorenew, color: Colors.white, size: 30), 
            onPressed: () {
              // Logica per aggiornare
            }
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white, size: 30), 
            onPressed: () {
              // Logica per navigare al Profilo
            }
          ),
        ],
      ),
    );
  }
}