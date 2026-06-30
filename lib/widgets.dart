import 'package:flutter/material.dart';

Widget vSpace(double h) {
  return SizedBox(height: h);
}

Widget hSpace(double w) {
  return SizedBox(width: w);
}

AppBar createSteamAppBar({
  String walletText = '',
  bool showBack = false,
  BuildContext? context,
}) {
  return AppBar(
    backgroundColor: Color(0xFF171D25),
    leading: showBack
        ? IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context!),
          )
        : null,
    title: Row(
      children: [
        Icon(Icons.whatshot, color: Color(0xFF66C0F4)),
        SizedBox(width: 8),
        Text(
          'Steam',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    ),
    actions: [
      if (walletText.isNotEmpty)
        Padding(
          padding: EdgeInsets.only(right: 8),
          child: Center(
            child: Text(
              walletText,
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
  );
}

Widget createGameCard(Map<String, dynamic> game, VoidCallback onTap) {
  double price = double.tryParse(game['price'].toString()) ?? 0;
  double salePrice = double.tryParse(game['salePrice'].toString()) ?? 0;
  bool isFree = price == 0;

  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF16202D),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(0xFF2A3F5A), width: 0.5),
      ),
      child: Row(
        children: [
          createGameImage(game['image'].toString(), 64),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game['title'].toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  game['genre'].toString(),
                  style: TextStyle(color: Color(0xFF8F98A0), fontSize: 12),
                ),
                SizedBox(height: 5),
                createStarRating(game['rating'].toString()),
                SizedBox(height: 4),
                createPriceDisplay(price, salePrice, isFree),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Color(0xFF8F98A0)),
        ],
      ),
    ),
  );
}

Widget createWishlistCard(
  Map<String, dynamic> game,
  VoidCallback onTap,
  VoidCallback onRemove,
) {
  double price = double.tryParse(game['price'].toString()) ?? 0;
  double salePrice =
      double.tryParse(game['salePrice'].toString().replaceAll(',', '')) ?? 0;
  bool isFree = price == 0;

  return Container(
    margin: EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Color(0xFF16202D),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Color(0xFF2A3F5A), width: 0.5),
    ),
    child: ListTile(
      contentPadding: EdgeInsets.all(12),
      leading: createGameImage(game['image'].toString(), 56),
      title: Text(
        game['title'].toString(),
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            game['genre'].toString(),
            style: TextStyle(color: Color(0xFF8F98A0), fontSize: 12),
          ),
          SizedBox(height: 4),
          createPriceDisplay(price, salePrice, isFree),
        ],
      ),
      onTap: onTap,
      trailing: IconButton(
        icon: Icon(Icons.favorite, color: Colors.redAccent),
        onPressed: onRemove,
        tooltip: 'Remove from Wishlist',
      ),
    ),
  );
}

Widget createCartCard(Map<String, dynamic> game, VoidCallback onRemove) {
  double price = double.tryParse(game['price'].toString()) ?? 0;
  double salePrice =
      double.tryParse(game['salePrice'].toString().replaceAll(',', '')) ?? 0;

  return Container(
    margin: EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Color(0xFF16202D),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Color(0xFF2A3F5A), width: 0.5),
    ),
    child: ListTile(
      contentPadding: EdgeInsets.all(12),
      leading: createGameImage(game['image'].toString(), 56),
      title: Text(
        game['title'].toString(),
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            game['genre'].toString(),
            style: TextStyle(color: Color(0xFF8F98A0), fontSize: 12),
          ),
          SizedBox(height: 4),
          createPriceDisplay(price, salePrice, false),
        ],
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete_outline, color: Colors.redAccent),
        onPressed: onRemove,
        tooltip: 'Remove from Cart',
      ),
    ),
  );
}

Widget createGameImage(String imagePath, double size) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Image.asset(
      imagePath,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: size,
          height: size,
          color: Color(0xFF2A3F5A),
          child: Icon(Icons.videogame_asset, color: Color(0xFF66C0F4)),
        );
      },
    ),
  );
}

Widget createStarRating(String rating) {
  return Row(
    children: [
      Icon(Icons.star, color: Color(0xFFFFD700), size: 14),
      SizedBox(width: 3),
      Text(rating, style: TextStyle(color: Color(0xFFFFD700), fontSize: 13)),
    ],
  );
}

Widget createPriceDisplay(double price, double salePrice, bool isFree) {
  if (isFree) {
    return Text(
      'Free',
      style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold),
    );
  }

  return Row(
    children: [
      Text(
        '₱${price.toStringAsFixed(2)}',
        style: TextStyle(
          color: Color(0xFF8F98A0),
          fontSize: 12,
          decoration: TextDecoration.lineThrough,
        ),
      ),
      SizedBox(width: 8),
      Text(
        '₱${salePrice.toStringAsFixed(2)}',
        style: TextStyle(
          color: Color(0xFF66C0F4),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    ],
  );
}

Widget createEmptyState(IconData icon, String title, String subtitle) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Color(0xFF8F98A0).withValues(alpha: 0.4), size: 80),
        SizedBox(height: 16),
        Text(title, style: TextStyle(color: Color(0xFF8F98A0), fontSize: 16)),
        SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(color: Color(0xFF8F98A0), fontSize: 13),
        ),
      ],
    ),
  );
}

Widget createSteamTextField(
  TextEditingController controller,
  String label, {
  TextInputType keyboardType = TextInputType.text,
}) {
  return TextField(
    controller: controller,
    style: TextStyle(color: Colors.white),
    keyboardType: keyboardType,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Color(0xFF8F98A0)),
      filled: true,
      fillColor: Color(0xFF2A3F5A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Color(0xFF66C0F4)),
      ),
    ),
  );
}

Widget createProfileTile(IconData icon, String label, String value) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(
      children: [
        Icon(icon, color: Color(0xFF66C0F4), size: 20),
        SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Color(0xFF8F98A0), fontSize: 11),
            ),
            SizedBox(height: 2),
            Text(value, style: TextStyle(color: Colors.white, fontSize: 15)),
          ],
        ),
      ],
    ),
  );
}

Widget createGenreChip(String label) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Color(0xFF2A3F5A).withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: Color(0xFF66C0F4),
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Future<void> showSteamDialog(
  BuildContext context,
  IconData icon,
  Color iconColor,
  String title,
  String message,
) async {
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Color(0xFF16202D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(icon, color: iconColor),
            SizedBox(width: 10),
            Text(title, style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(color: Color(0xFF8F98A0), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK', style: TextStyle(color: Color(0xFF66C0F4))),
          ),
        ],
      );
    },
  );
}
