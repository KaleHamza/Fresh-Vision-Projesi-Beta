import 'package:flutter/material.dart';
import 'scan_page.dart';
import 'fridge_page.dart';
import 'calendar_page.dart';

class AnaIskelet extends StatefulWidget {
  const AnaIskelet({super.key});

  @override
  State<AnaIskelet> createState() => _AnaIskeletState();
}

class _AnaIskeletState extends State<AnaIskelet> {
  int _seciliIndex = 0;
  
  final List<Widget> _sayfalar = [
    const TaramaSayfasi(),
    const BuzdolabiSayfasi(),
    const TakvimSayfasi(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _seciliIndex,
        children: _sayfalar,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _seciliIndex,
        onDestinationSelected: (idx) => setState(() => _seciliIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: 'Analiz'),
          NavigationDestination(icon: Icon(Icons.kitchen), label: 'Dolabım'),
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Günlük'),
        ],
      ),
    );
  }
}