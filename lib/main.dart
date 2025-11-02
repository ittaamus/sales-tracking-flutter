import 'package:flutter/material.dart';
import 'package:salesyuasa/pages/library_page.dart';
import 'package:salesyuasa/services/shared_preferences_service.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yuasa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: _getInitialRoute(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }

  Widget _getInitialRoute() {
    // Check if user is already logged in
    if (SharedPreferencesService.getLoginStatus()) {
      return MainScreen(); // Navigate to main page if logged in
    } else {
      return LoginScreen(); // Navigate to login if not logged in
    }
  }
}
