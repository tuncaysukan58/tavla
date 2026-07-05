import 'package:flutter/material.dart';
import '../models/checker.dart';
import '../models/player.dart';

class CheckerWidget extends StatelessWidget {
  final Checker checker;
  final double size;

  const CheckerWidget({
    super.key,
    required this.checker,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: checker.player == Player.white 
              ? [Colors.white, Colors.grey[300]!] 
              : [Colors.grey[700]!, Colors.black],
          center: const Alignment(-0.3, -0.3),
          radius: 0.8,
        ),
        border: Border.all(
            color: checker.player == Player.white ? Colors.grey[400]! : Colors.black87, 
            width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            offset: Offset(1, 3),
            blurRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.65,
          height: size * 0.65,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: checker.player == Player.white ? Colors.grey[300]! : Colors.grey[800]!,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
