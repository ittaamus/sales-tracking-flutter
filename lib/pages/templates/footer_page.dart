part of '../library_page.dart';

class FooterPage extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FooterPage({Key? key, required this.currentIndex, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap, // <--- cukup panggil callback
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: false,
      showSelectedLabels: false,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Ionicons.home_outline),
          activeIcon: Icon(Ionicons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Ionicons.calendar_outline),
          activeIcon: Icon(Ionicons.calendar),
          label: "Visit",
        ),
        BottomNavigationBarItem(
          icon: Icon(Ionicons.chatbubble_ellipses_outline),
          activeIcon: Icon(Ionicons.chatbubble_ellipses),
          label: "Chat",
        ),
        BottomNavigationBarItem(
          icon: Icon(Ionicons.person_outline),
          activeIcon: Icon(Ionicons.person),
          label: "Profile",
        ),
      ],
    );
  }
}
