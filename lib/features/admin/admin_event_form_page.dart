import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminEventFormPage extends StatefulWidget {
  final String pmiId;
  final String regionName;
  final String? eventId;
  final Map<String, dynamic>? existingData;

  const AdminEventFormPage({
    super.key,
    required this.pmiId,
    required this.regionName,
    this.eventId,
    this.existingData,
  });

  @override
  State<AdminEventFormPage> createState() => _AdminEventFormPageState();
}

class _AdminEventFormPageState extends State<AdminEventFormPage> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final locController = TextEditingController();
  final imageController = TextEditingController();

  DateTime? selectedDate;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    if (widget.existingData != null) {
      final data = widget.existingData!;
      titleController.text = data["title"] ?? "";
      descController.text = data["description"] ?? "";
      locController.text = data["location"] ?? "";
      imageController.text = data["imageUrl"] ?? "";

      selectedDate = DateTime.fromMillisecondsSinceEpoch(
        data["timestamp"] * 1000,
      );
    }
  }

  Future<void> _save() async {
    if (titleController.text.isEmpty ||
        descController.text.isEmpty ||
        locController.text.isEmpty ||
        selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap isi semua data.")),
      );
      return;
    }

    setState(() => isSaving = true);

    final timestamp = selectedDate!.millisecondsSinceEpoch ~/ 1000;

    final eventData = {
      "pmiId": widget.pmiId,
      "title": titleController.text.trim(),
      "description": descController.text.trim(),
      "location": locController.text.trim(),
      "imageUrl": imageController.text.trim(),
      "timestamp": timestamp,
    };

    if (widget.eventId == null) {
      await FirebaseFirestore.instance.collection("events").add(eventData);
    } else {
      await FirebaseFirestore.instance
          .collection("events")
          .doc(widget.eventId)
          .update(eventData);
    }

    setState(() => isSaving = false);
    if (mounted) Navigator.pop(context);
  }

  void _pickDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.eventId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Event" : "Tambah Event"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Judul Event",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Deskripsi",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: locController,
              decoration: const InputDecoration(
                labelText: "Lokasi Event",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: imageController,
              decoration: const InputDecoration(
                labelText: "URL Poster (opsional)",
                border: OutlineInputBorder(),
              ),
            ),
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
                    const Icon(Icons.event_rounded),
                    const SizedBox(width: 12),
                    Text(
                      selectedDate == null
                          ? "Pilih tanggal"
                          : _formatDate(selectedDate!),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: isSaving
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Text(
                        isEditing ? "Simpan Perubahan" : "Tambah Event",
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    return "${d.day}-${d.month}-${d.year}";
  }
}
