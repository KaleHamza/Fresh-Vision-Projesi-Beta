import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FruitHelpers {
  // Saklama İpuçları Verisi
  static const Map<String, String> _saklamaIpuclari = {
    'muz': 'Muzları buzdolabına koyma! Kabukları kararır. Oda sıcaklığında asarak sakla.',
    'elma': 'Elmalar etilen gazı yayar, diğerlerini bozar. Ayrı bir poşette sakla.',
    'portakal': 'Sebzelik kısmında, hava alacak şekilde 2 hafta saklayabilirsin.',
    'limon': 'Su dolu bir kavanozda buzdolabına koyarsan 1 ay taze kalır!',
    'çilek': 'Yıkamadan sakla. Sadece yiyeceğin zaman yıka yoksa erirler.',
    'üzüm': 'Yıkamadan, delikli bir kapta buzdolabında sakla.',
    'domates': 'Buzdolabı tadını bozar. Oda sıcaklığında, güneş görmeyen yerde sakla.',
    'biber': 'Kuru bir şekilde sebzelik gözünde sakla.',
    'default': 'Serin, kuru ve güneş görmeyen bir yerde saklamaya özen göster.'
  };

  // İpucu Getirme Fonksiyonu
  static String ipucuGetir(String meyveAdi) {
    String aranan = meyveAdi.toLowerCase();
    if (aranan.contains('muz')) return _saklamaIpuclari['muz']!;
    if (aranan.contains('elma')) return _saklamaIpuclari['elma']!;
    if (aranan.contains('portakal') || aranan.contains('mandalina')) return _saklamaIpuclari['portakal']!;
    if (aranan.contains('limon')) return _saklamaIpuclari['limon']!;
    if (aranan.contains('çilek')) return _saklamaIpuclari['çilek']!;
    if (aranan.contains('üzüm')) return _saklamaIpuclari['üzüm']!;
    if (aranan.contains('domates')) return _saklamaIpuclari['domates']!;
    if (aranan.contains('biber')) return _saklamaIpuclari['biber']!;
    return _saklamaIpuclari['default']!;
  }

  // Kalan Gün Hesaplama
  static int kalanGunHesapla(dynamic timestamp) {
    if (timestamp == null) return 0;
    DateTime sonKullanma = (timestamp as Timestamp).toDate();
    int fark = sonKullanma.difference(DateTime.now()).inDays;
    return fark < 0 ? 0 : fark;
  }

  // Tarih Formatlama
  static String tarihFormatla(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  // İkon Bulucu
  static Widget meyveIkonuBul(String ad, Color renk) {
    ad = ad.toLowerCase();
    IconData ikon = Icons.restaurant;
    if (ad.contains('muz')) ikon = Icons.nightlight_round;
    else if (ad.contains('elma')) ikon = Icons.circle;
    else if (ad.contains('üzüm')) ikon = Icons.bubble_chart;
    else if (ad.contains('çilek')) ikon = Icons.spa;
    else if (ad.contains('portakal') || ad.contains('limon')) ikon = Icons.sunny;
    
    return Icon(ikon, color: renk);
  }
}