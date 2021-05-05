import 'src/core/puzzle_animator.dart';
import 'src/flutter.dart';
import 'src/puzzle_home_state.dart';

void main() => runApp(PuzzleApp());

class PuzzleApp extends StatelessWidget {
  final int rows, columns;

  PuzzleApp({int columns = 3, int rows = 3})
      : columns = columns ?? 3,
        rows = rows ?? 3;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Slide Puzzle',
        home: Scaffold(body: _PuzzleHome(rows, columns)),
      );
}

class _PuzzleHome extends StatefulWidget {
  final int _rows, _columns;

  const _PuzzleHome(this._rows, this._columns);

  @override
  PuzzleHomeState createState() =>
      PuzzleHomeState(PuzzleAnimator(_columns, _rows));
}
