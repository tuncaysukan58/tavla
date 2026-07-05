import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/board_point.dart';
import '../providers/game_provider.dart';
import 'checker_widget.dart';

class PointWidget extends ConsumerWidget {
  final BoardPoint point;
  final bool isTopRow;
  final bool isDark;

  const PointWidget({
    super.key,
    required this.point,
    required this.isTopRow,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);
    
    final activeSourceIndex = gameState.draggingFromIndex ?? gameState.selectedFromIndex;
    final isPossibleTarget = activeSourceIndex != null && 
         notifier.canMove(activeSourceIndex, point.index);
         
    final isSelectedSource = gameState.selectedFromIndex == point.index;

    return DragTarget<int>(
      onWillAcceptWithDetails: (details) {
        final fromIndex = details.data;
        if (fromIndex == point.index) return false;
        return notifier.canMove(fromIndex, point.index);
      },
      onAcceptWithDetails: (details) {
        final fromIndex = details.data;
        notifier.move(fromIndex, point.index);
      },
      builder: (context, candidateData, rejectedData) {
        return GestureDetector(
          onTap: () => notifier.selectPoint(point.index),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final pointWidth = constraints.maxWidth;
              final pointHeight = constraints.maxHeight;
              final checkerSize = pointWidth * 0.9;
              
              final int checkerCount = point.count;
              double step = checkerSize;
              if (checkerCount * checkerSize > pointHeight) {
                step = (pointHeight - checkerSize) / (checkerCount - 1 > 0 ? checkerCount - 1 : 1);
              }
            // Highlight if it's a valid move for the currently dragged/selected checker
            final isDropTarget = candidateData.isNotEmpty;
            final isHighlighted = isPossibleTarget || isDropTarget;

            return Container(
              color: Colors.transparent, // Ensures hit testing covers the expanded area
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Triangle
                  CustomPaint(
                    size: Size(pointWidth, pointHeight),
                    painter: TrianglePainter(
                      isTopRow: isTopRow, 
                      isDark: isDark,
                      isHighlighted: isHighlighted,
                    ),
                  ),
                  
                  if (isSelectedSource)
                    Positioned(
                      top: isTopRow ? 0 : null,
                      bottom: !isTopRow ? 0 : null,
                      child: Container(
                        width: pointWidth,
                        height: pointHeight,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  
                  // Checkers
                  ...List.generate(checkerCount, (index) {
                    final checker = point.checkers[index];
                    final isTopChecker = index == checkerCount - 1;
                    
                    Widget checkerWidget = CheckerWidget(checker: checker, size: checkerSize);
                    
                    if (isTopChecker && checker.player == gameState.humanPlayer && gameState.remainingMoves.isNotEmpty) {
                      checkerWidget = Draggable<int>(
                        data: point.index,
                        onDragStarted: () => notifier.setDragging(point.index),
                        onDragEnd: (details) => notifier.setDragging(null),
                        onDraggableCanceled: (velocity, offset) => notifier.setDragging(null),
                        feedback: CheckerWidget(checker: checker, size: checkerSize),
                        childWhenDragging: Opacity(
                          opacity: 0.5,
                          child: checkerWidget,
                        ),
                        maxSimultaneousDrags: 1,
                        child: checkerWidget,
                      );
                    }

                    return Positioned(
                      top: isTopRow ? index * step : null,
                      bottom: !isTopRow ? index * step : null,
                      child: checkerWidget,
                    );
                  }),
                ],
              ),
            );
          },
        ),
      );
      },
    );
  }
}

class TrianglePainter extends CustomPainter {
  final bool isTopRow;
  final bool isDark;
  final bool isHighlighted;

  TrianglePainter({
    required this.isTopRow, 
    required this.isDark,
    this.isHighlighted = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Color color = isDark ? Colors.brown[700]! : Colors.brown[200]!;
    if (isHighlighted) {
      color = Colors.green[400]!;
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    if (isTopRow) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width / 2, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width / 2, 0);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TrianglePainter oldDelegate) {
    return oldDelegate.isTopRow != isTopRow || 
           oldDelegate.isDark != isDark ||
           oldDelegate.isHighlighted != isHighlighted;
  }
}
