import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  final String backendUrl;

  ApiService({required this.backendUrl});

  Future<String> sendImage(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final request = http.MultipartRequest('POST', Uri.parse(backendUrl));
      request.files.add(http.MultipartFile.fromBytes('file', imageBytes, filename: imageFile.path.split('/').last, contentType: MediaType('image', 'jpeg')));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final prettyJson = const JsonEncoder.withIndent('  ').convert(json.decode(response.body));
        return prettyJson;
      } else {
        return 'Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return 'Failed to connect $e';
    }
  }
}
