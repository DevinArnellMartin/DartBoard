import 'perfil.dart';
import 'ajustes.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.env['API_KEY'] ?? '',
      authDomain: dotenv.env['AUTH_DOMAIN'] ?? '',
      projectId: dotenv.env['PROJECT_ID'] ?? '',
      storageBucket: dotenv.env['STORAGE_BUCKET'] ?? '',
      messagingSenderId: dotenv.env['MESSAGING_SENDER_ID'] ?? '',
      appId: dotenv.env['APP_ID'] ?? '',
      measurementId: dotenv.env['MEASUREMENT_ID'] ?? '',
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Messaging Board',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'Message Boards'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => HomeState();
}

class HomeState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Home'),
      ),
      body: const Center(
        child: Text(
          'Message Board!',
          style: TextStyle(fontSize: 20),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text('Politics Board'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const MessageBoardScreen(boardType: 'Politics'),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Games Board'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const MessageBoardScreen(boardType: 'Games'),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBoardScreen extends StatelessWidget {
  final String boardType;

  const MessageBoardScreen({Key? key, required this.boardType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$boardType Board'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messageBoards')
                  .doc(boardType)
                  .collection('messages')
                  .where('timestamp', isNull: false) 
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(
                    child: Text('No messages yet.'),
                  );
                }

                return ListView(
                  children: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final timestamp = data['timestamp'] as Timestamp?;
                    final formattedDate = timestamp != null
                        ? timestamp.toDate().toString().substring(0, 16)
                        : 'Unknown';

                    return ListTile(
                      title: Text(data['message'] ?? 'No msg'),
                      subtitle: Text(data['username'] ?? 'AnonyMoose-Goose'),
                      trailing: Text(formattedDate),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onSubmitted: (message) {
                if (message.trim().isNotEmpty) {
                  FirebaseFirestore.instance
                      .collection('messageBoards')
                      .doc(boardType)
                      .collection('messages')
                      .add({
                    'message': message,
                    'username':
                        FirebaseAuth.instance.currentUser?.displayName ??
                            'Anonymous',
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                }
              },
              decoration: const InputDecoration(
                hintText: 'Type your message',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

