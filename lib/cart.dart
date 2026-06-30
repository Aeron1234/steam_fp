import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartGames = [];
  double wallet = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadCart();
  }

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    String raw = prefs.getString('gameList') ?? '[]';
    double w = prefs.getDouble('wallet') ?? 0;

    List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(
      (jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e)),
    );

    setState(() {
      cartGames = list
          .where(
            (g) =>
                g['addedToCart'] == 'yes' &&
                (double.tryParse(g['price'].toString()) ?? 0) > 0,
          )
          .toList();
      wallet = w;
      loading = false;
    });
  }

  double getTotal() {
    double total = 0;
    for (var g in cartGames) {
      total +=
          double.tryParse(g['salePrice'].toString().replaceAll(',', '')) ?? 0;
    }
    return total;
  }

  Future<void> removeFromCart(String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    String raw = prefs.getString('gameList') ?? '[]';

    List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(
      (jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e)),
    );

    int idx = list.indexWhere((g) => g['id'] == gameId);
    Map<String, dynamic> removed = cartGames.firstWhere(
      (g) => g['id'] == gameId,
      orElse: () => {},
    );

    if (idx != -1) {
      list[idx]['addedToCart'] = 'no';
      await prefs.setString('gameList', jsonEncode(list));
    }

    setState(() {
      cartGames.removeWhere((g) => g['id'] == gameId);
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
              Icon(Icons.remove_shopping_cart, color: Colors.redAccent),
              SizedBox(width: 10),
              Text(
                'Removed from Cart',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          content: Text(
            '"${removed['title']}" has been removed from your cart.',
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

  Future<void> buyAll() async {
    if (cartGames.isEmpty) return;

    double total = getTotal();

    if (wallet < total) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Color(0xFF16202D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Colors.orangeAccent),
              SizedBox(width: 10),
              Text(
                'Insufficient Funds',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          content: Text(
            'Your wallet balance (₱${wallet.toStringAsFixed(2)}) is not enough to purchase these items.\n\nTotal: ₱${total.toStringAsFixed(2)}\n\nPlease deposit more funds in your Account.',
            style: TextStyle(color: Color(0xFF8F98A0), height: 1.5),
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

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Color(0xFF16202D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.shopping_bag, color: Color(0xFF66C0F4)),
            SizedBox(width: 10),
            Text(
              'Confirm Purchase',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          'You are about to purchase ${cartGames.length} item(s) for ₱${total.toStringAsFixed(2)}.\n\nWallet after purchase: ₱${(wallet - total).toStringAsFixed(2)}',
          style: TextStyle(color: Color(0xFF8F98A0), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Color(0xFF8F98A0))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF66C0F4)),
            child: Text('Buy Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final prefs = await SharedPreferences.getInstance();
    double newWallet = wallet - total;
    await prefs.setDouble('wallet', newWallet);

    String raw = prefs.getString('gameList') ?? '[]';
    List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(
      (jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e)),
    );

    for (var g in cartGames) {
      int idx = list.indexWhere((item) => item['id'] == g['id']);
      if (idx != -1) {
        list[idx]['addedToCart'] = 'no';
      }
    }

    await prefs.setString('gameList', jsonEncode(list));

    setState(() {
      wallet = newWallet;
      cartGames.clear();
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
              Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
              SizedBox(width: 10),
              Text(
                'Purchase Successful',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          content: Text(
            'Your purchase was successful!\n\nAmount paid: ₱${total.toStringAsFixed(2)}\nRemaining balance: ₱${newWallet.toStringAsFixed(2)}',
            style: TextStyle(color: Color(0xFF8F98A0), height: 1.5),
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
    double total = getTotal();

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
            child: Center(
              child: Text(
                '₱${wallet.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Color(0xFF66C0F4),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.notifications_outlined, color: Colors.white),
          ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF66C0F4)))
          : RefreshIndicator(
              onRefresh: loadCart,
              child: cartGames.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            color: Color(0xFF8F98A0).withValues(alpha: 0.4),
                            size: 80,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Your cart is empty',
                            style: TextStyle(
                              color: Color(0xFF8F98A0),
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Browse games and add them to your cart',
                            style: TextStyle(
                              color: Color(0xFF8F98A0),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: cartGames.length,
                            itemBuilder: (ctx, i) {
                              Map<String, dynamic> g = cartGames[i];
                              double salePrice =
                                  double.tryParse(
                                    g['salePrice'].toString().replaceAll(
                                      ',',
                                      '',
                                    ),
                                  ) ??
                                  0;
                              double price =
                                  double.tryParse(g['price'].toString()) ?? 0;

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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        g['genre'].toString(),
                                        style: TextStyle(
                                          color: Color(0xFF8F98A0),
                                          fontSize: 12,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Row(
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
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () => removeFromCart(g['id']),
                                    tooltip: 'Remove from Cart',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Color(0xFF171D25),
                            border: Border(
                              top: BorderSide(color: Color(0xFF2A3F5A)),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Wallet Balance:',
                                    style: TextStyle(color: Color(0xFF8F98A0)),
                                  ),
                                  Text(
                                    '₱${wallet.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Color(0xFF66C0F4),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total (${cartGames.length} item${cartGames.length == 1 ? '' : 's'}):',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '₱${total.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              if (wallet < total)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Insufficient funds (need ₱${(total - wallet).toStringAsFixed(2)} more)',
                                    style: TextStyle(
                                      color: Colors.orangeAccent,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: buyAll,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: wallet >= total
                                        ? Color(0xFF4C6B8A)
                                        : Color(0xFF3A3A3A),
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    wallet >= total
                                        ? 'Purchase All  (₱${total.toStringAsFixed(2)})'
                                        : 'Insufficient Funds',
                                    style: TextStyle(
                                      color: wallet >= total
                                          ? Colors.white
                                          : Color(0xFF8F98A0),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
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
