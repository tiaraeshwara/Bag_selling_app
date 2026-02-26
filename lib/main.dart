import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD7B9AB),
          surface: const Color(0xFFFDFBF9),
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.35),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const AuthGateway(),
    );
  }
}

class AuthGateway extends StatefulWidget {
  const AuthGateway({super.key});

  @override
  State<AuthGateway> createState() => _AuthGatewayState();
}

class _AuthGatewayState extends State<AuthGateway> {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _currentUsernameKey = 'current_username';
  static const String _savedFirstNameKey = 'saved_first_name';
  static const String _savedLastNameKey = 'saved_last_name';
  static const String _savedUsernameKey = 'saved_username';
  static const String _savedPasswordKey = 'saved_password';

  bool _isLoading = true;
  bool _isAuthenticated = false;
  String? _currentUsername;
  String? _savedFirstName;
  String? _savedLastName;
  String? _savedUsername;
  String? _savedPassword;

  @override
  void initState() {
    super.initState();
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _isAuthenticated = prefs.getBool(_isLoggedInKey) ?? false;
      _currentUsername = prefs.getString(_currentUsernameKey);
      _savedFirstName = prefs.getString(_savedFirstNameKey);
      _savedLastName = prefs.getString(_savedLastNameKey);
      _savedUsername = prefs.getString(_savedUsernameKey);
      _savedPassword = prefs.getString(_savedPasswordKey);
      _isLoading = false;
    });
  }

  Future<void> _onLogin(String username, String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_currentUsernameKey, username);

    if (!mounted) return;

    setState(() {
      _isAuthenticated = true;
      _currentUsername = username;
      _savedUsername ??= username;
      _savedPassword ??= password;
    });
  }

  Future<void> _onSignup({
    required String firstName,
    required String lastName,
    required String username,
    required String password,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_savedFirstNameKey, firstName);
    await prefs.setString(_savedLastNameKey, lastName);
    await prefs.setString(_savedUsernameKey, username);
    await prefs.setString(_savedPasswordKey, password);
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_currentUsernameKey, username);

    if (!mounted) return;

    setState(() {
      _savedFirstName = firstName;
      _savedLastName = lastName;
      _savedUsername = username;
      _savedPassword = password;
      _isAuthenticated = true;
      _currentUsername = username;
    });
  }

  Future<void> _logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.remove(_currentUsernameKey);

    if (!mounted) return;

    setState(() {
      _isAuthenticated = false;
      _currentUsername = null;
    });
  }

  Future<void> _openAuthFromTopIcon() async {
    if (_isAuthenticated) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: GlassCard(
              borderRadius: BorderRadius.circular(24),
              tint: Colors.white.withOpacity(0.20),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account',
                    style: TextStyle(
                      color: Color(0xFF3E2723),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Logged in as ${_currentUsername ?? _savedUsername ?? 'User'}',
                    style: const TextStyle(
                      color: Color(0xFF5D4037),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Close'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          await _logout();
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
      return;
    }

    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AuthSection(
          savedFirstName: _savedFirstName,
          savedLastName: _savedLastName,
          savedUsername: _savedUsername,
          savedPassword: _savedPassword,
          onLogin: _onLogin,
          onSignup: _onSignup,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return MainNavigationLayout(
      onAuthPressed: _openAuthFromTopIcon,
      isAuthenticated: _isAuthenticated,
      currentUsername: _currentUsername ?? _savedUsername,
    );
  }
}

class AuthSection extends StatefulWidget {
  final String? savedFirstName;
  final String? savedLastName;
  final String? savedUsername;
  final String? savedPassword;
  final Future<void> Function(String username, String password) onLogin;
  final Future<void> Function({
    required String firstName,
    required String lastName,
    required String username,
    required String password,
  })
  onSignup;

  const AuthSection({
    super.key,
    required this.onLogin,
    required this.onSignup,
    this.savedFirstName,
    this.savedLastName,
    this.savedUsername,
    this.savedPassword,
  });

  @override
  State<AuthSection> createState() => _AuthSectionState();
}

class _AuthSectionState extends State<AuthSection> {
  @override
  void initState() {
    super.initState();
    _loginUsernameController.text = widget.savedUsername ?? '';
    _loginPasswordController.text = widget.savedPassword ?? '';
    _firstNameController.text = widget.savedFirstName ?? '';
    _lastNameController.text = widget.savedLastName ?? '';
    _signupUsernameController.text = widget.savedUsername ?? '';
  }

  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _signupFormKey = GlobalKey<FormState>();

  final TextEditingController _loginUsernameController =
      TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _signupUsernameController =
      TextEditingController();
  final TextEditingController _signupPasswordController =
      TextEditingController();
  final TextEditingController _reEnterPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _loginUsernameController.dispose();
    _loginPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _signupUsernameController.dispose();
    _signupPasswordController.dispose();
    _reEnterPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_loginFormKey.currentState?.validate() ?? false)) {
      return;
    }

    final String username = _loginUsernameController.text.trim();
    final String password = _loginPasswordController.text.trim();

    if ((widget.savedUsername?.isNotEmpty ?? false) &&
        (widget.savedPassword?.isNotEmpty ?? false) &&
        (username != widget.savedUsername ||
            password != widget.savedPassword)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid username or password.')),
      );
      return;
    }

    await widget.onLogin(username, password);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _handleSignup() async {
    if (!(_signupFormKey.currentState?.validate() ?? false)) {
      return;
    }

    await widget.onSignup(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      username: _signupUsernameController.text.trim(),
      password: _signupPasswordController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Signup successful. You are now logged in.'),
      ),
    );

    if (mounted) Navigator.pop(context);
  }

  Future<void> _handleForgotPassword() async {
    final TextEditingController forgotController = TextEditingController(
      text: _loginUsernameController.text.trim(),
    );

    final bool? sent = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GlassCard(
            borderRadius: BorderRadius.circular(22),
            tint: Colors.white.withOpacity(0.20),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Forgot Password',
                  style: TextStyle(
                    color: Color(0xFF3E2723),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: forgotController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    hintText: 'Enter your username',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (forgotController.text.trim().isEmpty) {
                          return;
                        }
                        Navigator.pop(context, true);
                      },
                      child: const Text('Send'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (sent == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password reset instructions sent for ${forgotController.text.trim()}.',
          ),
        ),
      );
    }

    forgotController.dispose();
  }

  String? _requiredValidator(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: GlassCard(
                  borderRadius: BorderRadius.circular(30),
                  tint: Colors.white.withOpacity(0.24),
                  padding: const EdgeInsets.all(20),
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome',
                          style: TextStyle(
                            color: Color(0xFF2F241F),
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Login or create your account to continue.',
                          style: TextStyle(
                            color: Color(0xFF6C5A48),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.30),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const TabBar(
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: BoxDecoration(
                              color: Color(0xFF6C5A48),
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            labelColor: Color(0xFFF7F2E9),
                            unselectedLabelColor: Color(0xFF6C5A48),
                            tabs: [
                              Tab(text: 'Login'),
                              Tab(text: 'Sign Up'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 420,
                          child: TabBarView(
                            children: [
                              Form(
                                key: _loginFormKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if ((widget.savedUsername?.isNotEmpty ??
                                        false))
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: Text(
                                          'Signed up username: ${widget.savedUsername}',
                                          style: const TextStyle(
                                            color: Color(0xFF6C5A48),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    TextFormField(
                                      controller: _loginUsernameController,
                                      decoration: const InputDecoration(
                                        labelText: 'User Name',
                                      ),
                                      validator: (value) => _requiredValidator(
                                        value,
                                        'User Name',
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: _loginPasswordController,
                                      obscureText: true,
                                      decoration: const InputDecoration(
                                        labelText: 'Password',
                                      ),
                                      validator: (value) =>
                                          _requiredValidator(value, 'Password'),
                                    ),
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: _handleForgotPassword,
                                        child: const Text('Forgot Password?'),
                                      ),
                                    ),
                                    const Spacer(),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: _handleLogin,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFF8EFE8,
                                          ),
                                          foregroundColor: const Color(
                                            0xFF5D4037,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Login',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Form(
                                key: _signupFormKey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _firstNameController,
                                      decoration: const InputDecoration(
                                        labelText: 'First Name',
                                      ),
                                      validator: (value) => _requiredValidator(
                                        value,
                                        'First Name',
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextFormField(
                                      controller: _lastNameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Last Name',
                                      ),
                                      validator: (value) => _requiredValidator(
                                        value,
                                        'Last Name',
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextFormField(
                                      controller: _signupUsernameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Username',
                                      ),
                                      validator: (value) =>
                                          _requiredValidator(value, 'Username'),
                                    ),
                                    const SizedBox(height: 10),
                                    TextFormField(
                                      controller: _signupPasswordController,
                                      obscureText: true,
                                      decoration: const InputDecoration(
                                        labelText: 'Password',
                                      ),
                                      validator: (value) =>
                                          _requiredValidator(value, 'Password'),
                                    ),
                                    const SizedBox(height: 10),
                                    TextFormField(
                                      controller: _reEnterPasswordController,
                                      obscureText: true,
                                      decoration: const InputDecoration(
                                        labelText: 'Re-enter Password',
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Re-enter Password is required';
                                        }
                                        if (value !=
                                            _signupPasswordController.text) {
                                          return 'Passwords do not match';
                                        }
                                        return null;
                                      },
                                    ),
                                    const Spacer(),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: _handleSignup,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFF8EFE8,
                                          ),
                                          foregroundColor: const Color(
                                            0xFF5D4037,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Sign Up',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MainNavigationLayout extends StatefulWidget {
  final VoidCallback onAuthPressed;
  final bool isAuthenticated;
  final String? currentUsername;

  const MainNavigationLayout({
    super.key,
    required this.onAuthPressed,
    required this.isAuthenticated,
    this.currentUsername,
  });

  @override
  State<MainNavigationLayout> createState() => _MainNavigationLayoutState();
}

class _MainNavigationLayoutState extends State<MainNavigationLayout> {
  int _selectedIndex = 0;
  final GlobalKey<_BagPageState> _bagPageKey = GlobalKey<_BagPageState>();
  final Map<String, ArrivalBag> _favoriteItems = {};

  // Pages matching the beige/brown theme
  List<Widget> get _pages => [
    BagPage(
      key: _bagPageKey,
      onToggleFavorite: _toggleFavorite,
      isFavorite: _isFavorite,
    ), // Home/Bag view
    const Center(
      child: Text("Search Page", style: TextStyle(color: Color(0xFF3E2723))),
    ),
    SavedPage(favoriteItems: _favoriteItems.values.toList(growable: false)),
    Center(
      child: Text(
        widget.isAuthenticated
            ? 'Profile: ${widget.currentUsername ?? 'User'}'
            : 'Profile',
        style: const TextStyle(color: Color(0xFF3E2723)),
      ),
    ),
  ];

  bool _isFavorite(String bagName) => _favoriteItems.containsKey(bagName);

  void _toggleFavorite(ArrivalBag item) {
    setState(() {
      if (_favoriteItems.containsKey(item.name)) {
        _favoriteItems.remove(item.name);
      } else {
        _favoriteItems[item.name] = item;
      }
    });
  }

  void _openSearchFromNavigation() {
    setState(() => _selectedIndex = 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bagPageKey.currentState?.openSearchPopupAndGoToNewArrivals();
    });
  }

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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 4),
                child: GlassCard(
                  borderRadius: BorderRadius.circular(28),
                  tint: const Color(0xEAF4F0E8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final bool isCompact = constraints.maxWidth < 760;

                      if (isCompact) {
                        return SizedBox(
                          height: 44,
                          child: Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Text(
                                  'TIVRA',
                                  style: TextStyle(
                                    color: Color(0xFF2F241F),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: _openSearchFromNavigation,
                                iconSize: 22,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints.tightFor(
                                  width: 34,
                                  height: 34,
                                ),
                                icon: const Icon(Icons.search),
                                color: const Color(0xFF6C5A48),
                                tooltip: 'Search',
                              ),
                              IconButton(
                                onPressed: () =>
                                    setState(() => _selectedIndex = 2),
                                iconSize: 22,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints.tightFor(
                                  width: 34,
                                  height: 34,
                                ),
                                icon: const Icon(Icons.favorite_border),
                                color: const Color(0xFF6C5A48),
                                tooltip: 'Saved',
                              ),
                              IconButton(
                                onPressed: widget.onAuthPressed,
                                iconSize: 22,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints.tightFor(
                                  width: 34,
                                  height: 34,
                                ),
                                icon: Icon(
                                  widget.isAuthenticated
                                      ? Icons.verified_user_outlined
                                      : Icons.login,
                                ),
                                color: const Color(0xFF6C5A48),
                                tooltip: widget.isAuthenticated
                                    ? 'Account'
                                    : 'Login / Signup',
                              ),
                            ],
                          ),
                        );
                      }

                      return SizedBox(
                        height: 52,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 6, right: 18),
                              child: Text(
                                'TIVRA',
                                style: TextStyle(
                                  color: Color(0xFF2F241F),
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 10,
                                children: [
                                  _TopNavTextItem(
                                    label: 'HOME',
                                    isSelected: _selectedIndex == 0,
                                    onTap: () =>
                                        setState(() => _selectedIndex = 0),
                                  ),
                                  _TopNavTextItem(
                                    label: 'SEARCH',
                                    isSelected: false,
                                    onTap: _openSearchFromNavigation,
                                  ),
                                  _TopNavTextItem(
                                    label: 'SAVED',
                                    isSelected: _selectedIndex == 2,
                                    onTap: () =>
                                        setState(() => _selectedIndex = 2),
                                  ),
                                  _TopNavTextItem(
                                    label: 'ACCOUNT',
                                    isSelected: _selectedIndex == 3,
                                    onTap: () =>
                                        setState(() => _selectedIndex = 3),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            if (widget.isAuthenticated)
                              SizedBox(
                                width: 110,
                                child: Text(
                                  widget.currentUsername ?? 'User',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    color: Color(0xFF5D4037),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            if (widget.isAuthenticated)
                              const SizedBox(width: 6),
                            IconButton(
                              onPressed: widget.onAuthPressed,
                              icon: Icon(
                                widget.isAuthenticated
                                    ? Icons.verified_user_outlined
                                    : Icons.login,
                              ),
                              color: const Color(0xFF6C5A48),
                              tooltip: widget.isAuthenticated
                                  ? 'Account'
                                  : 'Login / Signup',
                            ),
                            IconButton(
                              onPressed: () =>
                                  setState(() => _selectedIndex = 2),
                              icon: const Icon(Icons.favorite_border),
                              color: const Color(0xFF6C5A48),
                              tooltip: 'Saved',
                            ),
                            IconButton(
                              onPressed: () =>
                                  setState(() => _selectedIndex = 0),
                              icon: const Icon(Icons.shopping_bag_outlined),
                              color: const Color(0xFF6C5A48),
                              tooltip: 'Shop',
                            ),
                          ],
                        ),
                      );
                    },
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

class _TopNavTextItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TopNavTextItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C5A48) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? const Color(0xFFF7F2E9)
                : const Color(0xFF6C5A48),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.7,
          ),
        ),
      ),
    );
  }
}

class SavedPage extends StatelessWidget {
  final List<ArrivalBag> favoriteItems;

  const SavedPage({super.key, required this.favoriteItems});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: GlassCard(
        borderRadius: BorderRadius.circular(30),
        tint: Colors.white.withOpacity(0.22),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Saved Favorites',
              style: TextStyle(
                color: Color(0xFF3E2723),
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: favoriteItems.isEmpty
                  ? const Center(
                      child: Text(
                        'No favorite items yet. Tap hearts in New Arrivals.',
                        style: TextStyle(
                          color: Color(0xFF5D4037),
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.separated(
                      itemCount: favoriteItems.length,
                      separatorBuilder: (_, __) =>
                          const Divider(color: Color(0x333E2723), height: 14),
                      itemBuilder: (context, index) {
                        final ArrivalBag item = favoriteItems[index];
                        return ListTile(
                          onTap: () {
                            showDialog<void>(
                              context: context,
                              builder: (dialogContext) {
                                return Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: GlassCard(
                                    borderRadius: BorderRadius.circular(26),
                                    tint: Colors.white.withOpacity(0.18),
                                    padding: const EdgeInsets.all(16),
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 520,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            child: AspectRatio(
                                              aspectRatio: 16 / 10,
                                              child: Image.asset(
                                                item.imagePath,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          Text(
                                            item.name,
                                            style: const TextStyle(
                                              color: Color(0xFF3E2723),
                                              fontSize: 28,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Price: \$${item.price}',
                                            style: const TextStyle(
                                              color: Color(0xFF4E342E),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            'Category: ${item.category}',
                                            style: const TextStyle(
                                              color: Color(0xFF5D4037),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            'Material: ${item.material}',
                                            style: const TextStyle(
                                              color: Color(0xFF5D4037),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            'Color: ${item.color}',
                                            style: const TextStyle(
                                              color: Color(0xFF5D4037),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(dialogContext),
                                              child: const Text('Close'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          contentPadding: EdgeInsets.zero,
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              item.imagePath,
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            item.name,
                            style: const TextStyle(
                              color: Color(0xFF3E2723),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(
                            '${item.category} • ${item.color}',
                            style: const TextStyle(
                              color: Color(0xFF6C5A48),
                              fontSize: 12,
                            ),
                          ),
                          trailing: Text(
                            '\$${item.price}',
                            style: const TextStyle(
                              color: Color(0xFF4E342E),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class BagPage extends StatefulWidget {
  final ValueChanged<ArrivalBag> onToggleFavorite;
  final bool Function(String bagName) isFavorite;

  const BagPage({
    super.key,
    required this.onToggleFavorite,
    required this.isFavorite,
  });

  @override
  State<BagPage> createState() => _BagPageState();
}

class _BagPageState extends State<BagPage> {
  final Map<String, int> _selectedCounts = {};
  final Map<String, ArrivalBag> _selectedItems = {};
  final GlobalKey _newArrivalsSectionKey = GlobalKey();

  Future<void> openSearchPopupAndGoToNewArrivals() async {
    await _scrollToNewArrivalsSection();
    if (!mounted) return;
    await _showBagSearchPopup();
  }

  Future<void> _scrollToNewArrivalsSection() async {
    final BuildContext? sectionContext = _newArrivalsSectionKey.currentContext;
    if (sectionContext == null) return;

    await Scrollable.ensureVisible(
      sectionContext,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      alignment: 0.08,
    );
  }

  Future<void> _showBagSearchPopup() async {
    if (!mounted) return;

    final TextEditingController searchController = TextEditingController();
    String query = '';

    List<ArrivalBag> _matchingBags(String value) {
      final String normalized = value.trim().toLowerCase();
      if (normalized.isEmpty) {
        return _NewArrivalSectionState._items.take(8).toList();
      }

      return _NewArrivalSectionState._items.where((bag) {
        return bag.name.toLowerCase().contains(normalized) ||
            bag.category.toLowerCase().contains(normalized) ||
            bag.color.toLowerCase().contains(normalized) ||
            bag.material.toLowerCase().contains(normalized);
      }).toList();
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GlassCard(
            borderRadius: BorderRadius.circular(24),
            tint: Colors.white.withOpacity(0.18),
            padding: const EdgeInsets.all(16),
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                final List<ArrivalBag> suggestions = _matchingBags(query);

                return SizedBox(
                  width: 540,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 500),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Search Bags',
                          style: TextStyle(
                            color: Color(0xFF3E2723),
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: searchController,
                          autofocus: true,
                          onChanged: (value) {
                            setDialogState(() {
                              query = value;
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Type bag name, color, category...',
                            prefixIcon: Icon(Icons.search_rounded),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: suggestions.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No similar bags found.',
                                    style: TextStyle(
                                      color: Color(0xFF5D4037),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: suggestions.length,
                                  separatorBuilder: (_, __) => const Divider(
                                    color: Color(0x333E2723),
                                    height: 10,
                                  ),
                                  itemBuilder: (context, index) {
                                    final ArrivalBag bag = suggestions[index];
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.asset(
                                          bag.imagePath,
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      title: Text(
                                        bag.name,
                                        style: const TextStyle(
                                          color: Color(0xFF3E2723),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${bag.category} • ${bag.color}',
                                        style: const TextStyle(
                                          color: Color(0xFF6C5A48),
                                          fontSize: 12,
                                        ),
                                      ),
                                      trailing: Text(
                                        '\$${bag.price}',
                                        style: const TextStyle(
                                          color: Color(0xFF4E342E),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Close'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    searchController.dispose();
  }

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

  int get _selectedItemCount {
    int count = 0;
    for (final int quantity in _selectedCounts.values) {
      count += quantity;
    }
    return count;
  }

  void _addSelectedItem(ArrivalBag item) {
    setState(() {
      _selectedItems[item.name] = item;
      _selectedCounts[item.name] = (_selectedCounts[item.name] ?? 0) + 1;
    });

    _showSelectedItemsPopup();
  }

  void _increaseItem(String itemName) {
    setState(() {
      _selectedCounts[itemName] = (_selectedCounts[itemName] ?? 0) + 1;
    });
  }

  void _decreaseItem(String itemName) {
    setState(() {
      final int currentQty = _selectedCounts[itemName] ?? 0;
      if (currentQty <= 1) {
        _selectedCounts.remove(itemName);
        _selectedItems.remove(itemName);
      } else {
        _selectedCounts[itemName] = currentQty - 1;
      }
    });
  }

  void _removeItem(String itemName) {
    setState(() {
      _selectedCounts.remove(itemName);
      _selectedItems.remove(itemName);
    });
  }

  Future<void> _showSelectedItemsPopup() async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GlassCard(
            borderRadius: BorderRadius.circular(24),
            tint: Colors.white.withOpacity(0.18),
            padding: const EdgeInsets.all(18),
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                return SizedBox(
                  width: 520,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                      SingleChildScrollView(
                        child: _buildBillingSection(
                          isPopup: true,
                          onChanged: () => setDialogState(() {}),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Close'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
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
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GlassCard(
            borderRadius: BorderRadius.circular(22),
            tint: Colors.white.withOpacity(0.20),
            padding: const EdgeInsets.all(18),
            child: SizedBox(
              width: 380,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Bank Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: bankController,
                    decoration: const InputDecoration(labelText: 'Bank Name'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: accountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Account Number',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: holderController,
                    decoration: const InputDecoration(
                      labelText: 'Account Holder Name',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (hasBankDetails != true || !mounted) return;

    final bool? confirmPay = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GlassCard(
            borderRadius: BorderRadius.circular(22),
            tint: Colors.white.withOpacity(0.20),
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Confirm Payment',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Are you sure to pay \$$_totalBill ?',
                  style: const TextStyle(
                    color: Color(0xFF4E342E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('No'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Pay Now'),
                    ),
                  ],
                ),
              ],
            ),
          ),
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

  Widget _buildBillingSection({VoidCallback? onChanged, bool isPopup = false}) {
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
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              color: Color(0xFF4E342E),
                              fontWeight: FontWeight.w700,
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
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            _decreaseItem(item.name);
                            onChanged?.call();
                          },
                          icon: const Icon(Icons.remove_circle_outline),
                          color: const Color(0xFF5D4037),
                          visualDensity: VisualDensity.compact,
                        ),
                        Text(
                          'Qty: ${entry.value}',
                          style: const TextStyle(
                            color: Color(0xFF4E342E),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _increaseItem(item.name);
                            onChanged?.call();
                          },
                          icon: const Icon(Icons.add_circle_outline),
                          color: const Color(0xFF5D4037),
                          visualDensity: VisualDensity.compact,
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {
                            _removeItem(item.name);
                            onChanged?.call();
                          },
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Remove'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF5D4037),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0x333E2723), height: 6),
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
              onPressed: _selectedCounts.isEmpty
                  ? null
                  : () {
                      if (isPopup) {
                        Navigator.of(context).pop();
                      }
                      _openPaymentFlow();
                    },
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
    return LayoutBuilder(
      builder: (context, pageConstraints) {
        final bool isCompactPage = pageConstraints.maxWidth < 700;
        final double pagePadding = isCompactPage ? 14 : 30;
        final double heroHeight = isCompactPage ? 320 : 500;
        final bool showLeftFilters = pageConstraints.maxWidth >= 1080;
        final double topSectionMaxHeight = heroHeight + 150;

        final Widget topContent = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final bool isCompact = constraints.maxWidth < 560;

                final Widget searchField = GlassCard(
                  borderRadius: BorderRadius.circular(22),
                  tint: Colors.white.withOpacity(0.22),
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.45)),
                    ),
                    child: TextField(
                      readOnly: true,
                      onTap: openSearchPopupAndGoToNewArrivals,
                      style: const TextStyle(
                        color: Color(0xFF4E342E),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      cursorColor: const Color(0xFF5D4037),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                        hintText: 'Tap to search bags',
                        hintStyle: TextStyle(
                          color: Color(0xFF6C5A48),
                          fontSize: 15,
                          letterSpacing: 0.3,
                        ),
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Icon(
                            Icons.search_rounded,
                            size: 26,
                            color: Color(0xFF4E342E),
                          ),
                        ),
                        prefixIconConstraints: BoxConstraints(
                          minWidth: 44,
                          minHeight: 40,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                );

                final Widget cartButton = Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GlassCard(
                      borderRadius: BorderRadius.circular(14),
                      tint: Colors.white.withOpacity(0.28),
                      padding: EdgeInsets.zero,
                      child: IconButton(
                        onPressed: _showSelectedItemsPopup,
                        icon: const Icon(
                          Icons.shopping_bag_outlined,
                          color: Color(0xFF3E2723),
                        ),
                        tooltip: 'Open selected items',
                      ),
                    ),
                    if (_selectedItemCount > 0)
                      Positioned(
                        right: -4,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5D4037),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$_selectedItemCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                );

                return isCompact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Featured collection",
                                style: TextStyle(
                                  color: Colors.brown,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                "TIVRA\nCollection",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3E2723),
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: searchField),
                              const SizedBox(width: 10),
                              cartButton,
                            ],
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Featured collection",
                                style: TextStyle(
                                  color: Colors.brown,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                "TIVRA\nCollection",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3E2723),
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              SizedBox(width: 210, child: searchField),
                              const SizedBox(width: 10),
                              cartButton,
                            ],
                          ),
                        ],
                      );
              },
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                height: heroHeight,
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
          ],
        );

        final Widget bottomContent = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 12,
              runSpacing: 6,
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
            KeyedSubtree(
              key: _newArrivalsSectionKey,
              child: NewArrivalSection(
                onBuyNow: _addSelectedItem,
                onToggleFavorite: widget.onToggleFavorite,
                isFavorite: widget.isFavorite,
              ),
            ),
            const SizedBox(height: 30),
            BagDescriptionSection(isCompact: isCompactPage),
            const SizedBox(height: 30),
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
        );

        if (!showLeftFilters) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [topContent, const SizedBox(height: 30), bottomContent],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 252,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: topSectionMaxHeight,
                      ),
                      child: SingleChildScrollView(
                        child: const FiltersSidebar(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: topContent),
                ],
              ),
              const SizedBox(height: 30),
              bottomContent,
            ],
          ),
        );
      },
    );
  }
}

class BagDescriptionSection extends StatelessWidget {
  final bool isCompact;

  const BagDescriptionSection({super.key, required this.isCompact});

  static const List<_BagStory> _stories = [
    _BagStory(
      title: 'Classic Fit Review:\nWhy TIVRA Bags Stand Out',
      description:
          'Designed for everyday elegance with premium finishing, balanced shape, and timeless style.',
      imagePath: 'assets/bag1.jpg',
    ),
    _BagStory(
      title: 'Minimal Luxury\nFor Every Look',
      description:
          'Soft material, clean silhouette, and practical inner space for your daily essentials.',
      imagePath: 'assets/bag2.jpg',
    ),
    _BagStory(
      title: 'Crafted Details\nYou Can Feel',
      description:
          'From stitching to hardware, each element is made to deliver comfort and durability.',
      imagePath: 'assets/bag3.jpg',
    ),
    _BagStory(
      title: 'Modern Shapes\nWith Premium Finish',
      description:
          'Statement-ready forms in warm tones, made to pair with both casual and formal outfits.',
      imagePath: 'assets/bag4.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(_stories.length, (index) {
        final _BagStory item = _stories[index];
        final bool reverse = index.isOdd;

        return Padding(
          padding: EdgeInsets.only(
            bottom: index == _stories.length - 1 ? 0 : 18,
          ),
          child: GlassCard(
            borderRadius: BorderRadius.circular(24),
            tint: Colors.white.withOpacity(0.24),
            padding: const EdgeInsets.all(14),
            child: isCompact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: SizedBox(
                          height: 170,
                          width: double.infinity,
                          child: _BagStoryImage(imagePath: item.imagePath),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _BagStoryText(item: item, isCompact: true),
                    ],
                  )
                : SizedBox(
                    height: 250,
                    child: Row(
                      children: reverse
                          ? [
                              Expanded(
                                child: _BagStoryImage(
                                  imagePath: item.imagePath,
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: _BagStoryText(
                                  item: item,
                                  isCompact: false,
                                ),
                              ),
                            ]
                          : [
                              Expanded(
                                child: _BagStoryText(
                                  item: item,
                                  isCompact: false,
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: _BagStoryImage(
                                  imagePath: item.imagePath,
                                ),
                              ),
                            ],
                    ),
                  ),
          ),
        );
      }),
    );
  }
}

class FiltersSidebar extends StatefulWidget {
  const FiltersSidebar({super.key});

  @override
  State<FiltersSidebar> createState() => _FiltersSidebarState();
}

class _FiltersSidebarState extends State<FiltersSidebar> {
  final Set<String> _selectedCategoryFilters = {};
  bool _inStock = false;
  bool _outOfStock = false;
  RangeValues _priceRange = const RangeValues(0, 589);
  final Set<int> _selectedColors = {};
  bool _handbags = false;
  bool _isabel = false;
  final Set<String> _expandedSections = {};

  static const List<_FilterItem> _topCategories = [
    _FilterItem('Barrel bag', 9),
    _FilterItem('Box clutch', 9),
    _FilterItem('Briefcase', 9),
    _FilterItem('Bucket bag', 9),
    _FilterItem('Clutch bag', 10),
    _FilterItem('Crossbody bag', 12),
    _FilterItem('Feature product', 9),
  ];

  static const List<Color> _palette = [
    Color(0xFFF2EFE6),
    Color(0xFFE8DFCC),
    Color(0xFFEDD8A8),
    Color(0xFF1F1F1F),
    Color(0xFF6D4C41),
    Color(0xFF8D1E1E),
    Color(0xFFE8B38C),
    Color(0xFFB71C1C),
    Color(0xFFA86C3C),
    Color(0xFFBDBDBD),
    Color(0xFFE7D8A9),
    Color(0xFFD6D6D6),
  ];

  Widget _buildFilterRow({
    required String label,
    required int count,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      children: [
        Transform.scale(
          scale: 0.9,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF6C5A48),
            side: BorderSide(color: const Color(0xFF6C5A48).withOpacity(0.35)),
            visualDensity: VisualDensity.compact,
          ),
        ),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF4E342E),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          '($count)',
          style: const TextStyle(
            color: Color(0xFF4E342E),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required Widget child,
    String? subtitle,
    VoidCallback? onReset,
  }) {
    final bool isExpanded = _expandedSections.contains(title);

    return GlassCard(
      borderRadius: BorderRadius.circular(14),
      tint: const Color(0x99F8EFE8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF3E2723),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (onReset != null)
                TextButton(onPressed: onReset, child: const Text('Reset')),
              IconButton(
                onPressed: () {
                  setState(() {
                    if (isExpanded) {
                      _expandedSections.remove(title);
                    } else {
                      _expandedSections.add(title);
                    }
                  });
                },
                icon: Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: const Color(0xFF5D4037),
                ),
                iconSize: 20,
                constraints: const BoxConstraints.tightFor(
                  width: 28,
                  height: 28,
                ),
                tooltip: isExpanded ? 'Collapse' : 'Expand',
              ),
            ],
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF6C5A48),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          if (isExpanded) ...[const SizedBox(height: 4), child],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int selectedAvailability = (_inStock ? 1 : 0) + (_outOfStock ? 1 : 0);

    return GlassCard(
      borderRadius: BorderRadius.circular(22),
      tint: const Color(0x66F8EFE8),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExpandableSection(
            title: 'Categories',
            child: Column(
              children: _topCategories.map((item) {
                final bool checked = _selectedCategoryFilters.contains(
                  item.label,
                );
                return _buildFilterRow(
                  label: item.label,
                  count: item.count,
                  value: checked,
                  onChanged: (value) {
                    setState(() {
                      if (value ?? false) {
                        _selectedCategoryFilters.add(item.label);
                      } else {
                        _selectedCategoryFilters.remove(item.label);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          _buildExpandableSection(
            title: 'Filter',
            child: const Text(
              '15 products',
              style: TextStyle(
                color: Color(0xFF4E342E),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildExpandableSection(
            title: 'Availability',
            subtitle: '$selectedAvailability selected',
            onReset: () {
              setState(() {
                _inStock = false;
                _outOfStock = false;
              });
            },
            child: Column(
              children: [
                _buildFilterRow(
                  label: 'In stock',
                  count: 15,
                  value: _inStock,
                  onChanged: (value) =>
                      setState(() => _inStock = value ?? false),
                ),
                _buildFilterRow(
                  label: 'Out of stock',
                  count: 0,
                  value: _outOfStock,
                  onChanged: (value) =>
                      setState(() => _outOfStock = value ?? false),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildExpandableSection(
            title: 'Price',
            subtitle: 'The highest price is \$589.00',
            onReset: () {
              setState(() {
                _priceRange = const RangeValues(0, 589);
              });
            },
            child: Column(
              children: [
                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: 589,
                  divisions: 50,
                  activeColor: const Color(0xFF6C5A48),
                  inactiveColor: const Color(0x336C5A48),
                  labels: RangeLabels(
                    _priceRange.start.round().toString(),
                    _priceRange.end.round().toString(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _priceRange = value;
                    });
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x99FDFBF9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0x336C5A48)),
                        ),
                        child: Text('From: \$${_priceRange.start.round()}'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x99FDFBF9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0x336C5A48)),
                        ),
                        child: Text('To: \$${_priceRange.end.round()}'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildExpandableSection(
            title: 'Color',
            subtitle: '${_selectedColors.length} selected',
            onReset: () => setState(() => _selectedColors.clear()),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(_palette.length, (index) {
                final bool selected = _selectedColors.contains(index);
                return InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _selectedColors.remove(index);
                      } else {
                        _selectedColors.add(index);
                      }
                    });
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _palette[index],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF3E2723)
                            : const Color(0x33FFFFFF),
                        width: selected ? 2 : 1,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          _buildExpandableSection(
            title: 'Category',
            subtitle: '${_handbags ? 1 : 0} selected',
            onReset: () => setState(() => _handbags = false),
            child: _buildFilterRow(
              label: 'Handbags',
              count: 15,
              value: _handbags,
              onChanged: (value) => setState(() => _handbags = value ?? false),
            ),
          ),
          const SizedBox(height: 8),
          _buildExpandableSection(
            title: 'Brand',
            subtitle: '${_isabel ? 1 : 0} selected',
            onReset: () => setState(() => _isabel = false),
            child: _buildFilterRow(
              label: 'Isabel',
              count: 15,
              value: _isabel,
              onChanged: (value) => setState(() => _isabel = value ?? false),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterItem {
  final String label;
  final int count;

  const _FilterItem(this.label, this.count);
}

class _BagStoryText extends StatelessWidget {
  final _BagStory item;
  final bool isCompact;

  const _BagStoryText({required this.item, required this.isCompact});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.title,
            style: TextStyle(
              color: Color(0xFF5A3D33),
              fontSize: isCompact ? 24 : 34,
              height: 1.08,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: isCompact ? 10 : 14),
          Text(
            item.description,
            style: TextStyle(
              color: Color(0xFF6C5A48),
              fontSize: isCompact ? 14 : 16,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _BagStoryImage extends StatelessWidget {
  final String imagePath;

  const _BagStoryImage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
      ),
    );
  }
}

class _BagStory {
  final String title;
  final String description;
  final String imagePath;

  const _BagStory({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}

class NewArrivalSection extends StatefulWidget {
  final ValueChanged<ArrivalBag> onBuyNow;
  final ValueChanged<ArrivalBag> onToggleFavorite;
  final bool Function(String bagName) isFavorite;

  const NewArrivalSection({
    super.key,
    required this.onBuyNow,
    required this.onToggleFavorite,
    required this.isFavorite,
  });

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
    ArrivalBag(
      name: 'Aria',
      imagePath: 'assets/bag9.jpg',
      price: 235,
      category: 'Crossbody Bag',
      material: 'Faux Leather',
      color: 'Sand Beige',
    ),
    ArrivalBag(
      name: 'Nova',
      imagePath: 'assets/bag10.jpg',
      price: 280,
      category: 'Shoulder Bag',
      material: 'Premium PU',
      color: 'Deep Cocoa',
    ),
    ArrivalBag(
      name: 'Luna',
      imagePath: 'assets/bag11.jpg',
      price: 215,
      category: 'Satchel',
      material: 'Soft Grain Leather',
      color: 'Ivory Cream',
    ),
    ArrivalBag(
      name: 'Skye',
      imagePath: 'assets/bag12.jpg',
      price: 248,
      category: 'Top Handle Bag',
      material: 'Vegan Leather',
      color: 'Toffee Brown',
    ),
    ArrivalBag(
      name: 'Mira',
      imagePath: 'assets/bag13.jpg',
      price: 265,
      category: 'Handbag',
      material: 'PU Leather',
      color: 'Olive Taupe',
    ),
    ArrivalBag(
      name: 'Selene',
      imagePath: 'assets/bag14.jpg',
      price: 225,
      category: 'Mini Bag',
      material: 'Premium Synthetic',
      color: 'Dusty Rose',
    ),
    ArrivalBag(
      name: 'Nyla',
      imagePath: 'assets/bag15.jpg',
      price: 255,
      category: 'Tote Bag',
      material: 'Canvas Leather Mix',
      color: 'Walnut Tan',
    ),
    ArrivalBag(
      name: 'Faye',
      imagePath: 'assets/bag16.jpg',
      price: 238,
      category: 'Bowling Bag',
      material: 'Faux Leather',
      color: 'Mocha Nude',
    ),
    ArrivalBag(
      name: 'Clara',
      imagePath: 'assets/bag17.jpg',
      price: 272,
      category: 'Shoulder Bag',
      material: 'Premium PU',
      color: 'Espresso',
    ),
    ArrivalBag(
      name: 'Isla',
      imagePath: 'assets/bag18.jpg',
      price: 242,
      category: 'Crossbody Bag',
      material: 'Vegan Leather',
      color: 'Warm Beige',
    ),
    ArrivalBag(
      name: 'Vera',
      imagePath: 'assets/bag19.jpg',
      price: 288,
      category: 'Top Handle Bag',
      material: 'Soft Grain Leather',
      color: 'Rich Caramel',
    ),
    ArrivalBag(
      name: 'Hazel',
      imagePath: 'assets/bag20.jpg',
      price: 260,
      category: 'Satchel',
      material: 'Premium Synthetic',
      color: 'Chocolate Brown',
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
          const Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 6,
            children: [
              Text(
                "Bloggers' Choice",
                style: TextStyle(
                  color: Color(0xFFF8EFE8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "NEW ARRIVALS",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
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
                      onToggleFavorite: widget.onToggleFavorite,
                      isFavorite: widget.isFavorite(_items[index].name),
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

class ArrivalBagCard extends StatefulWidget {
  final ArrivalBag item;
  final VoidCallback onBuyNow;
  final ValueChanged<ArrivalBag> onToggleFavorite;
  final bool isFavorite;

  const ArrivalBagCard({
    super.key,
    required this.item,
    required this.onBuyNow,
    required this.onToggleFavorite,
    required this.isFavorite,
  });

  @override
  State<ArrivalBagCard> createState() => _ArrivalBagCardState();
}

class _ArrivalBagCardState extends State<ArrivalBagCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -6.0 : 0.0),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          scale: _isHovered ? 1.015 : 1,
          child: SizedBox(
            width: 240,
            child: GlassCard(
              borderRadius: BorderRadius.circular(24),
              tint: _isHovered
                  ? const Color(0xA3E4D6CC)
                  : const Color(0x88D9C7BB),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _isHovered
                              ? Colors.white.withOpacity(0.72)
                              : Colors.white.withOpacity(0.55),
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
                      IconButton(
                        onPressed: () {
                          widget.onToggleFavorite(widget.item);
                        },
                        iconSize: 22,
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          widget.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: widget.isFavorite
                              ? const Color.fromARGB(255, 95, 8, 53)
                              : const Color(0xFF6C5A48),
                        ),
                        tooltip: 'Favorite',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Center(
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        scale: _isHovered ? 1.05 : 1,
                        child: Image.asset(
                          widget.item.imagePath,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.item.name,
                    style: const TextStyle(
                      color: Color(0xFF3E2723),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Price: \$${widget.item.price}',
                    style: const TextStyle(
                      color: Color(0xFF4E342E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Category: ${widget.item.category}',
                    style: const TextStyle(
                      color: Color(0xFF4E342E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Material: ${widget.item.material}',
                    style: const TextStyle(
                      color: Color(0xFF4E342E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Color: ${widget.item.color}',
                    style: const TextStyle(
                      color: Color(0xFF4E342E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.onBuyNow,
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
          ),
        ),
      ),
    );
  }
}

class _ArrowCircle extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ArrowCircle({required this.icon, required this.onTap});

  @override
  State<_ArrowCircle> createState() => _ArrowCircleState();
}

class _ArrowCircleState extends State<_ArrowCircle> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.identity()..scale(_isHovered ? 1.08 : 1.0),
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: _isHovered
                ? Colors.white.withOpacity(0.58)
                : Colors.white.withOpacity(0.35),
            shape: BoxShape.circle,
          ),
          child: Icon(widget.icon, color: const Color(0xFF5D4037)),
        ),
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
