import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetailPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;
  
  const DetailPage({
    super.key,
    required this.docId,
    required this.data,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final user = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;
  late TextEditingController titleController;
  late TextEditingController descController;

  List<String> selectedLabelIds = [];

  CollectionReference get notesRef => FirebaseFirestore.instance
      .collection('users')
      .doc(user!.uid)
      .collection('notes');

  CollectionReference get labelsRef => FirebaseFirestore.instance
      .collection('users')
      .doc(user!.uid)
      .collection('labels');

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(
      text: widget.data['title'] ?? '',
    );

    descController = TextEditingController(
      text: widget.data['description'] ?? '',
    );

    selectedLabelIds =
        List<String>.from(widget.data['labels'] ?? []);
  }

  // 🔥 SAVE
  Future<void> save() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    await notesRef.doc(widget.docId).update({
      'title': titleController.text,
      'description': descController.text,
      'labels': selectedLabelIds,
    });

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  // 🔥 DELETE
  Future<void> delete() async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Note"),
        content: const Text("Yakin mau hapus note ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    // 🔥 kalau user pencet batal
    if (confirm != true) return;

    // 🔥 lanjut delete
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    await notesRef.doc(widget.docId).delete();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Note berhasil dihapus"),
      ),
    );

    setState(() {
      _isLoading = false;
    });

    Navigator.pop(context, true);
  }

  // 🔥 ADD LABEL
  Future<void> addLabel(String name) async {
    await labelsRef.add({
      'name': name,
    });
  }

  // 🔥 DELETE LABEL
  Future<void> deleteLabel(String id) async {
    await labelsRef.doc(id).delete();
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("User belum login"),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : save,
            style: ButtonStyle(
              foregroundColor:
                  WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.pressed)) {
                  return Colors.green;
                }
                return Colors.black;
              }),
            ),
            child: const Text(
              "Save",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _isLoading ? null : delete,
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔥 LABEL CHIP (REALTIME)
            SizedBox(
              height: 45,
              child: StreamBuilder(
                stream: labelsRef.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox();
                  }

                  final labels = snapshot.data!.docs;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: labels.map((doc) {
                        final id = doc.id;
                        final name = doc['name'];

                        final isSelected =
                            selectedLabelIds.contains(id);

                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            label: Text(name),
                            selected: isSelected,
                            onSelected: (val) {
                              setState(() {
                                if (val) {
                                  selectedLabelIds.add(id);
                                } else {
                                  selectedLabelIds.remove(id);
                                }
                              });
                            },
                            onDeleted: () async {
                              await deleteLabel(id);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // 🔥 TITLE
            TextField(
              controller: titleController,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                hintText: "Title",
                border: InputBorder.none,
              ),
            ),

            const SizedBox(height: 24),

            // 🔥 DESCRIPTION
            Expanded(
              child: TextField(
                controller: descController,
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  hintText: "Take a note...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}