import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => EstadoDePerfil();
}

class EstadoDePerfil extends State<ProfileScreen> {
  final TextEditingController nameControl = TextEditingController();
  final TextEditingController dob = TextEditingController();

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nameControl.text = prefs.getString('name') ?? '';
      dob.text = prefs.getString('dob') ?? '';
    });
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', nameControl.text);
    await prefs.setString('dob', dob.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            TextField(
              controller: nameControl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: dob,
              decoration: const InputDecoration(labelText: 'D.O.B'),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  dob.text =
                      '${picked.year}-${picked.month}-${picked.day}';
                }
              },
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
