import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TranscriptionService {
  Future<String> transcribeAudio(String audioFilePath) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null) throw Exception('OPENAI_API_KEY not found in .env');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.openai.com/v1/audio/transcriptions'),
    );

    request.headers['Authorization'] = 'Bearer $apiKey';
    request.fields['model'] = 'whisper-1';
    request.fields['language'] = 'en'; // Optional: can be made dynamic
    
    request.files.add(
      await http.MultipartFile.fromPath('file', audioFilePath),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['text'] as String;
    } else {
      final error = jsonDecode(response.body);
      throw Exception('Transcription failed: ${error['error']['message']}');
    }
  }
}