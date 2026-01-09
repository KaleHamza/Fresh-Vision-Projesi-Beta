import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class TakvimSayfasi extends StatefulWidget {
  const TakvimSayfasi({super.key});

  @override
  State<TakvimSayfasi> createState() => _TakvimSayfasiState();
}

class _TakvimSayfasiState extends State<TakvimSayfasi> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meyve Günlüğü")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('buzdolabim').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) return const Center(child: CircularProgressIndicator());

          // Verileri takvim formatına çevir
          Map<DateTime, List<dynamic>> etkinlikler = {};
          for (var doc in snapshot.data!.docs) {
            var data = doc.data() as Map<String, dynamic>;
            DateTime t = (data['eklenmeTarihi'] as Timestamp).toDate();
            DateTime key = DateTime.utc(t.year, t.month, t.day);
            if (etkinlikler[key] == null) etkinlikler[key] = [];
            etkinlikler[key]!.add(data);
          }

          List<dynamic> seciliListe = [];
          if (_selectedDay != null) {
            seciliListe = etkinlikler[DateTime.utc(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] ?? [];
          }

          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (sel, foc) => setState(() { _selectedDay = sel; _focusedDay = foc; }),
                eventLoader: (day) => etkinlikler[DateTime.utc(day.year, day.month, day.day)] ?? [],
                calendarStyle: const CalendarStyle(todayDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle), selectedDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: seciliListe.length,
                  itemBuilder: (context, index) {
                    var item = seciliListe[index];
                    return ListTile(
                      leading: const Icon(Icons.check, color: Colors.green),
                      title: Text(item['meyveAdi']),
                      trailing: Text("${item['tahminiOmur']} gün ömür"),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}