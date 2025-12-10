import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfileEditPage extends StatefulWidget {
  final String name;
  final String phone;
  final String province;
  final String bloodType;

  const UserProfileEditPage({
    super.key,
    required this.name,
    required this.phone,
    required this.province,
    required this.bloodType,
  });

  @override
  State<UserProfileEditPage> createState() => _UserProfileEditPageState();
}

class _UserProfileEditPageState extends State<UserProfileEditPage> {
  late TextEditingController nameController;
  late TextEditingController phoneController;

  String? selectedProvince;
  String? selectedBloodType;

  bool isSaving = false;

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

  final List<String> provinces = [
    "Aceh",
    "Sumatera Utara",
    "Sumatera Barat",
    "Riau",
    "Jambi",
    "Sumatera Selatan",
    "Bengkulu",
    "Lampung",
    "Kep. Bangka Belitung",
    "Kep. Riau",
    "DKI Jakarta",
    "Jawa Barat",
    "Jawa Tengah",
    "DI Yogyakarta",
    "Jawa Timur",
    "Banten",
    "Bali",
    "Nusa Tenggara Barat",
    "Nusa Tenggara Timur",
    "Kalimantan Barat",
    "Kalimantan Tengah",
    "Kalimantan Selatan",
    "Kalimantan Timur",
    "Kalimantan Utara",
    "Sulawesi Utara",
    "Sulawesi Tengah",
    "Sulawesi Selatan",
    "Sulawesi Tenggara",
    "Gorontalo",
    "Sulawesi Barat",
    "Maluku",
    "Maluku Utara",
    "Papua",
    "Papua Barat",
    "Papua Tengah",
    "Papua Pegunungan",
    "Papua Selatan",
    "Papua Barat Daya",
  ];

 @override
 void initState() {
   super.initState();
   nameController = TextEditingController(text: widget.name);
   phoneController = TextEditingController(text: widget.phone);

   // Perbaikan untuk dropdown error
   selectedProvince =
       provinces.contains(widget.province) ? widget.province : null;
 
   selectedBloodType =
       bloodTypes.contains(widget.bloodType) ? widget.bloodType : null;
 }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (nameController.text.isEmpty) {
      _showMessage("Nama tidak boleh kosong");
      return;
    }

    if (selectedBloodType == null || selectedProvince == null) {
      _showMessage("Harap lengkapi semua field");
      return;
    }

    setState(() => isSaving = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseFirestore.instance.collection("users").doc(uid);

    try {
      await ref.update({
        "name": nameController.text.trim(),
        "phone": phoneController.text.trim(),
        "province": selectedProvince,
        "bloodType": selectedBloodType,
      });

      _showMessage("Profil berhasil diperbarui!");

      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showMessage("Gagal menyimpan: $e");
    }

    if (mounted) setState(() => isSaving = false);
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profil"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ================= INPUT NAMA =================
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Nama Lengkap",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // ================= INPUT NOMOR HP =================
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Nomor HP",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // ================= DROPDOWN PROVINSI =================
            DropdownButtonFormField<String>(
              value: selectedProvince,
              items: provinces
                  .map((prov) =>
                      DropdownMenuItem(value: prov, child: Text(prov)))
                  .toList(),
              onChanged: (value) => setState(() => selectedProvince = value),
              decoration: const InputDecoration(
                labelText: "Provinsi Domisili",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // ================= DROPDOWN GOLONGAN DARAH =================
            DropdownButtonFormField<String>(
              value: selectedBloodType,
              items: bloodTypes
                  .map((bt) => DropdownMenuItem(value: bt, child: Text(bt)))
                  .toList(),
              onChanged: (value) => setState(() => selectedBloodType = value),
              decoration: const InputDecoration(
                labelText: "Golongan Darah",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            // ================= BUTTON SIMPAN =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Simpan",
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
