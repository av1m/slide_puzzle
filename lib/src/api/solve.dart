import 'dart:async';
import 'dart:convert' as convert;
import 'dart:math';
import 'package:http/http.dart' as http;

class API {
  static List<List<int>> parseTiles(List<List<String>> tiles) {
    final tilesInt = tiles
        .map((sublist) => sublist.map((x) => int.parse(x) + 1).toList())
        .toList();
    final tileMax = tilesInt.map((sublist) => sublist.reduce(max)).reduce(max);
    return tilesInt
        .map((sublist) =>
            sublist.map((e) => e = (e == tileMax ? 0 : e)).toList())
        .toList();
  }

  static Future<List<int>> solve(var tiles) async {
    print('im enter her');
    final body = {
      'tiles': API.parseTiles((tiles as List<List<String>>)),
      'method': 'a_star'
    };

    // https://sliding-block-puzzles.herokuapp.com/
    final url = Uri.parse('https://sliding-block-puzzles.herokuapp.com/');

    
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: convert.jsonEncode(body));
      if (response.statusCode == 200) {
        final data = convert.jsonDecode(response.body);
        final solutions = (data['solutions'] as List);
        return List<int>.from(solutions);
      }
    
    return List.empty();
  }
}

void main() {
  final tiles = [
    ['6', '5', '8'],
    ['4', '2', '0'],
    ['3', '1', '7']
  ];
  final data = API.solve(tiles);
  data.then((value) => print(value));
}
