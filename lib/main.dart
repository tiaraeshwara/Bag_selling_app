import 'dart:ui';

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
    const Center(
      child: Text("Search Page", style: TextStyle(color: Color(0xFF3E2723))),
    ),
    const Center(
      child: Text("Favorites", style: TextStyle(color: Color(0xFF3E2723))),
    ),
    const Center(
      child: Text("Profile", style: TextStyle(color: Color(0xFF3E2723))),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF1E8E1), Color(0xFFE2D2C6), Color(0xFFD3C2B8)],
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                child: GlassCard(
                  borderRadius: BorderRadius.circular(28),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: NavigationRail(
                    extended: _isExtended,
                    backgroundColor: Colors.transparent,
                    indicatorColor: Colors.white.withOpacity(0.45),
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: (int index) =>
                        setState(() => _selectedIndex = index),
                    leading: IconButton(
                      icon: Icon(
                        _isExtended ? Icons.arrow_back_ios : Icons.menu,
                        color: const Color(0xFF3E2723),
                      ),
                      onPressed: () =>
                          setState(() => _isExtended = !_isExtended),
                    ),
                    unselectedIconTheme: const IconThemeData(
                      color: Colors.brown,
                      opacity: 0.6,
                    ),
                    selectedIconTheme: const IconThemeData(
                      color: Color(0xFF3E2723),
                      size: 28,
                    ),
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home),
                        label: Text("Home"),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.search),
                        label: Text("Search"),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.favorite_border),
                        label: Text("Saved"),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.person_outline),
                        label: Text("Account"),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                    left: 10,
                    right: 10,
                  ),
                  child: GlassCard(
                    borderRadius: BorderRadius.circular(40),
                    padding: EdgeInsets.zero,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: _pages[_selectedIndex],
                    ),
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

class BagPage extends StatelessWidget {
  const BagPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Featured collection",
            style: TextStyle(color: Colors.brown, fontSize: 14),
          ),
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

          // Search bar section
          GlassCard(
            borderRadius: BorderRadius.circular(18),
            tint: Colors.white.withOpacity(0.24),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: const TextField(
              style: TextStyle(color: Color(0xFF3E2723)),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Color(0xFF3E2723)),
                hintText: 'Search bags',
                hintStyle: TextStyle(color: Colors.brown),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Image Container matching your reference
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Container(
              height: 500,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/bag7.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.12),
                      Colors.black.withOpacity(0.10),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "New Arrivals",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                ),
              ),
              Text(
                "View all",
                style: TextStyle(
                  color: Colors.brown,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // New arrivals detailed cards section
          const NewArrivalSection(),

          const SizedBox(height: 30),

          // Small items list
          SizedBox(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                SmallProductCard(
                  name: "Face Palette",
                  color: Color(0xFFF2E8DF),
                ),
                SmallProductCard(name: "Concealer", color: Color(0xFFEADFD4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NewArrivalSection extends StatelessWidget {
  const NewArrivalSection({super.key});

  static const List<ArrivalBag> _items = [
    ArrivalBag(
      name: 'Sabrina',
      imagePath: 'assets/bag6.jpg',
      price: 220,
      category: 'Handbag',
      material: 'Vegan Leather',
      color: 'Silver Black',
    ),
    ArrivalBag(
      name: 'Brielle',
      imagePath: 'assets/bag5.jpg',
      price: 200,
      category: 'Shoulder Bag',
      material: 'PU Leather',
      color: 'Pearl White',
    ),
    ArrivalBag(
      name: 'Naomi',
      imagePath: 'assets/bag7.jpg',
      price: 255,
      category: 'Bowling Bag',
      material: 'Premium Synthetic',
      color: 'Rose Pink',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: BorderRadius.circular(28),
      tint: const Color(0x66D48AA3),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "Bloggers' Choice",
                style: TextStyle(
                  color: Color(0xFFF6E6EB),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 16),
              Text(
                "NEW ARRIVALS",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(width: 16),
              Text(
                "Bestsellers",
                style: TextStyle(
                  color: Color(0xFFF6E6EB),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 420,
            child: Row(
              children: [
                _ArrowCircle(icon: Icons.arrow_back),
                const SizedBox(width: 12),
                Expanded(
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, index) =>
                        ArrivalBagCard(item: _items[index]),
                  ),
                ),
                const SizedBox(width: 12),
                _ArrowCircle(icon: Icons.arrow_forward),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ArrivalBagCard extends StatelessWidget {
  final ArrivalBag item;

  const ArrivalBagCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: GlassCard(
        borderRadius: BorderRadius.circular(24),
        tint: const Color(0x66F1C4D3),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.55),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'ECO',
                style: TextStyle(
                  color: Color(0xFF8D4E64),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: Image.asset(item.imagePath, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Price: \$${item.price}',
              style: const TextStyle(
                color: Color(0xFFFCEFF4),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Category: ${item.category}',
              style: const TextStyle(
                color: Color(0xFFFCEFF4),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Material: ${item.material}',
              style: const TextStyle(
                color: Color(0xFFFCEFF4),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Color: ${item.color}',
              style: const TextStyle(
                color: Color(0xFFFCEFF4),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF8D4E64),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Buy Now',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArrowCircle extends StatelessWidget {
  final IconData icon;

  const _ArrowCircle({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}

class ArrivalBag {
  final String name;
  final String imagePath;
  final int price;
  final String category;
  final String material;
  final String color;

  const ArrivalBag({
    required this.name,
    required this.imagePath,
    required this.price,
    required this.category,
    required this.material,
    required this.color,
  });
}

class SmallProductCard extends StatelessWidget {
  final String name;
  final Color color;
  const SmallProductCard({super.key, required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Padding(
        padding: const EdgeInsets.only(right: 15),
        child: GlassCard(
          borderRadius: BorderRadius.circular(20),
          tint: color.withOpacity(0.28),
          child: Center(
            child: Text(
              name,
              style: const TextStyle(
                color: Color(0xFF3E2723),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassImageTile extends StatelessWidget {
  final String imagePath;
  final EdgeInsetsGeometry? margin;

  const GlassImageTile({super.key, required this.imagePath, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: GlassCard(
        borderRadius: BorderRadius.circular(20),
        padding: EdgeInsets.zero,
        tint: Colors.white.withOpacity(0.08),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(imagePath, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.10),
                    Colors.transparent,
                    Colors.black.withOpacity(0.06),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final Color tint;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.padding = const EdgeInsets.all(12),
    this.tint = const Color(0x33FFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: borderRadius,
            border: Border.all(color: Colors.white.withOpacity(0.35), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
