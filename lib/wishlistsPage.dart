import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'gamePage.dart';

class WishlistsPage extends StatefulWidget {
  const WishlistsPage({super.key});

  @override
  _WishlistsPageState createState() => _WishlistsPageState();
}

class _WishlistsPageState extends State<WishlistsPage> {
  List<Map<String, dynamic>> wishlistGames = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadWishlist();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadWishlist();
  }

  Future<void> loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    String raw = prefs.getString('gameList') ?? '[]';

    List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(
      (jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e)),
    );

    setState(() {
      wishlistGames = list.where((g) => g['wishlisted'] == 'yes').toList();
      loading = false;
    });
  }

  Future<void> removeFromWishlist(String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    String raw = prefs.getString('gameList') ?? '[]';

    List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(
      (jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e)),
    );

    int idx = list.indexWhere((g) => g['id'] == gameId);
    if (idx != -1) {
      list[idx]['wishlisted'] = 'no';
      await prefs.setString('gameList', jsonEncode(list));
    }

    Map<String, dynamic> removed = wishlistGames.firstWhere(
      (g) => g['id'] == gameId,
      orElse: () => {},
    );

    setState(() {
      wishlistGames.removeWhere((g) => g['id'] == gameId);
    });

    if (mounted && removed.isNotEmpty) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Color(0xFF16202D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(Icons.favorite_border, color: Color(0xFF8F98A0)),
              SizedBox(width: 10),
              Text(
                'Removed from Wishlist',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          content: Text(
            '"${removed['title']}" has been removed from your wishlist.',
            style: TextStyle(color: Color(0xFF8F98A0)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK', style: TextStyle(color: Color(0xFF66C0F4))),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1B2838),
      appBar: AppBar(
        backgroundColor: Color(0xFF171D25),
        title: Row(
          children: [
            Icon(Icons.whatshot, color: Color(0xFF66C0F4)),
            SizedBox(width: 8),
            Text(
              'Steam',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.notifications_outlined, color: Colors.white),
          ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF66C0F4)))
          : RefreshIndicator(
              onRefresh: loadWishlist,
              child: wishlistGames.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            color: Color(0xFF8F98A0).withValues(alpha: 0.4),
                            size: 80,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Your wishlist is empty',
                            style: TextStyle(
                              color: Color(0xFF8F98A0),
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Browse games and add them to your wishlist',
                            style: TextStyle(
                              color: Color(0xFF8F98A0),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: wishlistGames.length,
                      itemBuilder: (ctx, i) {
                        Map<String, dynamic> g = wishlistGames[i];
                        double price =
                            double.tryParse(g['price'].toString()) ?? 0;
                        double salePrice =
                            double.tryParse(
                              g['salePrice'].toString().replaceAll(',', ''),
                            ) ??
                            0;
                        bool isFree = price == 0;

                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Color(0xFF16202D),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Color(0xFF2A3F5A),
                              width: 0.5,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(12),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                g['image'].toString(),
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  width: 56,
                                  height: 56,
                                  color: Color(0xFF2A3F5A),
                                  child: Icon(
                                    Icons.videogame_asset,
                                    color: Color(0xFF66C0F4),
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              g['title'].toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  g['genre'].toString(),
                                  style: TextStyle(
                                    color: Color(0xFF8F98A0),
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 4),
                                isFree
                                    ? Text(
                                        'Free',
                                        style: TextStyle(
                                          color: Color(0xFF4CAF50),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : Row(
                                        children: [
                                          Text(
                                            '₱${price.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: Color(0xFF8F98A0),
                                              fontSize: 11,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            '₱${salePrice.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: Color(0xFF66C0F4),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GamePage(gameId: g['id']),
                                ),
                              );
                              loadWishlist();
                            },
                            trailing: IconButton(
                              icon: Icon(
                                Icons.favorite,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => removeFromWishlist(g['id']),
                              tooltip: 'Remove from Wishlist',
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
