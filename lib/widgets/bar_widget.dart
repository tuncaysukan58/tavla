import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../models/player.dart';
import '../models/checker.dart';
import 'checker_widget.dart';

class BarWidget extends ConsumerWidget {
  const BarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);
    
    final whiteBar = gameState.board.whiteBar;
    final blackBar = gameState.board.blackBar;

    return Container(
      width: 40,
      color: Colors.brown[800],
      child: Column(
        children: [
          // Siyah kırık taşlar üstte
          Expanded(
            child: _buildBarSection(
              context, 
              checkers: blackBar, 
              player: Player.black, 
              isTop: true,
              gameState: gameState,
              notifier: notifier,
            ),
          ),
          // Beyaz kırık taşlar altta
          Expanded(
            child: _buildBarSection(
              context, 
              checkers: whiteBar, 
              player: Player.white, 
              isTop: false,
              gameState: gameState,
              notifier: notifier,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarSection(
    BuildContext context, {
    required List<Checker> checkers,
    required Player player,
    required bool isTop,
    required dynamic gameState,
    required dynamic notifier,
  }) {
    final barIndex = player == Player.white ? 24 : -1;

    return GestureDetector(
      onTap: checkers.isNotEmpty ? () => notifier.selectPoint(barIndex) : null,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final checkerSize = width * 0.9;
          
          double step = checkerSize;
          if (checkers.length * checkerSize > height) {
            step = (height - checkerSize) / (checkers.length - 1 > 0 ? checkers.length - 1 : 1);
          }

          final isSelectedSource = gameState.selectedFromIndex == barIndex;

          return Container(
            color: Colors.transparent, // Capture taps
            child: Stack(
              alignment: Alignment.center,
              children: List.generate(checkers.length, (index) {
                final checker = checkers[index];
                final isTopChecker = index == checkers.length - 1;
                
                Widget checkerWidget = CheckerWidget(
                  checker: checker,
                  size: checkerSize,
                );

                if (isSelectedSource && isTopChecker) {
                  checkerWidget = Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.yellowAccent.withOpacity(0.8),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: checkerWidget,
                  );
                }

                if (isTopChecker && checker.player == gameState.humanPlayer && gameState.remainingMoves.isNotEmpty) {
                  checkerWidget = Draggable<int>(
                    data: barIndex,
                    onDragStarted: () => notifier.setDragging(barIndex),
                    onDragEnd: (details) => notifier.setDragging(null),
                    onDraggableCanceled: (velocity, offset) => notifier.setDragging(null),
                    feedback: Material(
                      color: Colors.transparent,
                      child: CheckerWidget(checker: checker, size: checkerSize),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.5,
                      child: CheckerWidget(checker: checker, size: checkerSize),
                    ),
                    child: checkerWidget,
                  );
                }

                double offset = index * step;
                return Positioned(
                  top: isTop ? offset : null,
                  bottom: !isTop ? offset : null,
                  child: checkerWidget,
                );
              }),
            ),
          );
        },
      ),
    );
  }
}
