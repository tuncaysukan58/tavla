import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../models/player.dart';
import 'checker_widget.dart';

class BearOffWidget extends ConsumerWidget {
  const BearOffWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);

    final whiteBearOff = gameState.board.whiteBearOff;
    final blackBearOff = gameState.board.blackBearOff;

    return Container(
      width: 45,
      decoration: BoxDecoration(
        color: Colors.brown[900],
        border: const Border(
          left: BorderSide(color: Colors.black54, width: 2),
        ),
      ),
      child: Column(
        children: [
          // Siyah taşların toplandığı yer (üstte)
          Expanded(
            child: _buildBearOffSection(
              context: context,
              player: Player.black,
              checkers: blackBearOff,
              isTop: true,
              notifier: notifier,
            ),
          ),
          const Divider(color: Colors.black54, height: 4, thickness: 2),
          // Beyaz taşların toplandığı yer (altta)
          Expanded(
            child: _buildBearOffSection(
              context: context,
              player: Player.white,
              checkers: whiteBearOff,
              isTop: false,
              notifier: notifier,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBearOffSection({
    required BuildContext context,
    required Player player,
    required List checkers,
    required bool isTop,
    required dynamic notifier,
  }) {
    final targetIndex = player == Player.white ? -1 : 24;

    return DragTarget<int>(
      onWillAcceptWithDetails: (details) {
        final fromIndex = details.data;
        return notifier.canMove(fromIndex, targetIndex);
      },
      onAcceptWithDetails: (details) {
        final fromIndex = details.data;
        notifier.move(fromIndex, targetIndex);
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;
        
        return GestureDetector(
          onTap: () {
             // For tap-to-move support
             notifier.selectPoint(targetIndex);
          },
          child: Container(
            color: isHighlighted ? Colors.green.withOpacity(0.3) : Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final height = constraints.maxHeight;
                final width = constraints.maxWidth;
                // Bear off checkers are usually shown smaller and stacked tight
                final checkerHeight = width * 0.3;
                
                double step = checkerHeight;
                if (checkers.length * checkerHeight > height) {
                  step = (height - checkerHeight) / (checkers.length - 1 > 0 ? checkers.length - 1 : 1);
                }

                return Stack(
                  alignment: Alignment.center,
                  children: List.generate(checkers.length, (index) {
                    final offset = index * step;
                    return Positioned(
                      top: isTop ? offset : null,
                      bottom: !isTop ? offset : null,
                      child: Container(
                        width: width * 0.8,
                        height: checkerHeight,
                        decoration: BoxDecoration(
                          color: player == Player.white ? Colors.white : Colors.black87,
                          border: Border.all(color: Colors.grey[600]!, width: 1),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [
                            BoxShadow(color: Colors.black54, offset: Offset(0, 1), blurRadius: 2),
                          ],
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
