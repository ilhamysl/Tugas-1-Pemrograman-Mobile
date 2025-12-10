import 'package:flutter/material.dart';
import 'package:darahcepat/features/user/user_home_page.dart';
import 'user_pick_pmi_page.dart';
import 'user_event_page.dart';
import 'user_history_page.dart';
import 'user_profile_page.dart';


class UserMainPage extends StatefulWidget {
  const UserMainPage({super.key});

  @override
  State<UserMainPage> createState() => _UserMainPageState();
}

class _UserMainPageState extends State<UserMainPage> {
  int _selectedIndex = 0;

  // TODO: ganti ini dengan halaman yang benar jika sudah dibuat
  final List<Widget> _pages = const [
    UserHomePage(),          // index 0
    UserPickPmiPage(),           // index 1 = Stok Darah
    UserEventPage(),           // index 2 = Event List
    UserHistoryPage(),           // index 3 = Riwayat + Achievement
    UserProfilePage(),           // index 4 = Profile
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red.shade700,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bloodtype_outlined),
            label: "Stok",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_outlined),
            label: "Event",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: "Riwayat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}
