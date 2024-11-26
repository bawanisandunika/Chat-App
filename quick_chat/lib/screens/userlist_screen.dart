import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart'; // Import the ChatScreen

class UserListScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch registered users excluding the logged-in user
  Future<List<Map<String, dynamic>>> getRegisteredUsers() async {
    try {
      // Fetch all users from the 'users' collection
      QuerySnapshot snapshot = await _firestore.collection('users').get();

      // Get the currently logged-in user's ID
      String currentUserId = _auth.currentUser!.uid;

      // Filter out the logged-in user and map the remaining users
      return snapshot.docs
          .where((doc) => doc['id'] != currentUserId) // Exclude the current user
          .map((doc) => {
                'id': doc['id'],
                'email': doc['email'],
                'username': doc['username'],
              })
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch users: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getRegisteredUsers(), // Fetch registered users
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No registered users found.'));
          }

          // Display registered users
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final user = snapshot.data![index];
              return ListTile(
                title: Text(user['username']),
                subtitle: Text(user['email']),
                onTap: () {
                  // Navigate to the chat screen with the selected user
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(receiver: user),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
