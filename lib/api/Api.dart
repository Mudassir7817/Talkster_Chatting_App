import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:talkster_chatting_app/model/ChatUser.dart';

import '../model/Messages.dart';

class APIs {
  static late ChatUser me;

  static FirebaseAuth auth = FirebaseAuth.instance;

  static FirebaseFirestore fireStore = FirebaseFirestore.instance;

  static FirebaseStorage storage = FirebaseStorage.instance;

  static User get user => auth.currentUser!;

  static Future<bool> isUserExists() async {
    return (await fireStore.collection("Users").doc(user.uid).get()).exists;
  }

  static Future<void> CreateNewUser() async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();
    final chatuser = ChatUser(
        image: user.photoURL.toString(),
        about: "Hey, I am using Talkster",
        name: user.displayName.toString(),
        createdAt: time,
        id: user.uid,
        lastActive: time,
        isOnline: false,
        pushToken: '',
        email: user.email.toString());

    return await fireStore
        .collection("Users")
        .doc(user.uid)
        .set(chatuser.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getalluser() {
    return fireStore
        .collection("Users")
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  static Future<void> getSelfInfo() async {
    await fireStore
        .collection('Users')
        .doc(user.uid)
        .get()
        .then((user) async => {
              if (user.exists)
                {me = ChatUser.fromJson(user.data()!)}
              else
                {await CreateNewUser().then((value) => getSelfInfo())}
            });
  }

  static Future<void> updateUserInfo() async {
    await fireStore
        .collection('Users')
        .doc(user.uid)
        .update({'name': me.name, 'about': me.about});
  }

  static Future<void> updateImage(File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child("Profile Pictures/${user.uid}.$ext");

    ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));

    me.image = await ref.getDownloadURL();
    await fireStore
        .collection('Users')
        .doc(user.uid)
        .update({'image': me.image});
  }

  ///************************* CHAT SCREEN STUFF *****************************

  //For Getting conversation id:
  static String getConvoid(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  //For Getting all messages of a specific conversation from firestore database:
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMsg(
      ChatUser chatUser) {
    return fireStore
        .collection("Chats/${getConvoid(chatUser.id)}/messages")
        .snapshots();
  }

  //For Sending msgs
  static Future<void> sendMsg(ChatUser chatUser, String msgs) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final message = Messages(
        msg: msgs,
        read: '',
        fromId: user.uid,
        toId: chatUser.id,
        type: Type.text,
        sent: time);
    final ref =
        fireStore.collection("Chats/${getConvoid(chatUser.id)}/messages");
    await ref.doc(time).set(message.toJson());
  }

  static Future<void> updateMessageReadStatus(Messages message) async {
    fireStore
        .collection("Chats/${getConvoid(message.fromId)}/messages/")
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMsg(
      ChatUser chatUser) {
    return fireStore
        .collection("Chats/${getConvoid(chatUser.id)}/messages/")
        .limit(1)
        .snapshots();
  }
}
