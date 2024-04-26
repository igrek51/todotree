import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

final GlobalKey<ExplosionIndicatorState> explosionIndicatorKey = GlobalKey<ExplosionIndicatorState>();

class ExplosionIndicator extends StatefulWidget {
  ExplosionIndicator({super.key});

  @override
  State<ExplosionIndicator> createState() => ExplosionIndicatorState();
}

class ExplosionIndicatorState extends State<ExplosionIndicator> {
  late final _confettiController = ConfettiController(duration: const Duration(milliseconds: 200));

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirectionality: BlastDirectionality.explosive,
        shouldLoop: false,
        emissionFrequency: 1,
        numberOfParticles: 20,
        minBlastForce: 5,
        maxBlastForce: 100,
        gravity: 0.4,
        minimumSize: const Size(5, 5),
        maximumSize: const Size(8, 8),
      ),
    );
  }

  void animate() async {
    _confettiController.play();
  }
}
