import 'checker.dart';
import 'player.dart';

class BoardPoint {
  final int index;
  final List<Checker> checkers;

  const BoardPoint({
    required this.index,
    required this.checkers,
  });

  Player? get owner => checkers.isEmpty ? null : checkers.first.player;
  int get count => checkers.length;

  BoardPoint copyWith({
    int? index,
    List<Checker>? checkers,
  }) {
    return BoardPoint(
      index: index ?? this.index,
      checkers: checkers ?? this.checkers,
    );
  }
}
