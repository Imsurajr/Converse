import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
User? loggedInUser;

class ChatScreen extends StatefulWidget {
  @override
  static const String cid = "chat_screen";

  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String? messageText;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;

      if (user != null) {
        loggedInUser = user;
        print("email : ${loggedInUser?.email}");
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2F3E46),
      appBar: AppBar(
        foregroundColor: Colors.white70,
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF2F3E46),
        leading: null,
        actions: <Widget>[
          IconButton(
              color: Colors.white70,
              icon: Icon(Icons.logout_rounded),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        centerTitle: true,
        title: Text(
          'Chat',
          style: GoogleFonts.openSans(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration.copyWith(
                  color: Color(0xFF354F52)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 5),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all<double>(6.0),
                        backgroundColor:
                            MaterialStateProperty.all(Color(0xFF2a3f42)),
                      ),
                      onPressed: () {
                        messageTextController.clear();
                        _firestore.collection('messages')
                            //     .doc(
                            //   DateTime.now().millisecondsSinceEpoch.toString(),
                            // ).set({
                            //   'text': messageText,
                            //   'sender': loggedInUser?.email,
                            // });
                            .add(
                          {
                            'text': messageText,
                            'sender': loggedInUser?.email,
                          },
                        );
                      },
                      child: Text(
                        'Send',
                        style: kSendButtonTextStyle.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firestore.collection('messages').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }
        ;
        final messages = snapshot.data!.docs.reversed;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final messageText = message.get('text');
          final messageSender = message.get('sender');

          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
            isCurrentUser: messageSender == loggedInUser?.email,
          );
          messageBubbles.insert(0, messageBubble);
        }
        return Expanded(
          child: ListView.builder(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            itemCount: messageBubbles.length,
            itemBuilder: (BuildContext context, int index) {
              return messageBubbles[index];
            },
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble(
      {required this.sender, required this.text, required this.isCurrentUser});
  bool isCurrentUser;
  String sender;
  String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(fontSize: 12, color: Colors.white70),
          ),
          Material(
            elevation: 15.0,
            borderRadius: isCurrentUser
                ? BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                    topLeft: Radius.circular(30))
                : BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                    topRight: Radius.circular(30)),
            color: isCurrentUser ? Color(0xFF5fa778) : Color(0xFF026c45),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                text,
                style: GoogleFonts.openSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
