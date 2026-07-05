import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../models/board_point.dart';
import 'point_widget.dart';

import 'bar_widget.dart';
import 'bear_off_widget.dart';

class BoardWidget extends ConsumerWidget {
  const BoardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final board = gameState.board;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.brown[400]!,
            Colors.brown[600]!,
            Colors.brown[800]!,
          ],
        ),
        border: Border.all(color: Colors.brown[900]!, width: 12),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 15,
            offset: Offset(0, 8),
          )
        ],
      ),
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Left half
          Expanded(child: _buildHalf(board.points, isLeft: true)),
          // The Bar
          const BarWidget(),
          // Right half
          Expanded(child: _buildHalf(board.points, isLeft: false)),
          // The Bear Off Area
          const BearOffWidget(),
        ],
      ),
    );
  }

  Widget _buildHalf(List<BoardPoint> points, {required bool isLeft}) {
    final topIndices = isLeft ? [12, 13, 14, 15, 16, 17] : [18, 19, 20, 21, 22, 23];
    final bottomIndices = isLeft ? [11, 10, 9, 8, 7, 6] : [5, 4, 3, 2, 1, 0];

    return Column(
      children: [
        Expanded(
          child: Row(
            children: topIndices.map((index) {
              return Expanded(
                child: PointWidget(
                  point: points[index],
                  isTopRow: true,
                  isDark: index % 2 == 0,
                ),
              );
            }).toList(),
          ),
        ),
        // Empty space in the middle for dice or just separation
        const SizedBox(height: 40),
        Expanded(
          child: Row(
            children: bottomIndices.map((index) {
              return Expanded(
                child: PointWidget(
                  point: points[index],
                  isTopRow: false,
                  isDark: index % 2 != 0,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
