import 'package:flutter/material.dart';
import 'package:darahcepat/features/user/education_detail_page.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "DarahCepat",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, "/user-notif");
            },
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.red,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🩸 PREMIUM BANNER (TANPA TOMBOL & TANPA SEARCH BAR)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red.shade600,
                    Colors.red.shade400,
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.volunteer_activism,
                      size: 48, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    "Jadilah Pahlawan!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Satu kantong darahmu bisa menjadi harapan baru bagi banyak orang.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 📚 EDUKASI SECTION
            Text(
              "Edukasi Donor Darah",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.red.shade800,
              ),
            ),
            const SizedBox(height: 16),

            // CARD 1
            _eduCard(
              context,
              icon: Icons.local_hospital,
              title: "Manfaat Donor Darah Bagi Kesehatan",
              desc:
                  "Donor darah membantu kesehatan jantung dan menurunkan risiko penyakit tertentu.",
              content: """
Donor darah memberikan banyak manfaat bagi kesehatan pendonor:

1. Menjaga kesehatan jantung  
Kadar zat besi berlebih dapat meningkatkan risiko serangan jantung. Saat donor darah, kadar zat besi tubuh menurun secara alami.

2. Memperbarui sel darah  
Setelah donor, tubuh memproduksi sel darah merah baru sehingga sirkulasi darah menjadi lebih segar dan optimal.

3. Pemeriksaan kesehatan gratis  
Pendonor mendapatkan pemeriksaan tekanan darah, hemoglobin, dan riwayat kesehatan ringan secara rutin.

4. Efek psikologis positif  
Menolong orang lain meningkatkan rasa bahagia, percaya diri, dan menurunkan stres.

5. Menyelamatkan nyawa  
Satu kantong darahmu bisa menyelamatkan 2–3 orang yang membutuhkan transfusi.

Melakukan donor darah secara rutin sangat bermanfaat baik untuk kesehatan fisik maupun mental.
""",
            ),

            const SizedBox(height: 14),

            // CARD 2
            _eduCard(
              context,
              icon: Icons.block,
              title: "Siapa yang Tidak Boleh Donor Darah?",
              desc:
                  "Ada beberapa kondisi medis yang membuat seseorang tidak dianjurkan untuk donor.",
              content: """
Berikut adalah golongan yang tidak dianjurkan untuk donor darah:

1. Memiliki penyakit jantung berat  
2. Sedang demam atau infeksi akut  
3. Tekanan darah terlalu rendah atau terlalu tinggi  
4. Memiliki penyakit menular (HIV, hepatitis B/C, sifilis)  
5. Sedang hamil atau baru melahirkan  
6. Berat badan di bawah 45 kg  
7. Baru menjalani operasi besar  
8. Sedang mengonsumsi obat tertentu

Pastikan selalu berkonsultasi dengan petugas medis sebelum donor.
""",
            ),

            const SizedBox(height: 14),

            // CARD 3
            _eduCard(
              context,
              icon: Icons.tips_and_updates,
              title: "Tips Sebelum & Sesudah Donor Darah",
              desc:
                  "Beberapa tips agar donor lebih nyaman, aman, dan tidak pusing.",
              content: """
Tips Sebelum Donor Darah:

• Tidur cukup 6–8 jam  
• Minum air putih 2–3 gelas  
• Hindari makanan terlalu berlemak  
• Sarapan ringan  
• Jangan lakukan aktivitas berat sebelum donor  

Tips Sesudah Donor Darah:

• Istirahat minimal 10–15 menit  
• Minum air yang cukup  
• Jangan angkat beban berat dengan tangan bekas donor  
• Jika pusing, duduk atau berbaring sampai pulih  

Mengikuti tips ini membuat proses donor jauh lebih aman dan nyaman.
""",
            ),

            const SizedBox(height: 24),

            // ⚡ QUICK INFO SECTION
            Text(
              "Info Penting Lainnya",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.red.shade800,
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _quickInfo(
                    context,
                    title: "Berapa Sering Boleh Donor?",
                    content: """
Pria dapat donor darah setiap 3 bulan sekali,
sedangkan wanita setiap 3–4 bulan sekali.

Ini agar tubuh punya waktu cukup untuk
memulihkan sel darah merah dan hemoglobin.
""",
                  ),
                  _quickInfo(
                    context,
                    title: "Apakah Donor Darah Aman?",
                    content: """
Donor darah sangat aman jika mengikuti prosedur.

• Jarum suntik sekali pakai  
• Proses steril  
• Diperiksa medis sebelum donor  

Risiko komplikasi sangat rendah.
""",
                  ),
                  _quickInfo(
                    context,
                    title: "Berapa Lama Proses Donor?",
                    content: """
Proses pengambilan darah hanya 10–15 menit.

Total waktu (registrasi → selesai) sekitar 45–60 menit.
""",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🎯 FUN FACT
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                "Tahukah kamu? Kurang dari 5% masyarakat Indonesia rutin donor darah tiap tahun.",
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ⭐ CARD EDUKASI
  Widget _eduCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String desc,
    required String content,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EducationDetailPage(
              title: title,
              content: content,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 36, color: Colors.red.shade600),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }

  // ⭐ QUICK INFO
  Widget _quickInfo(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EducationDetailPage(
              title: title,
              content: content,
            ),
          ),
        );
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
