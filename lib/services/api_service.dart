import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // IP Adresini buradan yönetirsin
  final String apiUrl = 'http://192.168.1.3:5000/predict'; 

  Future<Map<String, dynamic>?> meyveAnalizEt(File resim) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(await http.MultipartFile.fromPath('file', resim.path));
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        return json.decode(responseData);
      } else {
        throw Exception("Sunucu Hatası: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Bağlantı Hatası: Lütfen IP adresini kontrol et.");
    }
  }
}