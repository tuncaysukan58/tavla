import 'dart:math';

class DiceRoll {
  final int die1;
  final int die2;
  
  const DiceRoll(this.die1, this.die2);

  bool get isDouble => die1 == die2;
  
  List<int> get availableMoves {
    if (isDouble) return [die1, die1, die1, die1];
    return [die1, die2];
  }

  static final Random _random = Random();

  static DiceRoll roll() {
    return DiceRoll(_random.nextInt(6) + 1, _random.nextInt(6) + 1);
  }
}
