import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'gamePage.dart';
import 'widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> gameList = [];
  List<Map<String, dynamic>> filteredList = [];
  double wallet = 0;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadGames();
  }

  Future<void> loadGames() async {
    final prefs = await SharedPreferences.getInstance();

    String raw = prefs.getString('gameList') ?? '[]';
    double w = prefs.getDouble('wallet') ?? 0;

    List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(
      (jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e)),
    );

    setState(() {
      gameList = list;
      filteredList = list;
      wallet = w;
    });
  }

  void searchGames(String query) {
    List<Map<String, dynamic>> results = [];

    if (query.isEmpty) {
      results = gameList;
    } else {
      for (int i = 0; i < gameList.length; i++) {
        String title = gameList[i]['title'].toString().toLowerCase();
        if (title.contains(query.toLowerCase())) {
          results.add(gameList[i]);
        }
      }
    }

    setState(() {
      filteredList = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1B2838),
      appBar: createSteamAppBar(
        walletText: 'Wallet: ₱${wallet.toStringAsFixed(2)}',
      ),
      body: RefreshIndicator(
        onRefresh: loadGames,
        child: ListView(
          children: [
            vSpace(16),

            // Search bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        searchGames(value);
                      },
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search games...',
                        hintStyle: TextStyle(color: Color(0xFF8F98A0)),
                        filled: true,
                        fillColor: Color(0xFF2A3F5A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  hSpace(10),
                  ElevatedButton(
                    onPressed: () {
                      searchGames(searchController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4C6B8A),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      'Search',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            vSpace(16),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A4A7A), Color(0xFF0D1B2A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 16,
                      top: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'STEAM GAMES',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            'GAMES STORE',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                          ),
                          vSpace(6),
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [Color(0xFF00D4FF), Color(0xFFFF6B35)],
                            ).createShader(bounds),
                            child: Text(
                              'SUMMER SALE!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFFF6B35),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'UP TO 70% OFF!',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          vSpace(8),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF4C6B8A),
                              padding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'SHOP NOW',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 12,
                      child: Row(
                        children: [
                          createGenreChip('FIGHTING'),
                          hSpace(6),
                          createGenreChip('SPORTS'),
                          hSpace(6),
                          createGenreChip('RPG'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            vSpace(16),

            // Game list
            for (int i = 0; i < filteredList.length; i++)
              createGameCard(filteredList[i], () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return GamePage(gameId: filteredList[i]['id']);
                    },
                  ),
                );
                loadGames();
              }),

            vSpace(20),
          ],
        ),
      ),
    );
  }
}
