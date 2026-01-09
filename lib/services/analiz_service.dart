import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AnalizService {
  final String apiUrl = 'http://192.168.1.3:5000/predict';

  // Sadece sonucu döndürür, UI ile ilgilenmez
  Future<Map<String, dynamic>?> meyveAnalizEt(File resim) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(await http.MultipartFile.fromPath('file', resim.path));
      
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        return json.decode(responseData);
      }
    } catch (e) {
      print("Hata: $e");
    }
    return null;
  }
}