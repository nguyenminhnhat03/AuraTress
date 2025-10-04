import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class AiService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage() async {
    try {
      return await _picker.pickImage(source: ImageSource.gallery);
    } catch (e) {
      debugPrint('Pick image error: $e');
      return null;
    }
  }

  Future<String> consultAI(String query, {XFile? image}) async {
    try {
      await Future.delayed(const Duration(seconds: 2));  // Mock delay
      return 'Gợi ý từ AI: Bạn nên thử màu nâu chocolate cho tóc oval của bạn.';  // Mock response
    } catch (e) {
      throw Exception('Tư vấn AI thất bại: $e');
    }
  }
}