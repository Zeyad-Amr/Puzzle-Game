import 'package:app/puzzle_slider.dart';
import 'package:flutter/material.dart';

class Game extends StatefulWidget {
  final int puzzleSize;
  const Game({super.key, required this.puzzleSize});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.blue[900],
      child: SafeArea(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  width: constraints.biggest.width,
                  // height: constraints.biggest.width,
                  // color: Colors.grey[800],
                  child: PuzzleSlider(
                      size: constraints.biggest,
                      puzzleSize: widget.puzzleSize,
                      imageBackground: const Image(
                        image: AssetImage("assets/images/eu.png"),
                      )),
                );
              },
            ),
          )
        ],
      )),
    ));
  }
}
