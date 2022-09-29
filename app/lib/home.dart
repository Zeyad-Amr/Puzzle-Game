import 'package:app/game.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int sliderVal = 2;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.blue[100],
        child: SafeArea(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Slide Puzzle ${sliderVal}x$sliderVal",
                style: TextStyle(
                  color: Colors.blue[900],
                  fontSize: 25,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Slider(
                min: 2,
                max: 6,
                label: sliderVal.toString(),
                value: sliderVal.toDouble(),
                onChanged: (value) {
                  setState(() {
                    sliderVal = value.toInt();
                  });
                },
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Game(puzzleSize: sliderVal),
                  ));
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
                child: const Text(
                  "Start",
                  style: TextStyle(fontSize: 30),
                ))
          ],
        )),
      ),
    );
  }
}
