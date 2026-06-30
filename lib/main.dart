import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'homePage.dart';
import 'wishlistsPage.dart';
import 'cart.dart';
import 'account.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initData();
  runApp(MyApp());
}

Future<void> initData() async {
  final prefs = await SharedPreferences.getInstance();

  if (!prefs.containsKey('wallet')) {
    await prefs.setDouble('wallet', 0);
  }

  if (!prefs.containsKey('username')) {
    await prefs.setString('username', 'Aeron Delen');
  }

  if (!prefs.containsKey('email')) {
    await prefs.setString('email', 'ardd@steam.com');
  }

  if (!prefs.containsKey('gameList')) {
    List<Map<String, String>> gameList = [
      {
        "id": "1",
        "image": "assets/images/Dota_2_Logo.png",
        "title": "Dota 2",
        "description":
            "Dota 2 is a free-to-play multiplayer online battle arena (MOBA) developed and published by Valve. Two teams of five players compete to destroy the opposing team's Ancient structure. With over 120 unique heroes, deep strategic gameplay, and a thriving esports scene, Dota 2 remains one of the most complex and rewarding competitive games ever made.",
        "genre": "MOBA / Strategy",
        "rating": "4.8",
        "wishlisted": "no",
        "addedToCart": "no",
        "price": "0",
        "salePrice": "0",
      },
      {
        "id": "2",
        "image": "assets/images/nba2k26-logo.png",
        "title": "NBA 2K26",
        "description":
            "NBA 2K26 delivers the most authentic basketball experience on PC and consoles. Featuring true-to-life player animations, revamped AI defense, and an expanded MyCAREER story mode, this year's entry raises the bar for sports simulations.",
        "genre": "Sports / Simulation",
        "rating": "4.5",
        "wishlisted": "no",
        "addedToCart": "no",
        "price": "6799.99",
        "salePrice": "2099.99",
      },
      {
        "id": "3",
        "image": "assets/images/Tekken-8-logo.jpg",
        "title": "Tekken 8",
        "description":
            "Tekken 8 is the latest chapter in the legendary King of Iron Fist Tournament, developed by Bandai Namco. Built on Unreal Engine 5, it features stunning visuals and a completely revamped combat system centered around the new Heat mechanic.",
        "genre": "Fighting / Action",
        "rating": "4.7",
        "wishlisted": "no",
        "addedToCart": "no",
        "price": "3999.99",
        "salePrice": "1199.99",
      },
      {
        "id": "4",
        "image": "assets/images/Hollow_Knight_logo.jpg",
        "title": "Hollow Knight",
        "description":
            "Hollow Knight is a classically styled 2D action-adventure game set in a vast underground kingdom of insects and heroes. Forge your own path through a sprawling hand-crafted world with precise platforming, challenging combat, and breathtaking art.",
        "genre": "Metroidvania / Indie",
        "rating": "4.9",
        "wishlisted": "no",
        "addedToCart": "no",
        "price": "1500.45",
        "salePrice": "450.13",
      },
      {
        "id": "5",
        "image": "assets/images/cyberpunk2077-logo.jpg",
        "title": "Cyberpunk 2077",
        "description":
            "Cyberpunk 2077 is an open-world, action-adventure RPG set in the megalopolis of Night City, where you play as V — a mercenary outlaw going after a one-of-a-kind implant that is the key to immortality.",
        "genre": "RPG / Open World",
        "rating": "4.6",
        "wishlisted": "no",
        "addedToCart": "no",
        "price": "1999.99",
        "salePrice": "599.99",
      },
      {
        "id": "6",
        "image": "assets/images/Elden-Ring-Logo.jpg",
        "title": "Elden Ring",
        "description":
            "Elden Ring is an action RPG developed by FromSoftware and published by Bandai Namco, created in collaboration with fantasy novelist George R. R. Martin. Rise, Tarnished, and be guided by grace to brandish the power of the Elden Ring.",
        "genre": "Action RPG / Souls",
        "rating": "4.9",
        "wishlisted": "no",
        "addedToCart": "no",
        "price": "1800.00",
        "salePrice": "540.00",
      },
      {
        "id": "7",
        "image": "assets/images/dbsz-logo.jpg",
        "title": "Dragon Ball: Sparking! ZERO",
        "description":
            "Dragon Ball: Sparking! ZERO is the long-awaited successor to the beloved Budokai Tenkaichi series. Featuring over 180 playable characters from across the Dragon Ball universe with stunning Unreal Engine 5 visuals.",
        "genre": "Anime / Fighting",
        "rating": "4.8",
        "wishlisted": "no",
        "addedToCart": "no",
        "price": "900.00",
        "salePrice": "270.00",
      },
      {
        "id": "8",
        "image": "assets/images/blackmyth-wukong-logo.jpg",
        "title": "Black Myth: Wukong",
        "description":
            "Black Myth: Wukong is an action RPG rooted in Chinese mythology, developed by Game Science. You take on the role of the Destined One to venture into the challenges and wonders ahead, and to unravel the truth veiled under the mist of myth.",
        "genre": "Action / Adventure",
        "rating": "4.8",
        "wishlisted": "no",
        "addedToCart": "no",
        "price": "3499.99",
        "salePrice": "1049.99",
      },
      {
        "id": "9",
        "image": "assets/images/apex-logo.png",
        "title": "Apex Legends",
        "description":
            "Apex Legends is a free-to-play battle royale hero shooter developed by Respawn Entertainment. Choose from a diverse roster of Legends, each with unique abilities, and compete in squads to be the last team standing.",
        "genre": "Battle Royale / FPS",
        "rating": "4.4",
        "wishlisted": "no",
        "addedToCart": "no",
        "price": "0",
        "salePrice": "0",
      },
      {
        "id": "10",
        "image": "assets/images/street-fighter-logo.jpg",
        "title": "Street Fighter 6",
        "description":
            "Street Fighter 6 is Capcom's landmark entry in the iconic fighting franchise, introducing the innovative Drive System that gives every fighter new offensive and defensive options.",
        "genre": "Fighting / Arcade",
        "rating": "4.6",
        "wishlisted": "no",
        "addedToCart": "no",
        "price": "457.12",
        "salePrice": "137.13",
      },
    ];

    await prefs.setString('gameList', jsonEncode(gameList));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Steam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF1B2838),
        fontFamily: 'Roboto',
      ),
      home: MainScaffold(),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget currentPage;

    if (selectedIndex == 0) {
      currentPage = HomePage();
    } else if (selectedIndex == 1) {
      currentPage = WishlistsPage();
    } else if (selectedIndex == 2) {
      currentPage = CartPage();
    } else {
      currentPage = AccountPage();
    }

    return Scaffold(
      body: currentPage,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (int i) {
          setState(() {
            selectedIndex = i;
          });
        },
        backgroundColor: Color(0xFF171D25),
        selectedItemColor: Color(0xFF66C0F4),
        unselectedItemColor: Color(0xFF8F98A0),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Wishlists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}
