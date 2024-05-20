import 'package:flutter/material.dart';

(double, double, double, double) getRenderBoxCoordinates(BuildContext context) {
  final RenderBox renderBox = context.findRenderObject() as RenderBox;
  Offset boxGlobalPos = renderBox.localToGlobal(Offset.zero);
  final centerX = boxGlobalPos.dx + renderBox.size.width / 2;
  final centerY = boxGlobalPos.dy + renderBox.size.height / 2;
  return (centerX, centerY, renderBox.size.width, renderBox.size.height);
}
