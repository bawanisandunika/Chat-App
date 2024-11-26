// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quick_chat/screens/chat_screen.dart';

class ChatRoomScreen extends StatefulWidget {
  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ValueNotifier for dark mode toggle
  ValueNotifier<bool> isDarkMode = ValueNotifier(false);

  // Fetch users from Firestore
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      String currentUserId = _auth.currentUser!.uid; // Get current user's ID

      // Exclude the current user from the user list
      return snapshot.docs
          .where((doc) => doc['id'] != currentUserId)
          .map((doc) => {
                'id': doc['id'],
                'email': doc['email'],
                'username': doc['username'],
              })
          .toList();
    } catch (e) {
      throw Exception('Failed to load users: ${e.toString()}');
    }
  }

  // Logout function
  Future<void> logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(
        context, '/login'); // Redirect to login screen
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,
      builder: (context, darkModeEnabled, child) {
        return MaterialApp(
          theme: darkModeEnabled
              ? ThemeData.dark() // Dark theme
              : ThemeData.light(), // Light theme
          home: Scaffold(
            appBar: AppBar(
              backgroundColor:
                  darkModeEnabled ? Colors.black : Colors.grey[200],
              elevation: 0,
              title: const Text(
                'USERS',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.black),
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: darkModeEnabled ? Colors.black : Colors.blue,
                    ),
                    child: const Text(
                      'Settings',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.dark_mode),
                    title: const Text('Dark Mode'),
                    trailing: Switch(
                      value: darkModeEnabled,
                      onChanged: (value) {
                        isDarkMode.value = value; // Toggle dark mode
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Log Out'),
                    onTap: logout, // Trigger the logout function
                  ),
                ],
              ),
            ),
            body: FutureBuilder<List<Map<String, dynamic>>>(
              future: getUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No users found.'));
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final user = snapshot.data![index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey[300],
                            child: const Icon(
                              Icons.person,
                              color: Colors.black54,
                            ),
                          ),
                          title: Text(
                            user['email'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.chat_bubble_outline,
                                color: Colors.grey[600]),
                            onPressed: () {
                              // Navigate to the ChatScreen with the selected user's details
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChatScreen(receiver: user),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
