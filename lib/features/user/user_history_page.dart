import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserHistoryPage extends StatelessWidget {
  const UserHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("Silakan login terlebih dahulu."),
        ),
      );
    }

    final userDocRef =
        FirebaseFirestore.instance.collection("users").doc(user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Donor"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: userDocRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                "Data pengguna belum tersedia.\nSilakan lengkapi profil terlebih dahulu.",
                textAlign: TextAlign.center,
              ),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;

          final String name = userData["name"] ?? "Pengguna";
          final int totalDonations = (userData["totalDonations"] ?? 0) as int;

          final DateTime? lastDonationDate =
              _parseLastDonationDate(userData["lastDonationDate"]);

          final _BadgeInfo badgeInfo = _getBadgeInfo(totalDonations);
          final String statusText =
              _getDonationStatusText(lastDonationDate, DateTime.now());

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ====== BAGIAN ATAS: BADGE + TOTAL DONOR ======
                _buildHeaderSection(
                  context: context,
                  name: name,
                  totalDonations: totalDonations,
                  badgeInfo: badgeInfo,
                  statusText: statusText,
                ),
                const SizedBox(height: 24),

                const Text(
                  "Riwayat Donor",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // ====== LIST RIWAYAT DONOR ======
                StreamBuilder<QuerySnapshot>(
                  stream: userDocRef
                      .collection("donation_history")
                      .orderBy("timestamp", descending: true)
                      .snapshots(),
                  builder: (context, historySnapshot) {
                    if (historySnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (!historySnapshot.hasData ||
                        historySnapshot.data!.docs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          "Belum ada riwayat donor.",
                          style: TextStyle(fontSize: 14),
                        ),
                      );
                    }

                    final docs = historySnapshot.data!.docs;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data =
                            docs[index].data() as Map<String, dynamic>;

                        final DateTime date = _parseTimestamp(data["timestamp"]);
                        final String location = data["location"] ?? "-";
                        final String status = data["status"] ?? "success";

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.bloodtype_rounded,
                                color: Colors.red,
                                size: 26,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _formatDate(date),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      location,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _mapStatusText(status),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            status == "success"
                                                ? Colors.green.shade700
                                                : Colors.orange.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= HELPER UI BAGIAN ATAS =================

  Widget _buildHeaderSection({
    required BuildContext context,
    required String name,
    required int totalDonations,
    required _BadgeInfo badgeInfo,
    required String statusText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge + info
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                badgeInfo.startColor,
                badgeInfo.endColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: badgeInfo.endColor.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              // Ikon Badge
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.18),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.7),
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  badgeInfo.icon,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),

              // Teks Badge + Gelar + Nama
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      badgeInfo.title, // contoh: "Donor Pemula"
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      badgeInfo.subtitle, // contoh: "Bronze"
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Icon ? info
              IconButton(
                onPressed: () => _showAchievementInfoDialog(context),
                icon: const Icon(
                  Icons.help_outline_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Total donor besar
        Center(
          child: Column(
            children: [
              Text(
                totalDonations.toString(),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Total Donor",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Status donor
        Center(
          child: Text(
            statusText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _showAchievementInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Tentang Achievement"),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("🥉 Donor Pemula — 1–2 kali donor"),
              SizedBox(height: 4),
              Text("🥈 Donor Aktif — 3–5 kali donor"),
              SizedBox(height: 4),
              Text("🥇 Donor Inspiratif — 6–10 kali donor"),
              SizedBox(height: 4),
              Text("💎 Donor Utama — 11–20 kali donor"),
              SizedBox(height: 4),
              Text("🔱 Pahlawan Kemanusiaan — 21+ kali donor"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tutup"),
            ),
          ],
        );
      },
    );
  }

  // ===================== LOGIC HELPER ======================

  static DateTime? _parseLastDonationDate(dynamic raw) {
    if (raw == null) return null;

    if (raw is Timestamp) {
      return raw.toDate();
    } else if (raw is String) {
      try {
        return DateTime.parse(raw);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static DateTime _parseTimestamp(dynamic raw) {
    if (raw == null) {
      return DateTime.now();
    }

    if (raw is Timestamp) {
      return raw.toDate();
    } else if (raw is int) {
      // diasumsikan detik sejak epoch
      return DateTime.fromMillisecondsSinceEpoch(raw * 1000);
    }
    return DateTime.now();
  }

  static String _formatDate(DateTime date) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "Mei", "Jun",
      "Jul", "Agu", "Sep", "Okt", "Nov", "Des"
    ];
    return "${date.day.toString().padLeft(2, '0')} "
        "${months[date.month - 1]} ${date.year}";
  }

  static String _mapStatusText(String status) {
    switch (status) {
      case "success":
        return "Status: Sukses";
      case "failed":
        return "Status: Gagal / Ditolak";
      default:
        return "Status: $status";
    }
  }

  static String _getDonationStatusText(
      DateTime? lastDonation, DateTime now) {
    if (lastDonation == null) {
      return "Status: Belum pernah donor.";
    }

    const cooldownDays = 90;
    final difference = now.difference(lastDonation).inDays;

    if (difference >= cooldownDays) {
      return "Status: Sudah bisa donor hari ini.";
    } else {
      final remaining = cooldownDays - difference;
      return "Status: Bisa donor lagi dalam $remaining hari.";
    }
  }

  static _BadgeInfo _getBadgeInfo(int totalDonations) {
    if (totalDonations <= 0) {
      return _BadgeInfo(
        title: "Belum Donor",
        subtitle: "Mulai langkah pertamamu",
        startColor: Colors.grey.shade500,
        endColor: Colors.grey.shade700,
        icon: Icons.shield_outlined,
      );
    } else if (totalDonations <= 2) {
      return _BadgeInfo(
        title: "Donor Pemula",
        subtitle: "Tingkat Bronze",
        startColor: const Color(0xFFCD7F32), // bronze
        endColor: const Color(0xFF8B4513),
        icon: Icons.emoji_events_rounded,
      );
    } else if (totalDonations <= 5) {
      return _BadgeInfo(
        title: "Donor Aktif",
        subtitle: "Tingkat Silver",
        startColor: const Color(0xFFC0C0C0),
        endColor: const Color(0xFF808080),
        icon: Icons.emoji_events_rounded,
      );
    } else if (totalDonations <= 10) {
      return _BadgeInfo(
        title: "Donor Inspiratif",
        subtitle: "Tingkat Gold",
        startColor: const Color(0xFFFFD700),
        endColor: const Color(0xFFFFA000),
        icon: Icons.emoji_events_rounded,
      );
    } else if (totalDonations <= 20) {
      return _BadgeInfo(
        title: "Donor Utama",
        subtitle: "Tingkat Platinum",
        startColor: const Color(0xFFE5E4E2),
        endColor: const Color(0xFF9E9E9E),
        icon: Icons.emoji_events_rounded,
      );
    } else {
      return _BadgeInfo(
        title: "Pahlawan Kemanusiaan",
        subtitle: "Tingkat Diamond",
        startColor: const Color(0xFF4A148C),
        endColor: const Color(0xFF7B1FA2),
        icon: Icons.emoji_events_rounded,
      );
    }
  }
}

// Model kecil untuk info badge
class _BadgeInfo {
  final String title;
  final String subtitle;
  final Color startColor;
  final Color endColor;
  final IconData icon;

  _BadgeInfo({
    required this.title,
    required this.subtitle,
    required this.startColor,
    required this.endColor,
    required this.icon,
  });
}
