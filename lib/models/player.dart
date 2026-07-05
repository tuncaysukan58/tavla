enum Player {
  white,
  black;

  Player get opponent => this == Player.white ? Player.black : Player.white;
}
