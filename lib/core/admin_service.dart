import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> loginAdmin(String kode, String password) async {
    try {
      final doc =
          await _db.collection("admin_accounts").doc(kode.trim()).get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      if (data["password"] == password.trim()) {
        return data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
