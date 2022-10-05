import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image;

class PuzzleSlider extends StatefulWidget {
  final Size size;

  /// set inner padding
  final double innerPadding;

  /// set image use for background
  final Image imageBackground;
  final int puzzleSize;

  const PuzzleSlider({
    Key? key,
    required this.size,
    this.innerPadding = 8,
    required this.imageBackground,
    required this.puzzleSize,
  }) : super(key: key);

  @override
  State<PuzzleSlider> createState() => _PuzzleSliderState();
}

class _PuzzleSliderState extends State<PuzzleSlider> {
  GlobalKey globalKey = GlobalKey();
  Size? size;

  /// list array slide objects
  List<SlideObject>? slideObjects;

  /// image load with renderer
  image.Image? fullImage;

  /// success flag
  bool success = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = Size(widget.size.width - widget.innerPadding * 2,
        widget.size.height - widget.innerPadding * 2);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          width: widget.size.width,
          height: widget.size.width,
          child: Padding(
            padding: EdgeInsets.all(widget.innerPadding),
            child: Stack(
              children: [
                if (slideObjects == null) ...[
                  RepaintBoundary(
                    key: globalKey,
                    child: SizedBox(
                      // color: Colors.grey[800],
                      height: double.maxFinite,
                      child: widget.imageBackground,
                    ),
                  )
                ],
                if (slideObjects != null)
                  ...slideObjects!
                      .where((slideObject) => slideObject.empty!)
                      .map((slideObject) {
                    return Positioned(
                        left: slideObject.posCurrent!.dx,
                        top: slideObject.posCurrent!.dy,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          width: slideObject.size!.width,
                          height: slideObject.size!.height,
                          child: Container(
                            color: Colors.white24,
                            child: Stack(children: [
                              if (slideObject.image != null) ...[
                                Opacity(
                                  opacity: 0.4,
                                  child: slideObject.image,
                                )
                              ],
                            ]),
                          ),
                        ));
                  }).toList(),
                if (slideObjects != null)
                  ...slideObjects!
                      .where((slideObject) => !slideObject.empty!)
                      .map((slideObject) {
                    return Positioned(
                        left: slideObject.posCurrent!.dx,
                        top: slideObject.posCurrent!.dy,
                        child: GestureDetector(
                          onTap: () => changePos(slideObject.indexCurrent!),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            width: slideObject.size!.width,
                            height: slideObject.size!.height,
                            child: Container(
                              color: Colors.blue,
                              child: Center(
                                  child: Stack(
                                children: [
                                  if (slideObject.image != null) ...[
                                    slideObject.image!
                                  ],
                                  Text(
                                    slideObject.indexDefault.toString(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                ],
                              )),
                            ),
                          ),
                        ));
                  }).toList()
              ],
            ),
          ),
        ),
        ElevatedButton(
            onPressed: () {
              _generatePuzzle();
            },
            child: const Text("Generate"))
      ],
    );
  }

  /// setup method use
  /// get render image
  /// same as jigsaw puzzle method before

  _getImageFromWidget() async {
    RenderBox? boundary =
        globalKey.currentContext!.findRenderObject() as RenderBox;
    RenderRepaintBoundary b = boundary as RenderRepaintBoundary;
    size = boundary.size;
    var img = await b.toImage();
    var byteData = await img.toByteData(format: ImageByteFormat.png);
    var pngBytes = byteData!.buffer.asUint8List();

    return image.decodeImage(pngBytes);
  }

  /// methode to generate puzzle
  _generatePuzzle() async {
    /// declare array puzzle

    /// 1st load render image to crop, we need load just once
    fullImage ??= await _getImageFromWidget();

    debugPrint(fullImage!.width.toString());

    /// calc box size for each puzzle
    Size sizeBox =
        Size(size!.width / widget.puzzleSize, size!.width / widget.puzzleSize);

    /// generate box puzzle
    slideObjects =
        List.generate(widget.puzzleSize * widget.puzzleSize, (index) {
      Offset offsetTemp = Offset(
        index % widget.puzzleSize * sizeBox.width,
        index ~/ widget.puzzleSize * sizeBox.height,
      );

      image.Image? tempCrop;
      if (fullImage != null) {
        tempCrop = image.copyCrop(
          fullImage!,
          offsetTemp.dx.round(),
          offsetTemp.dy.round(),
          sizeBox.width.round(),
          sizeBox.height.round(),
        );
      }

      return SlideObject(
          posCurrent: offsetTemp,
          posDefault: offsetTemp,
          indexCurrent: index,
          indexDefault: index + 1,
          size: sizeBox,
          image: tempCrop == null
              ? null
              : Image.memory(
                  Uint8List.fromList(image.encodePng(tempCrop)),
                  fit: BoxFit.contain,
                ));
    });
    slideObjects!.last.empty = true;

    // make random.. im using smple method..just rndom with move it.. haha

    // setup moveMethod 1st
    // proceed with swap block place
    // swap true - we swap horizontal line.. false - vertical
    bool swap = true;
    // process = [];

    // 20 * size puzzle shuffle
    for (var i = 0; i < widget.puzzleSize * 20; i++) {
      for (var j = 0; j < widget.puzzleSize / 2; j++) {
        SlideObject slideObjectEmpty = getEmptyObject();

        // get index of empty slide object
        int emptyIndex = slideObjectEmpty.indexCurrent!;
        // process.add(emptyIndex);
        int randKey;

        if (swap) {
          // horizontal swap
          int row = emptyIndex ~/ widget.puzzleSize;
          randKey =
              row * widget.puzzleSize + Random().nextInt(widget.puzzleSize);
        } else {
          int col = emptyIndex % widget.puzzleSize;
          randKey =
              widget.puzzleSize * Random().nextInt(widget.puzzleSize) + col;
        }

        // call change pos method we create before to swap place

        changePos(randKey);
        // ops forgot to swap
        // hmm bug.. :).. let move 1st with click..check whther bug on swap or change pos
        swap = !swap;
      }
    }

    // startSlide = false;
    // finishSwap = true;
    setState(() {});
  }

  // get empty slide object from list
  SlideObject getEmptyObject() {
    return slideObjects!.firstWhere((element) => element.empty!);
  }

  changePos(int indexCurrent) {
    // problem here i think..
    SlideObject slideObjectEmpty = getEmptyObject();

    // get index of empty slide object
    int emptyIndex = slideObjectEmpty.indexCurrent!;

    // min & max index based on vertical or horizontal

    int minIndex = min(indexCurrent, emptyIndex);
    int maxIndex = max(indexCurrent, emptyIndex);

    // temp list moves involves
    List<SlideObject> rangeMoves = [];

    // check if index current from vertical / horizontal line
    if (indexCurrent % widget.puzzleSize == emptyIndex % widget.puzzleSize) {
      // same vertical line
      rangeMoves = slideObjects!
          .where((element) =>
              element.indexCurrent! % widget.puzzleSize ==
              indexCurrent % widget.puzzleSize)
          .toList();
    } else if (indexCurrent ~/ widget.puzzleSize ==
        emptyIndex ~/ widget.puzzleSize) {
      rangeMoves = slideObjects!;
    } else {
      rangeMoves = [];
    }

    rangeMoves = rangeMoves
        .where((puzzle) =>
            puzzle.indexCurrent! >= minIndex &&
            puzzle.indexCurrent! <= maxIndex &&
            puzzle.indexCurrent != emptyIndex)
        .toList();

    // check empty index under or above current touch
    if (emptyIndex < indexCurrent) {
      rangeMoves.sort((a, b) => a.indexCurrent! < b.indexCurrent! ? 1 : 0);
    } else {
      rangeMoves.sort((a, b) => a.indexCurrent! < b.indexCurrent! ? 0 : 1);
    }

    // check if rangeMOves is exist,, then proceed switch position
    if (rangeMoves.isNotEmpty) {
      int tempIndex = rangeMoves[0].indexCurrent!;

      Offset tempPos = rangeMoves[0].posCurrent!;

      // yeayy.. sorry my mistake.. :)
      for (var i = 0; i < rangeMoves.length - 1; i++) {
        rangeMoves[i].indexCurrent = rangeMoves[i + 1].indexCurrent;
        rangeMoves[i].posCurrent = rangeMoves[i + 1].posCurrent;
      }

      rangeMoves.last.indexCurrent = slideObjectEmpty.indexCurrent;
      rangeMoves.last.posCurrent = slideObjectEmpty.posCurrent;

      // haha ..i forget to setup pos for empty puzzle box.. :p
      slideObjectEmpty.indexCurrent = tempIndex;
      slideObjectEmpty.posCurrent = tempPos;
    }
    // this to check if all puzzle box already in default place.. can set callback for success later
    if (slideObjects!
                .where((slideObject) =>
                    slideObject.indexCurrent == slideObject.indexDefault! - 1)
                .length ==
            slideObjects!.length
        // && finishSwap
        ) {
      debugPrint("Success");
      success = true;
    } else {
      success = false;
    }

    // startSlide = true;
    setState(() {});
  }
}

class SlideObject {
  /// setup offset for default / current positon
  Offset? posDefault;
  Offset? posCurrent;

  /// setup index for default / current position
  int? indexDefault;
  int? indexCurrent;

  /// status box is empty
  bool? empty;

  /// size each box
  Size? size;

  /// image field for crop later
  Image? image;
  SlideObject({
    this.posDefault,
    this.posCurrent,
    this.indexDefault,
    this.indexCurrent,
    this.empty = false,
    required this.size,
    this.image,
  });
}
