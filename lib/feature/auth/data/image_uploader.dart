import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImageUploader {
  static const String imgbbApiKey = 'YOUR_IMGBB_API_KEY';
  Future<String?> uploadImageToImgbb(File imageFile) async {
    final apiKey =
        '13bc3617dca04f77981a9c02ea8cbebb'; 

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey'),
    );

    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    final response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final jsonResp = jsonDecode(respStr);
      return jsonResp['data']['url'];
    } else {
      print('Image upload failed: ${response.statusCode}');
      return null;
    }
  }

  static Future<String?> uploadImage(File imageFile) async {
    final url = Uri.parse('https://api.imgbb.com/1/upload?key=$imgbbApiKey');
    final base64Image = base64Encode(imageFile.readAsBytesSync());

    final response = await http.post(url, body: {'image': base64Image});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']['url'];
    } else {
      print('Image upload failed: ${response.body}');
      return null;
    }
  }
}
