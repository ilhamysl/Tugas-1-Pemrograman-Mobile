import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'admin_event_form_page.dart';

class AdminEventPage extends StatelessWidget {
  const AdminEventPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection("pmi_admins")
          .where("uid", isEqualTo: uid)
          .limit(1)
          .get(),
      builder: (context, adminSnap) {
        if (adminSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (adminSnap.hasError ||
            adminSnap.data == null ||
            adminSnap.data!.docs.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Text(
                "Data admin tidak ditemukan.\nPeriksa koleksi pmi_admins.",
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final adminData = adminSnap.data!.docs.first.data();
        final String pmiId = adminData["code"];
        final String regionName = adminData["regionName"];

        return Scaffold(
          appBar: AppBar(
            title: const Text("Kelola Event Donor Darah"),
          ),

          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.red,
            child: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminEventFormPage(
                    pmiId: pmiId,
                    regionName: regionName,
                  ),
                ),
              );
            },
          ),

          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("events")
                .where("pmiId", isEqualTo: pmiId)
                .orderBy("timestamp")
                .snapshots(),
            builder: (context, snapshot) {

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const Center(
                  child: Text(
                    "Belum ada event donor darah.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final eventId = docs[index].id;

                  final imageUrl = data["imageUrl"];
                  final title = data["title"] ?? "-";
                  final location = data["location"] ?? "-";
                  final timestamp = data["timestamp"];
                  final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (imageUrl != null && imageUrl != "")
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrl,
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),

                        const SizedBox(height: 12),

                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),

                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 18),
                            const SizedBox(width: 6),
                            Expanded(child: Text(location)),
                          ],
                        ),

                        const SizedBox(height: 4),

                        Row(
                          children: [
                            const Icon(Icons.event_rounded, size: 18),
                            const SizedBox(width: 6),
                            Text(_formatDate(date)),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AdminEventFormPage(
                                      pmiId: pmiId,
                                      regionName: regionName,
                                      eventId: eventId,
                                      existingData: data,
                                    ),
                                  ),
                                );
                              },
                              child: const Text("Edit"),
                            ),
                            const SizedBox(width: 12),
                            TextButton(
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection("events")
                                    .doc(eventId)
                                    .delete();

                                if (!context.mounted) return;
    

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Event dihapus"),
                                  ),
                                );
                              },
                              child: const Text(
                                "Hapus",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  

  // ===============================
  // FORMAT TANGGAL
  // ===============================
  String _formatDate(DateTime date) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "Mei",
      "Jun",
      "Jul",
      "Agu",
      "Sep",
      "Okt",
      "Nov",
      "Des"
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }
}
