// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool isDarkMode = false; // Track theme mode

  @override
  void initState() {
    super.initState();
    _loadTheme(); // Load saved theme preference
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    setState(() {
      isDarkMode = value;
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context)
        .pushReplacementNamed('/login'); // Navigate to login screen
  }

  Future<void> _deleteAccount() async {
    try {
      await FirebaseAuth.instance.currentUser?.delete();
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      _showError('Unable to delete account. Please re-authenticate.');
    }
  }

  void _blockUser(String userId) {
    // Implement block user logic here
    _showMessage('User $userId has been blocked.');
  }

  void _reportUser(String userId) {
    // Implement report user logic here
    _showMessage('User $userId has been reported.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(title: Text('Main Screen')),
        drawer: Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text('Your Name'), // Replace with user's name
                accountEmail:
                    Text('yourname@example.com'), // Replace with user's email
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text('Y'), // Replace with user's initials or avatar
                ),
              ),
              ListTile(
                leading: Icon(Icons.light_mode),
                title: Text('Light/Dark Mode'),
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: _toggleTheme,
                ),
              ),
              ListTile(
                leading: Icon(Icons.block),
                title: Text('Block User'),
                onTap: () {
                  _blockUser(
                      'user_id'); // Replace 'user_id' with the target user's ID
                },
              ),
              ListTile(
                leading: Icon(Icons.report),
                title: Text('Report User'),
                onTap: () {
                  _reportUser(
                      'user_id'); // Replace 'user_id' with the target user's ID
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete Account'),
                onTap: () async {
                  final confirm = await _confirmDialog('Delete Account',
                      'Are you sure you want to delete your account?');
                  if (confirm) {
                    _deleteAccount();
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Log Out'),
                onTap: () async {
                  final confirm = await _confirmDialog(
                      'Log Out', 'Are you sure you want to log out?');
                  if (confirm) {
                    _logout();
                  }
                },
              ),
            ],
          ),
        ),
        body: Center(child: Text('Main Content Area')),
      ),
    );
  }

  Future<bool> _confirmDialog(String title, String content) async {
    return await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Confirm'),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
