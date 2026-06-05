import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mynote_pro/pages/detail_page.dart';
import 'profile_page.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final titleController = TextEditingController();
  final descController = TextEditingController();

  String searchQuery = '';
  bool isGrid = true;

  List<String> selectedLabelIds = [];
  String? selectedLabelFilter;

  File? selectedImage;
  final picker = ImagePicker();

  CollectionReference notesRef(String uid) =>
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notes');

  CollectionReference labelsRef(String uid) =>
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('labels');

  // 🔥 ADD NOTE
  Future<void> addNote() async {
    if (titleController.text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;

    await notesRef(user!.uid).add({
      'title': titleController.text,
      'description': descController.text,
      'labels': selectedLabelIds,
      'createdAt': Timestamp.now(),
    });

    titleController.clear();
    descController.clear();
    selectedLabelIds.clear();
    selectedImage = null;

    setState(() {});
  }

  // 🔥 DELETE NOTE
  Future<void> deleteNote(String id) async {
    final user = FirebaseAuth.instance.currentUser;

    await notesRef(user!.uid).doc(id).delete();
  }

  // 🔥 ADD LABEL
  Future<void> addLabel(String name) async {
    final user = FirebaseAuth.instance.currentUser;

    await labelsRef(user!.uid).add({'name': name});
  }

  Future<void> pickImage(ImageSource source) async {
    final picked = await picker.pickImage(source: source);

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  // 🔥 PICK LABEL
  void openLabelPicker() {
    final user = FirebaseAuth.instance.currentUser!;
    final labels = labelsRef(user.uid);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Pilih Label"),
              content: StreamBuilder<QuerySnapshot>(
                stream: labels.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox(
                      height: 50,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final labels = snapshot.data!.docs;

                  return SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 🔥 CHIP STYLE (INI YANG KAMU MAU)
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: labels.map((doc) {
                            final id = doc.id;
                            final name = doc['name'];
                            final selected =
                                selectedLabelIds.contains(id);

                            return ChoiceChip(
                              label: Text(name),
                              selected: selected,
                              onSelected: (value) {
                                // 🔥 update dialog
                                setStateDialog(() {
                                  if (value) {
                                    selectedLabelIds.add(id);
                                  } else {
                                    selectedLabelIds.remove(id);
                                  }
                                });

                                // 🔥 update chip di belakang
                                setState(() {});
                              },
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 10),

                        // 🔥 INPUT TAMBAH LABEL
                        TextField(
                          decoration: const InputDecoration(
                            hintText: "Tambah label...",
                          ),
                          onSubmitted: (val) async {
                            if (val.isNotEmpty) {
                              await addLabel(val);

                              Navigator.pop(context);
                              openLabelPicker();
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
  bool matchSearch(Map data) {
    final title = data['title'].toString().toLowerCase();
    final desc = data['description'].toString().toLowerCase();
    final input = searchQuery.toLowerCase();

    return title.contains(input) || desc.contains(input);
  }

  bool matchLabel(Map data) {
    if (selectedLabelFilter == null) return true;

    List labels = data['labels'] ?? [];
    return labels.contains(selectedLabelFilter);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // 🔥 CEK DULU
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final notes = notesRef(user.uid);
    final labels = labelsRef(user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Notes"),
        actions: [
          // 🔥 BUTTON TOGGLE GRID/LIST
          IconButton(
            icon: Icon(isGrid ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                isGrid = !isGrid;
              });
            },
          ),

          // 🔥 BUTTON PROFILE
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (val) {
                setState(() {
                  searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: "Search notes...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🔥 FILTER LABEL
          StreamBuilder<QuerySnapshot>(
            stream: labels.snapshots(),
            builder: (context, snapshot) {
              print("SNAPSHOT LABELS: ${snapshot.data}");
              if (!snapshot.hasData) return const SizedBox();

              final labels = snapshot.data!.docs;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text("Semua"),
                      selected: selectedLabelFilter == null,
                      onSelected: (_) {
                        setState(() {
                          selectedLabelFilter = null;
                        });
                      },
                    ),
                    const SizedBox(width: 6),
                    ...labels.map((doc) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(doc['name']),
                          selected: selectedLabelFilter == doc.id,
                          onSelected: (_) {
                            setState(() {
                              selectedLabelFilter = doc.id;
                            });
                          },
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),

          // 🔥 INPUT NOTE
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: "Title",
                      border: InputBorder.none,
                    ),
                  ),
                  Divider(color: const Color.fromARGB(255, 201, 200, 200)),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "Take a note...",
                      border: InputBorder.none,
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 🔥 KIRI (CHIP DOANG)
                      Expanded(
                        child: SizedBox(
                          height: 35,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: StreamBuilder<QuerySnapshot>(
                              stream: labels.snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return const SizedBox();

                                final labels = snapshot.data!.docs;

                                final labelMap = {
                                  for (var doc in labels) doc.id: doc['name'],
                                };

                                return Row(
                                  children: selectedLabelIds.map((id) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: Chip(
                                        label: Text(labelMap[id] ?? 'Unknown'),
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      // 🔥 KANAN (FIXED)
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.label_outline),
                            onPressed: openLabelPicker,
                          ),
                          ElevatedButton(
                            onPressed: addNote,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text("Tambah"),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                ],
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: notes
                .orderBy('createdAt', descending: true)
                .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                final filtered = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return matchSearch(data) && matchLabel(data);
                }).toList();

                return isGrid
                    ? GridView.builder(
                        padding: const EdgeInsets.all(10),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final doc = filtered[i];
                          final data = doc.data() as Map<String, dynamic>;

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DetailPage(docId: doc.id, data: data),
                                ),
                              );
                            },
                            child: Card(
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['title'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(data['description'],
                                          maxLines: 2, // 🔥 batasi 2 baris (bisa 1 / 3)
                                          overflow: TextOverflow.ellipsis,),
                                        
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    child: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => deleteNote(doc.id),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final doc = filtered[i];
                          final data = doc.data() as Map<String, dynamic>;

                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),

                              // 🔥 INI BORDER
                              border: Border.all(
                                color: const Color.fromARGB(255, 214, 199, 199),
                                width: 1,
                              ),

                              // 🔥 INI SHADOW
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.40),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ListTile(
                              title: Text(
                                data['title'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(data['description'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => deleteNote(doc.id),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DetailPage(docId: doc.id, data: data),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}
