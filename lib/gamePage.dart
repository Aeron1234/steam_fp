import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GamePage extends StatefulWidget {
  final String gameId;

  const GamePage({super.key, required this.gameId});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  Map<String, dynamic>? game;
  bool wishlisted = false;
  bool inCart = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadGame();
  }

  Future<void> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    String raw = prefs.getString('gameList') ?? '[]';

    List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(
      (jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e)),
    );

    Map<String, dynamic> found = list.firstWhere(
      (g) => g['id'] == widget.gameId,
      orElse: () => {},
    );

    if (found.isNotEmpty) {
      setState(() {
        game = found;
        wishlisted = found['wishlisted'] == 'yes';
        inCart = found['addedToCart'] == 'yes';
        loading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> getGameList() async {
    final prefs = await SharedPreferences.getInstance();
    String raw = prefs.getString('gameList') ?? '[]';
    return List<Map<String, dynamic>>.from(
      (jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e)),
    );
  }

  Future<void> saveGameList(List<Map<String, dynamic>> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gameList', jsonEncode(list));
  }

  Future<void> toggleWishlist() async {
    List<Map<String, dynamic>> list = await getGameList();
    int idx = list.indexWhere((g) => g['id'] == widget.gameId);
    if (idx == -1) return;

    bool newVal = !wishlisted;
    list[idx]['wishlisted'] = newVal ? 'yes' : 'no';
    await saveGameList(list);

    setState(() {
      wishlisted = newVal;
    });

    if (mounted) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Color(0xFF16202D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(
                newVal ? Icons.favorite : Icons.favorite_border,
                color: newVal ? Colors.redAccent : Color(0xFF8F98A0),
              ),
              SizedBox(width: 10),
              Text(
                newVal ? 'Added to Wishlist' : 'Removed from Wishlist',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          content: Text(
            newVal
                ? '"${game!['title']}" has been added to your wishlist.'
                : '"${game!['title']}" has been removed from your wishlist.',
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

  Future<void> toggleCart() async {
    if (inCart) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Color(0xFF16202D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF66C0F4)),
              SizedBox(width: 10),
              Text(
                'Already in Cart',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          content: Text(
            '"${game!['title']}" is already in your cart.',
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
      return;
    }

    List<Map<String, dynamic>> list = await getGameList();
    int idx = list.indexWhere((g) => g['id'] == widget.gameId);
    if (idx == -1) return;

    list[idx]['addedToCart'] = 'yes';
    await saveGameList(list);

    setState(() {
      inCart = true;
    });

    if (mounted) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Color(0xFF16202D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(Icons.shopping_cart, color: Color(0xFF66C0F4)),
              SizedBox(width: 10),
              Text(
                'Added to Cart',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          content: Text(
            '"${game!['title']}" has been added to your cart.',
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

  Widget buildDetailRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 14),
        children: [
          TextSpan(
            text: '$label: ',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          TextSpan(
            text: value,
            style: TextStyle(color: Color(0xFFCDD3D8)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: Color(0xFF1B2838),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF66C0F4)),
        ),
      );
    }

    if (game == null) {
      return Scaffold(
        backgroundColor: Color(0xFF1B2838),
        appBar: AppBar(backgroundColor: Color(0xFF171D25)),
        body: Center(
          child: Text('Game not found', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    double price = double.tryParse(game!['price'].toString()) ?? 0;
    double salePrice =
        double.tryParse(game!['salePrice'].toString().replaceAll(',', '')) ?? 0;
    bool isFree = price == 0;

    return Scaffold(
      backgroundColor: Color(0xFF1B2838),
      appBar: AppBar(
        backgroundColor: Color(0xFF171D25),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                game!['title'].toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Container(
                width: double.infinity,
                height: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Color(0xFF16202D),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    game!['image'].toString(),
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => Center(
                      child: Icon(
                        Icons.videogame_asset,
                        color: Color(0xFF66C0F4),
                        size: 80,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              game!['description'].toString(),
              style: TextStyle(
                color: Color(0xFFCDD3D8),
                fontSize: 14,
                height: 1.6,
              ),
            ),
            SizedBox(height: 20),
            buildDetailRow('Genre', game!['genre'].toString()),
            SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Ratings: ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  game!['rating'].toString(),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(width: 4),
                Icon(Icons.star, color: Color(0xFFFFD700), size: 16),
              ],
            ),
            SizedBox(height: 8),
            isFree
                ? Text(
                    'Free',
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                : Row(
                    children: [
                      Text(
                        '₱${price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Color(0xFF8F98A0),
                          decoration: TextDecoration.lineThrough,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        '₱${salePrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Color(0xFF66C0F4),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: toggleWishlist,
                  icon: Icon(
                    wishlisted ? Icons.favorite : Icons.favorite_border,
                    color: wishlisted ? Colors.redAccent : Colors.white,
                    size: 28,
                  ),
                  tooltip: wishlisted
                      ? 'Remove from Wishlist'
                      : 'Add to Wishlist',
                ),
                SizedBox(width: 8),
                if (!isFree)
                  IconButton(
                    onPressed: toggleCart,
                    icon: Icon(
                      inCart ? Icons.shopping_cart : Icons.add_shopping_cart,
                      color: inCart ? Color(0xFF66C0F4) : Colors.white,
                      size: 28,
                    ),
                    tooltip: inCart ? 'In Cart' : 'Add to Cart',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
