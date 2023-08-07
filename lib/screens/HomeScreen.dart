import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talkster_chatting_app/screens/SettingsScreen.dart';
import '../ThemeColor.dart';
import '../api/Api.dart';
import '../main.dart';
import '../model/ChatUser.dart';
import '../widgets/ChatCard.dart';

List<ChatUser> list = [];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _searchlist = [];

  bool _isSearching = false;
  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
    APIs.updateActiveStatus(true);
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume'))
          APIs.updateActiveStatus(true);

        if (message.toString().contains('pause'))
          APIs.updateActiveStatus(false);
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: _isSearching ? null : Icon(Icons.home),
            title: _isSearching
                ? TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Colors.black),
                        prefixIcon: Icon(Icons.search),
                        prefixIconColor: Colors.black,
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)))),
                    onChanged: (value) {
                      _searchlist.clear();
                      for (var i in list) {
                        if (i.name
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            i.email
                                .toLowerCase()
                                .contains(value.toLowerCase())) {
                          _searchlist.add(i);
                        }
                      }
                      setState(() {
                        _searchlist;
                      });
                    },
                  )
                : Text(
                    "Talkster",
                    style: TextStyle(fontSize: 24),
                  ),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: Icon(_isSearching
                    ? CupertinoIcons.clear_circled_solid
                    : Icons.search),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => SettingsScreen(
                                  user: APIs.me,
                                )));
                  },
                  icon: Icon(Icons.more_vert)),
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.all(14),
            child: FloatingActionButton(
              onPressed: () {},
              child: Icon(Icons.comment),
              backgroundColor: clr,
            ),
          ),
          body: StreamBuilder(
              stream: APIs.getalluser(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  //if data is loading
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Center(child: CircularProgressIndicator());

                  //if some or all data is loaded the show it:
                  case ConnectionState.active:
                  case ConnectionState.done:
                    final Data = snapshot.data?.docs;
                    list = Data?.map((e) => ChatUser.fromJson(e.data()))
                            .toList() ??
                        [];
                }

                if (list.isNotEmpty) {
                  return ListView.builder(
                      itemCount:
                          _isSearching ? _searchlist.length : list.length,
                      padding: EdgeInsets.only(top: mq.width * .03),
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return ChatCard(
                          user: _isSearching ? _searchlist[index] : list[index],
                        );
                      });
                } else {
                  return Center(
                    child: Text(
                      "Sorry! No User available",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  );
                }
              }),
        ),
      ),
    );
  }
}
