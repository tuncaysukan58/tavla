import 'player.dart';

class Checker {
  final Player player;
  final int id;

  const Checker({required this.player, required this.id});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Checker &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
