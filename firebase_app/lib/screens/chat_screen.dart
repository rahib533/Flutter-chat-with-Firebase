import 'package:firebase_app/screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_app/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
late User loggedInUser;

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String messageText = "";
  final _auth = FirebaseAuth.instance;
  final messageTextController = TextEditingController();

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  // void getMessages() async {
  //   var data = await _firestore.collection("messages").get().then((value) {
  //     print("begin");
  //     for (var item in value.docs) {
  //       print(item.data());
  //     }
  //     print("end");
  //   });
  // }
  void messageStream() async {
    await for (var snapshot in _firestore.collection("messages").snapshots()) {
      for (var message in snapshot.docs) {
        print(message.data());
      }
      print("========");
      for (var message in snapshot.docChanges) {
        print(message.doc.data());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () async {
                //Implement logout functionality
                try {
                  await _auth.signOut();
                  Navigator.pop(context);
                  Navigator.pushNamed(context, WelcomeScreen.id);
                } catch (e) {
                  print(e);
                }
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  Flexible(
                    child: GestureDetector(
                      onTap: () async {
                        //Implement send functionality.
                        try {
                          messageTextController.clear();
                          _firestore.collection("messages").add({
                            'text': messageText,
                            'sender': loggedInUser.email,
                          });
                        } catch (e) {
                          print(e);
                        }
                      },
                      child: Text(
                        'Send',
                        style: kSendButtonTextStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class MessageBubble extends StatelessWidget {
  MessageBubble(
      {required this.messageSender,
      required this.messageText,
      required this.isMe});

  String messageText;
  String messageSender;
  bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(messageSender),
          Material(
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  )
                : BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
            elevation: 5,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text(
                '$messageText',
                style: TextStyle(
                  fontSize: 15,
                  color: isMe ? Colors.white : Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  MessagesStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection("messages").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final messages = snapshot.data!.docs.reversed;
            List<MessageBubble> messageBubbless = [];
            for (var message in messages) {
              final messageText = message.get("text");
              final messageSender = message.get("sender");

              final currentUserEmail = loggedInUser.email;
              if (currentUserEmail == messageSender) {
                final messageWidget = MessageBubble(
                  messageText: messageText,
                  messageSender: messageSender,
                  isMe: true,
                );
                messageBubbless.add(messageWidget);
              } else {
                final messageWidget = MessageBubble(
                  messageText: messageText,
                  messageSender: messageSender,
                  isMe: false,
                );
                messageBubbless.add(messageWidget);
              }
            }
            return Expanded(
              child: ListView(
                reverse: true,
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                children: messageBubbless,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
          return Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        },
      ),
    );
  }
}
