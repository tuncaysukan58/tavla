import 'dart:math';
import 'package:flutter/material.dart';

class DiceWidget extends StatefulWidget {
  final int? faceValue;
  final VoidCallback? onTap;

  const DiceWidget({super.key, this.faceValue, this.onTap});

  @override
  State<DiceWidget> createState() => _DiceWidgetState();
}

class _DiceWidgetState extends State<DiceWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentFace = 1;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(() {
        setState(() {
          // Rapidly change faces while animating
          if (_controller.isAnimating) {
            _currentFace = _random.nextInt(6) + 1;
          }
        });
      });
  }

  @override
  void didUpdateWidget(DiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.faceValue != oldWidget.faceValue && widget.faceValue != null) {
      _controller.forward(from: 0).then((_) {
        setState(() {
          _currentFace = widget.faceValue!;
        });
      });
    } else if (widget.faceValue == null) {
      setState(() {});
    } else if (widget.faceValue != null && !_controller.isAnimating) {
      _currentFace = widget.faceValue!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final face = widget.faceValue == null && !_controller.isAnimating ? null : _currentFace;
    
    return GestureDetector(
      onTap: widget.onTap,
      child: Transform.rotate(
        angle: _controller.isAnimating ? _random.nextDouble() * 0.5 - 0.25 : 0,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 6,
                offset: Offset(2, 4),
              ),
            ],
          ),
          child: face == null 
              ? const Center(child: Icon(Icons.casino, color: Colors.grey, size: 30))
              : CustomPaint(
                  painter: DiceFacePainter(face),
                ),
        ),
      ),
    );
  }
}

class DiceFacePainter extends CustomPainter {
  final int face;

  DiceFacePainter(this.face);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87;
    final double radius = size.width * 0.12;
    final double center = size.width / 2;
    final double left = size.width * 0.25;
    final double right = size.width * 0.75;
    final double top = size.height * 0.25;
    final double bottom = size.height * 0.75;

    void drawDot(double x, double y) {
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    if (face % 2 != 0) {
      drawDot(center, center); // 1, 3, 5
    }
    if (face > 1) {
      drawDot(left, top); // 2, 3, 4, 5, 6
      drawDot(right, bottom); 
    }
    if (face > 3) {
      drawDot(right, top); // 4, 5, 6
      drawDot(left, bottom); 
    }
    if (face == 6) {
      drawDot(left, center); // 6
      drawDot(right, center); 
    }
  }

  @override
  bool shouldRepaint(covariant DiceFacePainter oldDelegate) => oldDelegate.face != face;
}
