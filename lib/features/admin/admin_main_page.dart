// lib/features/admin/admin_main_page.dart

import 'package:flutter/material.dart';
import 'package:darahcepat/core/admin_data_store.dart';

// IMPORT PAGE ADMIN
import 'admin_stock_page.dart';
import 'admin_event_page.dart';
import 'admin_donor_page.dart';
import 'admin_panggilan_page.dart';
import 'admin_profile_page.dart';

class AdminMainPage extends StatefulWidget {
  final Map<String, dynamic>? adminData;

  const AdminMainPage({super.key, this.adminData});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // SIMPAN DATA ADMIN SECARA GLOBAL
    AdminDataStore.adminData = widget.adminData;
  }

  final List<Widget> _pages = const [
    AdminStockPage(),
    AdminEventPage(),
    AdminDonorPage(),
    AdminPanggilanPage(),
    AdminProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bloodtype_rounded),
            label: "Stok",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_rounded),
            label: "Event",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_edu_rounded),
            label: "Donor",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active_rounded),
            label: "Panggilan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}
