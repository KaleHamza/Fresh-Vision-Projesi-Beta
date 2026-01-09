import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/api_service.dart';
import '../utils/fruit_helpers.dart';

class TaramaSayfasi extends StatefulWidget {
  const TaramaSayfasi({super.key});

  @override
  State<TaramaSayfasi> createState() => _TaramaSayfasiState();
}

class _TaramaSayfasiState extends State<TaramaSayfasi> {
  String _kullaniciAdi = "Şef"; 
  String _unvan = "Meyve Dedektifi 🕵️‍♂️";
  File? _secilenResim;
  bool _yukleniyor = false;
  Map<String, dynamic>? _sonuc;
  
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  // Animasyon Değişkenleri
  Timer? _zamanlayici;
  int _mesajIndex = 0;
  final List<String> _yuklemeMesajlari = [
    "Vitaminler sayılıyor... 🍊", "Kabuk analizi yapılıyor... 🔍",
    "Yapay zeka düşünüyor... 🤖", "Tazelik kontrolü sürüyor... ⏳"
  ];

  // --- UI Yardımcıları ---
  void _mesajGoster(String mesaj, {bool hata = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mesaj), backgroundColor: hata ? Colors.red : Colors.green),
    );
  }

  void _isimDegistir() {
    TextEditingController isimController = TextEditingController(text: _kullaniciAdi);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Adın Ne Olsun?"),
        content: TextField(controller: isimController),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal")),
          ElevatedButton(
            onPressed: () {
              setState(() { _kullaniciAdi = isimController.text; });
              Navigator.pop(context);
            },
            child: const Text("Kaydet"),
          )
        ],
      ),
    );
  }

  // --- İş Mantığı ---
  Future<void> _resimSec(ImageSource kaynak) async {
    final XFile? foto = await _picker.pickImage(source: kaynak);
    if (foto != null) {
      setState(() { _secilenResim = File(foto.path); _sonuc = null; });
      _analizBaslat(File(foto.path));
    }
  }

  Future<void> _analizBaslat(File resim) async {
    setState(() { _yukleniyor = true; });
    _zamanlayici = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      setState(() { _mesajIndex = (_mesajIndex + 1) % _yuklemeMesajlari.length; });
    });

    try {
      final sonuc = await _apiService.meyveAnalizEt(resim);
      setState(() { _sonuc = sonuc; });
    } catch (e) {
      _mesajGoster(e.toString(), hata: true);
    } finally {
      _zamanlayici?.cancel();
      setState(() { _yukleniyor = false; });
    }
  }

  void _firebaseKaydet() {
    if (_sonuc == null || _sonuc!['success'] == false) return;
    
    String meyveAdi = _sonuc!['fruit'];
    DateTime eklenme = DateTime.now();
    DateTime sonKullanma = eklenme.add(Duration(days: (_sonuc!['days_left'] as num).round()));

    FirebaseFirestore.instance.collection('buzdolabim').add({
      'meyveAdi': meyveAdi,
      'eklenmeTarihi': eklenme,
      'tahminiOmur': _sonuc!['days_left'],
      'sonKullanmaTarihi': sonKullanma,
      'durum': _sonuc!['status'],
      'saglikPuani': _sonuc!['health_score']
    }).then((_) {
      _mesajGoster('$meyveAdi eklendi! 🍎');
      setState(() { _sonuc = null; _secilenResim = null; });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildDailyInfo(),
              const SizedBox(height: 25),
              _buildImageArea(),
              const SizedBox(height: 20),
              _buildButtons(),
              const SizedBox(height: 20),
              if (_yukleniyor) _buildLoading() else if (_sonuc != null) _buildResultCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: _isimDegistir,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Merhaba,", style: TextStyle(color: Colors.grey)),
              Text("$_kullaniciAdi $_unvan", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
            ],
          ),
        ),
        const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.person, color: Colors.white)),
      ],
    );
  }

  Widget _buildDailyInfo() {
    return Container(
      padding: const EdgeInsets.all(15),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF81C784)]),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("💡 Günün Bilgisi", style: TextStyle(color: Colors.white70, fontSize: 12)),
          SizedBox(height: 5),
          Text("Çürük bir elma, sepetteki diğer elmaları da bozar.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildImageArea() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: _secilenResim == null
          ? const Center(child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey))
          : ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.file(_secilenResim!, fit: BoxFit.cover)),
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(onPressed: () => _resimSec(ImageSource.camera), icon: const Icon(Icons.camera_alt), label: const Text("Kamera")),
        const SizedBox(width: 15),
        ElevatedButton.icon(onPressed: () => _resimSec(ImageSource.gallery), icon: const Icon(Icons.photo_library), label: const Text("Galeri")),
      ],
    );
  }

  Widget _buildLoading() {
    return Column(
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 10),
        Text(_yuklemeMesajlari[_mesajIndex]),
      ],
    );
  }

  Widget _buildResultCard() {
    if (_sonuc!['fruit'] == null || _sonuc!['fruit'] == 'Bilinmiyor') {
      return const Card(color: Colors.redAccent, child: Padding(padding: EdgeInsets.all(10), child: Text("Tanımlanamadı", style: TextStyle(color: Colors.white))));
    }
    
    return Column(
      children: [
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(_sonuc!['fruit'], style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                Text(_sonuc!['status'], style: TextStyle(fontSize: 18, color: _sonuc!['status'] == 'TAZE' ? Colors.green : Colors.orange)),
                const Divider(),
                Text("İpucu: ${FruitHelpers.ipucuGetir(_sonuc!['fruit'])}"),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _firebaseKaydet, 
          icon: const Icon(Icons.save), 
          label: const Text("Kaydet"),
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.orange, foregroundColor: Colors.white),
        )
      ],
    );
  }
}