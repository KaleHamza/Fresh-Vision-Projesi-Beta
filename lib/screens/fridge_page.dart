import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/fruit_helpers.dart';

class BuzdolabiSayfasi extends StatelessWidget {
  const BuzdolabiSayfasi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Buzdolabım")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('buzdolabim')
            .orderBy('sonKullanmaTarihi')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Hata oluştu"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          final veriler = snapshot.data!.docs;
          if (veriler.isEmpty) return const Center(child: Text("Buzdolabın boş!"));

          // Gruplama
          Map<String, List<DocumentSnapshot>> gruplar = {};
          for (var belge in veriler) {
            String ad = (belge.data() as Map<String, dynamic>)['meyveAdi'] ?? "Bilinmiyor";
            if (!gruplar.containsKey(ad)) gruplar[ad] = [];
            gruplar[ad]!.add(belge);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: gruplar.keys.length,
            itemBuilder: (context, index) {
              String ad = gruplar.keys.elementAt(index);
              List<DocumentSnapshot> liste = gruplar[ad]!;
              
              // En riskli ürünün durumuna göre renk
              var enAcilVeri = liste.first.data() as Map<String, dynamic>;
              int enDusukGun = FruitHelpers.kalanGunHesapla(enAcilVeri['sonKullanmaTarihi']);
              Color renk = enDusukGun < 3 ? Colors.red : Colors.green;

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ExpansionTile(
                  leading: CircleAvatar(backgroundColor: renk.withOpacity(0.1), child: FruitHelpers.meyveIkonuBul(ad, renk)),
                  title: Text(ad, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${liste.length} Adet - En yakını $enDusukGun gün kaldı", style: TextStyle(color: renk)),
                  children: liste.map((belge) => _buildListItem(context, belge)).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot belge) {
    var data = belge.data() as Map<String, dynamic>;
    int kalan = FruitHelpers.kalanGunHesapla(data['sonKullanmaTarihi']);
    DateTime eklenme = (data['eklenmeTarihi'] as Timestamp).toDate();

    return ListTile(
      title: Text("Kalan: $kalan Gün", style: TextStyle(color: kalan < 3 ? Colors.red : Colors.black, fontWeight: FontWeight.bold)),
      subtitle: Text("Eklenme: ${FruitHelpers.tarihFormatla(eklenme)}"),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => belge.reference.delete()),
          IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.green), 
            onPressed: () {
              belge.reference.delete();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Afiyet olsun!")));
            }
          ),
        ],
      ),
    );
  }
}