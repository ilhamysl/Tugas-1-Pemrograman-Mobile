import 'package:flutter/material.dart';

class EducationDetailPage extends StatelessWidget {
  final String title;
  final String content;

  const EducationDetailPage({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Artikel Edukasi"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // JUDUL BESAR
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 12),

            // GARIS PEMBATAS HALUS
            Container(
              height: 1,
              width: double.infinity,
              color: Colors.grey.shade300,
            ),

            const SizedBox(height: 16),

            // ISI ARTIKEL
            Text(
              content,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
