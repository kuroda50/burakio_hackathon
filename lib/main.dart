import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '教授クラス一覧',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ProfessorsListScreen(), // 最初の画面に教授リストを表示
    );
  }
}

class ProfessorsListScreen extends StatelessWidget {
  const ProfessorsListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final professorsStream = FirebaseFirestore.instance
        .collection('professors')
        .orderBy('class')
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('教授リスト（クラス順）'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: professorsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('エラーが発生しました'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('データがありません'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              String id = docs[index].id;
              String className = data['class'] ?? 'クラス未設定';
              String name = data['name'] ?? '名前未設定';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    className,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('教授: $name'),
                  trailing: const Icon(Icons.play_arrow),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfessorDetailScreen(professorId: id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ProfessorDetailScreen extends StatelessWidget {
  final String professorId;

  const ProfessorDetailScreen({Key? key, required this.professorId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('教授の詳細'),
      ),
      body: Center(
        child: Text('教授のID: $professorId'),
      ),
    );
  }
}
