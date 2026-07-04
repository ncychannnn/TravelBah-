import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = "rwockmgf";
  static const String uploadPreset = "travelbah_upload";

  /// Upload image from Android/iOS
  Future<String?> uploadImage(File imageFile) async {
    try {
      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
      );

      final request = http.MultipartRequest(
        "POST",
        uri,
      );

      request.fields["upload_preset"] = uploadPreset;

      request.files.add(
        await http.MultipartFile.fromPath(
          "file",
          imageFile.path,
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final data = jsonDecode(
          await response.stream.bytesToString(),
        );

        return data["secure_url"];
      }

      return null;
    } catch (e) {
      print("Cloudinary Upload Error: $e");
      return null;
    }
  }

  /// Upload image from Flutter Web (Chrome)
  Future<String?> uploadImageFromBytes(Uint8List imageBytes) async {
    try {
      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
      );

      final request = http.MultipartRequest(
        "POST",
        uri,
      );

      request.fields["upload_preset"] = uploadPreset;

      request.files.add(
        http.MultipartFile.fromBytes(
          "file",
          imageBytes,
          filename: "travelbah.jpg",
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final data = jsonDecode(
          await response.stream.bytesToString(),
        );

        return data["secure_url"];
      }

      return null;
    } catch (e) {
      print("Cloudinary Upload Error: $e");
      return null;
    }
  }
}