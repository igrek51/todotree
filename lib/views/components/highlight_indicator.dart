import 'package:flutter/material.dart';

class HighlightIndicator extends StatefulWidget {
  HighlightIndicator({super.key});

  @override
  State<HighlightIndicator> createState() => HighlightIndicatorState();
}

class HighlightIndicatorState extends State<HighlightIndicator> with TickerProviderStateMixin {
  late final AnimationController _animController = AnimationController(
    value: 1,
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  Offset _offset = Offset.zero;
  Size _size = Size.zero;
  GlobalKey _boxKey = GlobalKey();

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: _boxKey,
      children: [
        Positioned(
          left: _offset.dx,
          top: _offset.dy,
          child: AnimatedBuilder(
            animation: CurvedAnimation(parent: _animController, curve: Curves.linear),
            builder: (context, child) {
              return Container(
                width: _size.width,
                height: _size.height,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(199, 53, 156, 240).withOpacity(1 - _animController.value),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void animate(double globalX, double globalY, double w, double h) {
    if (_boxKey.currentContext == null) return;
    RenderBox renderBox = _boxKey.currentContext!.findRenderObject() as RenderBox;
    Offset stackPosition = renderBox.localToGlobal(Offset.zero);
    setState(() {
      _offset = Offset(globalX - stackPosition.dx, globalY - stackPosition.dy);
      _size = Size(w, h);
    });
    _animController.forward(from: 0);
  }
}
