// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'core/puzzle_proxy.dart';
import 'flutter.dart';
import 'puzzle_controls.dart';
import 'widgets/material_interior_alt.dart';

final puzzleAnimationDuration = kThemeAnimationDuration * 3;

abstract class SharedTheme {
  const SharedTheme();

  String get name;

  Color get puzzleThemeBackground;

  RoundedRectangleBorder puzzleBorder(bool small);

  Color get puzzleBackgroundColor;

  Color get puzzleAccentColor;

  EdgeInsetsGeometry tilePadding(PuzzleProxy puzzle) => const EdgeInsets.all(6);

  Widget tileButton(int i, PuzzleProxy puzzle, bool small);

  Ink createInk(
    Widget child, {
    DecorationImage image,
    EdgeInsetsGeometry padding,
  }) =>
      Ink(
        padding: padding,
        decoration: BoxDecoration(
          image: image,
        ),
        child: child,
      );

  Widget createButton(
    PuzzleProxy puzzle,
    bool small,
    int tileValue,
    Widget content, {
    Color color,
    RoundedRectangleBorder shape,
  }) =>
      AnimatedContainer(
        duration: puzzleAnimationDuration,
        padding: tilePadding(puzzle),
        child: MaterialButton(
          animationDuration: puzzleAnimationDuration,
          clipBehavior: Clip.hardEdge,
          elevation: 4,
          onPressed: () => puzzle.clickOrShake(tileValue),
          shape: shape ?? puzzleBorder(small),
          padding: const EdgeInsets.symmetric(),
          color: color,
          child: content,
        ),
      );

  // Thought about using AnimatedContainer here, but it causes some weird
  // resizing behavior
  Widget styledWrapper(bool small, Widget child) => MaterialInterior(
        duration: puzzleAnimationDuration,
        shape: puzzleBorder(small),
        color: puzzleBackgroundColor,
        child: child,
      );

  TextStyle get _infoStyle => TextStyle(
        color: puzzleAccentColor,
        fontWeight: FontWeight.bold,
      );

  List<Widget> bottomControls(BuildContext context, PuzzleControls controls) =>
      <Widget>[
        IconButton(
          onPressed: controls.reset,
          icon: Icon(Icons.refresh, color: puzzleAccentColor),
        ),
        OutlinedButton(
            onPressed: () => _showMyDialog(context, controls),
            child: const Text('Solve')),
        Expanded(
          child: Container(),
        ),
        Text(
          controls.clickCount.toString(),
          textAlign: TextAlign.right,
          style: _infoStyle,
        ),
        const Text(' Moves'),
        SizedBox(
          width: 28,
          child: Text(
            controls.incorrectTiles.toString(),
            textAlign: TextAlign.right,
            style: _infoStyle,
          ),
        ),
        const Text(' Tiles left  ')
      ];

  Widget tileButtonCore(int i, PuzzleProxy puzzle, bool small) {
    if (i == puzzle.tileCount && !puzzle.solved) {
      return const Center();
    }

    return tileButton(i, puzzle, small);
  }

  Future<void> _showMyDialog(
      BuildContext context, PuzzleControls controls) async {
    var dropdownValue = 'a_star';
    var checkboxValue = false;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Solve this puzzle'),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  const Text('Please choose a resolution algorithm'),
                  const Text(
                    'If it is a parameterized algorithm, the default settings will be applied',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  DropdownButton<String>(
                    value: dropdownValue,
                    icon: const Icon(Icons.psychology_outlined),
                    iconSize: 24,
                    elevation: 16,
                    style: const TextStyle(color: Colors.blue),
                    underline: Container(
                      height: 2,
                      color: Colors.blueAccent,
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValue = newValue;
                      });
                    },
                    items: [
                      const DropdownMenuItem(
                        value: 'a_star',
                        child: Text('A*'),
                      ),
                      const DropdownMenuItem(
                        value: 'breadth_first',
                        child: Text('Breadth-First Search'),
                      ),
                      const DropdownMenuItem(
                        value: 'depth_first',
                        child: Text('Depth-First Search'),
                      ),
                      const DropdownMenuItem(
                        value: 'depth_limited',
                        child: Text('Breadth-Limited Search'),
                      ),
                      const DropdownMenuItem(
                        value: 'greedy_best_first',
                        child: Text('Greedy Best-First Search'),
                      ),
                      const DropdownMenuItem(
                        value: 'iterative_deepening',
                        child: Text('Iterative Deepening Depth-First Search'),
                      ),
                      const DropdownMenuItem(
                        value: 'uniform_cost',
                        child: Text('Uniform-Cost Search'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Text('Solve by putting the blank on top?'),
                      Checkbox(
                        value: checkboxValue,
                        onChanged: (value) {
                          setState(() {
                            checkboxValue = !checkboxValue;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('We try to solve the puzzle. Thanks for waiting'),
                    duration: Duration(seconds: 2),
                  ),
                );
                Navigator.of(context).pop();
                controls.solve(context, dropdownValue, checkboxValue);
              },
              child: const Text('Solve'),
            ),
          ],
        );
      },
    );
  }
}
