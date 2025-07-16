// ignore_for_file: avoid_print

import 'package:balloonblast/src/adds/ads_helper.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'gameScreen.dart';

class PlayerSelectionScreen extends StatefulWidget {
  const PlayerSelectionScreen({super.key});

  @override
  State<PlayerSelectionScreen> createState() => _PlayerSelectionScreenState();
}

class _PlayerSelectionScreenState extends State<PlayerSelectionScreen> {
  int selectedPlayerCount = 2;

  final List<Color> defaultColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.brown,
  ];

  List<Color?> selectedColors = [];

  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    selectedColors =
        List.generate(selectedPlayerCount, (index) => defaultColors[index]);

    InterstitialAd.load(
      adUnitId: AdHelper.getInterstatialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {});
          setState(() {
            _interstitialAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          print('Failed to load an interstatial ad: ${err.message}');
        },
      ),
    );
  }

  void updatePlayerCount(int count) {
    setState(() {
      selectedPlayerCount = count;
      selectedColors = List.generate(count, (index) => defaultColors[index]);
    });
  }

  void changePlayerColor(int playerIndex, Color newColor) {
    if (selectedColors.contains(newColor)) {
      final existingIndex = selectedColors.indexOf(newColor);
      if (existingIndex != playerIndex) {
        final temp = selectedColors[playerIndex];
        selectedColors[playerIndex] = newColor;
        selectedColors[existingIndex] = temp!;
        setState(() {});
        return;
      }
    }

    setState(() {
      selectedColors[playerIndex] = newColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    final availablePlayerCounts = List.generate(7, (index) => index + 2);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Image.asset(
                "assets/logo/chainFinal.png",
                height: 200,
              ),
              const Text(
                'Bubble Reaction',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 20),
                child: Row(
                  children: [
                    const Text("Select Player Count:"),
                    const SizedBox(width: 10),
                    DropdownButton2<int>(
                      value: selectedPlayerCount,
                      items: availablePlayerCounts
                          .map(
                            (count) => DropdownMenuItem(
                              value: count,
                              child: Text('$count Players'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) updatePlayerCount(value);
                      },
                      buttonStyleData: const ButtonStyleData(
                        height: 40,
                        width: 140,
                      ),
                      dropdownStyleData: DropdownStyleData(
                        maxHeight: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      menuItemStyleData: const MenuItemStyleData(height: 40),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: 250,
                child: ListView.builder(
                  itemCount: selectedPlayerCount,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('Player ${index + 1}'),
                      trailing: DropdownButton2<Color>(
                        value: selectedColors[index],
                        customButton: Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            color: selectedColors[index],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black26),
                          ),
                        ),
                        items: defaultColors
                            .take(selectedPlayerCount)
                            .map((color) {
                          return DropdownMenuItem<Color>(
                            value: color,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black26),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (color) {
                          if (color != null) changePlayerColor(index, color);
                        },
                        buttonStyleData: const ButtonStyleData(
                          height: 40,
                          width: 50,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 200,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        menuItemStyleData: const MenuItemStyleData(height: 40),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () async {
                    _interstitialAd?.show();
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChainReactionGame(
                          playerCount: selectedPlayerCount,
                          playerSelectColors: selectedColors,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Start Game",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
