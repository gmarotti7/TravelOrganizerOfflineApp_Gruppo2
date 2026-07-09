import 'package:flutter/material.dart';
import 'BottomBar.dart';

class RecapCost extends StatelessWidget {
  const RecapCost({Key? key}) : super(key: key);

  Widget _buildRecapItem(String label, String placeholderValue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Text(
              placeholderValue,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber, 

      // --- NUOVA BARRA SUPERIORE (Senza "Riepilogo Spesa") ---
      appBar: AppBar(
        backgroundColor: Colors.amber,
        elevation: 0, 
        
        // 1. FRECCIA INDIETRO A SINISTRA
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
          onPressed: () {
            // Logica per tornare indietro
          },
        ),
        
        // 2. TITOLO AL CENTRO
        centerTitle: true,
        title: const Text(
          'RIEPILOGO',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 24,
          ),
        ),
        
        // 3. MENU AD HAMBURGER A DESTRA
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black, size: 30),
            onPressed: () {
              // Logica per il menu laterale
            },
          ),
        ],
      ),

      // --- CORPO CENTRALE DELLA PAGINA ---
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // La riga con la freccia e il menu è stata spostata nell'AppBar!
              // Iniziamo direttamente con i dati:

              _buildRecapItem('TITOLO', 'Cena ristorante'),
              _buildRecapItem('IMPORTO', '50.00 EUR'),
              _buildRecapItem('CATEGORIA', 'Cibo e Bevande'),
              _buildRecapItem('STATO', 'Pagata'),
              _buildRecapItem('DATA', '09/07/2026'),
              _buildRecapItem('VIAGGIO ASSOCIATO', 'Vacanza a Roma'),
              _buildRecapItem('ATTIVITÀ ASSOCIATA', 'Tour serale'),
              _buildRecapItem('METODO DI PAGAMENTO', 'Carta di credito'),
              
              const SizedBox(height: 10),
              const Text(
                'NOTE:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Diviso il conto in due. Ottimo servizio, da consigliare.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 40), 
            ],
          ),
        ),
      ),

      // --- BARRA DI NAVIGAZIONE INFERIORE INDIPENDENTE ---
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}