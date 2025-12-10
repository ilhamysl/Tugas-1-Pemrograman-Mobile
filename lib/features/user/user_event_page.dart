import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'user_event_detail_page.dart';
class UserEventPage extends StatelessWidget {
  const UserEventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Donor Darah"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("events")
            .orderBy("timestamp")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text("Belum ada event donor darah."),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              final title = data["title"] ?? "-";
              final description = data["description"] ?? "";
              final location = data["location"] ?? "-";
              final imageUrl = data["imageUrl"];
              final timestamp = data["timestamp"] ?? 0;
              final date =
                  DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserEventDetailPage(eventData: data),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poster event
                      if (imageUrl != null && imageUrl != "")
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                          child: Image.network(
                            imageUrl,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),

                      // Konten event
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                const Icon(Icons.event, size: 16),
                                const SizedBox(width: 6),
                                Text(_formatDate(date)),
                              ],
                            ),
                            const SizedBox(height: 4),

                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded, size: 16),
                                const SizedBox(width: 6),
                                Expanded(child: Text(location)),
                              ],
                            ),
                            const SizedBox(height: 10),

                            Text(
                              description,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "Mei", "Jun",
      "Jul", "Agu", "Sep", "Okt", "Nov", "Des"
    ];

    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }
}
