import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReportDetailScreen extends StatefulWidget {
  const ReportDetailScreen({super.key, required this.reportId, required this.reportData});

  final String reportId;
  final Map<String, dynamic> reportData;

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final _commentController = TextEditingController();
  final _user = FirebaseAuth.instance.currentUser!;

  DocumentReference get _reportDoc => FirebaseFirestore.instance.collection('reports').doc(widget.reportId);
  CollectionReference get _likesRef => _reportDoc.collection('likes');
  CollectionReference get _persistsRef => _reportDoc.collection('stillPersists');
  DocumentReference get _myLikeDoc => _likesRef.doc(_user.uid);
  DocumentReference get _myPersistDoc => _persistsRef.doc(_user.uid);

  Future<void> _toggleLike() async {
    final doc = await _myLikeDoc.get();
    if (doc.exists) {
      await _myLikeDoc.delete();
    } else {
      await _myLikeDoc.set({'createdAt': FieldValue.serverTimestamp()});
    }
  }

  Future<void> _togglePersists() async {
    final doc = await _myPersistDoc.get();
    if (doc.exists) {
      await _myPersistDoc.delete();
    } else {
      await _myPersistDoc.set({'createdAt': FieldValue.serverTimestamp()});
    }
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    await _reportDoc.collection('comments').add({
      'text': text,
      'userEmail': _user.email,
      'createdAt': FieldValue.serverTimestamp(),
    });
    _commentController.clear();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.reportData;

    return Scaffold(
      appBar: AppBar(title: const Text('DETALHES DO REPORT')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Image.network(data['imageUrl'], height: 200, fit: BoxFit.contain),
                const SizedBox(height: 12),
                Text(data['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(data['description'], style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),

                Row(
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: _likesRef.snapshots(),
                      builder: (context, snapshot) {
                        final docs = snapshot.data?.docs ?? [];
                        final iLiked = docs.any((d) => d.id == _user.uid);
                        return ElevatedButton.icon(
                          onPressed: _toggleLike,
                          icon: Icon(iLiked ? Icons.favorite : Icons.favorite_border, color: const Color.fromARGB(255, 71, 143, 211)),
                          label: Text('CURTIR (${docs.length})'),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    StreamBuilder<QuerySnapshot>(
                      stream: _persistsRef.snapshots(),
                      builder: (context, snapshot) {
                        final docs = snapshot.data?.docs ?? [];
                        final iMarked = docs.any((d) => d.id == _user.uid);
                        return ElevatedButton.icon(
                          onPressed: _togglePersists,
                          icon: Icon(iMarked ? Icons.report_problem : Icons.report_problem_outlined, color: const Color.fromARGB(255, 71, 143, 211)),
                          label: Text('AINDA PERSISTE (${docs.length})'),
                        );
                      },
                    ),
                  ],
                ),

                const Divider(height: 32),
                const Text('COMENTÁRIOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),

                StreamBuilder<QuerySnapshot>(
                  stream: _reportDoc.collection('comments').orderBy('createdAt', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();
                    final comments = snapshot.data!.docs;
                    if (comments.isEmpty) {
                      return const Text('NENHUM COMENTÁRIO FOI REALIZADO AINDA', style: TextStyle(fontWeight: FontWeight.bold));
                    }
                    return Column(
                      children: comments.map((doc) {
                        final c = doc.data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text(c['text'] ?? '', style: const TextStyle(color: Color.fromARGB(255, 249, 252, 255))),
                          subtitle: Text(c['userEmail'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 249, 252, 255))),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(hintText: 'Escreva um comentário...'),
                  ),
                ),
                IconButton(onPressed: _sendComment, icon: const Icon(Icons.send)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}