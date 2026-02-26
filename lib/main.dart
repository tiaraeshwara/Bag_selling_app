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

class BagPage extends StatefulWidget {
  const BagPage({super.key});

  @override
  State<BagPage> createState() => _BagPageState();
}

class _BagPageState extends State<BagPage> {
  final Map<String, int> _selectedCounts = {};
  final Map<String, ArrivalBag> _selectedItems = {};

  int get _totalBill {
    int total = 0;
    _selectedCounts.forEach((name, quantity) {
      final ArrivalBag? item = _selectedItems[name];
      if (item != null) {
        total += item.price * quantity;
      }
    });
    return total;
  }

  void _addSelectedItem(ArrivalBag item) {
    setState(() {
      _selectedItems[item.name] = item;
      _selectedCounts[item.name] = (_selectedCounts[item.name] ?? 0) + 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} added to bill'),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  Future<void> _openPaymentFlow() async {
    if (_selectedCounts.isEmpty) return;

    final TextEditingController bankController = TextEditingController();
    final TextEditingController accountController = TextEditingController();
    final TextEditingController holderController = TextEditingController();

    final bool? hasBankDetails = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Bank Details'),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: bankController,
                  decoration: const InputDecoration(labelText: 'Bank Name'),
                ),
                TextField(
                  controller: accountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Account Number',
                  ),
                ),
                TextField(
                  controller: holderController,
                  decoration: const InputDecoration(
                    labelText: 'Account Holder Name',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (bankController.text.trim().isEmpty ||
                    accountController.text.trim().isEmpty ||
                    holderController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all bank details'),
                    ),
                  );
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text('Save Details'),
            ),
          ],
        );
      },
    );

    if (hasBankDetails != true || !mounted) return;

    final bool? confirmPay = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Payment'),
          content: Text('Are you sure to pay \$$_totalBill ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Pay Now'),
            ),
          ],
        );
      },
    );

    if (confirmPay == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment successful: \$$_totalBill paid')),
      );
      setState(() {
        _selectedCounts.clear();
        _selectedItems.clear();
      });
    }
  }

  Widget _buildBillingSection() {
    return GlassCard(
      borderRadius: BorderRadius.circular(24),
      tint: Colors.white.withOpacity(0.26),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selected Items',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3E2723),
            ),
          ),
          const SizedBox(height: 10),
          if (_selectedCounts.isEmpty)
            const Text(
              'No items selected yet. Tap Buy Now to add products.',
              style: TextStyle(
                color: Color(0xFF5D4037),
                fontWeight: FontWeight.w500,
              ),
            )
          else
            ..._selectedCounts.entries.map((entry) {
              final ArrivalBag? item = _selectedItems[entry.key];
              if (item == null) return const SizedBox.shrink();
              final int lineTotal = item.price * entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.name} x${entry.value}',
                        style: const TextStyle(
                          color: Color(0xFF4E342E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '\$$lineTotal',
                      style: const TextStyle(
                        color: Color(0xFF4E342E),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 10),
          const Divider(color: Color(0x4D3E2723)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Bill',
                style: TextStyle(
                  color: Color(0xFF3E2723),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '\$$_totalBill',
                style: const TextStyle(
                  color: Color(0xFF3E2723),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedCounts.isEmpty ? null : _openPaymentFlow,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF8EFE8),
                foregroundColor: const Color(0xFF5D4037),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Payment Method',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
          NewArrivalSection(onBuyNow: _addSelectedItem),

          const SizedBox(height: 24),
          _buildBillingSection(),

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

class NewArrivalSection extends StatefulWidget {
  final ValueChanged<ArrivalBag> onBuyNow;

  const NewArrivalSection({super.key, required this.onBuyNow});

  @override
  State<NewArrivalSection> createState() => _NewArrivalSectionState();
}

class _NewArrivalSectionState extends State<NewArrivalSection> {
  late final ScrollController _scrollController;

  static const double _cardWidth = 240;
  static const double _cardGap = 14;

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
    ArrivalBag(
      name: 'Avery',
      imagePath: 'assets/bag1.jpg',
      price: 240,
      category: 'Tote Bag',
      material: 'Canvas Leather Mix',
      color: 'Coffee Brown',
    ),
    ArrivalBag(
      name: 'Camila',
      imagePath: 'assets/bag2.jpg',
      price: 210,
      category: 'Crossbody Bag',
      material: 'Faux Leather',
      color: 'Nude Beige',
    ),
    ArrivalBag(
      name: 'Elise',
      imagePath: 'assets/bag3.jpg',
      price: 230,
      category: 'Satchel',
      material: 'Soft Grain Leather',
      color: 'Walnut Brown',
    ),
    ArrivalBag(
      name: 'Mila',
      imagePath: 'assets/bag4.jpg',
      price: 260,
      category: 'Top Handle Bag',
      material: 'Premium PU',
      color: 'Caramel',
    ),
    ArrivalBag(
      name: 'Zoe',
      imagePath: 'assets/bag8.jpg',
      price: 245,
      category: 'Mini Bag',
      material: 'Vegan Leather',
      color: 'Dark Mocha',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollTo(bool isNext) {
    if (!_scrollController.hasClients) return;

    final double step = _cardWidth + _cardGap;
    final double current = _scrollController.offset;
    final double target = isNext ? current + step : current - step;
    final double clampedTarget = target.clamp(
      0,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(
      clampedTarget,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: BorderRadius.circular(28),
      tint: const Color(0x99B89A8A),
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
                  color: Color(0xFFF8EFE8),
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
                  color: Color(0xFFF8EFE8),
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
                _ArrowCircle(
                  icon: Icons.arrow_back,
                  onTap: () => _scrollTo(false),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ListView.separated(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, index) => ArrivalBagCard(
                      item: _items[index],
                      onBuyNow: () => widget.onBuyNow(_items[index]),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _ArrowCircle(
                  icon: Icons.arrow_forward,
                  onTap: () => _scrollTo(true),
                ),
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
  final VoidCallback onBuyNow;

  const ArrivalBagCard({super.key, required this.item, required this.onBuyNow});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: GlassCard(
        borderRadius: BorderRadius.circular(24),
        tint: const Color(0x88D9C7BB),
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
                  color: Color(0xFF5D4037),
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
                color: Color(0xFF3E2723),
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Price: \$${item.price}',
              style: const TextStyle(
                color: Color(0xFF4E342E),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Category: ${item.category}',
              style: const TextStyle(
                color: Color(0xFF4E342E),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Material: ${item.material}',
              style: const TextStyle(
                color: Color(0xFF4E342E),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Color: ${item.color}',
              style: const TextStyle(
                color: Color(0xFF4E342E),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onBuyNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF8EFE8),
                  foregroundColor: const Color(0xFF5D4037),
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
  final VoidCallback onTap;

  const _ArrowCircle({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF5D4037)),
      ),
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
