import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserPickPmiPage extends StatelessWidget {
  const UserPickPmiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih UDD PMI"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("pmi_admins") // <-- FIX: pakai pmi_admins
            .orderBy("regionName")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Data UDD PMI belum tersedia.",
                textAlign: TextAlign.center,
              ),
            );
          }

          final pmiDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pmiDocs.length,
            itemBuilder: (context, index) {
              final doc = pmiDocs[index];
              final data = doc.data() as Map<String, dynamic>;

              final pmiId = doc.id; // example: PMI_BALI_01
              final name = data["regionName"] ?? "-";
              final address = data["province"] ?? "-";
              final phone = data["phone"] ?? "-";

              return _PmiCard(
                pmiId: pmiId,
                name: name,
                address: address,
                phone: phone,
              );
            },
          );
        },
      ),
    );
  }
}

class _PmiCard extends StatelessWidget {
  final String pmiId;
  final String name;
  final String address;
  final String phone;

  const _PmiCard({
    required this.pmiId,
    required this.name,
    required this.address,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          "/user-blood-stock",
          arguments: {
            "pmiId": pmiId,
            "pmiName": name,
          },
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nama UDD
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            // Alamat (provinsi)
            Text(
              address,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 4),

            // Telepon
            Text(
              "📞 $phone",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 10),

            // ==== STATUS RINGKAS STOK DARAH ====
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("pmi_stock")
                  .doc(pmiId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Text(
                    "Status stok: belum ada data",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  );
                }

                final stockData =
                    snapshot.data!.data() as Map<String, dynamic>;

                final List<String> bloodTypes = [
                  "A+",
                  "A-",
                  "B+",
                  "B-",
                  "O+",
                  "O-",
                  "AB+",
                  "AB-"
                ];

                // cari golongan kritis (<5)
                final List<String> criticalTypes = [];

                for (var type in bloodTypes) {
                  final int value = (stockData[type] ?? 0) as int;
                  if (value < 5) {
                    criticalTypes.add(type);
                  }
                }

                late String statusText;
                late Color statusColor;

                if (criticalTypes.isEmpty) {
                  statusText = "Status stok: semua golongan aman";
                  statusColor = Colors.green.shade700;
                } else if (criticalTypes.length == 1) {
                  statusText =
                      "Status stok: ${criticalTypes.first} kritis";
                  statusColor = Colors.red.shade700;
                } else if (criticalTypes.length == 2) {
                  statusText =
                      "Status stok: ${criticalTypes[0]} & ${criticalTypes[1]} kritis";
                  statusColor = Colors.red.shade700;
                } else {
                  final preview = criticalTypes.take(2).join(", ");
                  statusText =
                      "Status stok: $preview & lainnya kritis";
                  statusColor = Colors.red.shade700;
                }

                return Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
