import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool loggedIn = false;

  @override
  void initState() {
    super.initState();
    checkIfLogin();
  }

  Future<void> checkIfLogin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      loggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  Future<void> toggle() async { //login
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      loggedIn = !loggedIn;
    });
    await prefs.setBool('isLoggedIn', loggedIn);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          loggedIn ? 'Logged in!' : 'Logged out!',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              loggedIn ? 'Logged in' : 'Logged out',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: toggle,
              child: Text(loggedIn ? 'Log Out' : 'Log In'),
            ),
          ],
        ),
      ),
    );
  }
}

