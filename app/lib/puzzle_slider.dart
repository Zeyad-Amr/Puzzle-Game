import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
                        child: SizedBox(
                          width: slideObject.size!.width,
                          height: slideObject.size!.height,
                          child: Container(
                            color: Colors.yellow,
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
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          width: slideObject.size!.width,
                          height: slideObject.size!.height,
                          child: Container(
                            color: Colors.blue,
                            child: Center(
                                child:
                                    Text(slideObject.indexDefault.toString())),
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
      return SlideObject(
        posCurrent: offsetTemp,
        posDefault: offsetTemp,
        indexCurrent: index,
        indexDefault: index + 1,
        size: sizeBox,
      );
    });
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
