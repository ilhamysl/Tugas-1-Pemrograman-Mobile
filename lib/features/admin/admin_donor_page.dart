import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminDonorPage extends StatefulWidget {
  const AdminDonorPage({super.key});

  @override
  State<AdminDonorPage> createState() => _AdminDonorPageState();
}

class _AdminDonorPageState extends State<AdminDonorPage>
    with SingleTickerProviderStateMixin {

  final emailController = TextEditingController();
  DocumentSnapshot? foundUser;
  String? foundUserId;

  DateTime? selectedDate;
  String donorStatus = "success";

  bool isSearching = false;
  bool isSaving = false;

  // 🔥 Animation Controller untuk popup success
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ================================================================
  //                       WIDGET UTAMA
  // ================================================================
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder(
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

        if (!adminSnap.hasData || adminSnap.data!.docs.isEmpty) {
          return const Scaffold(
            body: Center(child: Text("Data admin tidak ditemukan.")),
          );
        }

        final admin = adminSnap.data!.docs.first.data();
        final pmiName = admin["regionName"];
        final pmiId = admin["code"];

        return Stack(
          children: [
            _buildMainUI(pmiName, pmiId),
            if (isSaving) _buildLoadingOverlay(),
          ],
        );
      },
    );
  }

  // ================================================================
  //                        MAIN UI
  // ================================================================
  Widget _buildMainUI(String pmiName, String pmiId) {
    return Scaffold(
      appBar: AppBar(title: const Text("Input Riwayat Donor")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Cari User berdasarkan Email",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: "contoh: user@gmail.com",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: isSearching ? null : _searchUser,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: isSearching
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                      : const Text("Cari"),
                ),
              ],
            ),

            const SizedBox(height: 24),

            if (foundUser != null) _buildUserInfo(foundUser!),
            const SizedBox(height: 22),

            if (foundUser != null) _buildDonorForm(pmiName, pmiId),
          ],
        ),
      ),
    );
  }

  // ================================================================
  //                      LOADING OVERLAY
  // ================================================================
  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.45),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }

  // ================================================================
  //                        SUCCESS POPUP
  // ================================================================
  Future<void> _showSuccessPopup() async {
    _animController.forward();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return ScaleTransition(
          scale: _scaleAnim,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.check_circle, color: Colors.green, size: 70),
                  SizedBox(height: 16),
                  Text(
                    "Berhasil Disimpan!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // Tunggu animasi Navigator selesai
    await Future.delayed(const Duration(milliseconds: 200));

    // Tutup popup (jika masih terbuka)
    if (Navigator.canPop(context)) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    // Tunggu sebentar lagi sebelum pop halaman
    await Future.delayed(const Duration(milliseconds: 150));

    // Tutup halaman donor (jika bisa dipop)
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  // ================================================================
  //                        SEARCH USER
  // ================================================================
  Future<void> _searchUser() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showMsg("Masukkan email terlebih dahulu.");
      return;
    }

    setState(() => isSearching = true);

    final snap = await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: email)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) {
      _showMsg("User tidak ditemukan.");
      setState(() {
        foundUser = null;
        foundUserId = null;
        isSearching = false;
      });
      return;
    }

    setState(() {
      foundUser = snap.docs.first;
      foundUserId = snap.docs.first.id;
      isSearching = false;
    });
  }

  // ================================================================
  //                        USER INFO CARD
  // ================================================================
  Widget _buildUserInfo(DocumentSnapshot user) {
    final data = user.data() as Map<String, dynamic>? ?? {};

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Data User Ditemukan",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text("Nama : ${data["name"] ?? "-"}"),
          Text("Email : ${data["email"] ?? "-"}"),
          Text("Golongan Darah : ${data["bloodType"] ?? "-"}"),
          Text("Total Donor : ${data["totalDonations"] ?? 0}"),
        ],
      ),
    );
  }

  // ================================================================
  //                        DONOR FORM
  // ================================================================
  Widget _buildDonorForm(String pmiName, String pmiId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Input Riwayat Donor",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),

        InkWell(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.event),
                const SizedBox(width: 12),
                Text(selectedDate == null
                    ? "Pilih tanggal donor"
                    : _formatDate(selectedDate!)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        DropdownButtonFormField<String>(
          value: donorStatus,
          items: const [
            DropdownMenuItem(value: "success", child: Text("Sukses")),
            DropdownMenuItem(value: "failed", child: Text("Gagal / Ditolak")),
          ],
          onChanged: (v) => setState(() => donorStatus = v!),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Status donor",
          ),
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isSaving ? null : () => _saveDonorHistory(pmiName, pmiId),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 14)),
            child: isSaving
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Simpan Riwayat", style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  // ================================================================
  //                        SAVE DONOR HISTORY
  // ================================================================
  Future<void> _saveDonorHistory(String pmiName, String pmiId) async {
    if (foundUserId == null) return;

    if (selectedDate == null) {
      _showMsg("Pilih tanggal donor terlebih dahulu.");
      return;
    }

    setState(() => isSaving = true);

    final uid = foundUserId!;
    final userRef = FirebaseFirestore.instance.collection("users").doc(uid);

    await userRef.collection("donation_history").add({
      "timestamp": Timestamp.fromDate(selectedDate!),
      "location": pmiName,
      "status": donorStatus,
      "pmiId": pmiId,
    });

    final userSnap = await userRef.get();
    final oldData = userSnap.data() ?? {};

    int oldTotal = (oldData["totalDonations"] ?? 0) as int;
    int newTotal = donorStatus == "success" ? oldTotal + 1 : oldTotal;

    await userRef.update({
      "totalDonations": newTotal,
      if (donorStatus == "success")
        "lastDonationDate": selectedDate!.toIso8601String(),
    });

    setState(() => isSaving = false);

    // 🔥 TAMPILKAN POPUP ANIMASI SUKSES
    _showSuccessPopup();
  }

  // ================================================================
  //                          HELPER
  // ================================================================
  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 1),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  void _showMsg(String m) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(m)));
  }

  String _formatDate(DateTime d) {
    const m = [
      "Jan","Feb","Mar","Apr","Mei","Jun",
      "Jul","Agu","Sep","Okt","Nov","Des"
    ];
    return "${d.day} ${m[d.month - 1]} ${d.year}";
  }
}
