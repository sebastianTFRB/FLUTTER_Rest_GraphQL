import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/launch.dart';

class RestService {
  final String base = 'https://api.spacexdata.com/v3';

  Future<List<Launch>> fetchLaunches({int limit = 10}) async {
    final url = Uri.parse('$base/launches?limit=$limit');
    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('REST error: ${res.statusCode}');
    }
    final List data = json.decode(res.body);
    return data.map((e) => Launch.fromRestJson(e)).toList();
  }
}
