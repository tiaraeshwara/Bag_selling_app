import 'package:flutter/material.dart';

void main() => runApp(const ElegantCosmeticApp());

class ElegantCosmeticApp extends StatelessWidget {
  const ElegantCosmeticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Using a clean, elegant font style
        fontFamily: 'Serif', 
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD7B9AB),
          surface: const Color(0xFFFDFBF9),
        ),
      ),
      home: const MainNavigationLayout(),
    );
  }
}

class MainNavigationLayout extends StatefulWidget {
  const MainNavigationLayout({super.key});

  @override
  State<MainNavigationLayout> createState() => _MainNavigationLayoutState();
}

class _MainNavigationLayoutState extends State<MainNavigationLayout> {
  int _selectedIndex = 0;
  bool _isExtended = false;

  // Pages matching the beige/brown theme
  final List<Widget> _pages = [
    const BagPage(), // Home/Bag view
    const Center(child: Text("Search Page", style: TextStyle(color: Color(0xFF3E2723)))),
    const Center(child: Text("Favorites", style: TextStyle(color: Color(0xFF3E2723)))),
    const Center(child: Text("Profile", style: TextStyle(color: Color(0xFF3E2723)))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6), // Base Beige
      body: Row(
        children: [
          // --- SIDE NAVIGATION BAR ---
          NavigationRail(
            extended: _isExtended,
            backgroundColor: const Color(0xFFF5EFE6),
            indicatorColor: const Color(0xFFE8DFD2),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) => setState(() => _selectedIndex = index),
            leading: IconButton(
              icon: Icon(_isExtended ? Icons.arrow_back_ios : Icons.menu, color: const Color(0xFF3E2723)),
              onPressed: () => setState(() => _isExtended = !_isExtended),
            ),
            unselectedIconTheme: const IconThemeData(color: Colors.brown, opacity: 0.5),
            selectedIconTheme: const IconThemeData(color: Color(0xFF3E2723), size: 28),
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: Text("Home")),
              NavigationRailDestination(icon: Icon(Icons.search), label: Text("Search")),
              NavigationRailDestination(icon: Icon(Icons.favorite_border), label: Text("Saved")),
              NavigationRailDestination(icon: Icon(Icons.person_outline), label: Text("Account")),
            ],
          ),

          // --- MAIN CONTENT AREA ---
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 10, right: 10),
              decoration: const BoxDecoration(
                color: Colors.white, // White card for content
                borderRadius: BorderRadius.all(Radius.circular(40)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(40)),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: _pages[_selectedIndex],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BagPage extends StatelessWidget {
  const BagPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Featured collection", style: TextStyle(color: Colors.brown, fontSize: 14)),
          const Text(
            "TIVRA\nCollection",
            style: TextStyle(
              fontSize: 32, 
              fontWeight: FontWeight.bold, 
              color: Color(0xFF3E2723),
              height: 1.1,
            ),
          ),
          const SizedBox(height: 20),
          
          // Image Container matching your reference
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFEADFD4),
              borderRadius: BorderRadius.circular(30),
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1586776977607-310e9c725c37?w=500'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 30),
          
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("New Arrivals", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
              Text("View all", style: TextStyle(color: Colors.brown, decoration: TextDecoration.underline)),
            ],
          ),
          const SizedBox(height: 20),
          
          // Small items list
          SizedBox(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                SmallProductCard(name: "Face Palette", color: Color(0xFFF2E8DF)),
                SmallProductCard(name: "Concealer", color: Color(0xFFEADFD4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SmallProductCard extends StatelessWidget {
  final String name;
  final Color color;
  const SmallProductCard({super.key, required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(child: Text(name, style: const TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.w600))),
    );
  }
}