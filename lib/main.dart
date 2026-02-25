import 'package:flutter/material.dart';

void main() {
  runApp(const DailyEleganceApp());
}

class DailyEleganceApp extends StatelessWidget {
  const DailyEleganceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFE5D9C5), // Light Beige
        fontFamily: 'Serif', // Use a Serif font for that "Elegance" feel
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Navigation Pages
  final List<Widget> _pages = [
    const HomeContent(),
    const Center(child: Text("Cart")),
    const Center(child: Text("Search")),
    const Center(child: Text("Contact")),
    const Center(child: Text("Profile")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We use Stack to create the split background effect from your image
      body: Stack(
        children: [
          Row(
            children: [
              Expanded(child: Container(color: const Color(0xFFE5D9C5))), // Cream
              Expanded(child: Container(color: const Color(0xFF2D1B14))), // Dark Brown
            ],
          ),
          SafeArea(child: _pages[_currentIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2D1B14),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.mail_outline), label: "Contact"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Menu Section (Top Bar)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.menu, color: Colors.black87),
              Text(
                "Daily Elegance".toUpperCase(),
                style: const TextStyle(
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Icon(Icons.favorite_border, color: Colors.black87),
            ],
          ),
        ),
        
        // 2. Hero Section (Matching your image)
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Daily\nElegance",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 60,
                    color: Colors.white,
                    height: 0.9,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 40),
                // Placeholder for your bag image
                Container(
                  height: 300,
                  width: 300,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(child: Image(image: AssetImage("./assets/homepage_bag.jpg"))),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}