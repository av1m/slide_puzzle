import 'dart:async';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

class API {
  static Future<List<int>> solve(var tiles) async {
    final body = {'tiles': convert.jsonEncode(tiles), 'method': 'a_star'};
    print(body);
    final url = Uri.parse('http://127.0.0.1:5000/');

    try {
      var response = await http.post(url, body: body);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      final solution = (convert.jsonDecode(response.body) as List);
      if (response.statusCode == 200) {
        return List<int>.from(solution);
      }
    } on Exception catch (e) {
      print(e);
    }
  }
}

void main() {
  final data = API.solve([
    ["3", "0", "4"],
    ["1", "2", "7"],
    ["8", "6", "5"]
  ]);
  data.then((value) => print(value));
}
