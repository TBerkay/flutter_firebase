import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  String data;

  @override
  void initState() {
    Firebase.initializeApp().whenComplete(() {
      print("complete");
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Firebase Example"),
      ),
      body: _buildList(context),
      floatingActionButton: _buildFloatActionButton(),
    );
  }

  Widget _buildList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<DocumentSnapshot> documents = snapshot.data.docs;
            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                return _buildListItem(context, documents[index]);
              },
            );
          } else {
            return Text("error");
          }
        });
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(15.0),
          child: Text(
            document["votes"].toString(),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          decoration: BoxDecoration(
              color: Colors.yellow[200],
              borderRadius: BorderRadius.circular(20.0)),
        ),
        title: Text(document["name"].toString().toUpperCase()),
        trailing: _buildCount(document),
      ),
    );
  }

  Widget _buildCount(DocumentSnapshot document) {
    return Container(
        child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              FirebaseFirestore.instance.runTransaction((transaction) async {
                DocumentSnapshot freshSnap =
                    await transaction.get(document.reference);
                await transaction.update(
                    freshSnap.reference, {'votes': document["votes"] + 1});
              });
            }),
        IconButton(
            icon: Icon(Icons.remove),
            onPressed: () {
              FirebaseFirestore.instance.runTransaction((transaction) async {
                DocumentSnapshot freshSnap =
                    await transaction.get(document.reference);
                await transaction.update(
                    freshSnap.reference, {'votes': document["votes"] - 1});
              });
            })
      ],
    ));
  }

  Widget _buildFloatActionButton() {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).primaryColor,
      child: Icon(Icons.add),
      onPressed: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return _buildDialog();
            });
      },
    );
  }

  Widget _buildDialog() {
    return AlertDialog(
      title: Text("ADD"),
      content: TextField(
        decoration: InputDecoration(labelText: "add data"),
        onChanged: (String value) {
          data = value;
        },
      ),
      actions: [
        FlatButton(
            onPressed: () {
              if (data.isEmpty == false) {
                FirebaseFirestore.instance
                    .collection("users")
                    .add({"name": data, "votes": 0});

                Navigator.pop(context);
              }
            },
            child: Text("Ekle"))
      ],
    );
  }
}
