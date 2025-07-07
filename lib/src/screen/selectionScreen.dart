import 'package:flutter/material.dart';
import 'gameScreen.dart';

class PlayerSelectionScreen extends StatelessWidget {
  const PlayerSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Number of Players")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            final playerCount = index + 2;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                child: Text('$playerCount Players'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ChainReactionGame(playerCount: playerCount),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}
