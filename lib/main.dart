import 'package:Tiffinity/data/constants.dart';
import 'package:Tiffinity/data/notifiers.dart';
import 'package:Tiffinity/data/auth_flag.dart';
import 'package:Tiffinity/views/auth/welcome_page.dart';
import 'package:Tiffinity/views/pages/admin_pages/admin_widget_tree.dart';
import 'package:Tiffinity/views/pages/customer_pages/customer_widget_tree.dart';
import 'package:Tiffinity/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp();
  await NotificationService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Widget _currentHome;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    initThemeMode();
    _initializeApp();
  }

  void _initializeApp() async {
    _currentHome = await _decideStartPage();
    setState(() => _isInitialized = true);
  }

  void initThemeMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool repeat = prefs.getBool(KConstants.themeModeKey) ?? false;
    isDarkModeNotifier.value = repeat;
  }

  Future<Widget> _decideStartPage() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (userDoc.exists && userDoc['role'] != null) {
        String role = userDoc['role'];

        if (role == 'customer') {
          return const CustomerWidgetTree();
        } else if (role == 'admin') {
          return const AdminWidgetTree();
        }
      }
    }

    return const WelcomePage();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.teal,
              brightness: isDarkMode ? Brightness.dark : Brightness.light,
            ),
          ),
          home:
              _isInitialized
                  ? StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (context, snapshot) {
                      // ✅ Use the getter function
                      if (getCheckoutLoginFlag()) {
                        return _currentHome;
                      }

                      final user = snapshot.data;
                      if (user == null) {
                        _currentHome = const WelcomePage();
                      }

                      return _currentHome;
                    },
                  )
                  : const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  ),
        );
      },
    );
  }
}
