import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminStockPage extends StatelessWidget {
  const AdminStockPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("User belum login sebagai admin."),
        ),
      );
    }

    final String adminUid = user.uid;

    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection("pmi_admins")
          .where("uid", isEqualTo: adminUid)
          .limit(1)
          .get(),
      builder: (context, adminSnap) {
        if (adminSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (adminSnap.hasError) {
          return Scaffold(
            body: Center(
              child: Text("Gagal memuat data admin: ${adminSnap.error}"),
            ),
          );
        }

        final docs = adminSnap.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Text(
                "Data admin tidak ditemukan di Firestore.\n"
                "Pastikan koleksi 'pmi_admins' punya field 'uid' = UID admin.",
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final adminData = docs.first.data();
        final String pmiId = (adminData["code"] ?? "").toString();
        final String regionName = (adminData["regionName"] ?? "").toString();

        if (pmiId.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Text(
                "Field 'code' (PMI ID) kosong.\nMohon cek koleksi 'pmi_admins'.",
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text("Stok Darah - $regionName"),
          ),
          body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection("pmi_stock")
                .doc(pmiId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text("Gagal memuat data stok: ${snapshot.error}"),
                );
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Center(
                  child: Text(
                    "Data stok belum tersedia untuk PMI ini.",
                    textAlign: TextAlign.center,
                  ),
                );
              }

              final stockData = snapshot.data!.data();
              if (stockData == null) {
                return const Center(
                  child: Text("Dokumen stok kosong."),
                );
              }

              final bloodTypes = [
                "A+","A-","B+","B-","O+","O-","AB+","AB-"
              ];

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: bloodTypes.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.95,  // 🔥 Lebihkan tinggi card supaya tidak overflow
                ),
                itemBuilder: (context, index) {
                  final type = bloodTypes[index];
                  final int value =
                      (stockData[type] ?? 0) is int ? stockData[type] : 0;

                  final _StatusInfo status = _getStockStatus(value);

                  return Container(
                    decoration: BoxDecoration(
                      color: status.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: status.color, width: 1.2),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: status.color,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Expanded(   // 🔥 Perbaikan: body text dapat ruang fleksibel
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Jumlah: $value",
                                  style: const TextStyle(fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(
                                "Status: ${status.label}",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: status.color,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: status.color,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              _showEditDialog(
                                context: context,
                                pmiId: pmiId,
                                type: type,
                                currentValue: value,
                              );
                            },
                            child: const Text("Edit"),
                          ),
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

  void _showEditDialog({
    required BuildContext context,
    required String pmiId,
    required String type,
    required int currentValue,
  }) {
    TextEditingController controller =
        TextEditingController(text: currentValue.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Stok $type"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Jumlah stok",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                final int? newStock = int.tryParse(controller.text);
                if (newStock == null || newStock < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Input tidak valid")),
                  );
                  return;
                }

                await FirebaseFirestore.instance
                    .collection("pmi_stock")
                    .doc(pmiId)
                    .update({ type: newStock });

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  _StatusInfo _getStockStatus(int value) {
    if (value >= 10) {
      return _StatusInfo("Normal", Colors.green);
    } else if (value >= 5) {
      return _StatusInfo("Menipis", Colors.orange);
    } else {
      return _StatusInfo("Kritis", Colors.red);
    }
  }
}

class _StatusInfo {
  final String label;
  final Color color;
  _StatusInfo(this.label, this.color);
}
