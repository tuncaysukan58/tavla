import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../models/player.dart';
import '../widgets/board_widget.dart';
import '../widgets/dice_widget.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);

    if (gameState.humanPlayer == null) {
      return Scaffold(
        backgroundColor: Colors.green[800],
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Tarafınızı Seçin', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () => notifier.setHumanPlayer(Player.white),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black),
                      child: const Text('Beyaz (İlk Başlar)'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => notifier.setHumanPlayer(Player.black),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black87, foregroundColor: Colors.white),
                      child: const Text('Siyah'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.green[800], // Classic board background color
      appBar: AppBar(
        title: const Text('Tavla', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.brown[900],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                gameState.currentPlayer == Player.white 
                  ? "Sıra: Beyaz ${gameState.humanPlayer == Player.white ? '(Sen)' : '(Bot)'}" 
                  : "Sıra: Siyah ${gameState.humanPlayer == Player.black ? '(Sen)' : '(Bot)'}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [

            
            // The Board
            Expanded(
              child: Stack(
                children: [
                  const Center(
                    child: BoardWidget(),
                  ),
                  if (gameState.message != null)
                    Center(
                      child: Container(
                        margin: const EdgeInsets.all(32),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [Colors.black.withOpacity(0.9), Colors.black.withOpacity(0.7)],
                            radius: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.amber, width: 2),
                        ),
                        child: Text(
                          gameState.message!,
                          style: const TextStyle(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Bottom controls (Dice, etc.)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      DiceWidget(
                        faceValue: gameState.currentDice?.die1,
                        onTap: (gameState.hasRolled || gameState.currentPlayer != gameState.humanPlayer) ? null : notifier.rollDice,
                      ),
                      const SizedBox(width: 16),
                      DiceWidget(
                        faceValue: gameState.currentDice?.die2,
                        onTap: (gameState.hasRolled || gameState.currentPlayer != gameState.humanPlayer) ? null : notifier.rollDice,
                      ),
                    ],
                  ),
                  
                  if (gameState.currentDice != null)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Kalan:\n${gameState.remainingMoves.join(', ')}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: Text(
                        gameState.currentPlayer == gameState.humanPlayer 
                            ? 'Zarlara dokun' 
                            : 'Rakip bekleniyor...',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                    
                  Row(
                    children: [
                      if (gameState.canUndo && gameState.currentPlayer == gameState.humanPlayer)
                        Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: IconButton(
                            onPressed: () => notifier.undo(),
                            icon: const Icon(Icons.undo, size: 28),
                            color: Colors.orange[800],
                            tooltip: 'Geri Al',
                          ),
                        ),
                      ElevatedButton(
                        onPressed: gameState.hasRolled ? notifier.endTurn : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          backgroundColor: Colors.brown[600],
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Turu Bitir', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
