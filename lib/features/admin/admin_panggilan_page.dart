import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminPanggilanPage extends StatefulWidget {
  const AdminPanggilanPage({super.key});

  @override
  State<AdminPanggilanPage> createState() => _AdminPanggilanPageState();
}

class _AdminPanggilanPageState extends State<AdminPanggilanPage> {
  String jenisPanggilan = "ajakan";
  String? selectedBloodType;

  bool isLoading = false;
  bool showSuccess = false;

  final bloodTypes = ["A+","A-","B+","B-","O+","O-","AB+","AB-"];

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection("pmi_admins")
          .where("uid", isEqualTo: uid)
          .limit(1)
          .get(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snap.data!.docs.isEmpty) {
          return const Scaffold(
            body: Center(child: Text("Data admin tidak ditemukan")),
          );
        }

        final admin = snap.data!.docs.first.data();
        final pmiId = admin["code"];
        final regionName = admin["regionName"];
        final province = admin["province"];

        return Stack(
          children: [
            _buildMainUI(pmiId, regionName, province),
            if (isLoading) _buildLoadingOverlay(),
            if (showSuccess) _buildSuccessOverlay(),
          ],
        );
      },
    );
  }

  Widget _buildMainUI(String pmiId, String regionName, String province) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panggilan Donor"),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Jenis Panggilan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

            RadioListTile(
              title: const Text("Ajakan Donor"),
              value: "ajakan",
              groupValue: jenisPanggilan,
              onChanged: (v) => setState(() => jenisPanggilan = v!),
            ),
            RadioListTile(
              title: const Text("Panggilan Darurat"),
              value: "darurat",
              groupValue: jenisPanggilan,
              onChanged: (v) => setState(() => jenisPanggilan = v!),
            ),

            const SizedBox(height: 16),

            const Text("Pilih Golongan Darah",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

            DropdownButtonFormField(
              decoration: const InputDecoration(border: OutlineInputBorder()),
              hint: const Text("Pilih"),
              items: bloodTypes
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => selectedBloodType = v),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _kirimDemoPanggilan(regionName, province),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Kirim Panggilan",
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.4),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.4),
      child: Center(
        child: AnimatedScale(
          scale: showSuccess ? 1 : 0.5,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutBack,
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.check_circle, color: Colors.green, size: 70),
                SizedBox(height: 12),
                Text("Panggilan Berhasil!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _kirimDemoPanggilan(String regionName, String province) async {
    if (selectedBloodType == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Pilih golongan darah.")));
      return;
    }

    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    /// Simpan notifikasi ke Firestore (untuk halaman notifikasi user)
    final title = jenisPanggilan == "ajakan"
        ? "Ajakan Donor Darah"
        : "Panggilan Darurat!";
    final body =
        "Golongan darah $selectedBloodType dibutuhkan di $regionName.";

    // (DEMO MODE) → Simpan ke collection umum "notifications_demo"
    await FirebaseFirestore.instance.collection("demo_notifications").add({
      "title": title,
      "body": body,
      "province": province,
      "bloodType": selectedBloodType,
      "timestamp": DateTime.now(),
    });

    setState(() {
      isLoading = false;
      showSuccess = true;
    });

    await Future.delayed(const Duration(seconds: 2));
    setState(() => showSuccess = false);
  }
}
