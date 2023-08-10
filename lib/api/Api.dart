import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';
import 'package:talkster_chatting_app/model/ChatUser.dart';
import '../model/Messages_Model.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;

  static FirebaseFirestore fireStore = FirebaseFirestore.instance;

  static FirebaseStorage storage = FirebaseStorage.instance;

  static late ChatUser me;

  static FirebaseMessaging fMsg = FirebaseMessaging.instance;

  static Future<void> getFirebaseMsgToken() async {
    await fMsg.requestPermission();

    await fMsg.getToken().then((value) {
      if (value != null) {
        me.pushToken = value;
        log('push Token: $value');
      }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
      }
    });
  }

  static Future<void> getFirebaseMessagingToken(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": chatUser.name,
          "body": msg,
          "android_channel_id": "chats",
        }
      };
      var response =
          await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                HttpHeaders.contentTypeHeader: 'Application/json',
                HttpHeaders.authorizationHeader:
                    'key=AAAAcpfPgPM:APA91bFePtsYx2J6ENC5pkKmbGPagKFNolrFVEErodp4_BeBZZ0CT1LaHRuwAAaBYAD4BLrHrYZqtmdU2XBHNcFjb1MDMzGkmiIqT9pP6lxlMtsHBCTUh9esQfAV_Hxa3ZjKgbOWA9kH'
              },
              body: jsonEncode(body));

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');
    } catch (e) {
      log('\n Exception in getFirebaseMessageToken: $e');
    }
  }

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
                {
                  getFirebaseMsgToken(),
                  me = ChatUser.fromJson(user.data()!),
                }
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
        .orderBy("sent", descending: true)
        .snapshots();
  }

  //For Sending msgs
  static Future<void> sendMsg(ChatUser chatUser, String msgs, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final message = Messages_Model(
        msg: msgs,
        read: '',
        fromId: user.uid,
        toId: chatUser.id,
        type: type,
        sent: time);
    final ref =
        fireStore.collection("Chats/${getConvoid(chatUser.id)}/messages");
    await ref.doc(time).set(message.toJson()).then((value) =>
        getFirebaseMessagingToken(
            chatUser, type == Type.text ? msgs : 'photo'));
  }

  static Future<void> updateMessageReadStatus(Messages_Model message) async {
    fireStore
        .collection("Chats/${getConvoid(message.fromId)}/messages/")
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMsg(
      ChatUser chatUser) {
    return fireStore
        .collection("Chats/${getConvoid(chatUser.id)}/messages/")
        .orderBy("sent", descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> sendChatImage(ChatUser chatuser, File file) async {
    final ext = file.path.split('.').last;

    final ref = storage.ref().child(
        "Chat images/${getConvoid(chatuser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext");

    await ref
        .putFile(file, SettableMetadata(contentType: 'Chat images/$ext'))
        .then((p0) => log('Data Transfered'));

    final imageURL = await ref.getDownloadURL();
    await sendMsg(chatuser, imageURL, Type.image);
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatuser) {
    return fireStore
        .collection("Users")
        .where('id', isEqualTo: chatuser.id)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    fireStore.collection("Users").doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  static Future<void> deleteMsg(Messages_Model message) async {
    await fireStore
        .collection("Chats/${getConvoid(message.toId)}/messages/")
        .doc(message.sent)
        .delete();

    await storage.refFromURL(message.msg);
  }

  static Future<void> updateMsg(
      Messages_Model message, String updatedMsg) async {
    await fireStore
        .collection("Chats/${getConvoid(message.toId)}/messages/")
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }
}
