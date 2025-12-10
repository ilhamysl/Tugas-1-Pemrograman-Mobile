import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'user_profile_edit_page.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text("Silakan login terlebih dahulu."),
        ),
      );
    }

    final userRef =
        FirebaseFirestore.instance.collection("users").doc(currentUser.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Saya"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: userRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                "Data profil belum tersedia.",
                style: TextStyle(fontSize: 14),
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final String name = data["name"] ?? "Pengguna";
          final String phone = data["phone"] ?? "-";
          final String province = data["province"] ?? "-";
          final String bloodType = data["bloodType"] ?? "-";
          final int totalDonor = data["totalDonations"] ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ================= HEADER =================
                Column(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.red.shade100,
                      child: Icon(
                        Icons.person_rounded,
                        color: Colors.red.shade600,
                        size: 55,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentUser.email ?? "",
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ================= GOLONGAN DARAH =================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bloodtype_rounded,
                          size: 30, color: Colors.red),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Golongan Darah",
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            bloodType,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ================= DETAIL LAIN =================
                _buildInfoTile(
                  icon: Icons.phone_rounded,
                  title: "Nomor HP",
                  value: phone,
                ),
                const SizedBox(height: 10),
                _buildInfoTile(
                  icon: Icons.map_rounded,
                  title: "Provinsi Domisili",
                  value: province,
                ),
                const SizedBox(height: 10),
                _buildInfoTile(
                  icon: Icons.volunteer_activism_rounded,
                  title: "Total Donor",
                  value: "$totalDonor kali",
                ),

                const SizedBox(height: 30),

                // ================= BUTTON EDIT PROFIL =================
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text(
                      "Edit Profil",
                      style: TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserProfileEditPage(
                            name: name,
                            phone: phone,
                            province: province,
                            bloodType: bloodType,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // ================= BUTTON LOGOUT =================
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text(
                      "Keluar",
                      style: TextStyle(fontSize: 16),
                    ),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          "/login",
                          (route) => false,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ===================== HELPER UNTUK INFO TILE =====================
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: Colors.grey.shade700),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
