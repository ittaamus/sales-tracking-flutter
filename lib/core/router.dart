part of '../pages/library_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case '/barang':
        return MaterialPageRoute(builder: (_) => BarangScreen());
      case '/addBarang':
        return MaterialPageRoute(builder: (_) => BarangAddScreen());
      case '/updateBarang':
        final barang =
            settings.arguments as BarangModel; // ambil dari arguments
        return MaterialPageRoute(
          builder: (_) => BarangUpdateScreen(barang: barang),
        );
      case '/visit':
        return MaterialPageRoute(builder: (_) => VisitScreen());
      case '/customer':
        return MaterialPageRoute(builder: (_) => CustomerScreen());
      case '/main_page':
        return MaterialPageRoute(builder: (_) => MainScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
