import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quick_chat/services/firestore_service.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> receiver;

  ChatScreen({Key? key, required this.receiver}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _messageController = TextEditingController();

  late String currentUserId;
  late String receiverId;
  late String chatId;

  get user1_ => null;

  get user2_ => null;

  @override
  void initState() {
    super.initState();
    currentUserId = _auth.currentUser!.uid;
    receiverId = widget.receiver['id'];
    chatId = getChatId(currentUserId, receiverId);
  }

  String getChatId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode ? '$user1_$user2' : '$user2_$user1';
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _firestoreService.sendMessage(
        chatId,
        currentUserId,
        receiverId,
        _messageController.text.trim(),
      );
      _messageController.clear();
    }
  }

  void handleLongPress(BuildContext context, Map<String, dynamic> message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.flag, color: Colors.red),
            title: Text("Report"),
            onTap: () {
              Navigator.pop(context);
              // Placeholder for Report action
              print("Reported message: ${message['message']}");
            },
          ),
          ListTile(
            leading: Icon(Icons.block, color: Colors.orange),
            title: Text("Block User"),
            onTap: () {
              Navigator.pop(context);
              // Placeholder for Block User action
              print("Blocked user: ${message['senderId']}");
            },
          ),
          ListTile(
            leading: Icon(Icons.cancel, color: Colors.grey),
            title: Text("Cancel"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.receiver['username']}'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firestoreService.getMessages(chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isMe = message['senderId'] == currentUserId;

                    return GestureDetector(
                      onLongPress: () => handleLongPress(context, message),
                      child: Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.green[200] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            message['message'],
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
