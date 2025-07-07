import 'package:flutter/material.dart';
import '../model/cellModel.dart';

class ChainReactionGame extends StatefulWidget {
  final int playerCount;

  const ChainReactionGame({super.key, required this.playerCount});

  @override
  State<ChainReactionGame> createState() => _ChainReactionGameState();
}

class _ChainReactionGameState extends State<ChainReactionGame> {
  final int rows = 12;
  final int cols = 6;

  late List<Cell> cells;
  int currentPlayer = 1;

  final availableColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.cyan,
    Colors.yellow,
    Colors.pink,
  ];

  late Map<int, Color> playerColors;

  int pendingExplosions = 0;
  bool waitingForExplosion = false;
  bool gameOver = false; // NEW: to track if game ended

  Set<int> activePlayers = {};

  @override
  void initState() {
    super.initState();
    playerColors = {
      for (int i = 1; i <= widget.playerCount; i++) i: availableColors[i - 1]
    };
    resetBoard();
  }

  int index(int row, int col) => row * cols + col;

  bool isInside(int row, int col) =>
      row >= 0 && row < rows && col >= 0 && col < cols;

  int getLimit(int row, int col) {
    if ((row == 0 || row == rows - 1) && (col == 0 || col == cols - 1)) {
      return 1;
    } else if (row == 0 || row == rows - 1 || col == 0 || col == cols - 1) {
      return 2;
    }
    return 3;
  }

  void addBall(int row, int col, [int? forcePlayer]) {
    if (gameOver) return; // BLOCK moves if game is over

    final i = index(row, col);
    final cell = cells[i];

    if (forcePlayer == null && cell.count > 0 && cell.owner != currentPlayer)
      return;

    final thisPlayer = forcePlayer ?? currentPlayer;

    if (forcePlayer == null) {
      activePlayers.add(currentPlayer);
    }

    setState(() {
      cell.count++;
      cell.owner = thisPlayer;
      cell.color = playerColors[thisPlayer]!;
    });

    final isExplosion = cell.count > getLimit(row, col);

    if (isExplosion) {
      pendingExplosions++;
      waitingForExplosion = true;

      Future.delayed(const Duration(milliseconds: 250), () {
        explode(row, col, thisPlayer);
        pendingExplosions--;

        if (pendingExplosions == 0 && forcePlayer == null) {
          waitingForExplosion = false;
          checkWinner();
          if (!gameOver) switchPlayer();
        }
      });
    } else if (forcePlayer == null && !waitingForExplosion) {
      checkWinner();
      if (!gameOver) switchPlayer();
    }
  }

  void explode(int row, int col, int player) {
    final i = index(row, col);

    setState(() {
      cells[i].count = 0;
      cells[i].owner = 0;
      cells[i].color = Colors.transparent;
    });

    final directions = [
      const Offset(0, -1),
      const Offset(0, 1),
      const Offset(-1, 0),
      const Offset(1, 0),
    ];

    for (var dir in directions) {
      final newRow = row + dir.dy.toInt();
      final newCol = col + dir.dx.toInt();
      if (isInside(newRow, newCol)) {
        addBall(newRow, newCol, player);
      }
    }
  }

  void switchPlayer() {
    setState(() {
      currentPlayer = currentPlayer % widget.playerCount + 1;
      print('player switched to $currentPlayer');
    });
  }

  void resetBoard() {
    cells = List.generate(rows * cols, (_) => Cell());
    currentPlayer = 1;
    pendingExplosions = 0;
    waitingForExplosion = false;
    gameOver = false; // Reset gameOver on new game
    activePlayers.clear();
    setState(() {});
  }

  void checkWinner() {
    final owners = cells.where((c) => c.count > 0).map((c) => c.owner).toSet();

    print('Active players: $activePlayers');
    print('Owners on board: $owners');

    if (activePlayers.length > 1 && owners.length == 1 && owners.first != 0) {
      gameOver = true; // mark game as over

      Future.delayed(const Duration(milliseconds: 300), () {
        showWinnerDialog(owners.first);
      });
    }
  }

  void showWinnerDialog(int player) {
    final playerColor = playerColors[player]!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('🎉 We Have a Winner!'),
        content: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: playerColor,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(child: Text('Player $player wins!')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).maybePop();
            },
            child: const Text('Exit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              resetBoard();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  Widget buildCell(int row, int col) {
    final i = index(row, col);
    final cell = cells[i];
    final limit = getLimit(row, col);

    return GestureDetector(
      onTap: () => addBall(row, col),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          border: Border.all(color: playerColors[currentPlayer]!, width: 1),
          color: const Color.fromARGB(31, 190, 188, 188),
        ),
        child: Center(
          child: cell.count > 0
              ? Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 4,
                  runSpacing: 4,
                  children: List.generate(
                    cell.count > limit ? limit : cell.count,
                    (_) => Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cell.color,
                      ),
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chain Reaction - Player $currentPlayer"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: resetBoard,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
          ),
          itemCount: rows * cols,
          itemBuilder: (context, i) => buildCell(i ~/ cols, i % cols),
        ),
      ),
    );
  }
}
