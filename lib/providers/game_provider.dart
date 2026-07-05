import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/board.dart';
import '../models/player.dart';
import '../models/dice.dart';
import '../models/checker.dart';
import '../models/board_point.dart';

class GameState {
  final Board board;
  final Player currentPlayer;
  final DiceRoll? currentDice;
  final List<int> remainingMoves;
  final bool hasRolled;
  final Player? winner;
  final Player? humanPlayer;
  final int? draggingFromIndex;
  final int? selectedFromIndex;
  final bool canUndo;
  final String? message;

  const GameState({
    required this.board,
    required this.currentPlayer,
    this.currentDice,
    this.remainingMoves = const [],
    this.hasRolled = false,
    this.winner,
    this.humanPlayer,
    this.draggingFromIndex,
    this.selectedFromIndex,
    this.canUndo = false,
    this.message,
  });

  factory GameState.initial() {
    return GameState(
      board: Board.initial(),
      currentPlayer: Player.white,
    );
  }

  GameState copyWith({
    Board? board,
    Player? currentPlayer,
    DiceRoll? currentDice,
    List<int>? remainingMoves,
    bool? hasRolled,
    Player? winner,
    Player? humanPlayer,
    int? draggingFromIndex,
    bool clearDragging = false,
    int? selectedFromIndex,
    bool clearSelected = false,
    bool? canUndo,
    String? message,
    bool clearMessage = false,
  }) {
    return GameState(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      currentDice: currentDice ?? this.currentDice,
      remainingMoves: remainingMoves ?? this.remainingMoves,
      hasRolled: hasRolled ?? this.hasRolled,
      winner: winner ?? this.winner,
      humanPlayer: humanPlayer ?? this.humanPlayer,
      draggingFromIndex: clearDragging ? null : (draggingFromIndex ?? this.draggingFromIndex),
      selectedFromIndex: clearSelected ? null : (selectedFromIndex ?? this.selectedFromIndex),
      canUndo: canUndo ?? this.canUndo,
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}

class GameNotifier extends Notifier<GameState> {
  final List<GameState> _turnHistory = [];
  Timer? _endTurnTimer;

  @override
  GameState build() {
    return GameState.initial();
  }

  void setHumanPlayer(Player player) {
    state = state.copyWith(humanPlayer: player);
    if (state.currentPlayer != player) {
      _playBotTurn();
    }
  }

  void setDragging(int? index) {
    state = state.copyWith(draggingFromIndex: index, clearDragging: index == null);
  }

  void selectPoint(int index) {
    if (state.currentPlayer != state.humanPlayer) return;
    if (state.remainingMoves.isEmpty) return;

    if (state.selectedFromIndex != null) {
      if (canMove(state.selectedFromIndex!, index)) {
        move(state.selectedFromIndex!, index);
        state = state.copyWith(clearSelected: true);
        return;
      }
      
      if (state.selectedFromIndex == index) {
        state = state.copyWith(clearSelected: true);
        return;
      }
    }

    final point = state.board.points[index];
    if (point.owner == state.currentPlayer) {
      state = state.copyWith(selectedFromIndex: index, clearSelected: false);
    } else {
      state = state.copyWith(clearSelected: true);
    }
  }

  void rollDice({bool isBot = false}) {
    if (state.hasRolled || state.winner != null) return;
    if (!isBot && state.currentPlayer != state.humanPlayer) return;
    
    _endTurnTimer?.cancel();
    _turnHistory.clear();
    
    final dice = DiceRoll.roll();
    state = state.copyWith(
      currentDice: dice,
      remainingMoves: dice.availableMoves,
      hasRolled: true,
      canUndo: false,
    );
    
    _checkAndHandleNoMoves();
  }

  void _checkAndHandleNoMoves() {
    if (state.remainingMoves.isEmpty) return;
    
    bool hasAnyValidMove = false;
    final hasBarCheckers = state.currentPlayer == Player.white 
        ? state.board.whiteBar.isNotEmpty 
        : state.board.blackBar.isNotEmpty;
        
    if (hasBarCheckers) {
      final barIndex = state.currentPlayer == Player.white ? 24 : -1;
      for (int j = 0; j <= 24; j++) {
        int targetJ = j == 24 ? (state.currentPlayer == Player.white ? -1 : 24) : j;
        if (canMove(barIndex, targetJ)) {
          hasAnyValidMove = true;
          break;
        }
      }
    } else {
      for (int i = 0; i < 24; i++) {
        for (int j = 0; j <= 24; j++) {
          int targetJ = j == 24 ? (state.currentPlayer == Player.white ? -1 : 24) : j;
          if (canMove(i, targetJ)) {
            hasAnyValidMove = true;
            break;
          }
        }
        if (hasAnyValidMove) break;
      }
    }

    if (!hasAnyValidMove) {
      state = state.copyWith(message: "Oynayacak hamle yok!");
      _delayedEndTurn();
    }
  }

  void _delayedEndTurn() {
    _endTurnTimer?.cancel();
    _endTurnTimer = Timer(const Duration(milliseconds: 1500), () {
      endTurn();
    });
  }

  void endTurn() {
    _endTurnTimer?.cancel();
    _turnHistory.clear();
    
    final nextPlayer = state.currentPlayer.opponent;
    state = state.copyWith(
      currentPlayer: nextPlayer,
      currentDice: null,
      remainingMoves: [],
      hasRolled: false,
      canUndo: false,
      clearDragging: true,
      clearSelected: true,
      clearMessage: true,
    );
    
    if (nextPlayer != state.humanPlayer && state.humanPlayer != null) {
      _playBotTurn();
    }
  }
  
  void undo() {
    if (_turnHistory.isEmpty) return;
    _endTurnTimer?.cancel();
    state = _turnHistory.removeLast();
  }
  
  Future<void> _playBotTurn() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (state.winner != null) return;
    
    rollDice(isBot: true);
    
    while (state.remainingMoves.isNotEmpty && state.currentPlayer != state.humanPlayer) {
      await Future.delayed(const Duration(milliseconds: 800));
      
      List<List<int>> validMoves = [];
      final hasBarCheckers = state.currentPlayer == Player.white 
          ? state.board.whiteBar.isNotEmpty 
          : state.board.blackBar.isNotEmpty;
          
      if (hasBarCheckers) {
        final barIndex = state.currentPlayer == Player.white ? 24 : -1;
        for (int j = 0; j <= 24; j++) {
          int targetJ = j == 24 ? (state.currentPlayer == Player.white ? -1 : 24) : j;
          if (canMove(barIndex, targetJ)) {
            validMoves.add([barIndex, targetJ]);
          }
        }
      } else {
        for (int i = 0; i < 24; i++) {
          for (int j = 0; j <= 24; j++) {
            int targetJ = j == 24 ? (state.currentPlayer == Player.white ? -1 : 24) : j;
            if (canMove(i, targetJ)) {
              validMoves.add([i, targetJ]);
            }
          }
        }
      }
      
      if (validMoves.isEmpty) {
        state = state.copyWith(message: "Oynayacak hamle yok!");
        break; // No moves left
      }
      
      validMoves.shuffle();
      final chosenMove = validMoves.first;
      move(chosenMove[0], chosenMove[1]);
    }
    
    // If still bot's turn but no moves could be made, end it with a delay so user reads the message
    if (state.currentPlayer != state.humanPlayer) {
       _delayedEndTurn();
    }
  }

  bool canBearOff(Player player) {
    if (player == Player.white) {
      if (state.board.whiteBar.isNotEmpty) return false;
      for (int i = 6; i < 24; i++) {
        if (state.board.points[i].owner == Player.white) return false;
      }
      return true;
    } else {
      if (state.board.blackBar.isNotEmpty) return false;
      for (int i = 0; i < 18; i++) {
        if (state.board.points[i].owner == Player.black) return false;
      }
      return true;
    }
  }
  
  bool canMove(int fromIndex, int toIndex) {
    if (state.remainingMoves.isEmpty) return false;

    final hasBarCheckers = state.currentPlayer == Player.white 
        ? state.board.whiteBar.isNotEmpty 
        : state.board.blackBar.isNotEmpty;

    Checker? checker;
    int distance;

    if (hasBarCheckers) {
      if (state.currentPlayer == Player.white && fromIndex != 24) return false;
      if (state.currentPlayer == Player.black && fromIndex != -1) return false;
      
      checker = state.currentPlayer == Player.white 
          ? state.board.whiteBar.last 
          : state.board.blackBar.last;
          
      distance = state.currentPlayer == Player.white 
          ? 24 - toIndex 
          : toIndex - (-1);
    } else {
      if (fromIndex == 24 || fromIndex == -1) return false;
      
      final fromPoint = state.board.points[fromIndex];
      if (fromPoint.checkers.isEmpty) return false;
      
      checker = fromPoint.checkers.last;
      if (checker.player != state.currentPlayer) return false;
      
      distance = checker.player == Player.white 
          ? fromIndex - toIndex 
          : toIndex - fromIndex;
    }

    if (distance <= 0) return false;
    
    int usedDie = -1;
    if (state.remainingMoves.contains(distance)) {
      usedDie = distance;
    } else {
      final isBearOff = (state.currentPlayer == Player.white && toIndex == -1) || 
                        (state.currentPlayer == Player.black && toIndex == 24);
      if (isBearOff) {
        final largerDice = state.remainingMoves.where((m) => m > distance).toList();
        if (largerDice.isNotEmpty) {
          largerDice.sort();
          bool hasHigherCheckers = false;
          if (state.currentPlayer == Player.white) {
            for (int i = fromIndex + 1; i < 6; i++) {
               if (state.board.points[i].owner == Player.white) {
                  hasHigherCheckers = true;
                  break;
               }
            }
          } else {
            for (int i = fromIndex - 1; i >= 18; i--) {
               if (state.board.points[i].owner == Player.black) {
                  hasHigherCheckers = true;
                  break;
               }
            }
          }
          if (!hasHigherCheckers) {
             usedDie = largerDice.first;
          }
        }
      }
    }
    
    if (usedDie == -1) return false;

    if (toIndex == -1 || toIndex == 24) {
      return canBearOff(state.currentPlayer);
    }

    final toPoint = state.board.points[toIndex];
    if (toPoint.owner != null && toPoint.owner != checker.player && toPoint.count > 1) {
      return false; // Rakip kapı almış
    }

    return true; 
  }

  void move(int fromIndex, int toIndex) {
    if (!canMove(fromIndex, toIndex)) return;
    
    Checker checker;
    List<Checker>? newFromCheckers;
    List<Checker> newWhiteBar = List.from(state.board.whiteBar);
    List<Checker> newBlackBar = List.from(state.board.blackBar);

    if (fromIndex == 24) {
      checker = newWhiteBar.removeLast();
    } else if (fromIndex == -1) {
      checker = newBlackBar.removeLast();
    } else {
      final fromPoint = state.board.points[fromIndex];
      checker = fromPoint.checkers.last;
      newFromCheckers = List<Checker>.from(fromPoint.checkers)..removeLast();
    }
    

    final distance = checker.player == Player.white 
        ? (fromIndex == 24 ? 24 - toIndex : fromIndex - toIndex) 
        : (fromIndex == -1 ? toIndex - (-1) : toIndex - fromIndex);
        
    int usedDie = distance;
    if (!state.remainingMoves.contains(distance)) {
      final largerDice = state.remainingMoves.where((m) => m > distance).toList();
      largerDice.sort();
      usedDie = largerDice.first;
    }
    
    List<Checker> newWhiteBearOff = List.from(state.board.whiteBearOff);
    List<Checker> newBlackBearOff = List.from(state.board.blackBearOff);
    List<Checker>? newToCheckers;
    
    final isBearOff = toIndex == -1 || toIndex == 24;

    if (isBearOff) {
      if (checker.player == Player.white) {
        newWhiteBearOff.add(checker);
      } else {
        newBlackBearOff.add(checker);
      }
    } else {
      final toPoint = state.board.points[toIndex];
      newToCheckers = List<Checker>.from(toPoint.checkers);
      
      // Taş kırma (Hit) mantığı
      if (toPoint.owner != null && toPoint.owner != checker.player && toPoint.count == 1) {
        final hitChecker = newToCheckers.removeLast();
        if (hitChecker.player == Player.white) {
          newWhiteBar.add(hitChecker);
        } else {
          newBlackBar.add(hitChecker);
        }
      }
      newToCheckers.add(checker);
    }
    
    _turnHistory.add(state);
    
    final newPoints = List<BoardPoint>.from(state.board.points);
    if (newFromCheckers != null) {
      newPoints[fromIndex] = state.board.points[fromIndex].copyWith(checkers: newFromCheckers);
    }
    if (!isBearOff) {
      newPoints[toIndex] = state.board.points[toIndex].copyWith(checkers: newToCheckers);
    }
    
    final newRemainingMoves = List<int>.from(state.remainingMoves);
    newRemainingMoves.remove(usedDie); 
    
    Player? winner;
    if (newWhiteBearOff.length == 15) {
      winner = Player.white;
    } else if (newBlackBearOff.length == 15) {
      winner = Player.black;
    }

    state = state.copyWith(
      board: state.board.copyWith(
        points: newPoints,
        whiteBar: newWhiteBar,
        blackBar: newBlackBar,
        whiteBearOff: newWhiteBearOff,
        blackBearOff: newBlackBearOff,
      ),
      remainingMoves: newRemainingMoves,
      clearDragging: true,
      clearSelected: true,
      canUndo: true,
      winner: winner,
    );
    
    if (winner != null) {
      state = state.copyWith(message: "Oyun Bitti! Kazanan: ${winner == Player.white ? 'Beyaz (Sen)' : 'Siyah (Bot)'}!");
      _endTurnTimer?.cancel();
    } else if (newRemainingMoves.isEmpty) {
      _delayedEndTurn();
    } else {
      _checkAndHandleNoMoves();
    }
  }
}

final gameProvider = NotifierProvider<GameNotifier, GameState>(GameNotifier.new);
