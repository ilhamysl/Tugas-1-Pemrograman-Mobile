import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserBloodStockPage extends StatelessWidget {
  const UserBloodStockPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final String pmiId = args['pmiId'] as String;
    final String pmiName = args['pmiName'] as String;

    return Scaffold(
      appBar: AppBar(
        title: Text("Stok Darah – $pmiName"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pmi_stock') // <-- FIX KOLEKSI
            .doc(pmiId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                "Data stok darah belum tersedia.",
                textAlign: TextAlign.center,
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final updatedAt = data['updatedAt'] as Timestamp?;
          final updatedTime = updatedAt?.toDate();

          // === FIELD FIX SESUAI FIRESTORE ===
          final List<Map<String, String>> bloodTypes = [
            {'field': 'A+', 'label': 'A+'},
            {'field': 'A-', 'label': 'A−'},
            {'field': 'B+', 'label': 'B+'},
            {'field': 'B-', 'label': 'B−'},
            {'field': 'O+', 'label': 'O+'},
            {'field': 'O-', 'label': 'O−'},
            {'field': 'AB+', 'label': 'AB+'},
            {'field': 'AB-', 'label': 'AB−'},
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (updatedTime != null)
                  Text(
                    "Diperbarui: ${_formatDateTime(updatedTime)}",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                const SizedBox(height: 12),

                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: bloodTypes.map((bt) {
                    final field = bt['field']!;
                    final label = bt['label']!;
                    final int value = (data[field] ?? 0) as int;

                    final status = _getStatus(value);
                    final Color bgColor = _getStatusBackgroundColor(status);
                    final Color chipColor = _getStatusChipColor(status);

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "$value Kantong",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: chipColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: chipColor,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(status),
                                  size: 16,
                                  color: chipColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: chipColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static String _formatDateTime(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return "$day $month $year, $hour:$minute";
  }

  String _getStatus(int value) {
    if (value < 5) return "Kritis";
    if (value < 20) return "Menipis";
    return "Aman";
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status) {
      case "Kritis":
        return Colors.red.shade50;
      case "Menipis":
        return Colors.yellow.shade50;
      case "Aman":
      default:
        return Colors.green.shade50;
    }
  }

  Color _getStatusChipColor(String status) {
    switch (status) {
      case "Kritis":
        return Colors.red.shade700;
      case "Menipis":
        return Colors.orange.shade700;
      case "Aman":
      default:
        return Colors.green.shade700;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case "Kritis":
        return Icons.error;
      case "Menipis":
        return Icons.warning_amber_rounded;
      case "Aman":
      default:
        return Icons.check_circle;
    }
  }
}
