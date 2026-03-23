import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class LocalModelService {
  late Interpreter interpreter;
  bool _isModelLoaded = false;

  // Model Sabitleri
  static const int imgSize = 224;
  static const double confidenceThreshold = 0.95; // Yanlış tahminleri önlemek için %95

  // Sınıf Listesi
  static const List<String> meyveler = [
    "apple", "banana", "bitter_gourd", "capsicum", "orange", "tomato"
  ];

  late List<String> siniflar;

  // Raf Ömürleri (gün)
  static const Map<String, int> rafOmurleri = {
    "apple": 30, "banana": 7, "bitter_gourd": 10, "capsicum": 14,
    "orange": 21, "tomato": 10,
  };

  LocalModelService() {
    _initializeSiniflar();
  }

  void _initializeSiniflar() {
    siniflar = [
      // Fresh items
      "Fresh Apple", "Fresh Banana", "Fresh Bitter Gourd", "Fresh Capsicum", "Fresh Orange", "Fresh Tomato",
      // Stale items
      "Stale Apple", "Stale Banana", "Stale Bitter Gourd", "Stale Capsicum", "Stale Orange", "Stale Tomato"
    ];
  }

  /// Modeli yükle
  Future<void> loadModel() async {
    try {
      if (_isModelLoaded) return;

      interpreter = await Interpreter.fromAsset('assets/meyve_modeli.tflite');
      _isModelLoaded = true;
      print("✅ Model başarıyla yüklendi!");
    } catch (e) {
      print("❌ Model yükleme hatası: $e");
      rethrow;
    }
  }

  /// Resmi işle ve tahmin yap
  Future<Map<String, dynamic>> meyveAnalizEt(File resim) async {
    try {
      if (!_isModelLoaded) {
        await loadModel();
      }

      // Resmi oku
      final bytes = await resim.readAsBytes();
      img.Image? decodedImage = img.decodeImage(bytes);

      if (decodedImage == null) {
        return {
          'success': false,
          'message': 'Resim okunamadı',
        };
      }

      // Resmi işle
      final processedImage = _preprocessImage(decodedImage);

      // Tahmin yap
      var output = List<double>.filled(siniflar.length, 0).reshape([1, siniflar.length]);
      interpreter.run(processedImage, output);

      List<double> predictions = output[0];

      // En yüksek tahmi bul
      int predictedIndex = 0;
      double maxConfidence = predictions[0];
      for (int i = 1; i < predictions.length; i++) {
        if (predictions[i] > maxConfidence) {
          maxConfidence = predictions[i];
          predictedIndex = i;
        }
      }
      double confidence = maxConfidence;

      // Güven eşiğini kontrol et
      if (confidence < confidenceThreshold) {
        return {
          'success': false,
          'message': 'Tanımlanamadı (Düşük güven skoru)',
        };
      }

      final label = siniflar[predictedIndex];
      // Örn: "Fresh Apple" → fruit="apple", status="Fresh"
      final parts = label.split(' ');
      final status = parts[0]; // "Fresh" veya "Stale"
      final fruitName = parts.sublist(1).join(' ').toLowerCase(); // "Apple" → "apple"

      // Raf ömrü hesapla
      final (daysLeft, healthScore) = _calculateShelfLife(status, fruitName, confidence);

      return {
        'success': true,
        'fruit': _formatFruitName(fruitName),
        'status': status == 'Fresh' ? 'TAZE' : 'ÇÜRÜK',
        'days_left': daysLeft,
        'health_score': healthScore,
        'confidence': confidence,
        'raw_label': label,
      };
    } catch (e) {
      print("❌ Analiz hatası: $e");
      return {
        'success': false,
        'message': 'Analiz hatası: $e',
      };
    }
  }

  /// Resimi modele uygun şekilde işle (API ile aynı preprocessing)
  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    // Resmi 224x224'e yeniden boyutlandır
    var resized = img.copyResize(image, width: imgSize, height: imgSize);

    // Kontrast ve parlaklığı artır (API'deki rembg etkisini taklit)
    resized = _enhanceContrast(resized);
    
    // Histogram equalization (contrast iyileştirme)
    resized = _equalizeHistogram(resized);

    // RGB normalize et ve tensor şekline dönüştür
    List<List<List<List<double>>>> input = List.generate(
      1,
      (i) => List.generate(
        imgSize,
        (y) => List.generate(
          imgSize,
          (x) {
            final pixel = resized.getPixel(x, y);
            
            // API ile aynı: 0-255 → 0-1 normalizasyonu
            final r = pixel.r.toDouble() / 255.0;
            final g = pixel.g.toDouble() / 255.0;
            final b = pixel.b.toDouble() / 255.0;
            
            return [r, g, b];
          },
        ),
      ),
    );

    return input;
  }

  /// Contrast ve parlaklığı artır (API'deki rembg efektini taklit)
  img.Image _enhanceContrast(img.Image image) {
    final result = img.Image(width: image.width, height: image.height);
    
    // Min/max pixel değerlerini bul
    int minR = 255, maxR = 0;
    int minG = 255, maxG = 0;
    int minB = 255, maxB = 0;
    
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        minR = minR > pixel.r ? pixel.r.toInt() : minR;
        maxR = maxR < pixel.r ? pixel.r.toInt() : maxR;
        minG = minG > pixel.g ? pixel.g.toInt() : minG;
        maxG = maxG < pixel.g ? pixel.g.toInt() : maxG;
        minB = minB > pixel.b ? pixel.b.toInt() : minB;
        maxB = maxB < pixel.b ? pixel.b.toInt() : maxB;
      }
    }
    
    // Normalize et (0-255 range'i expand et)
    double rangeR = (maxR - minR > 0) ? (maxR - minR).toDouble() : 1.0;
    double rangeG = (maxG - minG > 0) ? (maxG - minG).toDouble() : 1.0;
    double rangeB = (maxB - minB > 0) ? (maxB - minB).toDouble() : 1.0;
    
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        
        // Contrast Stretching
        final r = (_clamp(((pixel.r.toInt() - minR) / rangeR) * 255)).toInt();
        final g = (_clamp(((pixel.g.toInt() - minG) / rangeG) * 255)).toInt();
        final b = (_clamp(((pixel.b.toInt() - minB) / rangeB) * 255)).toInt();
        
        result.setPixelRgba(x, y, r, g, b, pixel.a.toInt());
      }
    }
    
    return result;
  }

  /// Histogram Equalization (contrast iyileştirme)
  img.Image _equalizeHistogram(img.Image image) {
    final result = img.Image(width: image.width, height: image.height);
    
    // Her kanal için histogram eşitleme
    final histogram = List<int>.filled(256, 0);
    
    // Tüm R kanalı piksellerini say
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        histogram[pixel.r.toInt()]++;
      }
    }
    
    // CDF (Cumulative Distribution Function) hesapla
    final cdf = List<int>.filled(256, 0);
    cdf[0] = histogram[0];
    for (int i = 1; i < 256; i++) {
      cdf[i] = cdf[i - 1] + histogram[i];
    }
    
    // Normalizasyon
    final totalPixels = image.width * image.height;
    final equalizedLut = List<int>.filled(256, 0);
    for (int i = 0; i < 256; i++) {
      equalizedLut[i] = (_clamp((cdf[i] / totalPixels) * 255)).toInt();
    }
    
    // LUT'u uygula
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final r = equalizedLut[pixel.r.toInt()];
        final g = equalizedLut[pixel.g.toInt()];
        final b = equalizedLut[pixel.b.toInt()];
        
        result.setPixelRgba(x, y, r, g, b, pixel.a.toInt());
      }
    }
    
    return result;
  }

  double _clamp(double value) {
    if (value < 0) return 0;
    if (value > 255) return 255;
    return value;
  }
  (double, double) _calculateShelfLife(String status, String fruitName, double confidence) {
    try {
      final maxDays = rafOmurleri[fruitName] ?? 7;

      double healthRatio;
      if (status == 'Fresh') {
        // Taze ise: confidence direkt health ratio
        healthRatio = confidence;
      } else {
        // Çürük ise: confidence ne kadar çürük olduğunu gösterir
        // Çürüklük %90+ ise 0 gün kaldı
        healthRatio = confidence > 0.9 ? 0.0 : (1.0 - confidence);
      }

      final daysLeft = (maxDays * healthRatio).round();
      final healthScore = (healthRatio * 100).round();

      return (daysLeft.toDouble(), healthScore.toDouble());
    } catch (e) {
      print("Raf ömrü hesaplama hatası: $e");
      return (0.0, 0.0);
    }
  }

  /// Meyve adını türkçeleştir
  String _formatFruitName(String name) {
    const Map<String, String> translations = {
      'apple': 'Elma',
      'banana': 'Muz',
      'bitter gourd': 'Acı Kabak',
      'bitter guard': 'Acı Kabak',
      'capsicum': 'Biber',
      'orange': 'Portakal',
      'tomato': 'Domates',
    };

    return translations[name.toLowerCase()] ?? name;
  }

  /// Modeli kapat (kaynakları serbest bırak)
  void dispose() {
    interpreter.close();
    _isModelLoaded = false;
  }
}
