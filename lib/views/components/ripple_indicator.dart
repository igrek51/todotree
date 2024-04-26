import 'package:flutter/material.dart';

class RippleIndicator extends StatefulWidget {
  RippleIndicator({super.key});

  @override
  State<RippleIndicator> createState() => RippleIndicatorState();
}

class RippleIndicatorState extends State<RippleIndicator> with TickerProviderStateMixin {
  late final AnimationController _rippleController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
    lowerBound: 0.0,
  );
  Offset _offset = Offset.zero;
  GlobalKey _boxKey = GlobalKey();

  @override
  void dispose() {
    _rippleController.dispose();
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
            animation: CurvedAnimation(parent: _rippleController, curve: Curves.fastOutSlowIn),
            builder: (context, child) {
              return SizedBox(
                width: 250,
                height: 250,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    _buildContainer(50 * _rippleController.value),
                    _buildContainer(125 * _rippleController.value),
                    _buildContainer(200 * _rippleController.value),
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildContainer(double radius) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue.withOpacity((1 - _rippleController.value) * 0.7),
      ),
    );
  }

  void animate(double globalX, double globalY) {
    if (_boxKey.currentContext == null) return;
    RenderBox renderBox = _boxKey.currentContext!.findRenderObject() as RenderBox;
    Offset boxPosition = renderBox.localToGlobal(Offset.zero);
    setState(() {
      _offset = Offset(globalX - boxPosition.dx - 125, globalY - boxPosition.dy - 125);
    });
    _rippleController.forward(from: 0);
  }
}
