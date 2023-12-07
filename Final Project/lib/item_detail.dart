import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'post_item.dart';
import 'list_items.dart';

class ItemDetail extends StatefulWidget {
  const ItemDetail({super.key, required this.docId});

  final String docId;

  @override
  State<ItemDetail> createState() => _ItemDetailState();
}

class _ItemDetailState extends State<ItemDetail> {
  final _detailKey = GlobalKey<FormState>();

  final itemImages = <String>[];

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  Future<Map<String, dynamic>> _getItemDetail() async {
    DocumentSnapshot doc =
    await db.collection('002127437_docs').doc(widget.docId).get();
    return doc.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new Item'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Hyper Garage Sale',
                style: TextStyle(fontSize: 36, color: Color(0xFFFFFFFF)),
              ),
            ),
            ListTile(
              title: const Text("New Post"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const NewPost()));
              },
            ),
            ListTile(
              title: const Text("Item List"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyHomePage()));
              },
            ),
            ListTile(
              title: const Text("Sign Out"),
              onTap: () async {
                await _firebaseAuth.signOut();
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder(
        future: _getItemDetail(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          Map<String, dynamic> doc = snapshot.data as Map<String, dynamic>;
          return ListView(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  label: Text(
                    "Title:",
                    style: TextStyle(fontSize: 18),
                  ),
                  contentPadding: EdgeInsets.all(10),
                ),
                initialValue: doc["title"],
                enabled: false,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  label: Text(
                    "Price:",
                    style: TextStyle(fontSize: 18),
                  ),
                  contentPadding: EdgeInsets.all(10),
                ),
                initialValue: doc["price"],
                enabled: false,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  label: Text(
                    "Description:",
                    style: TextStyle(fontSize: 18),
                  ),
                  contentPadding: EdgeInsets.all(10),
                ),
                initialValue: doc["description"],
                enabled: false,
                minLines: 3,
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 300,
                    child:
                    ListView(scrollDirection: Axis.horizontal, children: [
                      for (var imgUrl in doc["images"])
                        Image.network(
                          imgUrl,
                          width: MediaQuery.of(context).size.width,
                          height: 300,
                          fit: BoxFit.cover,
                        )
                    ]),
                  )),
            ],
          );
        },
      ),
    );
  }
}
