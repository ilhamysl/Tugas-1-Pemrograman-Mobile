import 'package:flutter/material.dart';

class UserEventDetailPage extends StatelessWidget {
  final Map<String, dynamic> eventData;

  const UserEventDetailPage({super.key, required this.eventData});

  @override
  Widget build(BuildContext context) {
    final title = eventData["title"] ?? "-";
    final desc = eventData["description"] ?? "";
    final location = eventData["location"] ?? "-";
    final imageUrl = eventData["imageUrl"];
    final timestamp = eventData["timestamp"] ?? 0;
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Event"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null && imageUrl != "")
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 210,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),

            Text(
              title,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.event),
                const SizedBox(width: 6),
                Text(
                  _formatDate(date),
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 4),

            Row(
              children: [
                const Icon(Icons.location_on_rounded),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(location),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              desc,
              style: const TextStyle(fontSize: 15, height: 1.6),
            ),
          ],
        ),
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
