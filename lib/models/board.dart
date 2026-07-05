import 'board_point.dart';
import 'checker.dart';
import 'player.dart';

class Board {
  final List<BoardPoint> points;
  final List<Checker> whiteBar;
  final List<Checker> blackBar;
  final List<Checker> whiteBearOff;
  final List<Checker> blackBearOff;

  const Board({
    required this.points,
    this.whiteBar = const [],
    this.blackBar = const [],
    this.whiteBearOff = const [],
    this.blackBearOff = const [],
  });

  factory Board.initial() {
    int checkerId = 0;
    Checker createChecker(Player p) => Checker(player: p, id: ++checkerId);
    List<Checker> createCheckers(Player p, int count) => 
        List.generate(count, (_) => createChecker(p));

    List<BoardPoint> initialPoints = List.generate(24, (index) {
      if (index == 23) return BoardPoint(index: index, checkers: createCheckers(Player.white, 2));
      if (index == 12) return BoardPoint(index: index, checkers: createCheckers(Player.white, 5));
      if (index == 7) return BoardPoint(index: index, checkers: createCheckers(Player.white, 3));
      if (index == 5) return BoardPoint(index: index, checkers: createCheckers(Player.white, 5));

      if (index == 0) return BoardPoint(index: index, checkers: createCheckers(Player.black, 2));
      if (index == 11) return BoardPoint(index: index, checkers: createCheckers(Player.black, 5));
      if (index == 16) return BoardPoint(index: index, checkers: createCheckers(Player.black, 3));
      if (index == 18) return BoardPoint(index: index, checkers: createCheckers(Player.black, 5));

      return BoardPoint(index: index, checkers: []);
    });

    return Board(points: initialPoints);
  }

  Board copyWith({
    List<BoardPoint>? points,
    List<Checker>? whiteBar,
    List<Checker>? blackBar,
    List<Checker>? whiteBearOff,
    List<Checker>? blackBearOff,
  }) {
    return Board(
      points: points ?? this.points,
      whiteBar: whiteBar ?? this.whiteBar,
      blackBar: blackBar ?? this.blackBar,
      whiteBearOff: whiteBearOff ?? this.whiteBearOff,
      blackBearOff: blackBearOff ?? this.blackBearOff,
    );
  }
}
